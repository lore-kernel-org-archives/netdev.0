From: Ajit Khaparde <ajit.khaparde@emulex.com>
Subject: [RFC iproute 1/2] iproute2: Add new option to ip link to set VF
 privileges
Date: Tue, 14 Feb 2012 13:26:37 -0600
Message-ID: <20120214192637.GA14402@akhaparde-VBox>
Reply-To: Ajit Khaparde <ajit.khaparde@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>
To: <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exht1.emulex.com ([138.239.113.183]:31047 "EHLO
	exht1.ad.emulex.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1760076Ab2BNT1D (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Feb 2012 14:27:03 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ajit Khaparde <ajit.khaparde@emulex.com>
---
 include/linux/if_link.h |   20 ++++++++++++++++++++
 ip/ipaddress.c          |   15 +++++++++++++++
 ip/iplink.c             |   10 ++++++++++
 3 files changed, 45 insertions(+), 0 deletions(-)

diff --git a/include/linux/if_link.h b/include/linux/if_link.h
index d3bc04c..ddd0a75 100644
--- a/include/linux/if_link.h
+++ b/include/linux/if_link.h
@@ -278,11 +278,26 @@ enum {
 	IFLA_VF_VLAN,
 	IFLA_VF_TX_RATE,	/* TX Bandwidth Allocation */
 	IFLA_VF_SPOOFCHK,	/* Spoof Checking on/off switch */
+	IFLA_VF_PRIVILEGE,	/* VF Privilege level setting */
 	__IFLA_VF_MAX,
 };
 
 #define IFLA_VF_MAX (__IFLA_VF_MAX - 1)
 
+enum {
+	IFLA_VF_PRIVILEGE_LOCAL = 1,	/* Local privileges Only */
+	IFLA_VF_PRIVILEGE_STATS	= 2,	/* Privilege to gather Stats */
+	IFLA_VF_PRIVILEGE_LNK_MGMT = 4,	/* Privilege to manage link params */
+	IFLA_VF_PRIVILEGE_DIAG	= 8,	/* Privilege to perform Diagnostics */
+	IFLA_VF_PRIVILEGE_MAC	= 16,	/* Privilege to modify MAC filters */
+	IFLA_VF_PRIVILEGE_VLAN	= 32,	/* Privilege to add or remove VLANs */
+	IFLA_VF_PRIVILEGE_DEV_CFG = 64,	/* Privilege to perform Dev config */
+	IFLA_VF_PRIVILEGE_SECURE = 128,	/* Privilege to access secure info */
+	__IFLA_VF_PRIVILEGE_MAX,
+};
+
+#define IFLA_VF_PRIVILEGE_MAX (__IFLA_VF_PRIVILEGE_MAX - 1)
+
 struct ifla_vf_mac {
 	__u32 vf;
 	__u8 mac[32]; /* MAX_ADDR_LEN */
@@ -304,6 +319,11 @@ struct ifla_vf_spoofchk {
 	__u32 setting;
 };
 
+struct ifla_vf_privilege {
+	__u32 vf;
+	__u32 privilege;
+};
+
 /* VF ports management section
  *
  *	Nested layout of set/get msg is:
diff --git a/ip/ipaddress.c b/ip/ipaddress.c
index 4a0ffd6..7ae23f0 100644
--- a/ip/ipaddress.c
+++ b/ip/ipaddress.c
@@ -198,6 +198,7 @@ static void print_vfinfo(FILE *fp, struct rtattr *vfinfo)
 	struct ifla_vf_vlan *vf_vlan;
 	struct ifla_vf_tx_rate *vf_tx_rate;
 	struct ifla_vf_spoofchk *vf_spoofchk;
+	struct ifla_vf_privilege *vf_privilege;
 	struct rtattr *vf[IFLA_VF_MAX+1];
 	struct rtattr *tmp;
 	SPRINT_BUF(b1);
@@ -224,6 +225,17 @@ static void print_vfinfo(FILE *fp, struct rtattr *vfinfo)
 	else
 		vf_spoofchk = RTA_DATA(vf[IFLA_VF_SPOOFCHK]);
 
+	/* Check if this kernel supports VF Privileges */
+	if (vf_spoofchk) {
+		tmp = (struct rtattr *)((char *)vf[IFLA_VF_SPOOFCHK] +
+					vf[IFLA_VF_SPOOFCHK]->rta_len);
+
+		if (tmp->rta_type != IFLA_VF_PRIVILEGE)
+			vf_privilege = NULL;
+		else
+			vf_privilege = RTA_DATA(vf[IFLA_VF_PRIVILEGE]);
+	}
+
 	fprintf(fp, "\n    vf %d MAC %s", vf_mac->vf,
 		ll_addr_n2a((unsigned char *)&vf_mac->mac,
 		ETH_ALEN, 0, b1, sizeof(b1)));
@@ -239,6 +251,9 @@ static void print_vfinfo(FILE *fp, struct rtattr *vfinfo)
 		else
 			fprintf(fp, ", spoof checking off");
 	}
+
+	if (vf_privilege && vf_privilege->privilege)
+		fprintf(fp, ", privilege 0x%x", vf_privilege->privilege);
 }
 
 int print_linkinfo(const struct sockaddr_nl *who,
diff --git a/ip/iplink.c b/ip/iplink.c
index 6b051b6..b42fd84 100644
--- a/ip/iplink.c
+++ b/ip/iplink.c
@@ -75,6 +75,8 @@ void iplink_usage(void)
 	fprintf(stderr, "				   [ rate TXRATE ] ] \n");
 
 	fprintf(stderr, "				   [ spoofchk { on | off} ] ] \n");
+
+	fprintf(stderr, "				   [ privilege PRIVILEGE ] \n");
 	fprintf(stderr, "			  [ master DEVICE ]\n");
 	fprintf(stderr, "			  [ nomaster ]\n");
 	fprintf(stderr, "       ip link show [ DEVICE | group GROUP ]\n");
@@ -243,6 +245,14 @@ int iplink_parse_vf(int vf, int *argcp, char ***argvp,
 			ivs.vf = vf;
 			addattr_l(&req->n, sizeof(*req), IFLA_VF_SPOOFCHK, &ivs, sizeof(ivs));
 
+		} else if (matches(*argv, "privilege") == 0) {
+			struct ifla_vf_privilege ivp;
+			NEXT_ARG();
+			if (get_unsigned(&ivp.privilege, *argv, 0))
+				invarg("Invalid \"privilege\" value\n", *argv);
+			ivp.vf = vf;
+			addattr_l(&req->n, sizeof(*req), IFLA_VF_PRIVILEGE, &ivp, sizeof(ivp));
+
 		} else {
 			/* rewind arg */
 			PREV_ARG();
-- 
1.7.1
