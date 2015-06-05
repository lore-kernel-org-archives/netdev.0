From: Martin KaFai Lau <kafai@fb.com>
Subject: [RFC PATCH net] tcp: Update pcount after skb_pull() during mtu probing
Date: Fri, 5 Jun 2015 09:16:54 -0700
Message-ID: <1433521014-2465771-1-git-send-email-kafai@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Kernel Team <kernel-team@fb.com>,
	Eric Dumazet <edumazet@google.com>,
	Neal Cardwell <ncardwell@google.com>,
	Yuchung Cheng <ycheng@google.com>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:9409 "EHLO
	mx0b-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751376AbbFEQQ5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Jun 2015 12:16:57 -0400
Received: from pps.filterd (m0004060 [127.0.0.1])
	by mx0b-00082601.pphosted.com (8.14.5/8.14.5) with SMTP id t55GFl9A027086
	for <netdev@vger.kernel.org>; Fri, 5 Jun 2015 09:16:56 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0b-00082601.pphosted.com with ESMTP id 1uubf1rta4-1
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Fri, 05 Jun 2015 09:16:56 -0700
Received: from facebook.com (2401:db00:20:7029:face:0:33:0)	by
 mx-out.facebook.com (10.212.232.63) with ESMTP	id
 4825c6540b9e11e592b70002c992ebde-6d4d52a0 for <netdev@vger.kernel.org>;	Fri,
 05 Jun 2015 09:16:54 -0700
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

This patch is to set the pcount after skb_pull() was called
in tcp_mtu_probe().

Signed-off-by: Martin KaFai Lau <kafai@fb.com>
Reported-by: Grant Zhang <gzhang@fastly.com>
Cc: Eric Dumazet <edumazet@google.com>
Cc: Neal Cardwell <ncardwell@google.com>
Cc: Yuchung Cheng <ycheng@google.com>
---
 net/ipv4/tcp_output.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index a369e8a..6c95c28 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -1984,8 +1984,9 @@ static int tcp_mtu_probe(struct sock *sk)
 								 skb->len, 0);
 			} else {
 				__pskb_trim_head(skb, copy);
-				tcp_set_skb_tso_segs(sk, skb, mss_now);
 			}
+			tcp_set_skb_tso_segs(sk, skb, mss_now);
+
 			TCP_SKB_CB(skb)->seq += copy;
 		}
 
-- 
1.8.1
