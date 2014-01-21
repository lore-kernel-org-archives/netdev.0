From: Nikolay Aleksandrov <nikolay@redhat.com>
Subject: [PATCH net-next 01/25] bonding: add infrastructure for an option API
Date: Tue, 21 Jan 2014 15:54:50 +0100
Message-ID: <1390316114-17815-2-git-send-email-nikolay@redhat.com>
References: <1390316114-17815-1-git-send-email-nikolay@redhat.com>
Cc: Nikolay Aleksandrov <nikolay@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:44088 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754601AbaAUOzp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 21 Jan 2014 09:55:45 -0500
Received: from int-mx02.intmail.prod.int.phx2.redhat.com (int-mx02.intmail.prod.int.phx2.redhat.com [10.5.11.12])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id s0LEtjKq027105
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Tue, 21 Jan 2014 09:55:45 -0500
In-Reply-To: <1390316114-17815-1-git-send-email-nikolay@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds the necessary basic infrastructure to support
centralized and unified option manipulation API for the bonding. The new
structure bond_option will be used to describe each option with its
dependencies on modes which will be checked automatically thus removing a
lot of duplicated code. Also automatic range checking is added for
some options. Currently the option setting function requires RTNL to
be acquired prior to calling it, since many options already rely on RTNL
it seemed like the best choice to protect all against common race
conditions.
In order to add an option the following steps need to be done:
1. Add an entry BOND_OPT_<option> to bond_options.h so it gets a unique id
   and a bit corresponding to the id
2. Add a bond_option entry to the bond_opts[] array in bond_options.c which
   describes the option, its dependencies and its manipulation function
3. Add code to export the option through sysfs and/or as a module parameter
   (the sysfs export will be made automatically in the future)

The options can have different flags set, currently the following are
supported:
BOND_OPTFLAG_NOSLAVES - require that the bond device has no slaves prior
                        to setting the option
BOND_OPTFLAG_IFDOWN - require that the bond device is down prior to
                      setting the option
BOND_OPTFLAG_RAWVAL - don't parse the value but return it raw for the
                      option to parse

There's a new value structure to describe different types of values
which can have the following flags:
BOND_VALFLAG_DEFAULT - marks the default option (permanent string alias
                       to this option is "default")
BOND_VALFLAG_MIN - the minimum value that this option can have
BOND_VALFLAG_MAX - the maximum value that this option can have

An example would be nice here, so if we have an option which can have
the values "off"(2), "special"(4, default) and supports a range, say
16 - 32, it should be defined as follows:
"off", 2,
"special", 4, BOND_VALFLAG_DEFAULT,
"rangemin", 16, BOND_VALFLAG_MIN,
"rangemax", 32, BOND_VALFLAG_MAX
So we have the valid intervals: [2, 2], [4, 4], [16, 32]
Also the valid strings: "off" = 2, "special" and "default" = 4
                        "rangemin" = 16, "rangemax" = 32

BOND_VALFLAG_(MIN|MAX) can be used to specify a valid range for an
option, if MIN is omitted then 0 is considered as a minimum. If an
exact match is found in the values[] table it will be returned,
otherwise the range is tried (if available).

The option parameter passing is done by using a special structure called
bond_opt_value which can take either a string or a value to parse. One
of the bond_opt_init(val|str) macros should be used depending on which
one does the user want to parse (string or value). Then a call to
__bond_opt_set should be done under RTNL.

Signed-off-by: Nikolay Aleksandrov <nikolay@redhat.com>
---
 drivers/net/bonding/bond_options.c | 272 +++++++++++++++++++++++++++++++++++++
 drivers/net/bonding/bond_options.h | 100 ++++++++++++++
 drivers/net/bonding/bonding.h      |   1 +
 3 files changed, 373 insertions(+)
 create mode 100644 drivers/net/bonding/bond_options.h

diff --git a/drivers/net/bonding/bond_options.c b/drivers/net/bonding/bond_options.c
index 945a666..edc2941 100644
--- a/drivers/net/bonding/bond_options.c
+++ b/drivers/net/bonding/bond_options.c
@@ -17,8 +17,280 @@
 #include <linux/rwlock.h>
 #include <linux/rcupdate.h>
 #include <linux/reciprocal_div.h>
+#include <linux/ctype.h>
 #include "bonding.h"
 
+static struct bond_option bond_opts[] = {
+	{ }
+};
+
+/* Searches for a value in opt's values[] table */
+struct bond_opt_value *bond_opt_get_val(unsigned int option, u64 val)
+{
+	struct bond_option *opt;
+	int i;
+
+	opt = bond_opt_get(option);
+	if (WARN_ON(!opt))
+		return NULL;
+	for (i = 0; opt->values && opt->values[i].string; i++)
+		if (opt->values[i].value == val)
+			return &opt->values[i];
+
+	return NULL;
+}
+
+/* Searches for a value in opt's values[] table which matches the flagmask */
+static struct bond_opt_value *bond_opt_get_flags(const struct bond_option *opt,
+						 u32 flagmask)
+{
+	int i;
+
+	for (i = 0; opt->values && opt->values[i].string; i++)
+		if (opt->values[i].flags & flagmask)
+			return &opt->values[i];
+
+	return NULL;
+}
+
+/* If maxval is missing then there's no range to check. In case minval is
+ * missing then it's considered to be 0.
+ */
+static bool bond_opt_check_range(const struct bond_option *opt, u64 val)
+{
+	struct bond_opt_value *minval, *maxval;
+
+	minval = bond_opt_get_flags(opt, BOND_VALFLAG_MIN);
+	maxval = bond_opt_get_flags(opt, BOND_VALFLAG_MAX);
+	if (!maxval || (minval && val < minval->value) || val > maxval->value)
+		return false;
+
+	return true;
+}
+
+/**
+ * bond_opt_parse - parse option value
+ * @opt: the option to parse against
+ * @val: value to parse
+ *
+ * This function tries to extract the value from @val and check if it's
+ * a possible match for the option and returns NULL if a match isn't found,
+ * or the struct_opt_value that matched. It also strips the new line from
+ * @val->string if it's present.
+ */
+struct bond_opt_value *bond_opt_parse(const struct bond_option *opt,
+				      struct bond_opt_value *val)
+{
+	char *p, valstr[BOND_OPT_MAX_NAMELEN + 1] = { 0, };
+	struct bond_opt_value *tbl, *ret = NULL;
+	bool checkval;
+	int i, rv;
+
+	/* No parsing if the option wants a raw val */
+	if (opt->flags & BOND_OPTFLAG_RAWVAL)
+		return val;
+
+	tbl = opt->values;
+	if (!tbl)
+		goto out;
+
+	/* ULLONG_MAX is used to bypass string processing */
+	checkval = val->value != ULLONG_MAX;
+	if (!checkval) {
+		if (!val->string)
+			goto out;
+		p = strchr(val->string, '\n');
+		if (p)
+			*p = '\0';
+		for (p = val->string; *p; p++)
+			if (!(isdigit(*p) || isspace(*p)))
+				break;
+		/* The following code extracts the string to match or the value
+		 * and sets checkval appropriately
+		 */
+		if (*p) {
+			rv = sscanf(val->string, "%32s", valstr);
+		} else {
+			rv = sscanf(val->string, "%llu", &val->value);
+			checkval = true;
+		}
+		if (!rv)
+			goto out;
+	}
+
+	for (i = 0; tbl[i].string; i++) {
+		/* Check for exact match */
+		if (checkval) {
+			if (val->value == tbl[i].value)
+				ret = &tbl[i];
+		} else {
+			if (!strcmp(valstr, "default") &&
+			    (tbl[i].flags & BOND_VALFLAG_DEFAULT))
+				ret = &tbl[i];
+
+			if (!strcmp(valstr, tbl[i].string))
+				ret = &tbl[i];
+		}
+		/* Found an exact match */
+		if (ret)
+			goto out;
+	}
+	/* Possible range match */
+	if (checkval && bond_opt_check_range(opt, val->value))
+		ret = val;
+out:
+	return ret;
+}
+
+/* Check opt's dependencies against bond mode and currently set options */
+static int bond_opt_check_deps(struct bonding *bond,
+			       const struct bond_option *opt)
+{
+	struct bond_params *params = &bond->params;
+
+	if (test_bit(params->mode, &opt->unsuppmodes))
+		return -EACCES;
+	if ((opt->flags & BOND_OPTFLAG_NOSLAVES) && bond_has_slaves(bond))
+		return -ENOTEMPTY;
+	if ((opt->flags & BOND_OPTFLAG_IFDOWN) && (bond->dev->flags & IFF_UP))
+		return -EBUSY;
+
+	return 0;
+}
+
+static void bond_opt_dep_print(struct bonding *bond,
+			       const struct bond_option *opt)
+{
+	struct bond_params *params;
+
+	params = &bond->params;
+	if (test_bit(params->mode, &opt->unsuppmodes))
+		pr_err("%s: option %s: mode dependency failed\n",
+		       bond->dev->name, opt->name);
+}
+
+static void bond_opt_error_interpret(struct bonding *bond,
+				     const struct bond_option *opt,
+				     int error, struct bond_opt_value *val)
+{
+	struct bond_opt_value *minval, *maxval;
+	char *p;
+
+	switch (error) {
+	case -EINVAL:
+		if (val) {
+			if (val->string) {
+				/* sometimes RAWVAL opts may have new lines */
+				p = strchr(val->string, '\n');
+				if (p)
+					*p = '\0';
+				pr_err("%s: option %s: invalid value (%s).\n",
+				       bond->dev->name, opt->name, val->string);
+			} else {
+				pr_err("%s: option %s: invalid value (%llu).\n",
+				       bond->dev->name, opt->name, val->value);
+			}
+		}
+		minval = bond_opt_get_flags(opt, BOND_VALFLAG_MIN);
+		maxval = bond_opt_get_flags(opt, BOND_VALFLAG_MAX);
+		if (!maxval)
+			break;
+		pr_err("%s: option %s: allowed values %llu - %llu.\n",
+		       bond->dev->name, opt->name, minval ? minval->value : 0,
+		       maxval->value);
+		break;
+	case -EACCES:
+		bond_opt_dep_print(bond, opt);
+		break;
+	case -ENOTEMPTY:
+		pr_err("%s: option %s: unable to set because the bond device has slaves.\n",
+		       bond->dev->name, opt->name);
+		break;
+	case -EBUSY:
+		pr_err("%s: option %s: unable to set because the bond device is up.\n",
+		       bond->dev->name, opt->name);
+		break;
+	default:
+		break;
+	}
+}
+
+/**
+ * __bond_opt_set - set a bonding option
+ * @bond: target bond device
+ * @option: option to set
+ * @val: value to set it to
+ *
+ * This function is used to change the bond's option value, it can be
+ * used for both enabling/changing an option and for disabling it. RTNL lock
+ * must be obtained before calling this function.
+ */
+int __bond_opt_set(struct bonding *bond,
+		   unsigned int option, struct bond_opt_value *val)
+{
+	struct bond_opt_value *retval = NULL;
+	const struct bond_option *opt;
+	int ret = -ENOENT;
+
+	ASSERT_RTNL();
+
+	opt = bond_opt_get(option);
+	if (WARN_ON(!val) || WARN_ON(!opt))
+		goto out;
+	ret = bond_opt_check_deps(bond, opt);
+	if (ret)
+		goto out;
+	retval = bond_opt_parse(opt, val);
+	if (!retval) {
+		ret = -EINVAL;
+		goto out;
+	}
+	ret = opt->set(bond, retval);
+out:
+	if (ret)
+		bond_opt_error_interpret(bond, opt, ret, val);
+
+	return ret;
+}
+
+/**
+ * bond_opt_tryset_rtnl - try to acquire rtnl and call __bond_opt_set
+ * @bond: target bond device
+ * @option: option to set
+ * @buf: value to set it to
+ *
+ * This function tries to acquire RTNL without blocking and if successful
+ * calls __bond_opt_set. It is mainly used for sysfs option manipulation.
+ */
+int bond_opt_tryset_rtnl(struct bonding *bond, unsigned int option, char *buf)
+{
+	struct bond_opt_value optval;
+	int ret;
+
+	if (!rtnl_trylock())
+		return restart_syscall();
+	bond_opt_initstr(&optval, buf);
+	ret = __bond_opt_set(bond, option, &optval);
+	rtnl_unlock();
+
+	return ret;
+}
+
+/**
+ * bond_opt_get - get a pointer to an option
+ * @option: option for which to return a pointer
+ *
+ * This function checks if option is valid and if so returns a pointer
+ * to its entry in the bond_opts[] option array.
+ */
+struct bond_option *bond_opt_get(unsigned int option)
+{
+	if (!BOND_OPT_VALID(option))
+		return NULL;
+
+	return &bond_opts[option];
+}
+
 int bond_option_mode_set(struct bonding *bond, int mode)
 {
 	if (bond_parm_tbl_lookup(mode, bond_mode_tbl) < 0) {
diff --git a/drivers/net/bonding/bond_options.h b/drivers/net/bonding/bond_options.h
new file mode 100644
index 0000000..e20f2eb
--- /dev/null
+++ b/drivers/net/bonding/bond_options.h
@@ -0,0 +1,100 @@
+/*
+ * drivers/net/bond/bond_options.h - bonding options
+ * Copyright (c) 2013 Nikolay Aleksandrov <nikolay@redhat.com>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ */
+
+#ifndef _BOND_OPTIONS_H
+#define _BOND_OPTIONS_H
+
+#define BOND_OPT_MAX_NAMELEN 32
+#define BOND_OPT_VALID(opt) ((opt) < BOND_OPT_LAST)
+#define BOND_MODE_ALL_EX(x) (~(x))
+
+/* Option flags:
+ * BOND_OPTFLAG_NOSLAVES - check if the bond device is empty before setting
+ * BOND_OPTFLAG_IFDOWN - check if the bond device is down before setting
+ * BOND_OPTFLAG_RAWVAL - the option parses the value itself
+ */
+enum {
+	BOND_OPTFLAG_NOSLAVES	= BIT(0),
+	BOND_OPTFLAG_IFDOWN	= BIT(1),
+	BOND_OPTFLAG_RAWVAL	= BIT(2)
+};
+
+/* Value type flags:
+ * BOND_VALFLAG_DEFAULT - mark the value as default
+ * BOND_VALFLAG_(MIN|MAX) - mark the value as min/max
+ */
+enum {
+	BOND_VALFLAG_DEFAULT	= BIT(0),
+	BOND_VALFLAG_MIN	= BIT(1),
+	BOND_VALFLAG_MAX	= BIT(2)
+};
+
+/* Option IDs, their bit positions correspond to their IDs */
+enum {
+	BOND_OPT_LAST
+};
+
+/* This structure is used for storing option values and for passing option
+ * values when changing an option. The logic when used as an arg is as follows:
+ * - if string != NULL -> parse it, if the opt is RAW type then return it, else
+ *   return the parse result
+ * - if string == NULL -> parse value
+ */
+struct bond_opt_value {
+	char *string;
+	u64 value;
+	u32 flags;
+};
+
+struct bonding;
+
+struct bond_option {
+	int id;
+	char *name;
+	char *desc;
+	u32 flags;
+
+	/* unsuppmodes is used to denote modes in which the option isn't
+	 * supported.
+	 */
+	unsigned long unsuppmodes;
+	/* supported values which this option can have, can be a subset of
+	 * BOND_OPTVAL_RANGE's value range
+	 */
+	struct bond_opt_value *values;
+
+	int (*set)(struct bonding *bond, struct bond_opt_value *val);
+};
+
+int __bond_opt_set(struct bonding *bond, unsigned int option,
+		   struct bond_opt_value *val);
+int bond_opt_tryset_rtnl(struct bonding *bond, unsigned int option, char *buf);
+struct bond_opt_value *bond_opt_parse(const struct bond_option *opt,
+				      struct bond_opt_value *val);
+struct bond_option *bond_opt_get(unsigned int option);
+struct bond_opt_value *bond_opt_get_val(unsigned int option, u64 val);
+
+/* This helper is used to initialize a bond_opt_value structure for parameter
+ * passing. There should be either a valid string or value, but not both.
+ * When value is ULLONG_MAX then string will be used.
+ */
+static inline void __bond_opt_init(struct bond_opt_value *optval,
+				   char *string, u64 value)
+{
+	memset(optval, 0, sizeof(*optval));
+	optval->value = ULLONG_MAX;
+	if (value == ULLONG_MAX)
+		optval->string = string;
+	else
+		optval->value = value;
+}
+#define bond_opt_initval(optval, value) __bond_opt_init(optval, NULL, value)
+#define bond_opt_initstr(optval, str) __bond_opt_init(optval, str, ULLONG_MAX)
+#endif /* _BOND_OPTIONS_H */
diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
index 8a935f8..92ee557 100644
--- a/drivers/net/bonding/bonding.h
+++ b/drivers/net/bonding/bonding.h
@@ -25,6 +25,7 @@
 #include <linux/etherdevice.h>
 #include "bond_3ad.h"
 #include "bond_alb.h"
+#include "bond_options.h"
 
 #define DRV_VERSION	"3.7.1"
 #define DRV_RELDATE	"April 27, 2011"
-- 
1.8.4.2
