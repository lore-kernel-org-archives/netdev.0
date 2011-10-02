From: "Yan, Zheng" <zheng.z.yan@intel.com>
Subject: [PATCH v3] tcp: properly update lost_cnt_hint during shifting
Date: Sun, 02 Oct 2011 22:21:50 +0800
Message-ID: <4E88737E.5030906@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	=?ISO-8859-1?Q?Ilpo_J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>,
	Nandita Dukkipati <nanditad@google.com>, ycheng@google.com,
	"davem@dav
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:44977 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752590Ab1JBOWF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 2 Oct 2011 10:22:05 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

lost_skb_hint is used by tcp_mark_head_lost() to mark the first unhandled skb.
lost_cnt_hint is the number of packets or sacked packets before the lost_skb_hint;
When shifting a skb that is before the lost_skb_hint, if tcp_is_fack() is ture,
the skb has already been counted in the lost_cnt_hint; if tcp_is_fack() is false,
tcp_sacktag_one() will increase the lost_cnt_hint. So tcp_shifted_skb() does not
need to adjust the lost_cnt_hint by itself. When shifting a skb that is equal to
lost_skb_hint, the shifted packets will not be counted by tcp_mark_head_lost().
So tcp_shifted_skb() should adjust the lost_cnt_hint even tcp_is_fack(tp) is true.

Signed-off-by: Zheng Yan <zheng.z.yan@intel.com>
---
Changes since v2:
 adjust the lost_cnt_hint even tcp_is_fack(tp) is true.

 net/ipv4/tcp_input.c |    4 +---
 1 files changed, 1 insertions(+), 3 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 21fab3e..d73aab3 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -1389,9 +1389,7 @@ static int tcp_shifted_skb(struct sock *sk, struct sk_buff *skb,
 
 	BUG_ON(!pcount);
 
-	/* Tweak before seqno plays */
-	if (!tcp_is_fack(tp) && tcp_is_sack(tp) && tp->lost_skb_hint &&
-	    !before(TCP_SKB_CB(tp->lost_skb_hint)->seq, TCP_SKB_CB(skb)->seq))
+	if (skb == tp->lost_skb_hint)
 		tp->lost_cnt_hint += pcount;
 
 	TCP_SKB_CB(prev)->end_seq += shifted;
-- 
1.7.4.4
