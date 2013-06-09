From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH iproute2 3/3] Add VF link state control
Date: Sun,  9 Jun 2013 16:14:27 +0300
Message-ID: <1370783667-19457-4-git-send-email-ogerlitz@mellanox.com>
References: <1370783667-19457-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, amirv@mellanox.com, ronye@mellanox.com,
	Or Gerlitz <ogerlitz@mellanox.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:40441 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752296Ab3FINNP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 9 Jun 2013 09:13:15 -0400
In-Reply-To: <1370783667-19457-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rony Efraim <ronye@mellanox.com>

Add link state per VF command

Signed-off-by: Rony Efraim <ronye@mellanox.com>
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 include/linux/if_link.h |   13 +++++++++++++
 ip/iplink.c             |   14 ++++++++++++++
 2 files changed, 27 insertions(+), 0 deletions(-)

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
