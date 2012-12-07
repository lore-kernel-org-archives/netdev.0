From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: Re: [RFC PATCH] af_packet: don't to defrag shared skb
Date: Fri, 07 Dec 2012 23:12:43 +0100
Message-ID: <1354918363.9124.29.camel@jlt4.sipsolutions.net>
References: <1354906561-4695-1-git-send-email-eric@regit.org>
	 <20121207.153134.25835204617509469.davem@davemloft.net>
	 <1354915824.9124.11.camel@jlt4.sipsolutions.net>
	 (sfid-20121207_223020_561049_DB965D43) <1354916502.9124.18.camel@jlt4.sipsolutions.net>
	 (sfid-20121207_224129_500056_6617D80D)
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: eric-EVVnsjFE0OfYtjvyW6yDsg@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org,
	Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1354916502.9124.18.camel-8Nb76shvtaUJvtFkdXX2HixXY32XiHfO@public.gmane.org> (sfid-20121207_224129_500056_6617D80D)
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, 2012-12-07 at 22:41 +0100, Johannes Berg wrote:

> wpa_supplicant opens a packet socket for ETH_P_EAPOL, which indirectly
> eventually calls dev_add_pack(). But if you do the same for another
> socket, you'll get the same again, and then deliver_skb() will deliver
> only a refcounted packet to the prot_hook->func().
> 
> This seems like it could very well cause the problem?

Ok I couldn't reproduce it because suricata didn't work this way, but I
did try using tcpdump (without the fanout) and deliver_skb() *is* called
twice for each packet as I thought. It thus seems the problem is
entirely in af_packet itself. It was changed a bit by Eric Dumazet in
bc416d9768 but the original code goes back to the original defrag
support in 7736d33f4, as far as I can tell. aec27311c changed the code
to not do skb_clone(), but it seems the skb_share_check() should be
before the pskb_pull().

Well, it seems ip_check_defrag() should simply not modify the SKB before
it unshares it ... like this maybe:

diff --git a/net/ipv4/ip_fragment.c b/net/ipv4/ip_fragment.c
index 448e685..8d5cc75 100644
--- a/net/ipv4/ip_fragment.c
+++ b/net/ipv4/ip_fragment.c
@@ -707,28 +707,27 @@ EXPORT_SYMBOL(ip_defrag);
 
 struct sk_buff *ip_check_defrag(struct sk_buff *skb, u32 user)
 {
-	const struct iphdr *iph;
+	struct iphdr iph;
 	u32 len;
 
 	if (skb->protocol != htons(ETH_P_IP))
 		return skb;
 
-	if (!pskb_may_pull(skb, sizeof(struct iphdr)))
+	if (!skb_copy_bits(skb, 0, &iph, sizeof(iph)))
 		return skb;
 
-	iph = ip_hdr(skb);
-	if (iph->ihl < 5 || iph->version != 4)
+	if (iph.ihl < 5 || iph.version != 4)
 		return skb;
-	if (!pskb_may_pull(skb, iph->ihl*4))
-		return skb;
-	iph = ip_hdr(skb);
-	len = ntohs(iph->tot_len);
-	if (skb->len < len || len < (iph->ihl * 4))
+
+	len = ntohs(iph.tot_len);
+	if (skb->len < len || len < (iph.ihl * 4))
 		return skb;
 
-	if (ip_is_fragment(ip_hdr(skb))) {
+	if (ip_is_fragment(&iph)) {
 		skb = skb_share_check(skb, GFP_ATOMIC);
 		if (skb) {
+			if (!pskb_may_pull(skb, iph.ihl*4))
+				return skb;
 			if (pskb_trim_rcsum(skb, len))
 				return skb;
 			memset(IPCB(skb), 0, sizeof(struct inet_skb_parm));

johannes

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
