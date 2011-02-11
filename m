From: David Miller <davem@davemloft.net>
Subject: Re: GRO/GSO hiding PMTU?
Date: Thu, 10 Feb 2011 22:35:44 -0800 (PST)
Message-ID: <20110210.223544.189709102.davem@davemloft.net>
References: <20110210.145555.39165146.davem@davemloft.net>
	<20110210235022.GA25293@gondor.apana.org.au>
	<20110210.222216.104050992.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20110210.222216.104050992.davem@davemloft.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: David Miller <davem@davemloft.net>
Date: Thu, 10 Feb 2011 22:22:16 -0800 (PST)

> I gave it a shot but it isn't easy.  We can figure out the length of
> the IP headers just fine, but the rest of the value we need to add
> to the MSS (the TCP header length) is transport specific which kind
> of implies a transport dependent gso proto op of some sort.
> 
> Or we just hack it, admit that only TCP creates GSO packets, and
> directly check for TCP protcol and then inspect the TCP header
> length :-)

Herbert how does this look for now?

Of course, we need to do something similar in all kinds of other spots.

Even places like bridging :-/

--------------------
ipv4: Check MSS properly in ip_forward() GSO check.

When we forward packets we decide whether we should send
a frag-needed ICMP back based upon the skb length.

But if this is a GSO packet, we wholesale elide the length
check entirely.

This is wrong, we do have to check things.  Except that the
length validation in this case is not straighforward.

We have to take the gso_size (which is the MSS) and add in
the IP and TCP header to arrive at the length we should use
to compare against the MTU.

Signed-off-by: David S. Miller <davem@davemloft.net>

diff --git a/net/ipv4/ip_forward.c b/net/ipv4/ip_forward.c
index 99461f0..7449890 100644
--- a/net/ipv4/ip_forward.c
+++ b/net/ipv4/ip_forward.c
@@ -51,6 +51,36 @@ static int ip_forward_finish(struct sk_buff *skb)
 	return dst_output(skb);
 }
 
+static bool send_frag_needed(struct sk_buff *skb, struct rtable *rt)
+{
+	unsigned int len_to_check = skb->len;
+
+	if (skb_is_gso(skb)) {
+		unsigned int gso_size = skb_shinfo(skb)->gso_size;
+		unsigned int ihl = ip_hdr(skb)->ihl * 4;
+		struct tcphdr th_stack, *th;
+
+		if (WARN_ON_ONCE(ip_hdr(skb)->protocol != IPPROTO_TCP))
+			return false;
+
+		th = skb_header_pointer(skb, ihl, sizeof(th_stack),
+					&th_stack);
+		if (!th)
+			return false;
+
+		len_to_check = gso_size + ihl + (th->doff * 4);
+	}
+
+	if (len_to_check <= dst_mtu(&rt->dst))
+		return false;
+	if (!(ip_hdr(skb)->frag_off & htons(IP_DF)))
+		return false;
+	if (skb->local_df)
+		return false;
+
+	return true;
+}
+
 int ip_forward(struct sk_buff *skb)
 {
 	struct iphdr *iph;	/* Our header */
@@ -87,8 +117,7 @@ int ip_forward(struct sk_buff *skb)
 	if (opt->is_strictroute && rt->rt_dst != rt->rt_gateway)
 		goto sr_failed;
 
-	if (unlikely(skb->len > dst_mtu(&rt->dst) && !skb_is_gso(skb) &&
-		     (ip_hdr(skb)->frag_off & htons(IP_DF))) && !skb->local_df) {
+	if (unlikely(send_frag_needed(skb, rt))) {
 		IP_INC_STATS(dev_net(rt->dst.dev), IPSTATS_MIB_FRAGFAILS);
 		icmp_send(skb, ICMP_DEST_UNREACH, ICMP_FRAG_NEEDED,
 			  htonl(dst_mtu(&rt->dst)));
