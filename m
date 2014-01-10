From: Nikolay Aleksandrov <nikolay@redhat.com>
Subject: [RFC net-next 1/3] bonding: add infrastructure for an option API
Date: Fri, 10 Jan 2014 14:11:33 +0100
Message-ID: <1389359495-9700-2-git-send-email-nikolay@redhat.com>
References: <1389359495-9700-1-git-send-email-nikolay@redhat.com>
Cc: Nikolay Aleksandrov <nikolay@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:48874 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756708AbaAJNQu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 10 Jan 2014 08:16:50 -0500
Received: from int-mx02.intmail.prod.int.phx2.redhat.com (int-mx02.intmail.prod.int.phx2.redhat.com [10.5.11.12])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id s0ADGoLd032336
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Fri, 10 Jan 2014 08:16:50 -0500
In-Reply-To: <1389359495-9700-1-git-send-email-nikolay@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds the necessary basic infrastructure to support
centralized and unified option manipulation API for the bonding. The new
structure bond_option will be used to describe each option with its
dependencies on modes which will be checked automatically thus removing a
lot of duplicated code. Also automatic range checking is added for
non-string options. Currently the option setting function requires RTNL to
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

The current available option types are:
BOND_OPTVAL_INTEGER - range option, the flags should be used to define
                      it properly
BOND_OPTVAL_STRING - string option or an option which wants to do its
                     own validation and conversion since the buffer is
                     passed unmodified to the option manipulation function

The options can have different flags set, currently the following are
supported:
BOND_OPTFLAG_NOSLAVES - require that the bond device has no slaves prior
                        to setting the option
BOND_OPTFLAG_IFDOWN - require that the bond device is down prior to
                      setting the option

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

BOND_VALFLAG_(MIN|MAX) can be used to specify a valid range for an
option, if MIN is omitted then 0 is considered as a minimum. If an
exact match is found in the values[] table it will be returned,
otherwise the range is tried (if available).
The values[] table which describes the allowed values for an option is
not mandatory for BOND_OPTVAL_STRING, but if it's present it will be
used.

For BOND_OPTVAL_INTEGER the values[] table is mandatory.

Signed-off-by: Nikolay Aleksandrov <nikolay@redhat.com>
---
 drivers/net/bonding/bond_options.c | 317 +++++++++++++++++++++++++++++++++++++
 drivers/net/bonding/bond_options.h |  82 ++++++++++
 drivers/net/bonding/bonding.h      |   1 +
 3 files changed, 400 insertions(+)
 create mode 100644 drivers/net/bonding/bond_options.h

diff --git a/drivers/net/bonding/bond_options.c b/drivers/net/bonding/bond_options.c
index 945a666..7765efb 100644
--- a/drivers/net/bonding/bond_options.c
+++ b/drivers/net/bonding/bond_options.c
@@ -17,8 +17,325 @@
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
+struct bond_value_tbl *bond_opt_get_val(unsigned int option, int val)
+{
+	struct bond_option *opt;
+	int i;
+
+	opt = bond_opt_get(option);
+	if (WARN_ON(!opt))
+		return NULL;
+	for (i = 0; opt->values && opt->values[i].name; i++)
+		if (opt->values[i].value == val)
+			return &opt->values[i];
+
+	return NULL;
+}
+
+/* Searches for a value in opt's values[] table which matches the flagmask */
+static struct bond_value_tbl *bond_opt_get_flags(const struct bond_option *opt,
+						 u32 flagmask)
+{
+	int i;
+
+	for (i = 0; opt->values && opt->values[i].name; i++)
+		if (opt->values[i].flags & flagmask)
+			return &opt->values[i];
+
+	return NULL;
+}
+
+static bool bond_opt_check_range(const struct bond_option *opt, int val)
+{
+	struct bond_value_tbl *minval, *maxval;
+
+	minval = bond_opt_get_flags(opt, BOND_VALFLAG_MIN);
+	maxval = bond_opt_get_flags(opt, BOND_VALFLAG_MAX);
+	if (val < 0 || (minval && val < minval->value) ||
+	    (maxval && val > maxval->value))
+		return false;
+
+	return true;
+}
+
+/**
+ * bond_opt_parse - parse option value
+ * @tbl: an option's values[] table to parse against
+ * @bufarg: value to parse
+ * @retval: pointer where to store the parsed value
+ * @string: how to treat bufarg (as string or integer)
+ *
+ * This functions tries to extract the value from bufarg and check if it's
+ * a possible match for the option. It shouldn't be possible to have a non-NULL
+ * return with @retval being < 0.
+ */
+struct bond_value_tbl *bond_opt_parse(const struct bond_option *opt,
+				      void *bufarg, int *retval, bool string)
+{
+	char *buf, *p, valstr[BOND_MAX_MODENAME_LEN + 1] = { 0, };
+	struct bond_value_tbl *tbl, *maxval = NULL, *ret = NULL;
+	int valint = -1, i, rv;
+
+	tbl = opt->values;
+	if (!tbl)
+		goto out;
+
+	if (string) {
+		buf = bufarg;
+		for (p = (char *)buf; *p; p++)
+			if (!(isdigit(*p) || isspace(*p)))
+				break;
+
+		if (*p)
+			rv = sscanf(buf, "%20s", valstr);
+		else
+			rv = sscanf(buf, "%d", &valint);
+
+		if (!rv)
+			goto out;
+	} else {
+		valint = *(int *)bufarg;
+	}
+
+	for (i = 0; tbl[i].name; i++) {
+		/* Obtain maxval in case we don't match anything */
+		if (tbl[i].flags & BOND_VALFLAG_MAX)
+			maxval = &tbl[i];
+
+		/* Check for exact match */
+		if (!strcmp(valstr, "default") &&
+		    (tbl[i].flags & BOND_VALFLAG_DEFAULT))
+			ret = &tbl[i];
+		else if (valint == tbl[i].value)
+			ret = &tbl[i];
+		else if (!strcmp(valstr, tbl[i].name))
+			ret = &tbl[i];
+
+		/* Exact match */
+		if (ret) {
+			valint = ret->value;
+			goto out;
+		}
+	}
+	/* Possible range match */
+	if (bond_opt_check_range(opt, valint))
+		ret = maxval;
+out:
+	if (ret)
+		*retval = valint;
+	else
+		*retval = -ENOENT;
+
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
+				     int error, char *buf)
+{
+	struct bond_value_tbl *minval, *maxval;
+	char *p;
+
+	p = strchr(buf, '\n');
+	if (p)
+		*p = '\0';
+	switch (error) {
+	case -EINVAL:
+		pr_err("%s: option %s: invalid value (%s).\n",
+		       bond->dev->name, opt->name, buf);
+		if (opt->valtype == BOND_OPTVAL_STRING)
+			break;
+		minval = bond_opt_get_flags(opt, BOND_VALFLAG_MIN);
+		maxval = bond_opt_get_flags(opt, BOND_VALFLAG_MAX);
+		if (!maxval)
+			break;
+		pr_err("%s: option %s: allowed values %d - %d.\n",
+		       bond->dev->name, opt->name, minval ? minval->value : 0,
+		       maxval->value);
+		break;
+	case -EACCES:
+		bond_opt_dep_print(bond, opt);
+		break;
+	case -ENOTEMPTY:
+		pr_err("%s: option %s: unable to set because the bond has slaves.\n",
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
+static int bond_opt_call_intset(struct bonding *bond,
+				const struct bond_option *opt,
+				int newval)
+{
+	struct bond_value_tbl *valptr;
+	int value = newval;
+
+	if (opt->valtype != BOND_OPTVAL_INTEGER)
+		return -EINVAL;
+	/* Check value and store the result in it */
+	valptr = bond_opt_parse(opt, &value, &value, false);
+	if (!valptr)
+		return -EINVAL;
+
+	return opt->set(bond, &value);
+}
+
+/**
+ * bond_opt_call_set - convert buf and check the value based on opt->valtype
+ * @bond: bond device to set on
+ * @opt: option to set
+ * @buf: value to set the option to
+ *
+ * This function converts buf to the appropriate value based on the opt's
+ * valtype.
+ */
+static int bond_opt_call_set(struct bonding *bond,
+			     const struct bond_option *opt,
+			     char *buf)
+{
+	struct bond_value_tbl *valptr;
+	int value = -1;
+
+	if (opt->valtype == BOND_OPTVAL_INTEGER) {
+		valptr = bond_opt_parse(opt, buf, &value, true);
+		if (!valptr)
+			return -EINVAL;
+		return opt->set(bond, &value);
+	} else {
+		return opt->set(bond, buf);
+	}
+}
+
+/**
+ * __bond_opt_set - set a bonding option
+ * @bond: target bond device
+ * @option: option to set
+ * @buf: value to set it to
+ *
+ * This function is used to change the bond's option value to newval, it can be
+ * used for both enabling/changing an option and for disabling it. RTNL lock
+ * must be obtained before calling this function.
+ */
+int __bond_opt_set(struct bonding *bond, unsigned int option, char *buf)
+{
+	const struct bond_option *opt;
+	int ret = -ENOENT;
+
+	ASSERT_RTNL();
+
+	opt = bond_opt_get(option);
+	if (WARN_ON(!buf) || WARN_ON(!opt))
+		goto out;
+	ret = bond_opt_check_deps(bond, opt);
+	if (ret)
+		goto out;
+	ret = bond_opt_call_set(bond, opt, buf);
+out:
+	if (ret)
+		bond_opt_error_interpret(bond, opt, ret, buf);
+
+	return ret;
+}
+
+/* See comment for __bond_opt_set. This function is used to set a
+ * BOND_OPTVAL_INTEGER option to a value directly without string parsing. The
+ * value is still checked against the option's values[] table.
+ */
+int __bond_opt_intset(struct bonding *bond, unsigned int option, int value)
+{
+	const struct bond_option *opt;
+	int ret = -ENOENT;
+
+	ASSERT_RTNL();
+
+	opt = bond_opt_get(option);
+	if (WARN_ON(!opt))
+		return ret;
+	ret = bond_opt_check_deps(bond, opt);
+	if (ret)
+		return ret;
+	ret = bond_opt_call_intset(bond, opt, value);
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
+ * calls __bond_opt_set, otherwise returns -EAGAIN to notify the caller.
+ */
+int bond_opt_tryset_rtnl(struct bonding *bond, unsigned int option, char *buf)
+{
+	int ret;
+
+	if (!rtnl_trylock())
+		return -EAGAIN;
+	ret = __bond_opt_set(bond, option, buf);
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
index 0000000..c72ecec
--- /dev/null
+++ b/drivers/net/bonding/bond_options.h
@@ -0,0 +1,82 @@
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
+#define BOND_OPT_VALID(opt) ((opt) < BOND_OPT_LAST)
+#define BOND_MODE_ALL_EX(x) (~(x))
+
+/* Option value types */
+enum {
+	BOND_OPTVAL_INTEGER,
+	BOND_OPTVAL_STRING
+};
+
+/* Option flags:
+ * BOND_OPTFLAG_NOSLAVES - check if the bond device is empty before setting
+ * BOND_OPTFLAG_IFDOWN - check if the bond device is down before setting
+ */
+enum {
+	BOND_OPTFLAG_NOSLAVES	= BIT(0),
+	BOND_OPTFLAG_IFDOWN	= BIT(1)
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
+struct bond_value_tbl {
+	char *name;
+	int value;
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
+	u8 valtype;
+
+	/* unsuppmodes is used to denote modes in which the option isn't
+	 * supported.
+	 */
+	unsigned long unsuppmodes;
+	/* supported values which this option can have, can be a subset of
+	 * BOND_OPTVAL_RANGE's value range
+	 */
+	struct bond_value_tbl *values;
+
+	int (*set)(struct bonding *bond, void *newval);
+};
+
+void bond_opt_init(void);
+int __bond_opt_set(struct bonding *bond, unsigned int option, char *buf);
+int __bond_opt_intset(struct bonding *bond, unsigned int option, int value);
+int bond_opt_tryset_rtnl(struct bonding *bond, unsigned int option, char *buf);
+struct bond_value_tbl *bond_opt_parse(const struct bond_option *opt,
+				      void *bufarg, int *retval, bool string);
+struct bond_option *bond_opt_get(unsigned int option);
+struct bond_value_tbl *bond_opt_get_val(unsigned int option, int val);
+#endif /* _BOND_OPTIONS_H */
diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
index 955dc48..71e751a 100644
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
1.8.1.4
