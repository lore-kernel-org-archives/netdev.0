From: Martin KaFai Lau <kafai@fb.com>
Subject: [PATCH net v2] tcp: Force updating pcount after skb_pull() during mtu probing
Date: Fri, 5 Jun 2015 17:46:32 -0700
Message-ID: <1433551592-3596877-1-git-send-email-kafai@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Kernel Team <kernel-team@fb.com>, Grant Zhang <gzhang@fastly.com>,
	Eric Dumazet <edumazet@google.com>,
	Neal Cardwell <ncardwell@google.com>,
	Yuchung Cheng <ycheng@google.com>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:45339 "EHLO
	mx0b-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751948AbbFFAqh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Jun 2015 20:46:37 -0400
Received: from pps.filterd (m0004077 [127.0.0.1])
	by mx0b-00082601.pphosted.com (8.14.5/8.14.5) with SMTP id t560iAtq013691
	for <netdev@vger.kernel.org>; Fri, 5 Jun 2015 17:46:36 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0b-00082601.pphosted.com with ESMTP id 1uuns1043g-1
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Fri, 05 Jun 2015 17:46:36 -0700
Received: from facebook.com (2401:db00:20:7029:face:0:33:0)	by
 mx-out.facebook.com (10.223.100.97) with ESMTP	id
 7a58cbb60be511e5ab8d24be0593f280-f82da2a0 for <netdev@vger.kernel.org>;	Fri,
 05 Jun 2015 17:46:33 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The problem is caught by this WARN_ON(len > skb->len) in tcp_fragment():

[<ffffffff810510ca>] warn_slowpath_null+0x1a/0x20
[<ffffffff8160ec90>] tcp_fragment+0x2a0/0x2b0
[<ffffffff81604e06>] tcp_mark_head_lost+0x196/0x230
[<ffffffff8160585d>] tcp_update_scoreboard+0x4d/0x80
[<ffffffff8160a9ac>] tcp_fastretrans_alert+0x6ac/0xa90
[<ffffffff8160b834>] tcp_ack+0x9d4/0x10e0
[<ffffffff8160c699>] tcp_rcv_established+0x309/0x7e0

The WARN_ON pointed out that tcp_skb_pcount (i.e.
TCP_SKB_CB(skb)->tcp_gso_segs) and skb->len is inconsistent.

The WARN_ON stack goes away after setting net.ipv4.tcp_mtu_probing to 0.

v2
- Replace the skb slicing codes by the existing tcp_trim_head(),
  suggested by Eric Dumazet.

v1
- Call tcp_set_skb_tso_segs() for all slicing cases.

Signed-off-by: Martin KaFai Lau <kafai@fb.com>
Reported-by: Grant Zhang <gzhang@fastly.com>
Cc: Grant Zhang <gzhang@fastly.com>
Cc: Eric Dumazet <edumazet@google.com>
Cc: Neal Cardwell <ncardwell@google.com>
Cc: Yuchung Cheng <ycheng@google.com>
---
 net/ipv4/tcp_output.c | 12 ++----------
 1 file changed, 2 insertions(+), 10 deletions(-)

diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index a369e8a..4ae4f0c 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -1977,16 +1977,8 @@ static int tcp_mtu_probe(struct sock *sk)
 		} else {
 			TCP_SKB_CB(nskb)->tcp_flags |= TCP_SKB_CB(skb)->tcp_flags &
 						   ~(TCPHDR_FIN|TCPHDR_PSH);
-			if (!skb_shinfo(skb)->nr_frags) {
-				skb_pull(skb, copy);
-				if (skb->ip_summed != CHECKSUM_PARTIAL)
-					skb->csum = csum_partial(skb->data,
-								 skb->len, 0);
-			} else {
-				__pskb_trim_head(skb, copy);
-				tcp_set_skb_tso_segs(sk, skb, mss_now);
-			}
-			TCP_SKB_CB(skb)->seq += copy;
+			tcp_skb_pcount_set(skb, 0);
+			tcp_trim_head(sk, skb, copy);
 		}
 
 		len += copy;
-- 
1.8.1
