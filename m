From: Kirill Tkhai <ktkhai@odin.com>
Subject: [iproute PATCH] Add ip rule save/restore
Date: Tue, 20 Oct 2015 13:41:48 +0300
Message-ID: <56261A6C.7050907@odin.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.parallels.com ([195.214.232.42]:55849 "EHLO
	relay.parallels.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751301AbbJTKl7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Oct 2015 06:41:59 -0400
Received: from [10.67.48.55] (helo=mail.parallels.net)
	by relay.parallels.com with esmtps (TLSv1.2:ECDHE-RSA-AES256-SHA384:256)
	(Exim 4.86)
	(envelope-from <ktkhai@odin.com>)
	id 1ZoUMf-0005Nh-2G
	for netdev@vger.kernel.org; Tue, 20 Oct 2015 13:41:57 +0300
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds save and restore commands to "ip rule"
similar the same is made in commit f4ff11e3e298 for "ip route".

The feature is useful in checkpoint/restore for container
migration, also it may be helpful in some normal situations.

Signed-off-by: Kirill Tkhai <ktkhai@odin.com>
---
 doc/ip-cref.tex    |   36 ++++++++++++++++++
 ip/iprule.c        |  103 +++++++++++++++++++++++++++++++++++++++++++++++++---
 man/man8/ip-rule.8 |   26 +++++++++++++
 3 files changed, 158 insertions(+), 7 deletions(-)

diff --git a/doc/ip-cref.tex b/doc/ip-cref.tex
index ea14795..67094c9 100644
--- a/doc/ip-cref.tex
+++ b/doc/ip-cref.tex
@@ -2246,6 +2246,42 @@ Besides that, the host 193.233.7.83 is translated into
 another prefix to look like 192.203.80.144 when talking
 to the outer world.
 
+\subsection{{\tt ip rule save} -- save rules tables}
+\label{IP-RULE-SAVE}
+
+\paragraph{Description:} this command saves the contents of the rules
+tables or the rule(s) selected by some criteria to standard output.
+
+\paragraph{Arguments:} \verb|ip rule save| has the same arguments as
+\verb|ip rule show|.
+
+\paragraph{Example:} This saves all the rules to the {\tt saved\_rules}
+file:
+\begin{verbatim}
+dan@caffeine:~ # ip rule save > saved_rules
+\end{verbatim}
+
+\paragraph{Output format:} The format of the data stream provided by
+\verb|ip rule save| is that of \verb|rtnetlink|.  See
+\verb|rtnetlink(7)| for more information.
+
+\subsection{{\tt ip rule restore} -- restore rules tables}
+\label{IP-RULE-RESTORE}
+
+\paragraph{Description:} this command restores the contents of the rules
+tables according to a data stream as provided by \verb|ip rule save| via
+standard input.  Note that any rules already in the table are left unchanged,
+and duplicates are not ignored.
+
+\paragraph{Arguments:} This command takes no arguments.
+
+\paragraph{Example:} This restores all rules that were saved to the
+{\tt saved\_rules} file:
+
+\begin{verbatim}
+dan@caffeine:~ # ip rule restore < saved_rules
+\end{verbatim}
+
 
 
 \section{{\tt ip maddress} --- multicast addresses management}
diff --git a/ip/iprule.c b/ip/iprule.c
index 2fa9ade..cec2924 100644
--- a/ip/iprule.c
+++ b/ip/iprule.c
@@ -21,6 +21,7 @@
 #include <arpa/inet.h>
 #include <string.h>
 #include <linux/fib_rules.h>
+#include <errno.h>
 
 #include "rt_names.h"
 #include "utils.h"
@@ -32,7 +33,8 @@ static void usage(void) __attribute__((noreturn));
 
 static void usage(void)
 {
-	fprintf(stderr, "Usage: ip rule [ list | add | del | flush ] SELECTOR ACTION\n");
+	fprintf(stderr, "Usage: ip rule [ list | add | del | flush | save ] SELECTOR ACTION\n");
+	fprintf(stderr, "       ip rule restore\n");
 	fprintf(stderr, "SELECTOR := [ not ] [ from PREFIX ] [ to PREFIX ] [ tos TOS ] [ fwmark FWMARK[/MASK] ]\n");
 	fprintf(stderr, "            [ iif STRING ] [ oif STRING ] [ pref NUMBER ]\n");
 	fprintf(stderr, "ACTION := [ table TABLE_ID ]\n");
@@ -205,24 +207,65 @@ int print_rule(const struct sockaddr_nl *who, struct nlmsghdr *n, void *arg)
 	return 0;
 }
 
-static int iprule_list(int argc, char **argv)
+static __u32 rule_dump_magic = 0x71706986;
+
+static int save_rule_prep(void)
+{
+	int ret;
+
+	if (isatty(STDOUT_FILENO)) {
+		fprintf(stderr, "Not sending a binary stream to stdout\n");
+		return -1;
+	}
+
+	ret = write(STDOUT_FILENO, &rule_dump_magic, sizeof(rule_dump_magic));
+	if (ret != sizeof(rule_dump_magic)) {
+		fprintf(stderr, "Can't write magic to dump file\n");
+		return -1;
+	}
+
+	return 0;
+}
+
+static int save_rule(const struct sockaddr_nl *who, struct nlmsghdr *n, void *arg)
 {
+	int ret;
+
+	ret = write(STDOUT_FILENO, n, n->nlmsg_len);
+	if ((ret > 0) && (ret != n->nlmsg_len)) {
+		fprintf(stderr, "Short write while saving nlmsg\n");
+		ret = -EIO;
+	}
+
+	return ret == n->nlmsg_len ? 0 : ret;
+}
+
+static int iprule_list_or_save(int argc, char **argv, int save)
+{
+	rtnl_filter_t filter = print_rule;
 	int af = preferred_family;
 
 	if (af == AF_UNSPEC)
 		af = AF_INET;
 
 	if (argc > 0) {
-		fprintf(stderr, "\"ip rule show\" does not take any arguments.\n");
+		fprintf(stderr, "\"ip rule %s\" does not take any arguments.\n",
+				save ? "save" : "show");
 		return -1;
 	}
 
+	if (save) {
+		if (save_rule_prep())
+			return -1;
+		filter = save_rule;
+	}
+
 	if (rtnl_wilddump_request(&rth, af, RTM_GETRULE) < 0) {
 		perror("Cannot send dump request");
 		return 1;
 	}
 
-	if (rtnl_dump_filter(&rth, print_rule, stdout) < 0) {
+	if (rtnl_dump_filter(&rth, filter, stdout) < 0) {
 		fprintf(stderr, "Dump terminated\n");
 		return 1;
 	}
@@ -230,6 +273,50 @@ static int iprule_list(int argc, char **argv)
 	return 0;
 }
 
+static int rule_dump_check_magic(void)
+{
+	int ret;
+	__u32 magic = 0;
+
+	if (isatty(STDIN_FILENO)) {
+		fprintf(stderr, "Can't restore rule dump from a terminal\n");
+		return -1;
+	}
+
+	ret = fread(&magic, sizeof(magic), 1, stdin);
+	if (magic != rule_dump_magic) {
+		fprintf(stderr, "Magic mismatch (%d elems, %x magic)\n", ret, magic);
+		return -1;
+	}
+
+	return 0;
+}
+
+static int restore_handler(const struct sockaddr_nl *nl,
+			   struct rtnl_ctrl_data *ctrl,
+			   struct nlmsghdr *n, void *arg)
+{
+	int ret;
+
+	n->nlmsg_flags |= NLM_F_REQUEST | NLM_F_CREATE | NLM_F_ACK;
+
+	ll_init_map(&rth);
+
+	ret = rtnl_talk(&rth, n, n, sizeof(*n));
+	if ((ret < 0) && (errno == EEXIST))
+		ret = 0;
+
+	return ret;
+}
+
+
+static int iprule_restore(void)
+{
+	if (rule_dump_check_magic())
+		exit(-1);
+
+	exit(rtnl_from_file(stdin, &restore_handler, NULL));
+}
 
 static int iprule_modify(int cmd, int argc, char **argv)
 {
@@ -443,11 +530,15 @@ static int iprule_flush(int argc, char **argv)
 int do_iprule(int argc, char **argv)
 {
 	if (argc < 1) {
-		return iprule_list(0, NULL);
+		return iprule_list_or_save(0, NULL, 0);
 	} else if (matches(argv[0], "list") == 0 ||
 		   matches(argv[0], "lst") == 0 ||
 		   matches(argv[0], "show") == 0) {
-		return iprule_list(argc-1, argv+1);
+		return iprule_list_or_save(argc-1, argv+1, 0);
+	} else if (matches(argv[0], "save") == 0) {
+		return iprule_list_or_save(argc-1, argv+1, 1);
+	} else if (matches(argv[0], "restore") == 0) {
+		return iprule_restore();
 	} else if (matches(argv[0], "add") == 0) {
 		return iprule_modify(RTM_NEWRULE, argc-1, argv+1);
 	} else if (matches(argv[0], "delete") == 0) {
diff --git a/man/man8/ip-rule.8 b/man/man8/ip-rule.8
index 6245d8c..b1d03e7 100644
--- a/man/man8/ip-rule.8
+++ b/man/man8/ip-rule.8
@@ -15,10 +15,13 @@ ip-rule \- routing policy database management
 
 .ti -8
 .B  ip rule
-.RB " [ " list " | " add " | " del " | " flush " ]"
+.RB " [ " list " | " add " | " del " | " flush " | " save " ]"
 .I  SELECTOR ACTION
 
 .ti -8
+.B  ip rule  " restore "
+
+.ti -8
 .IR SELECTOR " := [ "
 .B  from
 .IR PREFIX " ] [ "
@@ -265,6 +268,27 @@ This command has no arguments.
 This command has no arguments.
 The options list or lst are synonyms with show.
 
+.TP
+.B ip rule save
+save rules table information to stdout
+.RS
+This command behaves like
+.BR "ip rule show"
+except that the output is raw data suitable for passing to
+.BR "ip rule restore" .
+.RE
+
+.TP
+.B ip rule restore
+restore rules table information from stdin
+.RS
+This command expects to read a data stream as returned from
+.BR "ip rule save" .
+It will attempt to restore the rules table information exactly as
+it was at the time of the save. Any rules already in the table are
+left unchanged, and duplicates are not ignored.
+.RE
+
 .SH SEE ALSO
 .br
 .BR ip (8)
