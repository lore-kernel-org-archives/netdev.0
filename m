From: Alexander Aring <aar@pengutronix.de>
Subject: [RFC PATCH iproute2] tc: let m_ipt work with new iptables API headers
Date: Sun, 29 May 2016 20:27:13 +0200
Message-ID: <20160529182713.2131-1-aar@pengutronix.de>
Cc: kernel@pengutronix.de, clemens.gruber@pqgruber.com,
	Alexander Aring <aar@pengutronix.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.4.pengutronix.de ([92.198.50.35]:37162 "EHLO
	metis.ext.4.pengutronix.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753003AbcE2S1b (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 29 May 2016 14:27:31 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since commit 5cd1adb ("Update to current iptables headers") the build
with m_ipt.o and the following config will fail:

TC_CONFIG_XT:=n
TC_CONFIG_XT_OLD:=n
TC_CONFIG_XT_OLD_H:=n

This patch renames "iptables_target" to "xtables_target" and some other
things which gets renamed and I noticed while reading iptables git log.
Functions which are not used in m_ipt.c and not exported by the header
are removed, if they still used in m_ipt.c I added a static to the function.

Reported-by: Clemens Gruber <clemens.gruber@pqgruber.com>
Signed-off-by: Alexander Aring <aar@pengutronix.de>
---
I removed also "linux/if.h" because some redifinition errors and seems
not be necessary anymore.

I didn't test this implementation, I just fix the compile issues at m_ipt
implementation according to the algoritmn described above.

Maybe there are more TC_CONFIG_XT* config variants broken than just m_ipt?

 tc/m_ipt.c | 134 +++++++------------------------------------------------------
 1 file changed, 14 insertions(+), 120 deletions(-)

diff --git a/tc/m_ipt.c b/tc/m_ipt.c
index d088f5e..098f610 100644
--- a/tc/m_ipt.c
+++ b/tc/m_ipt.c
@@ -14,7 +14,6 @@
 #include <sys/socket.h>
 #include <netinet/in.h>
 #include <arpa/inet.h>
-#include <linux/if.h>
 #include <iptables.h>
 #include <linux/netfilter.h>
 #include <linux/netfilter_ipv4/ip_tables.h>
@@ -51,7 +50,7 @@ static struct option original_opts[] = {
 	{0, 0, 0, 0}
 };
 
-static struct iptables_target *t_list;
+static struct xtables_target *t_list;
 static struct option *opts = original_opts;
 static unsigned int global_option_offset;
 #define OPTION_OFFSET 256
@@ -59,32 +58,21 @@ static unsigned int global_option_offset;
 char *lib_dir;
 
 void
-register_target(struct iptables_target *me)
+xtables_register_target(struct xtables_target *me)
 {
-/*      fprintf(stderr, "\nDummy register_target %s\n", me->name);
-*/
 	me->next = t_list;
 	t_list = me;
 
 }
 
-void
-xtables_register_target(struct iptables_target *me)
-{
-	me->next = t_list;
-	t_list = me;
-}
-
-void
-exit_tryhelp(int status)
+static void exit_tryhelp(int status)
 {
 	fprintf(stderr, "Try `%s -h' or '%s --help' for more information.\n",
 		pname, pname);
 	exit(status);
 }
 
-void
-exit_error(enum exittype status, char *msg, ...)
+static void exit_error(enum xtables_exittype status, char *msg, ...)
 {
 	va_list args;
 
@@ -106,61 +94,6 @@ They should really have them as a library so i can link to them
 Email them next time i remember
 */
 
-char *
-addr_to_dotted(const struct in_addr *addrp)
-{
-	static char buf[20];
-	const unsigned char *bytep;
-
-	bytep = (const unsigned char *) &(addrp->s_addr);
-	sprintf(buf, "%d.%d.%d.%d", bytep[0], bytep[1], bytep[2], bytep[3]);
-	return buf;
-}
-
-int string_to_number_ll(const char *s, unsigned long long min,
-			unsigned long long max,
-		 unsigned long long *ret)
-{
-	unsigned long long number;
-	char *end;
-
-	/* Handle hex, octal, etc. */
-	errno = 0;
-	number = strtoull(s, &end, 0);
-	if (*end == '\0' && end != s) {
-		/* we parsed a number, let's see if we want this */
-		if (errno != ERANGE && min <= number && (!max || number <= max)) {
-			*ret = number;
-			return 0;
-		}
-	}
-	return -1;
-}
-
-int string_to_number_l(const char *s, unsigned long min, unsigned long max,
-		       unsigned long *ret)
-{
-	int result;
-	unsigned long long number;
-
-	result = string_to_number_ll(s, min, max, &number);
-	*ret = (unsigned long)number;
-
-	return result;
-}
-
-int string_to_number(const char *s, unsigned int min, unsigned int max,
-		unsigned int *ret)
-{
-	int result;
-	unsigned long number;
-
-	result = string_to_number_l(s, min, max, &number);
-	*ret = (unsigned int)number;
-
-	return result;
-}
-
 static void free_opts(struct option *local_opts)
 {
 	if (local_opts != original_opts) {
@@ -205,10 +138,10 @@ fw_calloc(size_t count, size_t size)
 	return p;
 }
 
-static struct iptables_target *
+static struct xtables_target *
 find_t(char *name)
 {
-	struct iptables_target *m;
+	struct xtables_target *m;
 
 	for (m = t_list; m; m = m->next) {
 		if (strcmp(m->name, name) == 0)
@@ -218,13 +151,13 @@ find_t(char *name)
 	return NULL;
 }
 
-static struct iptables_target *
+static struct xtables_target *
 get_target_name(const char *name)
 {
 	void *handle;
 	char *error;
 	char *new_name, *lname;
-	struct iptables_target *m;
+	struct xtables_target *m;
 	char path[strlen(lib_dir) + sizeof("/libipt_.so") + strlen(name)];
 
 #ifdef NO_SHARED_LIBS
@@ -291,7 +224,7 @@ get_target_name(const char *name)
 
 	m = dlsym(handle, new_name);
 	if ((error = dlerror()) != NULL) {
-		m = (struct iptables_target *) dlsym(handle, lname);
+		m = (struct xtables_target *) dlsym(handle, lname);
 		if ((error = dlerror()) != NULL) {
 			m = find_t(new_name);
 			if (m == NULL) {
@@ -313,42 +246,6 @@ get_target_name(const char *name)
 	return m;
 }
 
-
-struct in_addr *dotted_to_addr(const char *dotted)
-{
-	static struct in_addr addr;
-	unsigned char *addrp;
-	char *p, *q;
-	unsigned int onebyte;
-	int i;
-	char buf[20];
-
-	/* copy dotted string, because we need to modify it */
-	strncpy(buf, dotted, sizeof(buf) - 1);
-	addrp = (unsigned char *) &(addr.s_addr);
-
-	p = buf;
-	for (i = 0; i < 3; i++) {
-		if ((q = strchr(p, '.')) == NULL)
-			return (struct in_addr *) NULL;
-
-		*q = '\0';
-		if (string_to_number(p, 0, 255, &onebyte) == -1)
-			return (struct in_addr *) NULL;
-
-		addrp[i] = (unsigned char) onebyte;
-		p = q + 1;
-	}
-
-	/* we've checked 3 bytes, now we check the last one */
-	if (string_to_number(p, 0, 255, &onebyte) == -1)
-		return (struct in_addr *) NULL;
-
-	addrp[3] = (unsigned char) onebyte;
-
-	return &addr;
-}
-
 static void set_revision(char *name, u_int8_t revision)
 {
 	/* Old kernel sources don't have ".revision" field,
@@ -360,23 +257,20 @@ static void set_revision(char *name, u_int8_t revision)
 /*
  * we may need to check for version mismatch
 */
-int
-build_st(struct iptables_target *target, struct ipt_entry_target *t)
+static int build_st(struct xtables_target *target, struct ipt_entry_target *t)
 {
-	unsigned int nfcache = 0;
-
 	if (target) {
 		size_t size;
 
 		size =
-		    IPT_ALIGN(sizeof(struct ipt_entry_target)) + target->size;
+		    XT_ALIGN(sizeof(struct ipt_entry_target)) + target->size;
 
 		if (t == NULL) {
 			target->t = fw_calloc(1, size);
 			target->t->u.target_size = size;
 
 			if (target->init != NULL)
-				target->init(target->t, &nfcache);
+				target->init(target->t);
 			set_revision(target->t->u.user.name, target->revision);
 		} else {
 			target->t = t;
@@ -391,7 +285,7 @@ build_st(struct iptables_target *target, struct ipt_entry_target *t)
 static int parse_ipt(struct action_util *a, int *argc_p,
 		     char ***argv_p, int tca_id, struct nlmsghdr *n)
 {
-	struct iptables_target *m = NULL;
+	struct xtables_target *m = NULL;
 	struct ipt_entry fw;
 	struct rtattr *tail;
 	int c;
@@ -574,7 +468,7 @@ print_ipt(struct action_util *au, FILE * f, struct rtattr *arg)
 		fprintf(f, "\t[NULL ipt target parameters ]\n");
 		return -1;
 	} else {
-		struct iptables_target *m = NULL;
+		struct xtables_target *m = NULL;
 
 		t = RTA_DATA(tb[TCA_IPT_TARG]);
 		m = get_target_name(t->u.user.name);
-- 
2.8.3
