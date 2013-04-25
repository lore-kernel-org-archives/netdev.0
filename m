From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH net-next v3 1/4] packet_diag: disclose uid value
Date: Thu, 25 Apr 2013 15:21:48 +0200
Message-ID: <1366896111-4436-2-git-send-email-nicolas.dichtel@6wind.com>
References: <20130425.050008.2129680886418162075.davem@davemloft.net>
 <1366896111-4436-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: xiyou.wangcong@gmail.com, eric.dumazet@gmail.com,
	netdev@vger.kernel.org, Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:56284 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755924Ab3DYNV7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Apr 2013 09:21:59 -0400
In-Reply-To: <1366896111-4436-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This value is disclosed via /proc/net/packet but not via netlink messages.
The goal is to have the same level of information.

Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 include/uapi/linux/packet_diag.h |  1 +
 net/packet/diag.c                | 19 ++++++++++++++-----
 2 files changed, 15 insertions(+), 5 deletions(-)

diff --git a/include/uapi/linux/packet_diag.h b/include/uapi/linux/packet_diag.h
index afafd70..84f83a4 100644
--- a/include/uapi/linux/packet_diag.h
+++ b/include/uapi/linux/packet_diag.h
@@ -32,6 +32,7 @@ enum {
 	PACKET_DIAG_RX_RING,
 	PACKET_DIAG_TX_RING,
 	PACKET_DIAG_FANOUT,
+	PACKET_DIAG_UID,
 
 	__PACKET_DIAG_MAX,
 };
diff --git a/net/packet/diag.c b/net/packet/diag.c
index d3fcd1e..04c8219 100644
--- a/net/packet/diag.c
+++ b/net/packet/diag.c
@@ -125,8 +125,10 @@ static int pdiag_put_fanout(struct packet_sock *po, struct sk_buff *nlskb)
 	return ret;
 }
 
-static int sk_diag_fill(struct sock *sk, struct sk_buff *skb, struct packet_diag_req *req,
-		u32 portid, u32 seq, u32 flags, int sk_ino)
+static int sk_diag_fill(struct sock *sk, struct sk_buff *skb,
+			struct packet_diag_req *req,
+			struct user_namespace *user_ns,
+			u32 portid, u32 seq, u32 flags, int sk_ino)
 {
 	struct nlmsghdr *nlh;
 	struct packet_diag_msg *rp;
@@ -147,6 +149,11 @@ static int sk_diag_fill(struct sock *sk, struct sk_buff *skb, struct packet_diag
 			pdiag_put_info(po, skb))
 		goto out_nlmsg_trim;
 
+	if ((req->pdiag_show & PACKET_SHOW_INFO) &&
+	    nla_put_u32(skb, PACKET_DIAG_UID,
+			from_kuid_munged(user_ns, sock_i_uid(sk))))
+		goto out_nlmsg_trim;
+
 	if ((req->pdiag_show & PACKET_SHOW_MCLIST) &&
 			pdiag_put_mclist(po, skb))
 		goto out_nlmsg_trim;
@@ -183,9 +190,11 @@ static int packet_diag_dump(struct sk_buff *skb, struct netlink_callback *cb)
 		if (num < s_num)
 			goto next;
 
-		if (sk_diag_fill(sk, skb, req, NETLINK_CB(cb->skb).portid,
-					cb->nlh->nlmsg_seq, NLM_F_MULTI,
-					sock_i_ino(sk)) < 0)
+		if (sk_diag_fill(sk, skb, req,
+				 sk_user_ns(NETLINK_CB(cb->skb).sk),
+				 NETLINK_CB(cb->skb).portid,
+				 cb->nlh->nlmsg_seq, NLM_F_MULTI,
+				 sock_i_ino(sk)) < 0)
 			goto done;
 next:
 		num++;
-- 
1.8.2.1
