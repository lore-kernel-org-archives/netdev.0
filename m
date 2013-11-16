From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] veth: extend features to support tunneling
Date: Sat, 16 Nov 2013 13:40:27 -0800
Message-ID: <1384638027.8604.22.camel@edumazet-glaptop2.roam.corp.google.com>
References: <CAJZOPZ+jUanPW2mT_HiSWdvGfdRMHpX6vWyrboS3Zf_gH7rEgQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Alexei Starovoitov <ast@plumgrid.com>,
	David Miller <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Michael S. Tsirkin" <mst@redhat.com>,
	John Fastabend <john.r.fastabend@intel.com>
To: Or Gerlitz <or.gerlitz@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f41.google.com ([209.85.160.41]:56496 "EHLO
	mail-pb0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752127Ab3KPVka (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 16 Nov 2013 16:40:30 -0500
Received: by mail-pb0-f41.google.com with SMTP id jt11so5089993pbb.0
        for <netdev@vger.kernel.org>; Sat, 16 Nov 2013 13:40:29 -0800 (PST)
In-Reply-To: <CAJZOPZ+jUanPW2mT_HiSWdvGfdRMHpX6vWyrboS3Zf_gH7rEgQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2013-11-16 at 23:11 +0200, Or Gerlitz wrote:

> Guys (thanks Eric for the clarification over the other vxlan thread),
> with the latest networking code (e.g 3.12 or net-next)  do you expect
> notable performance (throughput) difference between these two configs?
> 
> 1. bridge --> vxlan --> NIC
> 2. veth --> bridge --> vxlan --> NIC
> 
> BTW #2 doesn't work when packets start to be large unless I manually
> decrease the veth device pair MTU. E.g if the NIC MTU is 1500, vxlan
> advertizes an MTU of 1450 (= 1500 - (14 + 20 + 8 + 8)) and the bridge
> inherits that, but not the veth device. Should someone/somewhere here
> generate an ICMP packet which will cause the stack to decreate the
> path mtu for the neighbour created on the veth device? what about
> para-virtualized guests which are plugged into this (or any host based
> tunneling) scheme, e.g in this scheme
> 
> 3. guest virtio NIC --> vhost  --> tap/macvtap --> bridge --> vxlan --> NIC
> 
> Who/how do we want the guest NIC mtu/path mtu to take into account the
> tunneling over-head?

I mentioned this problem on another thread : gso packets escape the
normal mtu checks in ip forwarding.

vi +91 net/ipv4/ip_forward.c

gso_size contains the size of the segment minus all headers.

Please try the following :

diff --git a/include/linux/tcp.h b/include/linux/tcp.h
index d68633452d9b..489b56935a56 100644
--- a/include/linux/tcp.h
+++ b/include/linux/tcp.h
@@ -388,4 +388,16 @@ static inline int fastopen_init_queue(struct sock *sk, int backlog)
 	return 0;
 }
 
+static inline unsigned int gso_size_with_headers(const struct sk_buff *skb)
+{
+	unsigned int hdrlen = skb_transport_header(skb) - skb_mac_header(skb);
+
+	if (skb_shinfo(skb)->gso_type & (SKB_GSO_TCPV4 | SKB_GSO_TCPV6))
+		hdrlen += tcp_hdrlen(skb);
+	else
+		hdrlen += 8; // sizeof(struct udphdr)
+
+	return skb_shinfo(skb)->gso_size + hdrlen;
+}
+
 #endif	/* _LINUX_TCP_H */
diff --git a/net/ipv4/ip_forward.c b/net/ipv4/ip_forward.c
index 694de3b7aebf..3949cc1dd1ca 100644
--- a/net/ipv4/ip_forward.c
+++ b/net/ipv4/ip_forward.c
@@ -57,6 +57,7 @@ int ip_forward(struct sk_buff *skb)
 	struct iphdr *iph;	/* Our header */
 	struct rtable *rt;	/* Route we use */
 	struct ip_options *opt	= &(IPCB(skb)->opt);
+	unsigned int len;
 
 	if (skb_warn_if_lro(skb))
 		goto drop;
@@ -88,7 +89,11 @@ int ip_forward(struct sk_buff *skb)
 	if (opt->is_strictroute && rt->rt_uses_gateway)
 		goto sr_failed;
 
-	if (unlikely(skb->len > dst_mtu(&rt->dst) && !skb_is_gso(skb) &&
+	len = skb->len;
+	if (skb_is_gso(skb))
+		len = gso_size_with_headers(skb);
+
+	if (unlikely(len > dst_mtu(&rt->dst) &&
 		     (ip_hdr(skb)->frag_off & htons(IP_DF))) && !skb->local_df) {
 		IP_INC_STATS(dev_net(rt->dst.dev), IPSTATS_MIB_FRAGFAILS);
 		icmp_send(skb, ICMP_DEST_UNREACH, ICMP_FRAG_NEEDED,
