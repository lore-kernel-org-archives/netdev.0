From: Octavian Purdila <opurdila@ixiacom.com>
Subject: [net-next PATCH v2 2/9] llc: add support for LLC_OPT_PKTINFO
Date: Thu, 24 Dec 2009 01:45:27 +0200
Message-ID: <1261611934-24348-3-git-send-email-opurdila@ixiacom.com>
References: <1261611934-24348-1-git-send-email-opurdila@ixiacom.com>
Cc: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Octavian Purdila <opurdila@ixiacom.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ixro-out-rtc.ixiacom.com ([92.87.192.98]:23684 "EHLO
	ixro-ex1.ixiacom.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1757542AbZLWXs4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Dec 2009 18:48:56 -0500
In-Reply-To: <1261611934-24348-1-git-send-email-opurdila@ixiacom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Octavian Purdila <opurdila@ixiacom.com>
---
 include/linux/llc.h    |    7 +++++++
 include/net/llc_conn.h |    1 +
 net/llc/af_llc.c       |   29 +++++++++++++++++++++++++++++
 3 files changed, 37 insertions(+), 0 deletions(-)

diff --git a/include/linux/llc.h b/include/linux/llc.h
index 7733585..ad7074b 100644
--- a/include/linux/llc.h
+++ b/include/linux/llc.h
@@ -36,6 +36,7 @@ enum llc_sockopts {
 	LLC_OPT_BUSY_TMR_EXP,	/* busy state expire time (secs). */
 	LLC_OPT_TX_WIN,		/* tx window size. */
 	LLC_OPT_RX_WIN,		/* rx window size. */
+	LLC_OPT_PKTINFO,	/* ancillary packet information. */
 	LLC_OPT_MAX
 };
 
@@ -70,6 +71,12 @@ enum llc_sockopts {
 #define LLC_SAP_RM	0xD4		/* Resource Management 		*/
 #define LLC_SAP_GLOBAL	0xFF		/* Global SAP. 			*/
 
+struct llc_pktinfo {
+	int lpi_ifindex;
+	unsigned char lpi_sap;
+	unsigned char lpi_mac[IFHWADDRLEN];
+};
+
 #ifdef __KERNEL__
 #define LLC_SAP_DYN_START	0xC0
 #define LLC_SAP_DYN_STOP	0xDE
diff --git a/include/net/llc_conn.h b/include/net/llc_conn.h
index e2374e3..fe982fd 100644
--- a/include/net/llc_conn.h
+++ b/include/net/llc_conn.h
@@ -76,6 +76,7 @@ struct llc_sock {
 	u32		    rx_pdu_hdr;	   /* used for saving header of last pdu
 					      received and caused sending FRMR.
 					      Used for resending FRMR */
+	u32		    cmsg_flags;
 };
 
 static inline struct llc_sock *llc_sk(const struct sock *sk)
diff --git a/net/llc/af_llc.c b/net/llc/af_llc.c
index 3a66546..ac691fe 100644
--- a/net/llc/af_llc.c
+++ b/net/llc/af_llc.c
@@ -47,6 +47,10 @@ static int llc_ui_wait_for_busy_core(struct sock *sk, long timeout);
 #define dprintk(args...)
 #endif
 
+/* Maybe we'll add some more in the future. */
+#define LLC_CMSG_PKTINFO	1
+
+
 /**
  *	llc_ui_next_link_no - return the next unused link number for a sap
  *	@sap: Address of sap to get link number from.
@@ -591,6 +595,20 @@ static int llc_wait_data(struct sock *sk, long timeo)
 	return rc;
 }
 
+static void llc_cmsg_rcv(struct msghdr *msg, struct sk_buff *skb)
+{
+	struct llc_sock *llc = llc_sk(skb->sk);
+
+	if (llc->cmsg_flags & LLC_CMSG_PKTINFO) {
+		struct llc_pktinfo info;
+
+		info.lpi_ifindex = llc_sk(skb->sk)->dev->ifindex;
+		llc_pdu_decode_dsap(skb, &info.lpi_sap);
+		llc_pdu_decode_da(skb, info.lpi_mac);
+		put_cmsg(msg, SOL_LLC, LLC_OPT_PKTINFO, sizeof(info), &info);
+	}
+}
+
 /**
  *	llc_ui_accept - accept a new incoming connection.
  *	@sock: Socket which connections arrive on.
@@ -812,6 +830,8 @@ copy_uaddr:
 		memcpy(uaddr, llc_ui_skb_cb(skb), sizeof(*uaddr));
 		msg->msg_namelen = sizeof(*uaddr);
 	}
+	if (llc_sk(sk)->cmsg_flags)
+		llc_cmsg_rcv(msg, skb);
 	goto out;
 }
 
@@ -1030,6 +1050,12 @@ static int llc_ui_setsockopt(struct socket *sock, int level, int optname,
 			goto out;
 		llc->rw = opt;
 		break;
+	case LLC_OPT_PKTINFO:
+		if (opt)
+			llc->cmsg_flags |= LLC_CMSG_PKTINFO;
+		else
+			llc->cmsg_flags &= ~LLC_CMSG_PKTINFO;
+		break;
 	default:
 		rc = -ENOPROTOOPT;
 		goto out;
@@ -1083,6 +1109,9 @@ static int llc_ui_getsockopt(struct socket *sock, int level, int optname,
 		val = llc->k;				break;
 	case LLC_OPT_RX_WIN:
 		val = llc->rw;				break;
+	case LLC_OPT_PKTINFO:
+		val = (llc->cmsg_flags & LLC_CMSG_PKTINFO) != 0;
+		break;
 	default:
 		rc = -ENOPROTOOPT;
 		goto out;
-- 
1.5.6.5

