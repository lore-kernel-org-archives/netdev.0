From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] inet: restore gso for vxlan
Date: Sun, 27 Oct 2013 18:18:16 -0700
Message-ID: <1382923096.13037.10.camel@edumazet-glaptop.roam.corp.google.com>
References: <CAMEtUuzswOVA6UkPRjS-O=gOe9BLLJ5qaAG_eAd_fTqDJo8ofA@mail.gmail.com>
	 <1382674000.7572.75.camel@edumazet-glaptop.roam.corp.google.com>
	 <1382692140.7572.79.camel@edumazet-glaptop.roam.corp.google.com>
	 <20131025.181809.348808013109842304.davem@davemloft.net>
	 <CAMEtUuxwi05oX0TqNdMbjy04MT=ZLemLXJQTTcAMrnWuhXLKdQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Alexei Starovoitov <ast@plumgrid.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f49.google.com ([209.85.220.49]:59088 "EHLO
	mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754833Ab3J1BSR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 27 Oct 2013 21:18:17 -0400
Received: by mail-pa0-f49.google.com with SMTP id lj1so6427632pab.22
        for <netdev@vger.kernel.org>; Sun, 27 Oct 2013 18:18:16 -0700 (PDT)
In-Reply-To: <CAMEtUuxwi05oX0TqNdMbjy04MT=ZLemLXJQTTcAMrnWuhXLKdQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Alexei reported a performance regression on vxlan, caused
by commit 3347c9602955 "ipv4: gso: make inet_gso_segment() stackable"

GSO vxlan packets were not properly segmented, adding IP fragments
while they were not expected.

Rename 'bool tunnel' to 'bool encap', and add a new boolean
to express the fact that UDP should be fragmented.
This fragmentation is triggered by skb->encapsulation being set.

Remove a "skb->encapsulation = 1" added in above commit,
as its not needed, as frags inherit skb->frag from original
GSO skb.
 
Reported-by: Alexei Starovoitov <ast@plumgrid.com>
Signed-off-by: Eric Dumazet <edumazet@google.com>
Tested-by: Alexei Starovoitov <ast@plumgrid.com>
---
 net/ipv4/af_inet.c |   15 +++++++--------
 1 file changed, 7 insertions(+), 8 deletions(-)

diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index f4a159e705c0..09d78d4a3cff 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -1251,8 +1251,8 @@ static struct sk_buff *inet_gso_segment(struct sk_buff *skb,
 	struct sk_buff *segs = ERR_PTR(-EINVAL);
 	const struct net_offload *ops;
 	unsigned int offset = 0;
+	bool udpfrag, encap;
 	struct iphdr *iph;
-	bool tunnel;
 	int proto;
 	int nhoff;
 	int ihl;
@@ -1290,8 +1290,8 @@ static struct sk_buff *inet_gso_segment(struct sk_buff *skb,
 		goto out;
 	__skb_pull(skb, ihl);
 
-	tunnel = SKB_GSO_CB(skb)->encap_level > 0;
-	if (tunnel)
+	encap = SKB_GSO_CB(skb)->encap_level > 0;
+	if (encap)
 		features = skb->dev->hw_enc_features & netif_skb_features(skb);
 	SKB_GSO_CB(skb)->encap_level += ihl;
 
@@ -1306,24 +1306,23 @@ static struct sk_buff *inet_gso_segment(struct sk_buff *skb,
 	if (IS_ERR_OR_NULL(segs))
 		goto out;
 
+	udpfrag = !!skb->encapsulation && proto == IPPROTO_UDP;
 	skb = segs;
 	do {
 		iph = (struct iphdr *)(skb_mac_header(skb) + nhoff);
-		if (!tunnel && proto == IPPROTO_UDP) {
+		if (udpfrag) {
 			iph->id = htons(id);
 			iph->frag_off = htons(offset >> 3);
 			if (skb->next != NULL)
 				iph->frag_off |= htons(IP_MF);
 			offset += skb->len - nhoff - ihl;
-		} else  {
+		} else {
 			iph->id = htons(id++);
 		}
 		iph->tot_len = htons(skb->len - nhoff);
 		ip_send_check(iph);
-		if (tunnel) {
+		if (encap)
 			skb_reset_inner_headers(skb);
-			skb->encapsulation = 1;
-		}
 		skb->network_header = (u8 *)iph - skb->head;
 	} while ((skb = skb->next));
 
