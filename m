From: Jakub Sitnicki <jkbs@redhat.com>
Subject: [PATCH net-next 4/5] ipv6: Compute multipath hash for sent ICMP errors from offending packet
Date: Mon, 24 Oct 2016 11:28:51 +0200
Message-ID: <1477301332-23954-5-git-send-email-jkbs@redhat.com>
References: <1477301332-23954-1-git-send-email-jkbs@redhat.com>
Cc: linux-kernel@vger.kernel.org,
        "David S. Miller" <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        James Morris <jmorris@namei.org>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        Patrick McHardy <kaber@trash.net>,
        Eric Dumazet <edumazet@google.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1477301332-23954-1-git-send-email-jkbs@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Improve debuggability with tools like traceroute and make PMTUD work in
setups that make use of ECMP routing by sending ICMP errors down the
same path as the offending packet would travel, if it was going in the
opposite direction.

There is a caveat, flows in both directions need use the same
label. Otherwise packets from flow in the opposite direction and ICMP
errors will not be routed over the same ECMP link.

Export the function for calculating the multipath hash so that we can
use it also on receive side, when forwarding ICMP errors.

Signed-off-by: Jakub Sitnicki <jkbs@redhat.com>
---
 include/linux/icmpv6.h |  2 ++
 net/ipv6/icmp.c        | 21 +++++++++++++++++++++
 2 files changed, 23 insertions(+)

diff --git a/include/linux/icmpv6.h b/include/linux/icmpv6.h
index 57086e9..6282e03 100644
--- a/include/linux/icmpv6.h
+++ b/include/linux/icmpv6.h
@@ -45,4 +45,6 @@ extern void				icmpv6_flow_init(struct sock *sk,
 							 const struct in6_addr *saddr,
 							 const struct in6_addr *daddr,
 							 int oif);
+struct ipv6hdr;
+extern u32				icmpv6_multipath_hash(const struct ipv6hdr *iph);
 #endif
diff --git a/net/ipv6/icmp.c b/net/ipv6/icmp.c
index bd59c34..ab376b3d1 100644
--- a/net/ipv6/icmp.c
+++ b/net/ipv6/icmp.c
@@ -385,6 +385,26 @@ static struct dst_entry *icmpv6_route_lookup(struct net *net,
 	return ERR_PTR(err);
 }
 
+u32 icmpv6_multipath_hash(const struct ipv6hdr *iph)
+{
+	struct flowi6 fl6;
+
+	/* Calculate the multipath hash from the offending IP datagram that
+	 * triggered the ICMP error. The source and destination addresses are
+	 * swapped as we do our best to route the ICMP message together with the
+	 * flow it belongs to. However, flows in both directions have to have
+	 * the same label (e.g. by using flow label reflection) for it to
+	 * happen.
+	 */
+	memset(&fl6, 0, sizeof(fl6));
+	fl6.daddr = iph->saddr;
+	fl6.saddr = iph->daddr;
+	fl6.flowlabel = ip6_flowinfo(iph);
+	fl6.flowi6_proto = iph->nexthdr;
+
+	return get_hash_from_flowi6(&fl6);
+}
+
 /*
  *	Send an ICMP message in response to a packet in error
  */
@@ -484,6 +504,7 @@ static void icmp6_send(struct sk_buff *skb, u8 type, u8 code, __u32 info,
 	fl6.flowi6_oif = iif;
 	fl6.fl6_icmp_type = type;
 	fl6.fl6_icmp_code = code;
+	fl6.mp_hash = icmpv6_multipath_hash(hdr);
 	security_skb_classify_flow(skb, flowi6_to_flowi(&fl6));
 
 	sk = icmpv6_xmit_lock(net);
-- 
2.7.4
