From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net] macvtap: make sure neighbour code can push ethernet
 header
Date: Fri, 27 Feb 2015 18:35:35 -0800
Message-ID: <1425090935.5130.74.camel@edumazet-glaptop2.roam.corp.google.com>
References: <54F0E38C.5060203@vultr.com>
	 <1425084533.5130.54.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1425086169.5130.57.camel@edumazet-glaptop2.roam.corp.google.com>
	 <54F11FC8.7010100@vultr.com>
	 <1425088894.5130.60.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1425089025.5130.61.camel@edumazet-glaptop2.roam.corp.google.com>
	 <54F123C4.2030907@vultr.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Brian Rak <brak@vultr.com>, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f181.google.com ([209.85.213.181]:40235 "EHLO
	mail-ig0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750752AbbB1Cfi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Feb 2015 21:35:38 -0500
Received: by igal13 with SMTP id l13so5213825iga.5
        for <netdev@vger.kernel.org>; Fri, 27 Feb 2015 18:35:37 -0800 (PST)
In-Reply-To: <54F123C4.2030907@vultr.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Brian reported crashes using IPv6 traffic with macvtap/veth combo.

I tracked the crashes in neigh_hh_output()

-> memcpy(skb->data - HH_DATA_MOD, hh->hh_data, HH_DATA_MOD);

Neighbour code assumes headroom to push Ethernet header is
at least 16 bytes.

It appears macvtap has only 14 bytes available on arches
where NET_IP_ALIGN is 0 (like x86)

Effect is a corruption of 2 bytes right before skb->head,
and possible crashes if accessing non existing memory.

This fix should also increase IPv4 performance, as paranoid code
in ip_finish_output2() wont have to call skb_realloc_headroom()

Reported-by: Brian Rak <brak@vultr.com>
Tested-by: Brian Rak <brak@vultr.com>
Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 drivers/net/macvtap.c |    7 +++++--
 1 file changed, 5 insertions(+), 2 deletions(-)

diff --git a/drivers/net/macvtap.c b/drivers/net/macvtap.c
index e40fdfccc9c10df4ea8676a1dd59275d5d9c6b88..27ecc5c4fa2665cd42ac1ca81717255f85507113 100644
--- a/drivers/net/macvtap.c
+++ b/drivers/net/macvtap.c
@@ -654,11 +654,14 @@ static void macvtap_skb_to_vnet_hdr(struct macvtap_queue *q,
 	} /* else everything is zero */
 }
 
+/* Neighbour code has some assumptions on HH_DATA_MOD alignment */
+#define MACVTAP_RESERVE HH_DATA_OFF(ETH_HLEN)
+
 /* Get packet from user space buffer */
 static ssize_t macvtap_get_user(struct macvtap_queue *q, struct msghdr *m,
 				struct iov_iter *from, int noblock)
 {
-	int good_linear = SKB_MAX_HEAD(NET_IP_ALIGN);
+	int good_linear = SKB_MAX_HEAD(MACVTAP_RESERVE);
 	struct sk_buff *skb;
 	struct macvlan_dev *vlan;
 	unsigned long total_len = iov_iter_count(from);
@@ -722,7 +725,7 @@ static ssize_t macvtap_get_user(struct macvtap_queue *q, struct msghdr *m,
 			linear = macvtap16_to_cpu(q, vnet_hdr.hdr_len);
 	}
 
-	skb = macvtap_alloc_skb(&q->sk, NET_IP_ALIGN, copylen,
+	skb = macvtap_alloc_skb(&q->sk, MACVTAP_RESERVE, copylen,
 				linear, noblock, &err);
 	if (!skb)
 		goto err;
