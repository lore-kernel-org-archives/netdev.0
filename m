From: Julian Anastasov <ja@ssi.bg>
Subject: [PATCH 2.6] ip_nat_ftp - manip at the right place
Date: Sat, 11 Sep 2004 10:53:53 +0300 (EEST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.58.0409111042580.1315@u.domain.uli>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com, Rusty Russell <rusty@rustcorp.com.au>
Return-path: <netdev-bounce@oss.sgi.com>
To: Harald Welte <laforge@netfilter.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


	Hello,

	This is a resend/resync for v2.6.9-rc1-bk17: change the
way the ip_nat_ftp helper manipulates the packets:

- no manips => no fixup

- check the direction, do manip once and at the same time when the
headers are changed

	This is needed mostly for IPVS setups and I hope we do not
create troubles for other setups or FTP software.

Signed-off-by: Julian Anastasov <ja@ssi.bg>

diff -ur v2.6.9-rc1-bk17/linux/net/ipv4/netfilter/ip_nat_ftp.c linux/net/ipv4/netfilter/ip_nat_ftp.c
--- v2.6.9-rc1-bk17/linux/net/ipv4/netfilter/ip_nat_ftp.c	2004-09-11 09:35:33.000000000 +0300
+++ linux/net/ipv4/netfilter/ip_nat_ftp.c	2004-09-11 10:29:38.343165344 +0300
@@ -237,17 +237,23 @@
 	unsigned int datalen;
 	int dir;
 	struct ip_ct_ftp_expect *exp_ftp_info;
+	int i, do_manip = 0;
 
 	if (!exp)
 		DEBUGP("ip_nat_ftp: no exp!!");
 
 	exp_ftp_info = &exp->help.exp_ftp_info;
 
-	/* Only mangle things once: original direction in POST_ROUTING
-	   and reply direction on PRE_ROUTING. */
+	/* Only mangle things once: for the first manip in this direction. */
 	dir = CTINFO2DIR(ctinfo);
-	if (!((hooknum == NF_IP_POST_ROUTING && dir == IP_CT_DIR_ORIGINAL)
-	      || (hooknum == NF_IP_PRE_ROUTING && dir == IP_CT_DIR_REPLY))) {
+	for (i = 0; i < info->num_manips; i++) {
+		if (info->manips[i].direction == dir) {
+			if (info->manips[i].hooknum == hooknum)
+				do_manip = 1;
+			break;
+		}
+	}
+	if (!do_manip) {
 		DEBUGP("nat_ftp: Not touching dir %s at hook %s\n",
 		       dir == IP_CT_DIR_ORIGINAL ? "ORIG" : "REPLY",
 		       hooknum == NF_IP_POST_ROUTING ? "POSTROUTING"
