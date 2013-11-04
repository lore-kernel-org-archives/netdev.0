From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net-next] ipv4: introduce new IP_MTU_DISCOVER mode IP_PMTUDISC_INTERFACE
Date: Tue, 5 Nov 2013 00:25:41 +0100
Message-ID: <20131104232541.GD8832@order.stressinduktion.org>
References: <20131030200725.GB9093@order.stressinduktion.org> <20131030.173608.2156276556221568210.davem@davemloft.net> <20131030225851.GB13902@order.stressinduktion.org> <20131031.002911.1316728367651608156.davem@davemloft.net> <20131031094226.GB17210@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
To: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	fweimer@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:49593 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750997Ab3KDXZn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Nov 2013 18:25:43 -0500
Content-Disposition: inline
In-Reply-To: <20131031094226.GB17210@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David!

On Thu, Oct 31, 2013 at 10:42:26AM +0100, Hannes Frederic Sowa wrote:
> On Thu, Oct 31, 2013 at 12:29:11AM -0400, David Miller wrote:
> > From: Hannes Frederic Sowa <hannes@stressinduktion.org>
> > Date: Wed, 30 Oct 2013 23:58:51 +0100
> > 
> > > DNS resolver can fallback to TCP for querying where we can honour the
> > > path MTU because it won't do any harm and ensures connectivity.
> > > 
> > > Also for TCP the socket is matched on the whole 4-tuple and we may
> > > fallback to a 2-tuple lookup on unconnected UDP sockets. The new socket
> > > option would let an application programmer choose to do path mtu discovery
> > > because it knows it will only use a connected socket. On unconnected
> > > sockets one can specify IP_PMTUDISC_INTERFACE to suppress the path MTU
> > > updates and always use the interface MTU without the DF-bit set.
> > 
> > This still sounds like a route scope policy with two binary states,
> > one for connected sockets and one for unconnected ones.
> 
> Orthogonally a user may want to decide per protocol. Path MTU discovery
> may happen on protocols where I have protection against fragment poisoning
> because of the TCP 3-WHS and want to drop path mtu discovery information
> on simple UDP request-response protocols even if they are used in
> connected state (this is the specific case I want to protect in DNS).
> 
> Do we accept path MTU information if we just send a spoofed TCP SYN
> request and then just fire a spoofed ICMP path mtu packet afterwards? I
> guess (I really have not checked), yes. If the UDP stack would use this
> information we again generate fragments and are vulnerable to UDP based
> cache poisoning attacks. So when can we really say we can match and
> trust the full socket ID?
> 
> Please note, dropping the path MTU on those sockets is merely an
> optimization.  All I care about is that we don't fragment packets locally
> and have the possibility to not set the DF-bit (so IP_PMTUDISC_PROBE
> without DF). I could very well remove the ip_sk_accept_pmtu logic from
> the patch.
> 
> I still think this patch is the reasonable way to solve this problem. If
> you still think it should be on a per-route basis I will look down on
> how this can be achieved but would focus on multiplexing the MTU per
> protocol somehow.

Sorry for being so pushy about this patch! :|

I did a proof of concept of a per-route setting to suppress local
datagram fragmentation. It does work and would solve the problem. I did
not find a clean way to deal with sockets already using IP_MTU_DISCOVER,
so I just overwrite the setting and fallback to the safe mode and don't
allow local fragmentation (but I don't touch the DF-flag). This could have
implications to applications which already set a policy for their sockets
and expect a certain behaviour (e.g. traceroute in some circumstances). I
don't like the approach, but I would like to see this problem solved. If
you would accept this patch I would retest and do a clean submission
(with the iproute2 bits) then. UI currently looks like this:

# ip r change default via 10.0.0.254 dgram_dont_local_frag 1

After all, I still think this should be a per-application/per-socket
setting because the application must deal with the fact that no local
fragmentation is possible so it has to be more sensitive to EMSGSIZE
errors. DNS has to negotiate the UDP buffer size with its peers already
(with the help of EDNS), so there is already logic to deal with the
size of fragments and so it should not be done transparently IMHO.

With the per-route setting DNS implementations can work around this by
querying the IP_MTU or handle the socket errors but I don't know about
other UDP applications on the same host. Everything is ok as long as
the DNS server is the only application on that system.

This is not the same as e.g. TCP_QUICKACK which can transparently be
dealt with by applications and thus makes sense to be a per-route
setting. Applications will see different behaviour when using
dgram_dont_frag. This really is no tuning parameter.

I also tried per-protocol path MTUs and abandoned the patch earlier
today. It got too complex and had problems with how to emulate a common
mtu for old iproutes.

Also, I would be happy to support this patch and the per-socket approach.

I would love to hear your feedback.

diff --git a/include/net/route.h b/include/net/route.h
index dd4ae00..3f6b04b 100644
--- a/include/net/route.h
+++ b/include/net/route.h
@@ -313,12 +313,23 @@ static inline int ip4_dst_hoplimit(const struct dst_entry *dst)
 	return hoplimit;
 }
 
+static inline bool ip_dgram_local_fragment(const struct dst_entry *dst,
+				      const struct sock *sk)
+{
+	if (sk->sk_protocol == IPPROTO_UDP &&
+	    dst_metric(dst, RTAX_DGRAM_DONT_LOCAL_FRAG))
+		return false;
+	return true;
+}
+
 static inline int ip_skb_dst_mtu(struct sk_buff *skb)
 {
 	struct inet_sock *inet = skb->sk ? inet_sk(skb->sk) : NULL;
+	struct dst_entry *dst = skb_dst(skb);
 
-	return (inet && inet->pmtudisc == IP_PMTUDISC_PROBE) ?
-	       skb_dst(skb)->dev->mtu : dst_mtu(skb_dst(skb));
+	return (inet && (inet->pmtudisc == IP_PMTUDISC_PROBE ||
+			 !ip_dgram_local_fragment(dst, skb->sk))) ?
+	       dst->dev->mtu : dst_mtu(dst);
 }
 
 #endif	/* _ROUTE_H */
diff --git a/include/uapi/linux/rtnetlink.h b/include/uapi/linux/rtnetlink.h
index eb0f1a5..2e450f3 100644
--- a/include/uapi/linux/rtnetlink.h
+++ b/include/uapi/linux/rtnetlink.h
@@ -388,6 +388,8 @@ enum {
 #define RTAX_INITRWND RTAX_INITRWND
 	RTAX_QUICKACK,
 #define RTAX_QUICKACK RTAX_QUICKACK
+	RTAX_DGRAM_DONT_LOCAL_FRAG,
+#define RTAX_DGRAM_DONT_LOCAL_FRAG RTAX_DGRAM_DONT_LOCAL_FRAG
 	__RTAX_MAX
 };
 
diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
index 51be64e..661c618 100644
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -823,7 +823,8 @@ static int __ip_append_data(struct sock *sk,
 
 	fragheaderlen = sizeof(struct iphdr) + (opt ? opt->optlen : 0);
 	maxfraglen = ((mtu - fragheaderlen) & ~7) + fragheaderlen;
-	maxnonfragsize = (inet->pmtudisc >= IP_PMTUDISC_DO) ?
+	maxnonfragsize = ((inet->pmtudisc >= IP_PMTUDISC_DO) ||
+			  !ip_dgram_local_fragment(&rt->dst, sk)) ?
 			 mtu : 0xFFFF;
 
 	if (cork->length + length > maxnonfragsize - fragheaderlen) {
@@ -1063,7 +1064,8 @@ static int ip_setup_cork(struct sock *sk, struct inet_cork *cork,
 	 * We steal reference to this route, caller should not release it
 	 */
 	*rtp = NULL;
-	cork->fragsize = inet->pmtudisc == IP_PMTUDISC_PROBE ?
+	cork->fragsize = ((inet->pmtudisc == IP_PMTUDISC_PROBE) ||
+			  !ip_dgram_local_fragment(&rt->dst, sk)) ?
 			 rt->dst.dev->mtu : dst_mtu(&rt->dst);
 	cork->dst = &rt->dst;
 	cork->length = 0;
@@ -1148,8 +1150,9 @@ ssize_t	ip_append_page(struct sock *sk, struct flowi4 *fl4, struct page *page,
 
 	fragheaderlen = sizeof(struct iphdr) + (opt ? opt->optlen : 0);
 	maxfraglen = ((mtu - fragheaderlen) & ~7) + fragheaderlen;
-	maxnonfragsize = (inet->pmtudisc >= IP_PMTUDISC_DO) ?
-			 mtu : 0xFFFF;
+	maxnonfragsize = ((inet->pmtudisc >= IP_PMTUDISC_DO) ||
+			  !ip_dgram_local_fragment(&rt->dst, sk)) ?
+		         mtu : 0xFFFF;
 
 	if (cork->length + size > maxnonfragsize - fragheaderlen) {
 		ip_local_error(sk, EMSGSIZE, fl4->daddr, inet->inet_dport, mtu);
@@ -1309,7 +1312,8 @@ struct sk_buff *__ip_make_skb(struct sock *sk,
 	 * to fragment the frame generated here. No matter, what transforms
 	 * how transforms change size of the packet, it will come out.
 	 */
-	if (inet->pmtudisc < IP_PMTUDISC_DO)
+	if (inet->pmtudisc < IP_PMTUDISC_DO &&
+	    ip_dgram_local_fragment(&rt->dst, sk))
 		skb->local_df = 1;
 
 	/* DF bit is set when we want to see DF on outgoing frames.

Thank you,

  Hannes
