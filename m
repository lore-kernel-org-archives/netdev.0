From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Bonding driver has bad load balancing for forwarded traffic,
 3.7+
Date: Mon, 15 Apr 2013 17:37:59 -0700
Message-ID: <1366072679.4459.113.camel@edumazet-glaptop>
References: <516C075E.30105@telenet.dn.ua>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev <netdev@vger.kernel.org>
To: "Vitaly V. Bursov" <vitalyb@telenet.dn.ua>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <516C075E.30105@telenet.dn.ua>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2013-04-15 at 16:57 +0300, Vitaly V. Bursov wrote:
> Hello,
> 
> I have a bonding device (mode=802.3ad xmit_hash_policy=layer2+3 miimon=300) and
> for kernels <3.7 forwarded IPv4 traffic distributed fine across multiple physical
> links. Ethernet cards are Intel 82576 with igb driver (various versions).
> 
> 3.7 and 3.8 kernels tend to fully utilize only one link and leave the others almost idling.
> 
> Replacing bond_xmit_hash_policy_* functions with older ones (3.6 kernel) looks like
> resolves the issue (but I haven't tested it thoroughly).
> 
> So, I added
>          printk(KERN_INFO "hash_policy: protocol = %d, skb_network_header_len = %d, %d %d\n",
>              skb->protocol, skb_network_header_len(skb),
>              skb_headlen(skb), skb_network_offset(skb));
> to bond_xmit_hash_policy_l23() of bond_main.c
> 
> and got this:
> [   65.280831] hash_policy: protocol = 8, skb_network_header_len = 0, 74 14
> [   65.280835] hash_policy: protocol = 8, skb_network_header_len = 0, 74 14
> [   65.280839] hash_policy: protocol = 8, skb_network_header_len = 0, 74 14
> [   65.280843] hash_policy: protocol = 8, skb_network_header_len = 0, 74 14
> [   65.280847] hash_policy: protocol = 8, skb_network_header_len = 0, 74 14
> [   65.280851] hash_policy: protocol = 8, skb_network_header_len = 0, 74 14
> 
> It's clear that the new check condition (skb_network_header_len(skb) >= sizeof(*iph))
> fails here and hash policy fallbacks to l2 balancing.
> 
> I have no idea how to fix this besides removing this check completely, any
> help would be appreciated.
> 

Thanks for your report.

CC netdev

I guess that for forwarding setup, we don't set skb->transport_header

Please try following fix :

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 07401a3..356d2f9 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -3286,20 +3286,22 @@ static int bond_xmit_hash_policy_l2(struct sk_buff *skb, int count)
  */
 static int bond_xmit_hash_policy_l23(struct sk_buff *skb, int count)
 {
-	struct ethhdr *data = (struct ethhdr *)skb->data;
-	struct iphdr *iph;
-	struct ipv6hdr *ipv6h;
+	const struct ethhdr *data;
+	const struct iphdr *iph;
+	const struct ipv6hdr *ipv6h;
 	u32 v6hash;
-	__be32 *s, *d;
+	const __be32 *s, *d;
 
 	if (skb->protocol == htons(ETH_P_IP) &&
-	    skb_network_header_len(skb) >= sizeof(*iph)) {
+	    pskb_network_may_pull(skb, sizeof(*iph))) {
 		iph = ip_hdr(skb);
+		data = (struct ethhdr *)skb->data;
 		return ((ntohl(iph->saddr ^ iph->daddr) & 0xffff) ^
 			(data->h_dest[5] ^ data->h_source[5])) % count;
 	} else if (skb->protocol == htons(ETH_P_IPV6) &&
-		   skb_network_header_len(skb) >= sizeof(*ipv6h)) {
+		   pskb_network_may_pull(skb, sizeof(*ipv6h))) {
 		ipv6h = ipv6_hdr(skb);
+		data = (struct ethhdr *)skb->data;
 		s = &ipv6h->saddr.s6_addr32[0];
 		d = &ipv6h->daddr.s6_addr32[0];
 		v6hash = (s[1] ^ d[1]) ^ (s[2] ^ d[2]) ^ (s[3] ^ d[3]);
