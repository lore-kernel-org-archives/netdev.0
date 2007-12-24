From: jamal <hadi@cyberus.ca>
Subject: [PATCH] [IPROUTE2] IPT action compatibility with iptables 1.4.0
Date: Mon, 24 Dec 2007 11:55:05 -0500
Message-ID: <1198515305.4427.12.camel@localhost>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-cyOv5H/vMYvBnEINejU7"
Cc: Denys Fedoryshchenko <denys@visp.net.lb>, netdev@vger.kernel.org,
	Pablo Neira Ayuso <pablo@netfilter.org>
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wa-out-1112.google.com ([209.85.146.180]:29434 "EHLO
	wa-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750846AbXLXQzO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Dec 2007 11:55:14 -0500
Received: by wa-out-1112.google.com with SMTP id v27so2788728wah.23
        for <netdev@vger.kernel.org>; Mon, 24 Dec 2007 08:55:13 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-cyOv5H/vMYvBnEINejU7
Content-Type: text/plain
Content-Transfer-Encoding: 7bit


Stephen,

Please apply this patch from Denys Fedoryshchenko to make the ipt action
work with latest iptables.

cheers,
jamal


--=-cyOv5H/vMYvBnEINejU7
Content-Disposition: attachment; filename=ipt-p1
Content-Type: text/plain; name=ipt-p1; charset=us-ascii
Content-Transfer-Encoding: 7bit

New iptables 1.4.0 has some library names changed from libipt to libxt.
It is prefferable also to open libxt_ first, as newer "style".

Signed-off-by: Denys Fedoryshchenko <nuclearcat@nuclearcat.com>
Signed-off-by: Jamal Hadi Salim <hadi@cyberus.ca>

---
commit fe7b0dd9c19451019494d834c631c045e75e2b05
tree 452a75a6ec17d63832b03972ec9059b5cf9d8cfe
parent 235ac6a41d9d0439cce4eca8acdd31cac28605fc
author Denys Fedoryshchenko <nuclearcat@nuclearcat.com> Mon, 24 Dec 2007 11:51:11 -0500
committer Jamal Hadi Salim <hadi@cyberus.ca> Mon, 24 Dec 2007 11:51:11 -0500

 tc/m_ipt.c |   24 ++++++++++++++++++++++--
 1 files changed, 22 insertions(+), 2 deletions(-)

diff --git a/tc/m_ipt.c b/tc/m_ipt.c
index acbb8d2..f2a9305 100644
--- a/tc/m_ipt.c
+++ b/tc/m_ipt.c
@@ -69,6 +69,13 @@ register_target(struct iptables_target *me)
 }
 
 void
+xtables_register_target(struct iptables_target *me)
+{
+	me->next = t_list;
+	t_list = me;
+}
+
+void
 exit_tryhelp(int status)
 {
 	fprintf(stderr, "Try `%s -h' or '%s --help' for more information.\n",
@@ -248,11 +255,24 @@ get_target_name(const char *name)
 		}
 	}
 
-	sprintf(path,  "%s/libipt_%s.so",lib_dir, new_name);
+	/* try libxt_xx first */
+	sprintf(path, "%s/libxt_%s.so", lib_dir, new_name);
 	handle = dlopen(path, RTLD_LAZY);
 	if (!handle) {
-		sprintf(path, lib_dir, "/libipt_%s.so", lname);
+		/* try libipt_xx next */
+		sprintf(path, "%s/libipt_%s.so", lib_dir, new_name);
 		handle = dlopen(path, RTLD_LAZY);
+
+		if (!handle) {
+			sprintf(path, "%s/libxt_%s.so", lib_dir , lname);
+			handle = dlopen(path, RTLD_LAZY);
+		}
+
+		if (!handle) {
+			sprintf(path, "%s/libipt_%s.so", lib_dir , lname);
+			handle = dlopen(path, RTLD_LAZY);
+		}
+		/* ok, lets give up .. */
 		if (!handle) {
 			fputs(dlerror(), stderr);
 			printf("\n");

--=-cyOv5H/vMYvBnEINejU7--

