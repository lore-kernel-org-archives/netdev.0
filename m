From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH V3 iproute2 3/3] Add VF link state control
Date: Thu, 13 Jun 2013 13:19:12 +0300
Message-ID: <1371118752-2314-4-git-send-email-ogerlitz@mellanox.com>
References: <1371118752-2314-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, amirv@mellanox.com, ronye@mellanox.com,
	Or Gerlitz <ogerlitz@mellanox.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:40927 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1758571Ab3FMKR4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 13 Jun 2013 06:17:56 -0400
In-Reply-To: <1371118752-2314-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rony Efraim <ronye@mellanox.com>

Add link state per VF command

Signed-off-by: Rony Efraim <ronye@mellanox.com>
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 include/linux/if_link.h |   13 +++++++++++++
 ip/ipaddress.c          |   23 +++++++++++++++++++++++
 ip/iplink.c             |   14 ++++++++++++++
 3 files changed, 50 insertions(+), 0 deletions(-)

diff --git a/include/linux/if_link.h b/include/linux/if_link.h
index 965dc9f..f01f691 100644
--- a/include/linux/if_link.h
+++ b/include/linux/if_link.h
@@ -334,6 +334,7 @@ enum {
 	IFLA_VF_VLAN,
 	IFLA_VF_TX_RATE,	/* TX Bandwidth Allocation */
 	IFLA_VF_SPOOFCHK,	/* Spoof Checking on/off switch */
+	IFLA_VF_LINK_STATE,     /* link state on/off switch */
 	__IFLA_VF_MAX,
 };
 
@@ -360,6 +361,18 @@ struct ifla_vf_spoofchk {
 	__u32 setting;
 };
 
+enum {
+	IFLA_VF_LINK_STATE_AUTO,	/* link state of the uplink */
+	IFLA_VF_LINK_STATE_ENABLE,	/* link always up */
+	IFLA_VF_LINK_STATE_DISABLE,	/* link always down */
+	__IFLA_VF_LINK_STATE_MAX,
+};
+
+struct ifla_vf_link_state {
+	__u32 vf;
+	__u32 link_state;
+};
+
 /* VF ports management section
  *
  *	Nested layout of set/get msg is:
diff --git a/ip/ipaddress.c b/ip/ipaddress.c
index 5b9a438..d2524e8 100644
--- a/ip/ipaddress.c
+++ b/ip/ipaddress.c
@@ -229,6 +229,7 @@ static void print_vfinfo(FILE *fp, struct rtattr *vfinfo)
 	struct ifla_vf_vlan *vf_vlan;
 	struct ifla_vf_tx_rate *vf_tx_rate;
 	struct ifla_vf_spoofchk *vf_spoofchk;
+	struct ifla_vf_link_state *vf_linkstate;
 	struct rtattr *vf[IFLA_VF_MAX+1];
 	struct rtattr *tmp;
 	SPRINT_BUF(b1);
@@ -255,6 +256,20 @@ static void print_vfinfo(FILE *fp, struct rtattr *vfinfo)
 	else
 		vf_spoofchk = RTA_DATA(vf[IFLA_VF_SPOOFCHK]);
 
+	if (vf_spoofchk) {
+		/* Check if the link state vf info type is supported by
+		 * this kernel.
+		 */
+		tmp = (struct rtattr *)((char *)vf[IFLA_VF_SPOOFCHK] +
+				vf[IFLA_VF_SPOOFCHK]->rta_len);
+
+		if (tmp->rta_type != IFLA_VF_LINK_STATE)
+			vf_linkstate = NULL;
+		else
+			vf_linkstate = RTA_DATA(vf[IFLA_VF_LINK_STATE]);
+	} else
+		vf_linkstate = NULL;
+
 	fprintf(fp, "\n    vf %d MAC %s", vf_mac->vf,
 		ll_addr_n2a((unsigned char *)&vf_mac->mac,
 		ETH_ALEN, 0, b1, sizeof(b1)));
@@ -270,6 +285,14 @@ static void print_vfinfo(FILE *fp, struct rtattr *vfinfo)
 		else
 			fprintf(fp, ", spoof checking off");
 	}
+	if (vf_linkstate) {
+		if (vf_linkstate->link_state == IFLA_VF_LINK_STATE_AUTO)
+			fprintf(fp, ", link-state auto");
+		else if (vf_linkstate->link_state == IFLA_VF_LINK_STATE_ENABLE)
+			fprintf(fp, ", link-state enable");
+		else
+			fprintf(fp, ", link-state disable");
+	}
 }
 
 static void print_link_stats64(FILE *fp, const struct rtnl_link_stats64 *s) {
diff --git a/ip/iplink.c b/ip/iplink.c
index dc98019..ada9d42 100644
--- a/ip/iplink.c
+++ b/ip/iplink.c
@@ -77,6 +77,7 @@ void iplink_usage(void)
 	fprintf(stderr, "				   [ rate TXRATE ] ] \n");
 
 	fprintf(stderr, "				   [ spoofchk { on | off} ] ] \n");
+	fprintf(stderr, "				   [ state { auto | enable | disable} ] ]\n");
 	fprintf(stderr, "			  [ master DEVICE ]\n");
 	fprintf(stderr, "			  [ nomaster ]\n");
 	fprintf(stderr, "       ip link show [ DEVICE | group GROUP ] [up]\n");
@@ -255,6 +256,19 @@ static int iplink_parse_vf(int vf, int *argcp, char ***argvp,
 			ivs.vf = vf;
 			addattr_l(&req->n, sizeof(*req), IFLA_VF_SPOOFCHK, &ivs, sizeof(ivs));
 
+		} else if (matches(*argv, "state") == 0) {
+			struct ifla_vf_link_state ivl;
+			NEXT_ARG();
+			if (matches(*argv, "auto") == 0)
+				ivl.link_state = IFLA_VF_LINK_STATE_AUTO;
+			else if (matches(*argv, "enable") == 0)
+				ivl.link_state = IFLA_VF_LINK_STATE_ENABLE;
+			else if (matches(*argv, "disable") == 0)
+				ivl.link_state = IFLA_VF_LINK_STATE_DISABLE;
+			else
+				invarg("Invalid \"state\" value\n", *argv);
+			ivl.vf = vf;
+			addattr_l(&req->n, sizeof(*req), IFLA_VF_LINK_STATE, &ivl, sizeof(ivl));
 		} else {
 			/* rewind arg */
 			PREV_ARG();
-- 
1.7.1
