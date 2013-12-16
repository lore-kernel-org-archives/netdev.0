From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH net] net: inet_diag: zero out uninitialized idiag_{src,dst} fields
Date: Tue, 17 Dec 2013 00:38:39 +0100
Message-ID: <1387237119-10780-1-git-send-email-dborkman@redhat.com>
Cc: darkjames-ws@darkjames.pl, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:34739 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750866Ab3LPXip (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 16 Dec 2013 18:38:45 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jakub reported while working with nlmon netlink sniffer that parts of
the inet_diag_sockid are not initialized when r->idiag_family != AF_INET6.
That is, fields of r->id.idiag_src[1 ... 3], r->id.idiag_dst[1 ... 3].

In fact, it seems that we can leak 6 * sizeof(u32) byte of kernel [slab]
memory through this. At least, in udp_dump_one(), we allocate a skb in ...

  rep = nlmsg_new(sizeof(struct inet_diag_msg) + ..., GFP_KERNEL);

... and then pass that to inet_sk_diag_fill() that puts the whole struct
inet_diag_msg into the skb, where we only fill out r->id.idiag_src[0],
r->id.idiag_dst[0] and leave the rest untouched:

  r->id.idiag_src[0] = inet->inet_rcv_saddr;
  r->id.idiag_dst[0] = inet->inet_daddr;

struct inet_diag_msg embeds struct inet_diag_sockid that is correctly /
fully filled out in IPv6 case, but for IPv4 not.

So just zero them out by using plain memset (for this little amount of
bytes it's probably not worth the extra check for idiag_family == AF_INET).

Similarly, fix also other places where we fill that out.

Reported-by: Jakub Zawadzki <darkjames-ws@darkjames.pl>
Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
---
 net/ipv4/inet_diag.c | 16 ++++++++++++++++
 1 file changed, 16 insertions(+)

diff --git a/net/ipv4/inet_diag.c b/net/ipv4/inet_diag.c
index 56a964a..a0f52da 100644
--- a/net/ipv4/inet_diag.c
+++ b/net/ipv4/inet_diag.c
@@ -106,6 +106,10 @@ int inet_sk_diag_fill(struct sock *sk, struct inet_connection_sock *icsk,
 
 	r->id.idiag_sport = inet->inet_sport;
 	r->id.idiag_dport = inet->inet_dport;
+
+	memset(&r->id.idiag_src, 0, sizeof(r->id.idiag_src));
+	memset(&r->id.idiag_dst, 0, sizeof(r->id.idiag_dst));
+
 	r->id.idiag_src[0] = inet->inet_rcv_saddr;
 	r->id.idiag_dst[0] = inet->inet_daddr;
 
@@ -240,12 +244,19 @@ static int inet_twsk_diag_fill(struct inet_timewait_sock *tw,
 
 	r->idiag_family	      = tw->tw_family;
 	r->idiag_retrans      = 0;
+
 	r->id.idiag_if	      = tw->tw_bound_dev_if;
 	sock_diag_save_cookie(tw, r->id.idiag_cookie);
+
 	r->id.idiag_sport     = tw->tw_sport;
 	r->id.idiag_dport     = tw->tw_dport;
+
+	memset(&r->id.idiag_src, 0, sizeof(r->id.idiag_src));
+	memset(&r->id.idiag_dst, 0, sizeof(r->id.idiag_dst));
+
 	r->id.idiag_src[0]    = tw->tw_rcv_saddr;
 	r->id.idiag_dst[0]    = tw->tw_daddr;
+
 	r->idiag_state	      = tw->tw_substate;
 	r->idiag_timer	      = 3;
 	r->idiag_expires      = jiffies_to_msecs(tmo);
@@ -726,8 +737,13 @@ static int inet_diag_fill_req(struct sk_buff *skb, struct sock *sk,
 
 	r->id.idiag_sport = inet->inet_sport;
 	r->id.idiag_dport = ireq->ir_rmt_port;
+
+	memset(&r->id.idiag_src, 0, sizeof(r->id.idiag_src));
+	memset(&r->id.idiag_dst, 0, sizeof(r->id.idiag_dst));
+
 	r->id.idiag_src[0] = ireq->ir_loc_addr;
 	r->id.idiag_dst[0] = ireq->ir_rmt_addr;
+
 	r->idiag_expires = jiffies_to_msecs(tmo);
 	r->idiag_rqueue = 0;
 	r->idiag_wqueue = 0;
-- 
1.8.3.1
