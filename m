From: Simon Horman <horms-/R6kz+dDXgpPR4JQBCEnsQ@public.gmane.org>
Subject: Re: [RFC v4] Add TCP encap_rcv hook (repost)
Date: Mon, 23 Apr 2012 17:30:08 +0900
Message-ID: <20120423083007.GB22556@verge.net.au>
References: <61c89e02-c916-421e-b469-62b307853b1b@tahiti.vyatta.com>
	<1335110082.2132.22.camel@mojatatu>
	<20120423051359.GE11672@verge.net.au>
	<20120423.033658.1229108613501573952.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, stephen.hemminger-ZtmgI6mnKB3QT0dZR+AlfA@public.gmane.org,
	jhs-jkUAjuhPggJWk0Htik3J/w@public.gmane.org, eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20120423.033658.1229108613501573952.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
List-Unsubscribe: <http://openvswitch.org/mailman/options/dev>,
	<mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://openvswitch.org/pipermail/dev>
List-Post: <mailto:dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Help: <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=help>
List-Subscribe: <http://openvswitch.org/mailman/listinfo/dev>,
	<mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=subscribe>
Sender: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
Errors-To: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, Apr 23, 2012 at 03:36:58AM -0400, David Miller wrote:
> From: Simon Horman <horms-/R6kz+dDXgpPR4JQBCEnsQ@public.gmane.org>
> Date: Mon, 23 Apr 2012 14:14:02 +0900
> 
> > On Sun, Apr 22, 2012 at 11:54:42AM -0400, Jamal Hadi Salim wrote:
> >> On Sun, 2012-04-22 at 08:22 -0700, Stephen Hemminger wrote:
> >> 
> >> > STT isn't really doing TCP, it just lying and pretending to be
> >> > TCP to allow TSO to work! There is no packet ordering, sequence
> >> > numbers or any real transport layer. 
> > 
> > Yes, that is my understanding. Originally I envisaged that an STT
> > implementation would rely more heavily on the TCP stack. However, as
> > STT doesn't rely on any of the features of TCP other than its header
> > this was not the case and (almost) bypassing the TCP stack seems
> > to be sufficient.
> > 
> > I believe the motivation for reusing TCP is, as Stephen suggests,
> > to allow some hardware acceleration to occur.
> 
> Yes, this is what the IETF draft states.
> 
> But I wonder about your encap_rcv hook placement, nevermind
> that your posted patch won't compile since tcp_sock lacks
> an encap_tcv member and your patch didn't add one. :-)

I'm pretty sure the patch I posted added encap_rcv to tcp_sock.
Am I missing the point?

> You'll need to somehow create either a fully established or a
> listening socket for that hook to work.
> 
> You'd need to perform a full handshake to get a socket into
> established state, and it seems STT doesn't do a TCP handshake.
> 
> That leaves you with the listening socket option, and in that case I
> want to know how you're going to send packets out of this STT tunnel?

Currently I am setting up a listening socket. The Open vSwtich tunneling
code transmits skbs and using either dev_queue_xmit() or ip_local_out().
I'm not sure that I have exercised the ip_local_out() case yet.

But perhaps that doesn't answer your question?

> In order to get the advertised benefits of this STT thing, you'll need
> to go through the whole TCP data packet sending engine, in order to
> get all the TSO/GSO stuff initialized properly on the SKB so the NIC
> will do it's thing.
> 
> But you can't send data out of an un-established TCP socket.
> 
> At the very least, we'll need to see the rest of your full
> implementation before we can say whether this encap_rcv hook is the
> right way to do things.

Sure, I'm happy to provide my implementation, though it is still WIP.
The most recent patch is below.

I should point out that the actual transmission of packets occurs outside
of that patch in existing Open vSwtich code. I am unsure of the best
way to make that available to you.

It is the ovs_tnl_send() function in datapath/tunnel.c
which is available in the openvswitch git repository.

git://openvswitch.org/openvswitch

For reference I have included the file in this email after the STT patch.


---- begin stt patch ----
tunnelling: stt: Prototype Implementation

This is a not yet well exercised implementation of STT intended for review,
I am sure there are numerous areas that need improvement.

In particular:
- The transmit path's generation of partial checksums needs to be tested
- The VLAN stripping code needs to be excercised
- The code needs to be exercised in the presence of HW checksumming
- In general, the code has been exercised by running Open vSwtich in
  KVM guests on the same host. Testing between physucal hosts is needed.

This implementation is based on the CAPWAP implementation and in particular
includes defragmentation code almost identical to CAPWAP. It seems to me
that while fragmentation can be handled by GSO/TSO, defragmentation code is
needed in STT in the case where LRO/GRO doesn't reassemble an entire STT
frame for some reason.

If the defragmentation code, which is of non-trivial length, remains more
or less in its present state then there is some scope for consolidation
with CAPWAP. Other code that may possibly be consolidated with CAPWAP has
been marked accordingly.

This code depends on a encap_rcv hook being added to the Linux Kernel's TCP
stack. A patch to add such a hook will be posted separately. Ultimately
this change or some alternative will need to be applied to the mainline
Linux kernel's TCP stack if STT is to be widely deployed. Motivating this
change to the TCP stack is part of the purpose of this prototype STT
implementation.

The configuration of STT is analogous to that of other tunneling
protocols such as GRE which are supported by Open vSwtich.

e.g.

ovs-vsctl add bridge project0 ports @newport \
        -- --id=@newport create port name=stt0 interfaces=[@newinterface] \
        -- --id=@newinterface create interface name=stt0 type=stt options="remote_ip=10.0.99.192,key=64"

Signed-off-by: Simon Horman <horms-/R6kz+dDXgpPR4JQBCEnsQ@public.gmane.org>

---

v3
* Correct stripping of vlan tag on transmit
* Correct setting of vlan TCI on recieve
  - Use __vlan_hwaccel_put_tag instead of vlan_put_tag
* Use encap_rcv_enable() to enable receiving packets from the TCP stack
  - This is an update for the new implementation of the TCP stack
    patch that adds encap_rcv
* call pskb_may_pull() for STT_FRAME_HLEN + ETH_HLEN bytes in
  process_stt_proto() as this is required by ovs_flow_extract()
* Include "stt: " in pr_fmt
* Make use of pr_* instead of printk
* Rate limit all packet-generated pr_* messages
* STT flags are 8bits wide so don't define them using __cpu_to_be16()
* Only include l4_offset if
  1. get_ip_summed(skb) is OVS_CSUM_PARTIAL
  2. skb->csum_start is non-zero
  3. it is between 0 and 255
  - Warn if the first two conditions are met but not the third one.
* Only set STT_FLAG_CHECKSUM_VERIFIED if
  get_ip_summed(skb) is * OVS_CSUM_UNNECESSARY
* Print a debug message if get_ip_summed(skb) is OVS_CSUM_UNNECESSARY,
  this case is yet to be exercised
* In the rx path, adjust skb->csum_start to take into account pulling
  STT_FRAME_HLEN if get_ip_summed(skb) is OVS_CSUM_PARTIAL
* Warn if skb->dev is NULL on defragmentation and stop processing the skb.
  - This fixes a crash bug
  - But how can this occur?

v2

* Transmit
  - Correct calculation of segment offset
  - Streamline source port calculation and setting STT_FLAG_IP_VERSION.
    This allows IPv4 and IPv6 to share more code and for overall there
    to be less code.
  - Calculate partial checksum for GSO skbs. Is this correct?
  - Only calculate full checksum for non-GSO skbs.
  - Set STT_FLAG_CHECKSUM_VERIFIED for all non-GSO skbs.
  - Remove use of l4_offset, the patch modifying the tunnelling code
    to supply this has been dropped. Instead calculate the value
    based on csum_start if it is set and the network protocol of
    the inner packet is IPv4 or IPv6

* Receive
  - Correct number of bytes pulled
    + Only the TCP header plus the STT header less the pad needs to be pulled.
  - Only access STT header after it has been pulled
  - Verify checksum on receive
  - Remove use of encap_type, it is no longer present in the proposed
    TCP stack patch
  - Use the acknowledgement (tcph->ack_seq) as the fragment id
    in defragmentation

* Transmit and Receive
  - Add stt_seg_len() helper and use it in segmentation and desegmentation
    code. This corrects several offset calculation errors.
---
 acinclude.m4                |    3 +
 datapath/Modules.mk         |    3 +-
 datapath/tunnel.h           |    1 +
 datapath/vport-stt.c        |  803 +++++++++++++++++++++++++++++++++++++++++++
 datapath/vport.c            |    3 +
 datapath/vport.h            |    2 +
 include/linux/openvswitch.h |    1 +
 lib/netdev-vport.c          |    9 +-
 vswitchd/vswitch.xml        |   10 +
 9 files changed, 833 insertions(+), 2 deletions(-)
 create mode 100644 datapath/vport-stt.c

diff --git a/acinclude.m4 b/acinclude.m4
index 69bb772..f3a52fa 100644
--- a/acinclude.m4
+++ b/acinclude.m4
@@ -266,6 +266,9 @@ AC_DEFUN([OVS_CHECK_LINUX_COMPAT], [
   OVS_GREP_IFELSE([$KSRC/include/linux/if_vlan.h], [ADD_ALL_VLANS_CMD],
                   [OVS_DEFINE([HAVE_VLAN_BUG_WORKAROUND])])
 
+  OVS_GREP_IFELSE([$KSRC/include/linux/tcp.h], [encap_rcv],
+                  [OVS_DEFINE([HAVE_TCP_ENCAP_RCV])])
+
   OVS_CHECK_LOG2_H
 
   if cmp -s datapath/linux/kcompat.h.new \
diff --git a/datapath/Modules.mk b/datapath/Modules.mk
index 24c1075..6fbe3dd 100644
--- a/datapath/Modules.mk
+++ b/datapath/Modules.mk
@@ -26,7 +26,8 @@ openvswitch_sources = \
 	vport-gre.c \
 	vport-internal_dev.c \
 	vport-netdev.c \
-	vport-patch.c
+	vport-patch.c \
+	vport-stt.c
 
 openvswitch_headers = \
 	checksum.h \
diff --git a/datapath/tunnel.h b/datapath/tunnel.h
index 33eb63c..96f59b1 100644
--- a/datapath/tunnel.h
+++ b/datapath/tunnel.h
@@ -41,6 +41,7 @@
  */
 #define TNL_T_PROTO_GRE		0
 #define TNL_T_PROTO_CAPWAP	1
+#define TNL_T_PROTO_STT		2
 
 /* These flags are only needed when calling tnl_find_port(). */
 #define TNL_T_KEY_EXACT		(1 << 10)
diff --git a/datapath/vport-stt.c b/datapath/vport-stt.c
new file mode 100644
index 0000000..638998d
--- /dev/null
+++ b/datapath/vport-stt.c
@@ -0,0 +1,803 @@
+/*
+ * Copyright (c) 2012 Horms Solutions Ltd.
+ * Distributed under the terms of the GNU GPL version 2.
+ *
+ * Significant portions of this file may be copied from parts of the Linux
+ * kernel, by Linus Torvalds and others.
+ *
+ * Significant portions of this file may be copied from
+ * other parts of Open vSwitch, by Nicira Networks and others.
+ */
+
+#define pr_fmt(fmt) KBUILD_MODNAME ": stt: " fmt
+
+#include <linux/version.h>
+#ifdef HAVE_TCP_ENCAP_RCV
+
+#include <linux/if.h>
+#include <linux/in.h>
+#include <linux/ip.h>
+#include <linux/list.h>
+#include <linux/net.h>
+#include <net/net_namespace.h>
+
+#include <net/icmp.h>
+#include <net/inet_frag.h>
+#include <net/ip.h>
+#include <net/ipv6.h>
+#include <net/protocol.h>
+#include <net/udp.h>
+#include <net/tcp.h>
+
+#include "datapath.h"
+#include "tunnel.h"
+#include "vport.h"
+#include "vport-generic.h"
+
+#define STT_DST_PORT 58882 /* Change to actual port number once awarded by IANA */
+
+/* XXX: Possible Consolidation: The same values as capwap */
+#define STT_FRAG_TIMEOUT (30 * HZ)
+#define STT_FRAG_MAX_MEM (256 * 1024)
+#define STT_FRAG_PRUNE_MEM (192 * 1024)
+#define STT_FRAG_SECRET_INTERVAL (10 * 60 * HZ)
+
+#define STT_FLAG_CHECKSUM_VERIFIED	(1 << 0)
+#define STT_FLAG_CHECKSUM_PARTIAL	(1 << 1)
+#define STT_FLAG_IP_VERSION		(1 << 2)
+#define STT_FLAG_TCP_PAYLOAD		(1 << 3)
+
+#define FRAG_OFF_MASK	0xffffU
+#define FRAME_LEN_SHIFT	16
+
+struct stthdr {
+	uint8_t	version;
+	uint8_t flags;
+	uint8_t l4_offset;
+	uint8_t reserved;
+	__be16 mss;
+	__be16 vlan_tci;
+	__be64 context_id;
+};
+
+/*
+ * Not in stthdr to avoid that structure being padded to
+ * a 64bit boundary - 2 bytes of pad are required, not 8
+ */
+struct stthdr_pad {
+	uint8_t pad[2];
+};
+
+static struct stthdr *stt_hdr(const struct sk_buff *skb)
+{
+	return (struct stthdr *)(tcp_hdr(skb) + 1);
+}
+
+/*
+ * The minimum header length.
+ */
+#define STT_SEG_HLEN   sizeof(struct tcphdr)
+#define STT_FRAME_HLEN (STT_SEG_HLEN + sizeof(struct stthdr) + \
+			sizeof(struct stthdr_pad))
+
+static inline int stt_seg_len(struct sk_buff *skb)
+{
+	return skb->len - skb_transport_offset(skb) - STT_SEG_HLEN;
+}
+
+static inline struct ethhdr *stt_inner_eth_header(struct sk_buff *skb)
+{
+	return (struct ethhdr *)((char *)skb_transport_header(skb)
+				 + STT_FRAME_HLEN);
+}
+
+/* XXX: Possible Consolidation: Same as capwap */
+struct frag_match {
+	__be32 saddr;
+	__be32 daddr;
+	__be32 id;
+};
+
+/* XXX: Possible Consolidation: Same as capwap */
+struct frag_queue {
+	struct inet_frag_queue ifq;
+	struct frag_match match;
+};
+
+/* XXX: Possible Consolidation: Same as capwap */
+struct frag_skb_cb {
+	u16 offset;
+};
+#define FRAG_CB(skb) ((struct frag_skb_cb *)(skb)->cb)
+
+static struct sk_buff *defrag(struct sk_buff *skb, u16 frame_len);
+
+static void stt_frag_init(struct inet_frag_queue *, void *match);
+static unsigned int stt_frag_hash(struct inet_frag_queue *);
+static int stt_frag_match(struct inet_frag_queue *, void *match);
+static void stt_frag_expire(unsigned long ifq);
+
+static struct inet_frags frag_state = {
+	.constructor	= stt_frag_init,
+	.qsize		= sizeof(struct frag_queue),
+	.hashfn		= stt_frag_hash,
+	.match		= stt_frag_match,
+	.frag_expire	= stt_frag_expire,
+	.secret_interval = STT_FRAG_SECRET_INTERVAL,
+};
+
+/* random value for selecting source ports */
+static u32 stt_port_rnd __read_mostly;
+
+static int stt_hdr_len(const struct tnl_mutable_config *mutable)
+{
+	return (int)STT_FRAME_HLEN;
+}
+
+static void stt_build_header(const struct vport *vport,
+			     const struct tnl_mutable_config *mutable,
+			     void *header)
+{
+	struct tcphdr *tcph = header;
+	struct stthdr *stth = (struct stthdr *)(tcph + 1);
+	struct stthdr_pad *pad = (struct stthdr_pad *)(stth + 1);
+
+	tcph->dest = htons(STT_DST_PORT);
+	tcp_flag_word(tcph) = 0;
+	tcph->doff = sizeof(struct tcphdr) / 4;
+	tcph->ack = 1;
+	pad->pad[0] = pad->pad[1] = 0;
+}
+
+static u16 stt_src_port(u32 hash)
+{
+	int low, high;
+	inet_get_local_port_range(&low, &high);
+	return hash % (high - low) + low;
+}
+
+struct sk_buff *stt_update_header(const struct vport *vport,
+				  const struct tnl_mutable_config *mutable,
+				  struct dst_entry *dst,
+				  struct sk_buff *skb)
+{
+	struct tcphdr *tcph;
+	struct stthdr *stth;
+	struct ethhdr *inner_ethh;
+	struct tnl_vport *tnl_vport = tnl_vport_priv(vport);
+	__be32 frag_id = htonl(atomic_inc_return(&tnl_vport->frag_id));
+	__be32 vlan_tci = 0;
+	u32 hash = jhash_1word(skb->protocol, stt_port_rnd);
+	int l4_protocol = IPPROTO_MAX;
+
+	if (skb->protocol == htons(ETH_P_8021Q)) {
+		struct vlan_ethhdr *vlanh;
+
+		if (unlikely(!pskb_may_pull(skb, VLAN_ETH_HLEN)))
+			goto err;
+
+		vlanh = (struct vlan_ethhdr *)stt_inner_eth_header(skb);
+		vlan_tci = vlanh->h_vlan_TCI;
+
+		/* STT requires that the encapsulated frame be untagged
+		 * and the STT header only allows saving one VLAN TCI.
+		 * So there seems to be no way to handle the presence of
+		 * more than one vlan tag other than to drop the packet
+		 */
+		if (vlan_eth_hdr(skb)->h_vlan_encapsulated_proto ==
+		    htons(ETH_P_8021Q))
+			goto err;
+
+		memmove(skb->data + VLAN_HLEN, skb->data,
+			(size_t)((char *)vlanh - (char *)skb->data) +
+			2 * ETH_ALEN);
+		if (unlikely(!skb_pull(skb, VLAN_HLEN)))
+			goto err;
+
+		skb->protocol = vlan_eth_hdr(skb)->h_vlan_encapsulated_proto;
+		skb->mac_header += VLAN_HLEN;
+		skb->network_header += VLAN_HLEN;
+		skb->transport_header += VLAN_HLEN;
+	}
+
+	tcph = tcp_hdr(skb);
+	stth = (struct stthdr *)(tcph + 1);
+	inner_ethh = stt_inner_eth_header(skb);
+
+	stth->flags = 0;
+
+	if (skb->protocol == htons(ETH_P_IP)) {
+		struct iphdr *iph = (struct iphdr *)(inner_ethh + 1);
+		hash = jhash_2words(iph->saddr, iph->daddr, hash);
+		l4_protocol = iph->protocol;
+		stth->flags |= STT_FLAG_IP_VERSION;
+	} else if (skb->protocol == htons(ETH_P_IPV6)) {
+		struct ipv6hdr *ipv6h = (struct ipv6hdr *)(inner_ethh + 1);
+		hash = jhash(ipv6h->saddr.s6_addr,
+			     sizeof(ipv6h->saddr.s6_addr), hash);
+		hash = jhash(ipv6h->daddr.s6_addr,
+			     sizeof(ipv6h->daddr.s6_addr), hash);
+		l4_protocol = ipv6h->nexthdr;
+	}
+
+	stth->l4_offset = 0;
+	if (get_ip_summed(skb) == OVS_CSUM_PARTIAL && skb->csum_start) {
+		int off = skb->csum_start - skb_headroom(skb);
+		if (likely(off < 256 && off > 0))
+		    stth->l4_offset = off;
+		else if (net_ratelimit())
+			pr_err("%s: l4_offset is out of range %d should be "
+			       "between 0 and 255", __func__, off);
+	}
+
+	if (stth->l4_offset && (l4_protocol == IPPROTO_TCP ||
+				l4_protocol == IPPROTO_UDP ||
+				l4_protocol == IPPROTO_DCCP ||
+				l4_protocol == IPPROTO_SCTP)) {
+		/* TCP, UDP, DCCP and SCTP place the source and destination
+		 * ports in the first and second 16-bits of their header,
+		 * so grabbing the first 32-bits will give a combined value.
+		 */
+		__be32 *ports = (__be32 *)((char *)inner_ethh +
+					   stth->l4_offset);
+		hash = jhash_1word(*ports, hash);
+	}
+
+	if (l4_protocol == IPPROTO_TCP)
+		stth->flags |= STT_FLAG_TCP_PAYLOAD;
+
+	stth->reserved = 0;
+	stth->mss = htons(dst_mtu(dst));
+	stth->vlan_tci = vlan_tci;
+	stth->context_id = mutable->out_key;
+
+	tcph->source = htons(stt_src_port(hash));
+	tcph->seq = htonl(stt_seg_len(skb) << FRAME_LEN_SHIFT);
+	tcph->ack_seq = frag_id;
+	tcph->ack = 1;
+	tcph->psh = 1;
+
+	switch (get_ip_summed(skb)) {
+	case OVS_CSUM_PARTIAL:
+		stth->flags |= STT_FLAG_CHECKSUM_PARTIAL;
+		tcph->check = ~tcp_v4_check(skb->len,
+					    ip_hdr(skb)->saddr,
+					    ip_hdr(skb)->daddr, 0);
+		skb->csum_start = skb_transport_header(skb) - skb->head;
+		skb->csum_offset = offsetof(struct tcphdr, check);
+		break;
+	case OVS_CSUM_UNNECESSARY:
+		stth->flags |= STT_FLAG_CHECKSUM_VERIFIED;
+		pr_debug_once("%s: checsum unnecessary\n", __func__);
+	default:
+		tcph->check = 0;
+		skb->csum = skb_checksum(skb, skb_transport_offset(skb),
+					 skb->len - skb_transport_offset(skb),
+					 0);
+		tcph->check = tcp_v4_check(skb->len - skb_transport_offset(skb),
+					   ip_hdr(skb)->saddr,
+					   ip_hdr(skb)->daddr, skb->csum);
+		set_ip_summed(skb, OVS_CSUM_UNNECESSARY);
+	}
+	forward_ip_summed(skb, 1);
+
+	return skb;
+err:
+	kfree_skb(skb);
+	return NULL;
+}
+
+static inline struct capwap_net *ovs_get_stt_net(struct net *net)
+{
+	struct ovs_net *ovs_net = net_generic(net, ovs_net_id);
+	return &ovs_net->vport_net.stt;
+}
+
+static struct sk_buff *process_stt_proto(struct sk_buff *skb, __be64 *key)
+{
+	struct tcphdr *tcph = tcp_hdr(skb);
+	struct stthdr *stth;
+	u16 frame_len;
+
+	skb_postpull_rcsum(skb, skb_transport_header(skb),
+			   STT_SEG_HLEN + ETH_HLEN);
+
+	frame_len = ntohl(tcph->seq) >> FRAME_LEN_SHIFT;
+	if (stt_seg_len(skb) < frame_len) {
+		skb = defrag(skb, frame_len);
+		if (!skb)
+			return NULL;
+	}
+
+	if (skb->len < (tcph->doff << 2) || tcp_checksum_complete(skb)) {
+		if (net_ratelimit()) {
+			struct iphdr *iph = ip_hdr(skb);
+			pr_info("stt: dropped frame with "
+			       "invalid checksum  (%pI4, %d)->(%pI4, %d)\n",
+			       &iph->saddr, ntohs(tcph->source),
+			       &iph->daddr, ntohs(tcph->dest));
+		}
+		goto error;
+	}
+
+	/* STT_FRAME_HLEN less two pad bytes is needed here.
+	 * STT_FRAME_HLEN is needed by our caller, stt_rcv().
+	 * An additional ETH_HLEN bytes are required by ovs_flow_extract()
+	 * which is called indirectly by our caller.
+	 */
+	if (unlikely(!pskb_may_pull(skb, STT_FRAME_HLEN + ETH_HLEN))) {
+		if (net_ratelimit())
+			pr_info("dropped frame that is too short! %d < %lu\n",
+				skb->len, STT_FRAME_HLEN + ETH_HLEN);
+		goto error;
+	}
+
+	stth = stt_hdr(skb);
+	/* Only accept STT version 0, its all we know */
+	if (stth->version != 0)
+		goto error;
+
+	*key = stth->context_id;
+	__vlan_hwaccel_put_tag(skb, ntohs(stth->vlan_tci));
+
+	return skb;
+error:
+	kfree_skb(skb);
+	return NULL;
+}
+
+/* Called with rcu_read_lock and BH disabled. */
+static int stt_rcv(struct sock *sk, struct sk_buff *skb)
+{
+	struct vport *vport;
+	const struct tnl_mutable_config *mutable;
+	struct iphdr *iph;
+	__be64 key = 0;
+
+	/* pskb_may_pull() has already been called for
+	 * sizeof(struct tcphdr) in tcp_v4_rcv(), so there
+	 * is no need to do so again here
+	 */
+
+	skb = process_stt_proto(skb, &key);
+	if (unlikely(!skb))
+		goto out;
+
+	iph = ip_hdr(skb);
+	vport = ovs_tnl_find_port(sock_net(sk), iph->daddr, iph->saddr, key,
+				  TNL_T_PROTO_STT, &mutable);
+	if (unlikely(!vport)) {
+		icmp_send(skb, ICMP_DEST_UNREACH, ICMP_PORT_UNREACH, 0);
+		goto error;
+	}
+
+	if (mutable->flags & TNL_F_IN_KEY_MATCH)
+		OVS_CB(skb)->tun_id = key;
+	else
+		OVS_CB(skb)->tun_id = 0;
+
+	__skb_pull(skb, STT_FRAME_HLEN);
+	skb_postpull_rcsum(skb, skb_transport_header(skb),
+			   STT_FRAME_HLEN + ETH_HLEN);
+	if (get_ip_summed(skb) == OVS_CSUM_PARTIAL)
+		skb->csum_start += STT_FRAME_HLEN;
+
+	ovs_tnl_rcv(vport, skb, iph->tos);
+	goto out;
+
+error:
+	kfree_skb(skb);
+out:
+	return 0;
+}
+
+static const struct tnl_ops stt_tnl_ops = {
+	.tunnel_type	= TNL_T_PROTO_STT,
+	.ipproto	= IPPROTO_TCP,
+	.hdr_len	= stt_hdr_len,
+	.build_header	= stt_build_header,
+	.update_header	= stt_update_header,
+};
+
+static int init_socket(struct net *net)
+{
+	int err;
+	struct capwap_net *stt_net = ovs_get_stt_net(net);
+	struct sockaddr_in sin;
+
+	if (stt_net->n_tunnels) {
+		stt_net->n_tunnels++;
+		return 0;
+	}
+
+	err = sock_create_kern(AF_INET, SOCK_STREAM, 0,
+			       &stt_net->capwap_rcv_socket);
+	if (err)
+		goto error;
+
+	/* release net ref. */
+	sk_change_net(stt_net->capwap_rcv_socket->sk, net);
+
+	sin.sin_family = AF_INET;
+	sin.sin_addr.s_addr = htonl(INADDR_ANY);
+	sin.sin_port = htons(STT_DST_PORT);
+
+	err = kernel_bind(stt_net->capwap_rcv_socket, (struct sockaddr *)&sin,
+			  sizeof(struct sockaddr_in));
+	if (err)
+		goto error_sock;
+
+	tcp_sk(stt_net->capwap_rcv_socket->sk)->encap_rcv = stt_rcv;
+	tcp_encap_enable();
+
+	stt_net->frag_state.timeout = STT_FRAG_TIMEOUT;
+	stt_net->frag_state.high_thresh	= STT_FRAG_MAX_MEM;
+	stt_net->frag_state.low_thresh	= STT_FRAG_PRUNE_MEM;
+
+	inet_frags_init_net(&stt_net->frag_state);
+
+	err = kernel_listen(stt_net->capwap_rcv_socket, 7);
+	if (err)
+		goto error_sock;
+
+	stt_net->n_tunnels++;
+	return 0;
+
+error_sock:
+	sk_release_kernel(stt_net->capwap_rcv_socket->sk);
+error:
+	pr_warn("cannot register protocol handler : %d\n", err);
+	return err;
+}
+
+/* XXX: Possible Consolidation: Very similar to vport-capwap.c:release_socket() */
+static void release_socket(struct net *net)
+{
+	struct capwap_net *stt_net = ovs_get_stt_net(net);
+
+	stt_net->n_tunnels--;
+	if (stt_net->n_tunnels)
+		return;
+
+	inet_frags_exit_net(&stt_net->frag_state, &frag_state);
+	sk_release_kernel(stt_net->capwap_rcv_socket->sk);
+}
+
+/* XXX: Possible Consolidation: Very similar to capwap_create() */
+static struct vport *stt_create(const struct vport_parms *parms)
+{
+	struct vport *vport;
+	int err;
+
+	err = init_socket(ovs_dp_get_net(parms->dp));
+	if (err)
+		return ERR_PTR(err);
+
+	vport = ovs_tnl_create(parms, &ovs_stt_vport_ops, &stt_tnl_ops);
+	if (IS_ERR(vport))
+		release_socket(ovs_dp_get_net(parms->dp));
+
+	return vport;
+}
+
+/* XXX: Possible Consolidation: Same as capwap_destroy() */
+static void stt_destroy(struct vport *vport)
+{
+	ovs_tnl_destroy(vport);
+	release_socket(ovs_dp_get_net(vport->dp));
+}
+
+/* XXX: Possible Consolidation: Same as capwap_init() */
+static int stt_init(void)
+{
+	inet_frags_init(&frag_state);
+	get_random_bytes(&stt_port_rnd, sizeof(stt_port_rnd));
+	return 0;
+}
+
+/* XXX: Possible Consolidation: Same as capwap_exit() */
+static void stt_exit(void)
+{
+	inet_frags_fini(&frag_state);
+}
+
+/* All of the following functions relate to fragmentation reassembly. */
+
+static struct frag_queue *ifq_cast(struct inet_frag_queue *ifq)
+{
+	return container_of(ifq, struct frag_queue, ifq);
+}
+
+/* XXX: Possible Consolidation: Identical to to vport-capwap.c:frag_hash() */
+static u32 frag_hash(struct frag_match *match)
+{
+	return jhash_3words((__force u16)match->id, (__force u32)match->saddr,
+			    (__force u32)match->daddr,
+			    frag_state.rnd) & (INETFRAGS_HASHSZ - 1);
+}
+
+/* XXX: Possible Consolidation: Identical to to vport-capwap.c:queue_find() */
+static struct frag_queue *queue_find(struct netns_frags *ns_frag_state,
+				     struct frag_match *match)
+{
+	struct inet_frag_queue *ifq;
+
+	read_lock(&frag_state.lock);
+
+	ifq = inet_frag_find(ns_frag_state, &frag_state, match, frag_hash(match));
+	if (!ifq)
+		return NULL;
+
+	/* Unlock happens inside inet_frag_find(). */
+
+	return ifq_cast(ifq);
+}
+
+/* XXX: Possible Consolidation: Identical to to vport-capwap.c:frag_reasm() */
+static struct sk_buff *frag_reasm(struct frag_queue *fq, struct net_device *dev)
+{
+	struct sk_buff *head = fq->ifq.fragments;
+	struct sk_buff *frag;
+
+	/* Succeed or fail, we're done with this queue. */
+	inet_frag_kill(&fq->ifq, &frag_state);
+
+	if (fq->ifq.len > 65535)
+		return NULL;
+
+	/* Can't have the head be a clone. */
+	if (skb_cloned(head) && pskb_expand_head(head, 0, 0, GFP_ATOMIC))
+		return NULL;
+
+	/*
+	 * We're about to build frag list for this SKB.  If it already has a
+	 * frag list, alloc a new SKB and put the existing frag list there.
+	 */
+	if (skb_shinfo(head)->frag_list) {
+		int i;
+		int paged_len = 0;
+
+		frag = alloc_skb(0, GFP_ATOMIC);
+		if (!frag)
+			return NULL;
+
+		frag->next = head->next;
+		head->next = frag;
+		skb_shinfo(frag)->frag_list = skb_shinfo(head)->frag_list;
+		skb_shinfo(head)->frag_list = NULL;
+
+		for (i = 0; i < skb_shinfo(head)->nr_frags; i++)
+			paged_len += skb_shinfo(head)->frags[i].size;
+		frag->len = frag->data_len = head->data_len - paged_len;
+		head->data_len -= frag->len;
+		head->len -= frag->len;
+
+		frag->ip_summed = head->ip_summed;
+		atomic_add(frag->truesize, &fq->ifq.net->mem);
+	}
+
+	skb_shinfo(head)->frag_list = head->next;
+	atomic_sub(head->truesize, &fq->ifq.net->mem);
+
+	/* Properly account for data in various packets. */
+	for (frag = head->next; frag; frag = frag->next) {
+		head->data_len += frag->len;
+		head->len += frag->len;
+
+		if (head->ip_summed != frag->ip_summed)
+			head->ip_summed = CHECKSUM_NONE;
+		else if (head->ip_summed == CHECKSUM_COMPLETE)
+			head->csum = csum_add(head->csum, frag->csum);
+
+		head->truesize += frag->truesize;
+		atomic_sub(frag->truesize, &fq->ifq.net->mem);
+	}
+
+	head->next = NULL;
+	head->dev = dev;
+	head->tstamp = fq->ifq.stamp;
+	fq->ifq.fragments = NULL;
+
+	return head;
+}
+
+/* XXX: Possible Consolidation: Identical to to vport-capwap.c:frag_queue() */
+static struct sk_buff *frag_queue(struct frag_queue *fq, struct sk_buff *skb,
+				  u16 offset, bool frag_last)
+{
+	struct sk_buff *prev, *next;
+	struct net_device *dev;
+	int end;
+
+	if (fq->ifq.last_in & INET_FRAG_COMPLETE)
+		goto error;
+
+	if (stt_seg_len(skb) <= 0)
+		goto error;
+
+	end = offset + stt_seg_len(skb);
+
+	if (frag_last) {
+		/*
+		 * Last fragment, shouldn't already have data past our end or
+		 * have another last fragment.
+		 */
+		if (end < fq->ifq.len || fq->ifq.last_in & INET_FRAG_LAST_IN)
+			goto error;
+
+		fq->ifq.last_in |= INET_FRAG_LAST_IN;
+		fq->ifq.len = end;
+	} else {
+		/* Fragments should align to 8 byte chunks. */
+		if (end & ~FRAG_OFF_MASK)
+			goto error;
+
+		if (end > fq->ifq.len) {
+			/*
+			 * Shouldn't have data past the end, if we already
+			 * have one.
+			 */
+			if (fq->ifq.last_in & INET_FRAG_LAST_IN)
+				goto error;
+
+			fq->ifq.len = end;
+		}
+	}
+
+	/* Find where we fit in. */
+	prev = NULL;
+	for (next = fq->ifq.fragments; next != NULL; next = next->next) {
+		if (FRAG_CB(next)->offset >= offset)
+			break;
+		prev = next;
+	}
+
+	/*
+	 * Overlapping fragments aren't allowed.  We shouldn't start before
+	 * the end of the previous fragment.
+	 */
+	if (prev && FRAG_CB(prev)->offset + stt_seg_len(prev) > offset)
+		goto error;
+
+	/* We also shouldn't end after the beginning of the next fragment. */
+	if (next && end > FRAG_CB(next)->offset)
+		goto error;
+
+	FRAG_CB(skb)->offset = offset;
+
+	/* Link into list. */
+	skb->next = next;
+	if (prev)
+		prev->next = skb;
+	else
+		fq->ifq.fragments = skb;
+
+	dev = skb->dev;
+	skb->dev = NULL;
+
+	fq->ifq.stamp = skb->tstamp;
+	fq->ifq.meat += stt_seg_len(skb);
+	atomic_add(skb->truesize, &fq->ifq.net->mem);
+	if (offset == 0)
+		fq->ifq.last_in |= INET_FRAG_FIRST_IN;
+
+	/* If we have all fragments do reassembly. */
+	if (fq->ifq.last_in == (INET_FRAG_FIRST_IN | INET_FRAG_LAST_IN) &&
+	    fq->ifq.meat == fq->ifq.len)
+		return frag_reasm(fq, dev);
+
+	write_lock(&frag_state.lock);
+	list_move_tail(&fq->ifq.lru_list, &fq->ifq.net->lru_list);
+	write_unlock(&frag_state.lock);
+
+	return NULL;
+
+error:
+	kfree_skb(skb);
+	return NULL;
+}
+
+/* XXX: Possible Consolidation: Similar to vport-capwap.c:defrag() */
+static struct sk_buff *defrag(struct sk_buff *skb, u16 frame_len)
+{
+	struct iphdr *iph = ip_hdr(skb);
+	struct tcphdr *tcph = tcp_hdr(skb);
+	struct netns_frags *ns_frag_state;
+	struct frag_match match;
+	u16 frag_off;
+	struct frag_queue *fq;
+	bool frag_last = false;
+
+	if (unlikely(!skb->dev)) {
+		if (net_ratelimit())
+			pr_err("%s: No skb->dev!\n", __func__);
+		goto out;
+	}
+
+	ns_frag_state = &ovs_get_stt_net(dev_net(skb->dev))->frag_state;
+	if (atomic_read(&ns_frag_state->mem) > ns_frag_state->high_thresh)
+		inet_frag_evictor(ns_frag_state, &frag_state);
+
+	match.daddr = iph->daddr;
+	match.saddr = iph->saddr;
+	match.id = tcph->ack_seq;
+	frag_off = ntohl(tcph->seq) & FRAG_OFF_MASK;
+	if (frame_len == stt_seg_len(skb) + frag_off)
+		frag_last = true;
+
+	fq = queue_find(ns_frag_state, &match);
+	if (fq) {
+		spin_lock(&fq->ifq.lock);
+		skb = frag_queue(fq, skb, frag_off, frag_last);
+		spin_unlock(&fq->ifq.lock);
+
+		inet_frag_put(&fq->ifq, &frag_state);
+
+		return skb;
+	}
+
+out:
+	kfree_skb(skb);
+	return NULL;
+}
+
+/* XXX: Possible Consolidation: Functionally identical to capwap_frag_init */
+static void stt_frag_init(struct inet_frag_queue *ifq, void *match_)
+{
+	struct frag_match *match = match_;
+
+	ifq_cast(ifq)->match = *match;
+}
+
+/* XXX: Possible Consolidation: Functionally identical to capwap_frag_hash */
+static unsigned int stt_frag_hash(struct inet_frag_queue *ifq)
+{
+	return frag_hash(&ifq_cast(ifq)->match);
+}
+
+/* XXX: Possible Consolidation: Almost functionally identical to capwap_frag_match */
+static int stt_frag_match(struct inet_frag_queue *ifq, void *a_)
+{
+	struct frag_match *a = a_;
+	struct frag_match *b = &ifq_cast(ifq)->match;
+
+	return a->id == b->id && a->saddr == b->saddr && a->daddr == b->daddr;
+}
+
+/* Run when the timeout for a given queue expires. */
+/* XXX: Possible Consolidation: Functionally identical to capwap_frag_hash */
+static void stt_frag_expire(unsigned long ifq)
+{
+	struct frag_queue *fq;
+
+	fq = ifq_cast((struct inet_frag_queue *)ifq);
+
+	spin_lock(&fq->ifq.lock);
+
+	if (!(fq->ifq.last_in & INET_FRAG_COMPLETE))
+		inet_frag_kill(&fq->ifq, &frag_state);
+
+	spin_unlock(&fq->ifq.lock);
+	inet_frag_put(&fq->ifq, &frag_state);
+}
+
+const struct vport_ops ovs_stt_vport_ops = {
+	.type		= OVS_VPORT_TYPE_STT,
+	.flags		= VPORT_F_TUN_ID,
+	.init		= stt_init,
+	.exit		= stt_exit,
+	.create		= stt_create,
+	.destroy	= stt_destroy,
+	.set_addr	= ovs_tnl_set_addr,
+	.get_name	= ovs_tnl_get_name,
+	.get_addr	= ovs_tnl_get_addr,
+	.get_options	= ovs_tnl_get_options,
+	.set_options	= ovs_tnl_set_options,
+	.get_dev_flags	= ovs_vport_gen_get_dev_flags,
+	.is_running	= ovs_vport_gen_is_running,
+	.get_operstate	= ovs_vport_gen_get_operstate,
+	.send		= ovs_tnl_send,
+};
+#else
+#warning STT requires TCP encap_rcv hook in Kernel
+#endif /* HAVE_TCP_ENCAP_RCV */
diff --git a/datapath/vport.c b/datapath/vport.c
index b75a866..575e7a2 100644
--- a/datapath/vport.c
+++ b/datapath/vport.c
@@ -44,6 +44,9 @@ static const struct vport_ops *base_vport_ops_list[] = {
 #if LINUX_VERSION_CODE >= KERNEL_VERSION(2,6,26)
 	&ovs_capwap_vport_ops,
 #endif
+#ifdef HAVE_TCP_ENCAP_RCV
+	&ovs_stt_vport_ops,
+#endif
 };
 
 static const struct vport_ops **vport_ops_list;
diff --git a/datapath/vport.h b/datapath/vport.h
index 2aafde0..3994eb1 100644
--- a/datapath/vport.h
+++ b/datapath/vport.h
@@ -33,6 +33,7 @@ struct vport_parms;
 
 struct vport_net {
 	struct capwap_net capwap;
+	struct capwap_net stt;
 };
 
 /* The following definitions are for users of the vport subsytem: */
@@ -257,5 +258,6 @@ extern const struct vport_ops ovs_internal_vport_ops;
 extern const struct vport_ops ovs_patch_vport_ops;
 extern const struct vport_ops ovs_gre_vport_ops;
 extern const struct vport_ops ovs_capwap_vport_ops;
+extern const struct vport_ops ovs_stt_vport_ops;
 
 #endif /* vport.h */
diff --git a/include/linux/openvswitch.h b/include/linux/openvswitch.h
index 0578b5f..47f6dca 100644
--- a/include/linux/openvswitch.h
+++ b/include/linux/openvswitch.h
@@ -185,6 +185,7 @@ enum ovs_vport_type {
 	OVS_VPORT_TYPE_PATCH = 100, /* virtual tunnel connecting two vports */
 	OVS_VPORT_TYPE_GRE,      /* GRE tunnel */
 	OVS_VPORT_TYPE_CAPWAP,   /* CAPWAP tunnel */
+	OVS_VPORT_TYPE_STT,      /* STT tunnel */
 	__OVS_VPORT_TYPE_MAX
 };
 
diff --git a/lib/netdev-vport.c b/lib/netdev-vport.c
index 7bd50a4..346878b 100644
--- a/lib/netdev-vport.c
+++ b/lib/netdev-vport.c
@@ -165,6 +165,9 @@ netdev_vport_get_netdev_type(const struct dpif_linux_vport *vport)
     case OVS_VPORT_TYPE_CAPWAP:
         return "capwap";
 
+    case OVS_VPORT_TYPE_STT:
+        return "stt";
+
     case __OVS_VPORT_TYPE_MAX:
         break;
     }
@@ -965,7 +968,11 @@ netdev_vport_register(void)
 
         { OVS_VPORT_TYPE_PATCH,
           { "patch", VPORT_FUNCTIONS(NULL) },
-          parse_patch_config, unparse_patch_config }
+          parse_patch_config, unparse_patch_config },
+
+        { OVS_VPORT_TYPE_STT,
+          { "stt", VPORT_FUNCTIONS(netdev_vport_get_drv_info) },
+          parse_tunnel_config, unparse_tunnel_config }
     };
 
     int i;
diff --git a/vswitchd/vswitch.xml b/vswitchd/vswitch.xml
index f3ea338..d8c860e 100644
--- a/vswitchd/vswitch.xml
+++ b/vswitchd/vswitch.xml
@@ -1177,6 +1177,16 @@
             A pair of virtual devices that act as a patch cable.
           </dd>
 
+          <dt><code>stt</code></dt>
+          <dd>
+	    An Ethernet tunnel over STT (IETF draft-davie-stt-01).  UDP
+	    ports 58882 is used as the destination port and ports from the
+	    ephemeral range, which may be via proc using
+	    sys/net/ipv4/ip_local_port_range, are used as the source ports.
+	    STT currently requires modifications to the Linux kernel and is
+	    not supported by any released kernel version.
+          </dd>
+
           <dt><code>null</code></dt>
           <dd>An ignored interface.</dd>
         </dl>
-- 
1.7.9.5
---- end stt patch ----


---- begin datapath/tunnel.c ----
/*
 * Copyright (c) 2007-2012 Nicira Networks.
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of version 2 of the GNU General Public
 * License as published by the Free Software Foundation.
 *
 * This program is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
 * General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
 * 02110-1301, USA
 */

#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt

#include <linux/if_arp.h>
#include <linux/if_ether.h>
#include <linux/ip.h>
#include <linux/if_vlan.h>
#include <linux/igmp.h>
#include <linux/in.h>
#include <linux/in_route.h>
#include <linux/inetdevice.h>
#include <linux/jhash.h>
#include <linux/list.h>
#include <linux/kernel.h>
#include <linux/version.h>
#include <linux/workqueue.h>
#include <linux/rculist.h>

#include <net/dsfield.h>
#include <net/dst.h>
#include <net/icmp.h>
#include <net/inet_ecn.h>
#include <net/ip.h>
#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
#include <net/ipv6.h>
#endif
#include <net/route.h>
#include <net/xfrm.h>

#include "checksum.h"
#include "datapath.h"
#include "tunnel.h"
#include "vlan.h"
#include "vport.h"
#include "vport-generic.h"
#include "vport-internal_dev.h"

#ifdef NEED_CACHE_TIMEOUT
/*
 * On kernels where we can't quickly detect changes in the rest of the system
 * we use an expiration time to invalidate the cache.  A shorter expiration
 * reduces the length of time that we may potentially blackhole packets while
 * a longer time increases performance by reducing the frequency that the
 * cache needs to be rebuilt.  A variety of factors may cause the cache to be
 * invalidated before the expiration time but this is the maximum.  The time
 * is expressed in jiffies.
 */
#define MAX_CACHE_EXP HZ
#endif

/*
 * Interval to check for and remove caches that are no longer valid.  Caches
 * are checked for validity before they are used for packet encapsulation and
 * old caches are removed at that time.  However, if no packets are sent through
 * the tunnel then the cache will never be destroyed.  Since it holds
 * references to a number of system objects, the cache will continue to use
 * system resources by not allowing those objects to be destroyed.  The cache
 * cleaner is periodically run to free invalid caches.  It does not
 * significantly affect system performance.  A lower interval will release
 * resources faster but will itself consume resources by requiring more frequent
 * checks.  A longer interval may result in messages being printed to the kernel
 * message buffer about unreleased resources.  The interval is expressed in
 * jiffies.
 */
#define CACHE_CLEANER_INTERVAL (5 * HZ)

#define CACHE_DATA_ALIGN 16
#define PORT_TABLE_SIZE  1024

static struct hlist_head *port_table __read_mostly;
static int port_table_count;

static void cache_cleaner(struct work_struct *work);
static DECLARE_DELAYED_WORK(cache_cleaner_wq, cache_cleaner);

/*
 * These are just used as an optimization: they don't require any kind of
 * synchronization because we could have just as easily read the value before
 * the port change happened.
 */
static unsigned int key_local_remote_ports __read_mostly;
static unsigned int key_remote_ports __read_mostly;
static unsigned int key_multicast_ports __read_mostly;
static unsigned int local_remote_ports __read_mostly;
static unsigned int remote_ports __read_mostly;
static unsigned int multicast_ports __read_mostly;

#if LINUX_VERSION_CODE >= KERNEL_VERSION(2,6,36)
#define rt_dst(rt) (rt->dst)
#else
#define rt_dst(rt) (rt->u.dst)
#endif

#if LINUX_VERSION_CODE >= KERNEL_VERSION(3,1,0)
static struct hh_cache *rt_hh(struct rtable *rt)
{
	struct neighbour *neigh = dst_get_neighbour_noref(&rt->dst);
	if (!neigh || !(neigh->nud_state & NUD_CONNECTED) ||
			!neigh->hh.hh_len)
		return NULL;
	return &neigh->hh;
}
#else
#define rt_hh(rt) (rt_dst(rt).hh)
#endif

static struct vport *tnl_vport_to_vport(const struct tnl_vport *tnl_vport)
{
	return vport_from_priv(tnl_vport);
}

/* This is analogous to rtnl_dereference for the tunnel cache.  It checks that
 * cache_lock is held, so it is only for update side code.
 */
static struct tnl_cache *cache_dereference(struct tnl_vport *tnl_vport)
{
	return rcu_dereference_protected(tnl_vport->cache,
				 lockdep_is_held(&tnl_vport->cache_lock));
}

static void schedule_cache_cleaner(void)
{
	schedule_delayed_work(&cache_cleaner_wq, CACHE_CLEANER_INTERVAL);
}

static void free_cache(struct tnl_cache *cache)
{
	if (!cache)
		return;

	ovs_flow_put(cache->flow);
	ip_rt_put(cache->rt);
	kfree(cache);
}

static void free_config_rcu(struct rcu_head *rcu)
{
	struct tnl_mutable_config *c = container_of(rcu, struct tnl_mutable_config, rcu);
	kfree(c);
}

static void free_cache_rcu(struct rcu_head *rcu)
{
	struct tnl_cache *c = container_of(rcu, struct tnl_cache, rcu);
	free_cache(c);
}

/* Frees the portion of 'mutable' that requires RTNL and thus can't happen
 * within an RCU callback.  Fortunately this part doesn't require waiting for
 * an RCU grace period.
 */
static void free_mutable_rtnl(struct tnl_mutable_config *mutable)
{
	ASSERT_RTNL();
	if (ipv4_is_multicast(mutable->key.daddr) && mutable->mlink) {
		struct in_device *in_dev;
		in_dev = inetdev_by_index(port_key_get_net(&mutable->key), mutable->mlink);
		if (in_dev)
			ip_mc_dec_group(in_dev, mutable->key.daddr);
	}
}

static void assign_config_rcu(struct vport *vport,
			      struct tnl_mutable_config *new_config)
{
	struct tnl_vport *tnl_vport = tnl_vport_priv(vport);
	struct tnl_mutable_config *old_config;

	old_config = rtnl_dereference(tnl_vport->mutable);
	rcu_assign_pointer(tnl_vport->mutable, new_config);

	free_mutable_rtnl(old_config);
	call_rcu(&old_config->rcu, free_config_rcu);
}

static void assign_cache_rcu(struct vport *vport, struct tnl_cache *new_cache)
{
	struct tnl_vport *tnl_vport = tnl_vport_priv(vport);
	struct tnl_cache *old_cache;

	old_cache = cache_dereference(tnl_vport);
	rcu_assign_pointer(tnl_vport->cache, new_cache);

	if (old_cache)
		call_rcu(&old_cache->rcu, free_cache_rcu);
}

static unsigned int *find_port_pool(const struct tnl_mutable_config *mutable)
{
	bool is_multicast = ipv4_is_multicast(mutable->key.daddr);

	if (mutable->flags & TNL_F_IN_KEY_MATCH) {
		if (mutable->key.saddr)
			return &local_remote_ports;
		else if (is_multicast)
			return &multicast_ports;
		else
			return &remote_ports;
	} else {
		if (mutable->key.saddr)
			return &key_local_remote_ports;
		else if (is_multicast)
			return &key_multicast_ports;
		else
			return &key_remote_ports;
	}
}

static u32 port_hash(const struct port_lookup_key *key)
{
	return jhash2((u32 *)key, (PORT_KEY_LEN / sizeof(u32)), 0);
}

static struct hlist_head *find_bucket(u32 hash)
{
	return &port_table[(hash & (PORT_TABLE_SIZE - 1))];
}

static void port_table_add_port(struct vport *vport)
{
	struct tnl_vport *tnl_vport = tnl_vport_priv(vport);
	const struct tnl_mutable_config *mutable;
	u32 hash;

	if (port_table_count == 0)
		schedule_cache_cleaner();

	mutable = rtnl_dereference(tnl_vport->mutable);
	hash = port_hash(&mutable->key);
	hlist_add_head_rcu(&tnl_vport->hash_node, find_bucket(hash));
	port_table_count++;

	(*find_port_pool(rtnl_dereference(tnl_vport->mutable)))++;
}

static void port_table_move_port(struct vport *vport,
		      struct tnl_mutable_config *new_mutable)
{
	struct tnl_vport *tnl_vport = tnl_vport_priv(vport);
	u32 hash;

	hash = port_hash(&new_mutable->key);
	hlist_del_init_rcu(&tnl_vport->hash_node);
	hlist_add_head_rcu(&tnl_vport->hash_node, find_bucket(hash));

	(*find_port_pool(rtnl_dereference(tnl_vport->mutable)))--;
	assign_config_rcu(vport, new_mutable);
	(*find_port_pool(rtnl_dereference(tnl_vport->mutable)))++;
}

static void port_table_remove_port(struct vport *vport)
{
	struct tnl_vport *tnl_vport = tnl_vport_priv(vport);

	hlist_del_init_rcu(&tnl_vport->hash_node);

	port_table_count--;
	if (port_table_count == 0)
		cancel_delayed_work_sync(&cache_cleaner_wq);

	(*find_port_pool(rtnl_dereference(tnl_vport->mutable)))--;
}

static struct vport *port_table_lookup(struct port_lookup_key *key,
				       const struct tnl_mutable_config **pmutable)
{
	struct hlist_node *n;
	struct hlist_head *bucket;
	u32 hash = port_hash(key);
	struct tnl_vport *tnl_vport;

	bucket = find_bucket(hash);

	hlist_for_each_entry_rcu(tnl_vport, n, bucket, hash_node) {
		struct tnl_mutable_config *mutable;

		mutable = rcu_dereference_rtnl(tnl_vport->mutable);
		if (!memcmp(&mutable->key, key, PORT_KEY_LEN)) {
			*pmutable = mutable;
			return tnl_vport_to_vport(tnl_vport);
		}
	}

	return NULL;
}

struct vport *ovs_tnl_find_port(struct net *net, __be32 saddr, __be32 daddr,
				__be64 key, int tunnel_type,
				const struct tnl_mutable_config **mutable)
{
	struct port_lookup_key lookup;
	struct vport *vport;
	bool is_multicast = ipv4_is_multicast(saddr);

	port_key_set_net(&lookup, net);
	lookup.saddr = saddr;
	lookup.daddr = daddr;

	/* First try for exact match on in_key. */
	lookup.in_key = key;
	lookup.tunnel_type = tunnel_type | TNL_T_KEY_EXACT;
	if (!is_multicast && key_local_remote_ports) {
		vport = port_table_lookup(&lookup, mutable);
		if (vport)
			return vport;
	}
	if (key_remote_ports) {
		lookup.saddr = 0;
		vport = port_table_lookup(&lookup, mutable);
		if (vport)
			return vport;

		lookup.saddr = saddr;
	}

	/* Then try matches that wildcard in_key. */
	lookup.in_key = 0;
	lookup.tunnel_type = tunnel_type | TNL_T_KEY_MATCH;
	if (!is_multicast && local_remote_ports) {
		vport = port_table_lookup(&lookup, mutable);
		if (vport)
			return vport;
	}
	if (remote_ports) {
		lookup.saddr = 0;
		vport = port_table_lookup(&lookup, mutable);
		if (vport)
			return vport;
	}

	if (is_multicast) {
		lookup.saddr = 0;
		lookup.daddr = saddr;
		if (key_multicast_ports) {
			lookup.tunnel_type = tunnel_type | TNL_T_KEY_EXACT;
			lookup.in_key = key;
			vport = port_table_lookup(&lookup, mutable);
			if (vport)
				return vport;
		}
		if (multicast_ports) {
			lookup.tunnel_type = tunnel_type | TNL_T_KEY_MATCH;
			lookup.in_key = 0;
			vport = port_table_lookup(&lookup, mutable);
			if (vport)
				return vport;
		}
	}

	return NULL;
}

static void ecn_decapsulate(struct sk_buff *skb, u8 tos)
{
	if (unlikely(INET_ECN_is_ce(tos))) {
		__be16 protocol = skb->protocol;

		skb_set_network_header(skb, ETH_HLEN);

		if (protocol == htons(ETH_P_8021Q)) {
			if (unlikely(!pskb_may_pull(skb, VLAN_ETH_HLEN)))
				return;

			protocol = vlan_eth_hdr(skb)->h_vlan_encapsulated_proto;
			skb_set_network_header(skb, VLAN_ETH_HLEN);
		}

		if (protocol == htons(ETH_P_IP)) {
			if (unlikely(!pskb_may_pull(skb, skb_network_offset(skb)
			    + sizeof(struct iphdr))))
				return;

			IP_ECN_set_ce(ip_hdr(skb));
		}
#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
		else if (protocol == htons(ETH_P_IPV6)) {
			if (unlikely(!pskb_may_pull(skb, skb_network_offset(skb)
			    + sizeof(struct ipv6hdr))))
				return;

			IP6_ECN_set_ce(ipv6_hdr(skb));
		}
#endif
	}
}

/**
 *	ovs_tnl_rcv - ingress point for generic tunnel code
 *
 * @vport: port this packet was received on
 * @skb: received packet
 * @tos: ToS from encapsulating IP packet, used to copy ECN bits
 *
 * Must be called with rcu_read_lock.
 *
 * Packets received by this function are in the following state:
 * - skb->data points to the inner Ethernet header.
 * - The inner Ethernet header is in the linear data area.
 * - skb->csum does not include the inner Ethernet header.
 * - The layer pointers are undefined.
 */
void ovs_tnl_rcv(struct vport *vport, struct sk_buff *skb, u8 tos)
{
	struct ethhdr *eh;

	skb_reset_mac_header(skb);
	eh = eth_hdr(skb);

	if (likely(ntohs(eh->h_proto) >= 1536))
		skb->protocol = eh->h_proto;
	else
		skb->protocol = htons(ETH_P_802_2);

	skb_dst_drop(skb);
	nf_reset(skb);
	skb_clear_rxhash(skb);
	secpath_reset(skb);

	ecn_decapsulate(skb, tos);
	vlan_set_tci(skb, 0);

	if (unlikely(compute_ip_summed(skb, false))) {
		kfree_skb(skb);
		return;
	}

	ovs_vport_receive(vport, skb);
}

static bool check_ipv4_address(__be32 addr)
{
	if (ipv4_is_multicast(addr) || ipv4_is_lbcast(addr)
	    || ipv4_is_loopback(addr) || ipv4_is_zeronet(addr))
		return false;

	return true;
}

static bool ipv4_should_icmp(struct sk_buff *skb)
{
	struct iphdr *old_iph = ip_hdr(skb);

	/* Don't respond to L2 broadcast. */
	if (is_multicast_ether_addr(eth_hdr(skb)->h_dest))
		return false;

	/* Don't respond to L3 broadcast or invalid addresses. */
	if (!check_ipv4_address(old_iph->daddr) ||
	    !check_ipv4_address(old_iph->saddr))
		return false;

	/* Only respond to the first fragment. */
	if (old_iph->frag_off & htons(IP_OFFSET))
		return false;

	/* Don't respond to ICMP error messages. */
	if (old_iph->protocol == IPPROTO_ICMP) {
		u8 icmp_type, *icmp_typep;

		icmp_typep = skb_header_pointer(skb, (u8 *)old_iph +
						(old_iph->ihl << 2) +
						offsetof(struct icmphdr, type) -
						skb->data, sizeof(icmp_type),
						&icmp_type);

		if (!icmp_typep)
			return false;

		if (*icmp_typep > NR_ICMP_TYPES
			|| (*icmp_typep <= ICMP_PARAMETERPROB
				&& *icmp_typep != ICMP_ECHOREPLY
				&& *icmp_typep != ICMP_ECHO))
			return false;
	}

	return true;
}

static void ipv4_build_icmp(struct sk_buff *skb, struct sk_buff *nskb,
			    unsigned int mtu, unsigned int payload_length)
{
	struct iphdr *iph, *old_iph = ip_hdr(skb);
	struct icmphdr *icmph;
	u8 *payload;

	iph = (struct iphdr *)skb_put(nskb, sizeof(struct iphdr));
	icmph = (struct icmphdr *)skb_put(nskb, sizeof(struct icmphdr));
	payload = skb_put(nskb, payload_length);

	/* IP */
	iph->version		=	4;
	iph->ihl		=	sizeof(struct iphdr) >> 2;
	iph->tos		=	(old_iph->tos & IPTOS_TOS_MASK) |
					IPTOS_PREC_INTERNETCONTROL;
	iph->tot_len		=	htons(sizeof(struct iphdr)
					      + sizeof(struct icmphdr)
					      + payload_length);
	get_random_bytes(&iph->id, sizeof(iph->id));
	iph->frag_off		=	0;
	iph->ttl		=	IPDEFTTL;
	iph->protocol		=	IPPROTO_ICMP;
	iph->daddr		=	old_iph->saddr;
	iph->saddr		=	old_iph->daddr;

	ip_send_check(iph);

	/* ICMP */
	icmph->type		=	ICMP_DEST_UNREACH;
	icmph->code		=	ICMP_FRAG_NEEDED;
	icmph->un.gateway	=	htonl(mtu);
	icmph->checksum		=	0;

	nskb->csum = csum_partial((u8 *)icmph, sizeof(struct icmphdr), 0);
	nskb->csum = skb_copy_and_csum_bits(skb, (u8 *)old_iph - skb->data,
					    payload, payload_length,
					    nskb->csum);
	icmph->checksum = csum_fold(nskb->csum);
}

#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
static bool ipv6_should_icmp(struct sk_buff *skb)
{
	struct ipv6hdr *old_ipv6h = ipv6_hdr(skb);
	int addr_type;
	int payload_off = (u8 *)(old_ipv6h + 1) - skb->data;
	u8 nexthdr = ipv6_hdr(skb)->nexthdr;
	__be16 frag_off;

	/* Check source address is valid. */
	addr_type = ipv6_addr_type(&old_ipv6h->saddr);
	if (addr_type & IPV6_ADDR_MULTICAST || addr_type == IPV6_ADDR_ANY)
		return false;

	/* Don't reply to unspecified addresses. */
	if (ipv6_addr_type(&old_ipv6h->daddr) == IPV6_ADDR_ANY)
		return false;

	/* Don't respond to ICMP error messages. */
	payload_off = ipv6_skip_exthdr(skb, payload_off, &nexthdr, &frag_off);
	if (payload_off < 0)
		return false;

	if (nexthdr == NEXTHDR_ICMP) {
		u8 icmp_type, *icmp_typep;

		icmp_typep = skb_header_pointer(skb, payload_off +
						offsetof(struct icmp6hdr,
							icmp6_type),
						sizeof(icmp_type), &icmp_type);

		if (!icmp_typep || !(*icmp_typep & ICMPV6_INFOMSG_MASK))
			return false;
	}

	return true;
}

static void ipv6_build_icmp(struct sk_buff *skb, struct sk_buff *nskb,
			    unsigned int mtu, unsigned int payload_length)
{
	struct ipv6hdr *ipv6h, *old_ipv6h = ipv6_hdr(skb);
	struct icmp6hdr *icmp6h;
	u8 *payload;

	ipv6h = (struct ipv6hdr *)skb_put(nskb, sizeof(struct ipv6hdr));
	icmp6h = (struct icmp6hdr *)skb_put(nskb, sizeof(struct icmp6hdr));
	payload = skb_put(nskb, payload_length);

	/* IPv6 */
	ipv6h->version		=	6;
	ipv6h->priority		=	0;
	memset(&ipv6h->flow_lbl, 0, sizeof(ipv6h->flow_lbl));
	ipv6h->payload_len	=	htons(sizeof(struct icmp6hdr)
					      + payload_length);
	ipv6h->nexthdr		=	NEXTHDR_ICMP;
	ipv6h->hop_limit	=	IPV6_DEFAULT_HOPLIMIT;
	ipv6h->daddr		=	old_ipv6h->saddr;
	ipv6h->saddr		=	old_ipv6h->daddr;

	/* ICMPv6 */
	icmp6h->icmp6_type	=	ICMPV6_PKT_TOOBIG;
	icmp6h->icmp6_code	=	0;
	icmp6h->icmp6_cksum	=	0;
	icmp6h->icmp6_mtu	=	htonl(mtu);

	nskb->csum = csum_partial((u8 *)icmp6h, sizeof(struct icmp6hdr), 0);
	nskb->csum = skb_copy_and_csum_bits(skb, (u8 *)old_ipv6h - skb->data,
					    payload, payload_length,
					    nskb->csum);
	icmp6h->icmp6_cksum = csum_ipv6_magic(&ipv6h->saddr, &ipv6h->daddr,
						sizeof(struct icmp6hdr)
						+ payload_length,
						ipv6h->nexthdr, nskb->csum);
}
#endif /* IPv6 */

bool ovs_tnl_frag_needed(struct vport *vport,
			 const struct tnl_mutable_config *mutable,
			 struct sk_buff *skb, unsigned int mtu, __be64 flow_key)
{
	unsigned int eth_hdr_len = ETH_HLEN;
	unsigned int total_length = 0, header_length = 0, payload_length;
	struct ethhdr *eh, *old_eh = eth_hdr(skb);
	struct sk_buff *nskb;

	/* Sanity check */
	if (skb->protocol == htons(ETH_P_IP)) {
		if (mtu < IP_MIN_MTU)
			return false;

		if (!ipv4_should_icmp(skb))
			return true;
	}
#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
	else if (skb->protocol == htons(ETH_P_IPV6)) {
		if (mtu < IPV6_MIN_MTU)
			return false;

		/*
		 * In theory we should do PMTUD on IPv6 multicast messages but
		 * we don't have an address to send from so just fragment.
		 */
		if (ipv6_addr_type(&ipv6_hdr(skb)->daddr) & IPV6_ADDR_MULTICAST)
			return false;

		if (!ipv6_should_icmp(skb))
			return true;
	}
#endif
	else
		return false;

	/* Allocate */
	if (old_eh->h_proto == htons(ETH_P_8021Q))
		eth_hdr_len = VLAN_ETH_HLEN;

	payload_length = skb->len - eth_hdr_len;
	if (skb->protocol == htons(ETH_P_IP)) {
		header_length = sizeof(struct iphdr) + sizeof(struct icmphdr);
		total_length = min_t(unsigned int, header_length +
						   payload_length, 576);
	}
#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
	else {
		header_length = sizeof(struct ipv6hdr) +
				sizeof(struct icmp6hdr);
		total_length = min_t(unsigned int, header_length +
						  payload_length, IPV6_MIN_MTU);
	}
#endif

	payload_length = total_length - header_length;

	nskb = dev_alloc_skb(NET_IP_ALIGN + eth_hdr_len + header_length +
			     payload_length);
	if (!nskb)
		return false;

	skb_reserve(nskb, NET_IP_ALIGN);

	/* Ethernet / VLAN */
	eh = (struct ethhdr *)skb_put(nskb, eth_hdr_len);
	memcpy(eh->h_dest, old_eh->h_source, ETH_ALEN);
	memcpy(eh->h_source, mutable->eth_addr, ETH_ALEN);
	nskb->protocol = eh->h_proto = old_eh->h_proto;
	if (old_eh->h_proto == htons(ETH_P_8021Q)) {
		struct vlan_ethhdr *vh = (struct vlan_ethhdr *)eh;

		vh->h_vlan_TCI = vlan_eth_hdr(skb)->h_vlan_TCI;
		vh->h_vlan_encapsulated_proto = skb->protocol;
	} else
		vlan_set_tci(nskb, vlan_get_tci(skb));
	skb_reset_mac_header(nskb);

	/* Protocol */
	if (skb->protocol == htons(ETH_P_IP))
		ipv4_build_icmp(skb, nskb, mtu, payload_length);
#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
	else
		ipv6_build_icmp(skb, nskb, mtu, payload_length);
#endif

	/*
	 * Assume that flow based keys are symmetric with respect to input
	 * and output and use the key that we were going to put on the
	 * outgoing packet for the fake received packet.  If the keys are
	 * not symmetric then PMTUD needs to be disabled since we won't have
	 * any way of synthesizing packets.
	 */
	if ((mutable->flags & (TNL_F_IN_KEY_MATCH | TNL_F_OUT_KEY_ACTION)) ==
	    (TNL_F_IN_KEY_MATCH | TNL_F_OUT_KEY_ACTION))
		OVS_CB(nskb)->tun_id = flow_key;

	if (unlikely(compute_ip_summed(nskb, false))) {
		kfree_skb(nskb);
		return false;
	}

	ovs_vport_receive(vport, nskb);

	return true;
}

static bool check_mtu(struct sk_buff *skb,
		      struct vport *vport,
		      const struct tnl_mutable_config *mutable,
		      const struct rtable *rt, __be16 *frag_offp)
{
	bool df_inherit = mutable->flags & TNL_F_DF_INHERIT;
	bool pmtud = mutable->flags & TNL_F_PMTUD;
	__be16 frag_off = mutable->flags & TNL_F_DF_DEFAULT ? htons(IP_DF) : 0;
	int mtu = 0;
	unsigned int packet_length = skb->len - ETH_HLEN;

	/* Allow for one level of tagging in the packet length. */
	if (!vlan_tx_tag_present(skb) &&
	    eth_hdr(skb)->h_proto == htons(ETH_P_8021Q))
		packet_length -= VLAN_HLEN;

	if (pmtud) {
		int vlan_header = 0;

		/* The tag needs to go in packet regardless of where it
		 * currently is, so subtract it from the MTU.
		 */
		if (vlan_tx_tag_present(skb) ||
		    eth_hdr(skb)->h_proto == htons(ETH_P_8021Q))
			vlan_header = VLAN_HLEN;

		mtu = dst_mtu(&rt_dst(rt))
			- ETH_HLEN
			- mutable->tunnel_hlen
			- vlan_header;
	}

	if (skb->protocol == htons(ETH_P_IP)) {
		struct iphdr *iph = ip_hdr(skb);

		if (df_inherit)
			frag_off = iph->frag_off & htons(IP_DF);

		if (pmtud && iph->frag_off & htons(IP_DF)) {
			mtu = max(mtu, IP_MIN_MTU);

			if (packet_length > mtu &&
			    ovs_tnl_frag_needed(vport, mutable, skb, mtu,
						OVS_CB(skb)->tun_id))
				return false;
		}
	}
#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
	else if (skb->protocol == htons(ETH_P_IPV6)) {
		/* IPv6 requires end hosts to do fragmentation
		 * if the packet is above the minimum MTU.
		 */
		if (df_inherit && packet_length > IPV6_MIN_MTU)
			frag_off = htons(IP_DF);

		if (pmtud) {
			mtu = max(mtu, IPV6_MIN_MTU);

			if (packet_length > mtu &&
			    ovs_tnl_frag_needed(vport, mutable, skb, mtu,
						OVS_CB(skb)->tun_id))
				return false;
		}
	}
#endif

	*frag_offp = frag_off;
	return true;
}

static void create_tunnel_header(const struct vport *vport,
				 const struct tnl_mutable_config *mutable,
				 const struct rtable *rt, void *header)
{
	struct tnl_vport *tnl_vport = tnl_vport_priv(vport);
	struct iphdr *iph = header;

	iph->version	= 4;
	iph->ihl	= sizeof(struct iphdr) >> 2;
	iph->frag_off	= htons(IP_DF);
	iph->protocol	= tnl_vport->tnl_ops->ipproto;
	iph->tos	= mutable->tos;
	iph->daddr	= rt->rt_dst;
	iph->saddr	= rt->rt_src;
	iph->ttl	= mutable->ttl;
	if (!iph->ttl)
		iph->ttl = ip4_dst_hoplimit(&rt_dst(rt));

	tnl_vport->tnl_ops->build_header(vport, mutable, iph + 1);
}

static void *get_cached_header(const struct tnl_cache *cache)
{
	return (void *)cache + ALIGN(sizeof(struct tnl_cache), CACHE_DATA_ALIGN);
}

#ifdef HAVE_RT_GENID
static inline int rt_genid(struct net *net)
{
	return atomic_read(&net->ipv4.rt_genid);
}
#endif

static bool check_cache_valid(const struct tnl_cache *cache,
			      const struct tnl_mutable_config *mutable)
{
	struct hh_cache *hh;

	if (!cache)
		return false;

	hh = rt_hh(cache->rt);
	return hh &&
#ifdef NEED_CACHE_TIMEOUT
		time_before(jiffies, cache->expiration) &&
#endif
#ifdef HAVE_RT_GENID
		rt_genid(dev_net(rt_dst(cache->rt).dev)) == cache->rt->rt_genid &&
#endif
#ifdef HAVE_HH_SEQ
		hh->hh_lock.sequence == cache->hh_seq &&
#endif
		mutable->seq == cache->mutable_seq &&
		(!ovs_is_internal_dev(rt_dst(cache->rt).dev) ||
		(cache->flow && !cache->flow->dead));
}

static void __cache_cleaner(struct tnl_vport *tnl_vport)
{
	const struct tnl_mutable_config *mutable =
			rcu_dereference(tnl_vport->mutable);
	const struct tnl_cache *cache = rcu_dereference(tnl_vport->cache);

	if (cache && !check_cache_valid(cache, mutable) &&
	    spin_trylock_bh(&tnl_vport->cache_lock)) {
		assign_cache_rcu(tnl_vport_to_vport(tnl_vport), NULL);
		spin_unlock_bh(&tnl_vport->cache_lock);
	}
}

static void cache_cleaner(struct work_struct *work)
{
	int i;

	schedule_cache_cleaner();

	rcu_read_lock();
	for (i = 0; i < PORT_TABLE_SIZE; i++) {
		struct hlist_node *n;
		struct hlist_head *bucket;
		struct tnl_vport *tnl_vport;

		bucket = &port_table[i];
		hlist_for_each_entry_rcu(tnl_vport, n, bucket, hash_node)
			__cache_cleaner(tnl_vport);
	}
	rcu_read_unlock();
}

static void create_eth_hdr(struct tnl_cache *cache, struct hh_cache *hh)
{
	void *cache_data = get_cached_header(cache);
	int hh_off;

#ifdef HAVE_HH_SEQ
	unsigned hh_seq;

	do {
		hh_seq = read_seqbegin(&hh->hh_lock);
		hh_off = HH_DATA_ALIGN(hh->hh_len) - hh->hh_len;
		memcpy(cache_data, (void *)hh->hh_data + hh_off, hh->hh_len);
		cache->hh_len = hh->hh_len;
	} while (read_seqretry(&hh->hh_lock, hh_seq));

	cache->hh_seq = hh_seq;
#else
	read_lock(&hh->hh_lock);
	hh_off = HH_DATA_ALIGN(hh->hh_len) - hh->hh_len;
	memcpy(cache_data, (void *)hh->hh_data + hh_off, hh->hh_len);
	cache->hh_len = hh->hh_len;
	read_unlock(&hh->hh_lock);
#endif
}

static struct tnl_cache *build_cache(struct vport *vport,
				     const struct tnl_mutable_config *mutable,
				     struct rtable *rt)
{
	struct tnl_vport *tnl_vport = tnl_vport_priv(vport);
	struct tnl_cache *cache;
	void *cache_data;
	int cache_len;
	struct hh_cache *hh;

	if (!(mutable->flags & TNL_F_HDR_CACHE))
		return NULL;

	/*
	 * If there is no entry in the ARP cache or if this device does not
	 * support hard header caching just fall back to the IP stack.
	 */

	hh = rt_hh(rt);
	if (!hh)
		return NULL;

	/*
	 * If lock is contended fall back to directly building the header.
	 * We're not going to help performance by sitting here spinning.
	 */
	if (!spin_trylock(&tnl_vport->cache_lock))
		return NULL;

	cache = cache_dereference(tnl_vport);
	if (check_cache_valid(cache, mutable))
		goto unlock;
	else
		cache = NULL;

	cache_len = LL_RESERVED_SPACE(rt_dst(rt).dev) + mutable->tunnel_hlen;

	cache = kzalloc(ALIGN(sizeof(struct tnl_cache), CACHE_DATA_ALIGN) +
			cache_len, GFP_ATOMIC);
	if (!cache)
		goto unlock;

	create_eth_hdr(cache, hh);
	cache_data = get_cached_header(cache) + cache->hh_len;
	cache->len = cache->hh_len + mutable->tunnel_hlen;

	create_tunnel_header(vport, mutable, rt, cache_data);

	cache->mutable_seq = mutable->seq;
	cache->rt = rt;
#ifdef NEED_CACHE_TIMEOUT
	cache->expiration = jiffies + tnl_vport->cache_exp_interval;
#endif

	if (ovs_is_internal_dev(rt_dst(rt).dev)) {
		struct sw_flow_key flow_key;
		struct vport *dst_vport;
		struct sk_buff *skb;
		int err;
		int flow_key_len;
		struct sw_flow *flow;

		dst_vport = ovs_internal_dev_get_vport(rt_dst(rt).dev);
		if (!dst_vport)
			goto done;

		skb = alloc_skb(cache->len, GFP_ATOMIC);
		if (!skb)
			goto done;

		__skb_put(skb, cache->len);
		memcpy(skb->data, get_cached_header(cache), cache->len);

		err = ovs_flow_extract(skb, dst_vport->port_no, &flow_key,
				       &flow_key_len);

		consume_skb(skb);
		if (err)
			goto done;

		flow = ovs_flow_tbl_lookup(rcu_dereference(dst_vport->dp->table),
					   &flow_key, flow_key_len);
		if (flow) {
			cache->flow = flow;
			ovs_flow_hold(flow);
		}
	}

done:
	assign_cache_rcu(vport, cache);

unlock:
	spin_unlock(&tnl_vport->cache_lock);

	return cache;
}

static struct rtable *__find_route(const struct tnl_mutable_config *mutable,
				   u8 ipproto, u8 tos)
{
#if LINUX_VERSION_CODE < KERNEL_VERSION(2,6,39)
	struct flowi fl = { .nl_u = { .ip4_u = {
					.daddr = mutable->key.daddr,
					.saddr = mutable->key.saddr,
					.tos = tos } },
			    .proto = ipproto };
	struct rtable *rt;

	if (unlikely(ip_route_output_key(port_key_get_net(&mutable->key), &rt, &fl)))
		return ERR_PTR(-EADDRNOTAVAIL);

	return rt;
#else
	struct flowi4 fl = { .daddr = mutable->key.daddr,
			     .saddr = mutable->key.saddr,
			     .flowi4_tos = tos,
			     .flowi4_proto = ipproto };

	return ip_route_output_key(port_key_get_net(&mutable->key), &fl);
#endif
}

static struct rtable *find_route(struct vport *vport,
				 const struct tnl_mutable_config *mutable,
				 u8 tos, struct tnl_cache **cache)
{
	struct tnl_vport *tnl_vport = tnl_vport_priv(vport);
	struct tnl_cache *cur_cache = rcu_dereference(tnl_vport->cache);

	*cache = NULL;
	tos = RT_TOS(tos);

	if (likely(tos == mutable->tos &&
	    check_cache_valid(cur_cache, mutable))) {
		*cache = cur_cache;
		return cur_cache->rt;
	} else {
		struct rtable *rt;

		rt = __find_route(mutable, tnl_vport->tnl_ops->ipproto, tos);
		if (IS_ERR(rt))
			return NULL;

		if (likely(tos == mutable->tos))
			*cache = build_cache(vport, mutable, rt);

		return rt;
	}
}

static bool need_linearize(const struct sk_buff *skb)
{
	int i;

	if (unlikely(skb_shinfo(skb)->frag_list))
		return true;

	/*
	 * Generally speaking we should linearize if there are paged frags.
	 * However, if all of the refcounts are 1 we know nobody else can
	 * change them from underneath us and we can skip the linearization.
	 */
	for (i = 0; i < skb_shinfo(skb)->nr_frags; i++)
		if (unlikely(page_count(skb_frag_page(&skb_shinfo(skb)->frags[i])) > 1))
			return true;

	return false;
}

static struct sk_buff *handle_offloads(struct sk_buff *skb,
				       const struct tnl_mutable_config *mutable,
				       const struct rtable *rt)
{
	int min_headroom;
	int err;

	min_headroom = LL_RESERVED_SPACE(rt_dst(rt).dev) + rt_dst(rt).header_len
			+ mutable->tunnel_hlen
			+ (vlan_tx_tag_present(skb) ? VLAN_HLEN : 0);

	if (skb_headroom(skb) < min_headroom || skb_header_cloned(skb)) {
		int head_delta = SKB_DATA_ALIGN(min_headroom -
						skb_headroom(skb) +
						16);
		err = pskb_expand_head(skb, max_t(int, head_delta, 0),
					0, GFP_ATOMIC);
		if (unlikely(err))
			goto error_free;
	}

	forward_ip_summed(skb, true);

	if (skb_is_gso(skb)) {
		struct sk_buff *nskb;

		nskb = skb_gso_segment(skb, 0);
		if (IS_ERR(nskb)) {
			kfree_skb(skb);
			err = PTR_ERR(nskb);
			goto error;
		}

		consume_skb(skb);
		skb = nskb;
	} else if (get_ip_summed(skb) == OVS_CSUM_PARTIAL) {
		/* Pages aren't locked and could change at any time.
		 * If this happens after we compute the checksum, the
		 * checksum will be wrong.  We linearize now to avoid
		 * this problem.
		 */
		if (unlikely(need_linearize(skb))) {
			err = __skb_linearize(skb);
			if (unlikely(err))
				goto error_free;
		}

		err = skb_checksum_help(skb);
		if (unlikely(err))
			goto error_free;
	}

	set_ip_summed(skb, OVS_CSUM_NONE);

	return skb;

error_free:
	kfree_skb(skb);
error:
	return ERR_PTR(err);
}

static int send_frags(struct sk_buff *skb,
		      const struct tnl_mutable_config *mutable)
{
	int sent_len;

	sent_len = 0;
	while (skb) {
		struct sk_buff *next = skb->next;
		int frag_len = skb->len - mutable->tunnel_hlen;
		int err;

		skb->next = NULL;
		memset(IPCB(skb), 0, sizeof(*IPCB(skb)));

		err = ip_local_out(skb);
		skb = next;
		if (unlikely(net_xmit_eval(err)))
			goto free_frags;
		sent_len += frag_len;
	}

	return sent_len;

free_frags:
	/*
	 * There's no point in continuing to send fragments once one has been
	 * dropped so just free the rest.  This may help improve the congestion
	 * that caused the first packet to be dropped.
	 */
	ovs_tnl_free_linked_skbs(skb);
	return sent_len;
}

int ovs_tnl_send(struct vport *vport, struct sk_buff *skb)
{
	struct tnl_vport *tnl_vport = tnl_vport_priv(vport);
	const struct tnl_mutable_config *mutable = rcu_dereference(tnl_vport->mutable);

	enum vport_err_type err = VPORT_E_TX_ERROR;
	struct rtable *rt;
	struct dst_entry *unattached_dst = NULL;
	struct tnl_cache *cache;
	int sent_len = 0;
	__be16 frag_off = 0;
	u8 ttl;
	u8 inner_tos;
	u8 tos;

	/* Validate the protocol headers before we try to use them. */
	if (skb->protocol == htons(ETH_P_8021Q) &&
	    !vlan_tx_tag_present(skb)) {
		if (unlikely(!pskb_may_pull(skb, VLAN_ETH_HLEN)))
			goto error_free;

		skb->protocol = vlan_eth_hdr(skb)->h_vlan_encapsulated_proto;
		skb_set_network_header(skb, VLAN_ETH_HLEN);
	}

	if (skb->protocol == htons(ETH_P_IP)) {
		if (unlikely(!pskb_may_pull(skb, skb_network_offset(skb)
		    + sizeof(struct iphdr))))
			skb->protocol = 0;
	}
#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
	else if (skb->protocol == htons(ETH_P_IPV6)) {
		if (unlikely(!pskb_may_pull(skb, skb_network_offset(skb)
		    + sizeof(struct ipv6hdr))))
			skb->protocol = 0;
	}
#endif

	/* ToS */
	if (skb->protocol == htons(ETH_P_IP))
		inner_tos = ip_hdr(skb)->tos;
#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
	else if (skb->protocol == htons(ETH_P_IPV6))
		inner_tos = ipv6_get_dsfield(ipv6_hdr(skb));
#endif
	else
		inner_tos = 0;

	if (mutable->flags & TNL_F_TOS_INHERIT)
		tos = inner_tos;
	else
		tos = mutable->tos;

	tos = INET_ECN_encapsulate(tos, inner_tos);

	/* Route lookup */
	rt = find_route(vport, mutable, tos, &cache);
	if (unlikely(!rt))
		goto error_free;
	if (unlikely(!cache))
		unattached_dst = &rt_dst(rt);

	/* Reset SKB */
	nf_reset(skb);
	secpath_reset(skb);
	skb_dst_drop(skb);
	skb_clear_rxhash(skb);

	/* Offloading */
	skb = handle_offloads(skb, mutable, rt);
	if (IS_ERR(skb))
		goto error;

	/* MTU */
	if (unlikely(!check_mtu(skb, vport, mutable, rt, &frag_off))) {
		err = VPORT_E_TX_DROPPED;
		goto error_free;
	}

	/*
	 * If we are over the MTU, allow the IP stack to handle fragmentation.
	 * Fragmentation is a slow path anyways.
	 */
	if (unlikely(skb->len + mutable->tunnel_hlen > dst_mtu(&rt_dst(rt)) &&
		     cache)) {
		unattached_dst = &rt_dst(rt);
		dst_hold(unattached_dst);
		cache = NULL;
	}

	/* TTL */
	ttl = mutable->ttl;
	if (!ttl)
		ttl = ip4_dst_hoplimit(&rt_dst(rt));

	if (mutable->flags & TNL_F_TTL_INHERIT) {
		if (skb->protocol == htons(ETH_P_IP))
			ttl = ip_hdr(skb)->ttl;
#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
		else if (skb->protocol == htons(ETH_P_IPV6))
			ttl = ipv6_hdr(skb)->hop_limit;
#endif
	}

	while (skb) {
		struct iphdr *iph;
		struct sk_buff *next_skb = skb->next;
		skb->next = NULL;

		if (unlikely(vlan_deaccel_tag(skb)))
			goto next;

		if (likely(cache)) {
			skb_push(skb, cache->len);
			memcpy(skb->data, get_cached_header(cache), cache->len);
			skb_reset_mac_header(skb);
			skb_set_network_header(skb, cache->hh_len);

		} else {
			skb_push(skb, mutable->tunnel_hlen);
			create_tunnel_header(vport, mutable, rt, skb->data);
			skb_reset_network_header(skb);

			if (next_skb)
				skb_dst_set(skb, dst_clone(unattached_dst));
			else {
				skb_dst_set(skb, unattached_dst);
				unattached_dst = NULL;
			}
		}
		skb_set_transport_header(skb, skb_network_offset(skb) + sizeof(struct iphdr));

		iph = ip_hdr(skb);
		iph->tos = tos;
		iph->ttl = ttl;
		iph->frag_off = frag_off;
		ip_select_ident(iph, &rt_dst(rt), NULL);

		skb = tnl_vport->tnl_ops->update_header(vport, mutable,
							&rt_dst(rt), skb);
		if (unlikely(!skb))
			goto next;

		if (likely(cache)) {
			int orig_len = skb->len - cache->len;
			struct vport *cache_vport;

			cache_vport = ovs_internal_dev_get_vport(rt_dst(rt).dev);
			skb->protocol = htons(ETH_P_IP);
			iph = ip_hdr(skb);
			iph->tot_len = htons(skb->len - skb_network_offset(skb));
			ip_send_check(iph);

			if (cache_vport) {
				if (unlikely(compute_ip_summed(skb, true))) {
					kfree_skb(skb);
					goto next;
				}

				OVS_CB(skb)->flow = cache->flow;
				ovs_vport_receive(cache_vport, skb);
				sent_len += orig_len;
			} else {
				int xmit_err;

				skb->dev = rt_dst(rt).dev;
				xmit_err = dev_queue_xmit(skb);

				if (likely(net_xmit_eval(xmit_err) == 0))
					sent_len += orig_len;
			}
		} else
			sent_len += send_frags(skb, mutable);

next:
		skb = next_skb;
	}

	if (unlikely(sent_len == 0))
		ovs_vport_record_error(vport, VPORT_E_TX_DROPPED);

	goto out;

error_free:
	ovs_tnl_free_linked_skbs(skb);
error:
	ovs_vport_record_error(vport, err);
out:
	dst_release(unattached_dst);
	return sent_len;
}

static const struct nla_policy tnl_policy[OVS_TUNNEL_ATTR_MAX + 1] = {
	[OVS_TUNNEL_ATTR_FLAGS]    = { .type = NLA_U32 },
	[OVS_TUNNEL_ATTR_DST_IPV4] = { .type = NLA_U32 },
	[OVS_TUNNEL_ATTR_SRC_IPV4] = { .type = NLA_U32 },
	[OVS_TUNNEL_ATTR_OUT_KEY]  = { .type = NLA_U64 },
	[OVS_TUNNEL_ATTR_IN_KEY]   = { .type = NLA_U64 },
	[OVS_TUNNEL_ATTR_TOS]      = { .type = NLA_U8 },
	[OVS_TUNNEL_ATTR_TTL]      = { .type = NLA_U8 },
};

/* Sets OVS_TUNNEL_ATTR_* fields in 'mutable', which must initially be
 * zeroed. */
static int tnl_set_config(struct net *net, struct nlattr *options,
			  const struct tnl_ops *tnl_ops,
			  const struct vport *cur_vport,
			  struct tnl_mutable_config *mutable)
{
	const struct vport *old_vport;
	const struct tnl_mutable_config *old_mutable;
	struct nlattr *a[OVS_TUNNEL_ATTR_MAX + 1];
	int err;

	if (!options)
		return -EINVAL;

	err = nla_parse_nested(a, OVS_TUNNEL_ATTR_MAX, options, tnl_policy);
	if (err)
		return err;

	if (!a[OVS_TUNNEL_ATTR_FLAGS] || !a[OVS_TUNNEL_ATTR_DST_IPV4])
		return -EINVAL;

	mutable->flags = nla_get_u32(a[OVS_TUNNEL_ATTR_FLAGS]) & TNL_F_PUBLIC;

	port_key_set_net(&mutable->key, net);
	mutable->key.daddr = nla_get_be32(a[OVS_TUNNEL_ATTR_DST_IPV4]);
	if (a[OVS_TUNNEL_ATTR_SRC_IPV4]) {
		if (ipv4_is_multicast(mutable->key.daddr))
			return -EINVAL;
		mutable->key.saddr = nla_get_be32(a[OVS_TUNNEL_ATTR_SRC_IPV4]);
	}

	if (a[OVS_TUNNEL_ATTR_TOS]) {
		mutable->tos = nla_get_u8(a[OVS_TUNNEL_ATTR_TOS]);
		if (mutable->tos != RT_TOS(mutable->tos))
			return -EINVAL;
	}

	if (a[OVS_TUNNEL_ATTR_TTL])
		mutable->ttl = nla_get_u8(a[OVS_TUNNEL_ATTR_TTL]);

	mutable->key.tunnel_type = tnl_ops->tunnel_type;
	if (!a[OVS_TUNNEL_ATTR_IN_KEY]) {
		mutable->key.tunnel_type |= TNL_T_KEY_MATCH;
		mutable->flags |= TNL_F_IN_KEY_MATCH;
	} else {
		mutable->key.tunnel_type |= TNL_T_KEY_EXACT;
		mutable->key.in_key = nla_get_be64(a[OVS_TUNNEL_ATTR_IN_KEY]);
	}

	if (!a[OVS_TUNNEL_ATTR_OUT_KEY])
		mutable->flags |= TNL_F_OUT_KEY_ACTION;
	else
		mutable->out_key = nla_get_be64(a[OVS_TUNNEL_ATTR_OUT_KEY]);

	mutable->tunnel_hlen = tnl_ops->hdr_len(mutable);
	if (mutable->tunnel_hlen < 0)
		return mutable->tunnel_hlen;

	mutable->tunnel_hlen += sizeof(struct iphdr);

	old_vport = port_table_lookup(&mutable->key, &old_mutable);
	if (old_vport && old_vport != cur_vport)
		return -EEXIST;

	mutable->mlink = 0;
	if (ipv4_is_multicast(mutable->key.daddr)) {
		struct net_device *dev;
		struct rtable *rt;

		rt = __find_route(mutable, tnl_ops->ipproto, mutable->tos);
		if (IS_ERR(rt))
			return -EADDRNOTAVAIL;
		dev = rt_dst(rt).dev;
		ip_rt_put(rt);
		if (__in_dev_get_rtnl(dev) == NULL)
			return -EADDRNOTAVAIL;
		mutable->mlink = dev->ifindex;
		ip_mc_inc_group(__in_dev_get_rtnl(dev), mutable->key.daddr);
	}

	return 0;
}

struct vport *ovs_tnl_create(const struct vport_parms *parms,
			     const struct vport_ops *vport_ops,
			     const struct tnl_ops *tnl_ops)
{
	struct vport *vport;
	struct tnl_vport *tnl_vport;
	struct tnl_mutable_config *mutable;
	int initial_frag_id;
	int err;

	vport = ovs_vport_alloc(sizeof(struct tnl_vport), vport_ops, parms);
	if (IS_ERR(vport)) {
		err = PTR_ERR(vport);
		goto error;
	}

	tnl_vport = tnl_vport_priv(vport);

	strcpy(tnl_vport->name, parms->name);
	tnl_vport->tnl_ops = tnl_ops;

	mutable = kzalloc(sizeof(struct tnl_mutable_config), GFP_KERNEL);
	if (!mutable) {
		err = -ENOMEM;
		goto error_free_vport;
	}

	random_ether_addr(mutable->eth_addr);

	get_random_bytes(&initial_frag_id, sizeof(int));
	atomic_set(&tnl_vport->frag_id, initial_frag_id);

	err = tnl_set_config(ovs_dp_get_net(parms->dp), parms->options, tnl_ops,
			     NULL, mutable);
	if (err)
		goto error_free_mutable;

	spin_lock_init(&tnl_vport->cache_lock);

#ifdef NEED_CACHE_TIMEOUT
	tnl_vport->cache_exp_interval = MAX_CACHE_EXP -
				       (net_random() % (MAX_CACHE_EXP / 2));
#endif

	rcu_assign_pointer(tnl_vport->mutable, mutable);

	port_table_add_port(vport);
	return vport;

error_free_mutable:
	free_mutable_rtnl(mutable);
	kfree(mutable);
error_free_vport:
	ovs_vport_free(vport);
error:
	return ERR_PTR(err);
}

int ovs_tnl_set_options(struct vport *vport, struct nlattr *options)
{
	struct tnl_vport *tnl_vport = tnl_vport_priv(vport);
	const struct tnl_mutable_config *old_mutable;
	struct tnl_mutable_config *mutable;
	int err;

	mutable = kzalloc(sizeof(struct tnl_mutable_config), GFP_KERNEL);
	if (!mutable) {
		err = -ENOMEM;
		goto error;
	}

	/* Copy fields whose values should be retained. */
	old_mutable = rtnl_dereference(tnl_vport->mutable);
	mutable->seq = old_mutable->seq + 1;
	memcpy(mutable->eth_addr, old_mutable->eth_addr, ETH_ALEN);

	/* Parse the others configured by userspace. */
	err = tnl_set_config(ovs_dp_get_net(vport->dp), options, tnl_vport->tnl_ops,
			     vport, mutable);
	if (err)
		goto error_free;

	if (port_hash(&mutable->key) != port_hash(&old_mutable->key))
		port_table_move_port(vport, mutable);
	else
		assign_config_rcu(vport, mutable);

	return 0;

error_free:
	free_mutable_rtnl(mutable);
	kfree(mutable);
error:
	return err;
}

int ovs_tnl_get_options(const struct vport *vport, struct sk_buff *skb)
{
	const struct tnl_vport *tnl_vport = tnl_vport_priv(vport);
	const struct tnl_mutable_config *mutable = rcu_dereference_rtnl(tnl_vport->mutable);

	if (nla_put_u32(skb, OVS_TUNNEL_ATTR_FLAGS,
		      mutable->flags & TNL_F_PUBLIC) ||
	    nla_put_be32(skb, OVS_TUNNEL_ATTR_DST_IPV4, mutable->key.daddr))
		goto nla_put_failure;

	if (!(mutable->flags & TNL_F_IN_KEY_MATCH) &&
	    nla_put_be64(skb, OVS_TUNNEL_ATTR_IN_KEY, mutable->key.in_key))
		goto nla_put_failure;
	if (!(mutable->flags & TNL_F_OUT_KEY_ACTION) &&
	    nla_put_be64(skb, OVS_TUNNEL_ATTR_OUT_KEY, mutable->out_key))
		goto nla_put_failure;
	if (mutable->key.saddr &&
	    nla_put_be32(skb, OVS_TUNNEL_ATTR_SRC_IPV4, mutable->key.saddr))
		goto nla_put_failure;
	if (mutable->tos && nla_put_u8(skb, OVS_TUNNEL_ATTR_TOS, mutable->tos))
		goto nla_put_failure;
	if (mutable->ttl && nla_put_u8(skb, OVS_TUNNEL_ATTR_TTL, mutable->ttl))
		goto nla_put_failure;

	return 0;

nla_put_failure:
	return -EMSGSIZE;
}

static void free_port_rcu(struct rcu_head *rcu)
{
	struct tnl_vport *tnl_vport = container_of(rcu,
						   struct tnl_vport, rcu);

	free_cache((struct tnl_cache __force *)tnl_vport->cache);
	kfree((struct tnl_mutable __force *)tnl_vport->mutable);
	ovs_vport_free(tnl_vport_to_vport(tnl_vport));
}

void ovs_tnl_destroy(struct vport *vport)
{
	struct tnl_vport *tnl_vport = tnl_vport_priv(vport);
	struct tnl_mutable_config *mutable;

	mutable = rtnl_dereference(tnl_vport->mutable);
	port_table_remove_port(vport);
	free_mutable_rtnl(mutable);
	call_rcu(&tnl_vport->rcu, free_port_rcu);
}

int ovs_tnl_set_addr(struct vport *vport, const unsigned char *addr)
{
	struct tnl_vport *tnl_vport = tnl_vport_priv(vport);
	struct tnl_mutable_config *old_mutable, *mutable;

	old_mutable = rtnl_dereference(tnl_vport->mutable);
	mutable = kmemdup(old_mutable, sizeof(struct tnl_mutable_config), GFP_KERNEL);
	if (!mutable)
		return -ENOMEM;

	old_mutable->mlink = 0;

	memcpy(mutable->eth_addr, addr, ETH_ALEN);
	assign_config_rcu(vport, mutable);

	return 0;
}

const char *ovs_tnl_get_name(const struct vport *vport)
{
	const struct tnl_vport *tnl_vport = tnl_vport_priv(vport);
	return tnl_vport->name;
}

const unsigned char *ovs_tnl_get_addr(const struct vport *vport)
{
	const struct tnl_vport *tnl_vport = tnl_vport_priv(vport);
	return rcu_dereference_rtnl(tnl_vport->mutable)->eth_addr;
}

void ovs_tnl_free_linked_skbs(struct sk_buff *skb)
{
	while (skb) {
		struct sk_buff *next = skb->next;
		kfree_skb(skb);
		skb = next;
	}
}

int ovs_tnl_init(void)
{
	int i;

	port_table = kmalloc(PORT_TABLE_SIZE * sizeof(struct hlist_head *),
			     GFP_KERNEL);
	if (!port_table)
		return -ENOMEM;

	for (i = 0; i < PORT_TABLE_SIZE; i++)
		INIT_HLIST_HEAD(&port_table[i]);

	return 0;
}

void ovs_tnl_exit(void)
{
	kfree(port_table);
}

---- end datapath/tunnel.c ----
