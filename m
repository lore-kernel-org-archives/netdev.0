From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [RFC] net: store port/representative id in metadata_dst
Date: Fri, 23 Sep 2016 08:34:29 +0200
Message-ID: <20160923063429.GA1821@nanopsycho.orion>
References: <1474572417-15907-1-git-send-email-jakub.kicinski@netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Thomas Graf <tgraf@suug.ch>,
        Roopa Prabhu <roopa@cumulusnetworks.com>,
        ogerlitz@mellanox.com, John Fastabend <john.fastabend@gmail.com>,
        sridhar.samudrala@intel.com, ast@kernel.org, daniel@iogearbox.net,
        simon.horman@netronome.com, Paolo Abeni <pabeni@redhat.com>,
        Pravin B Shelar <pshelar@nicira.com>,
        Jiri Benc <jbenc@redhat.com>, hannes@stressinduktion.org,
        kubakici@wp.pl
To: Jakub Kicinski <jakub.kicinski@netronome.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:33956 "EHLO
        mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932127AbcIWGed (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 23 Sep 2016 02:34:33 -0400
Received: by mail-wm0-f67.google.com with SMTP id l132so1052739wmf.1
        for <netdev@vger.kernel.org>; Thu, 22 Sep 2016 23:34:32 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1474572417-15907-1-git-send-email-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thu, Sep 22, 2016 at 09:26:57PM CEST, jakub.kicinski@netronome.com wrote:
>Switches and modern SR-IOV enabled NICs may multiplex traffic from
>representators and control messages over single set of hardware queues.
>Control messages and muxed traffic may need ordered delivery.
>
>Those requirements make it hard to comfortably use TC infrastructure
>today unless we have a way of attaching metadata to skbs at the upper
>device.  Because single set of queues is used for many netdevs stopping
>TC/sched queues of all of them reliably is impossible and lower
>device has to retreat to returning NETDEV_TX_BUSY and usually
>has to take extra locks on the fastpath.
>
>This patch attempts to enable port/representative devs to attach metadata
>to skbs which carry port id.  This way representatives can be queueless
>and all queuing can be performed at the lower netdev in the usual way.
>
>Traffic arriving on the port/representative interfaces will be have 
>metadata attached and will subsequently be queued to the lower device
>for transmission.  The lower device should recognize the metadata and
>translate it to HW specific format which is most likely either a special
>header inserted before the network headers or descriptor/metadata fields.
>
>Metadata is associated with the lower device by storing the netdev pointer
>along with port id so that if TC decides to redirect or mirror the new 
>netdev will not try to interpret it.
>
>This is mostly for SR-IOV devices since switches don't have lower
>netdevs today.
>
>Since I don't have any real user in the tree at this point please
>allow me to present a trivial example use here:
>
>void upper_init(struct upper *upper, struct lower *lower, unsigned int id)
>{
>	upper->lower_dev = lower;
>
>	upper->dst_meta = metadata_dst_alloc(0, METADATA_HW_PORT_MUX,
>					     GFP_KERNEL);
>	upper->dst_meta.u.lower_dev = lower->netdev;
>	upper->dst_meta.u.port_info.port_id = id;
>}
>
>int upper_tx(struct sk_buff *skb, struct net_device *netdev)
>{
>	struct upper *upper = netdev_priv(netdev);
>
>	skb_dst_drop(skb);
>	skb_dst_set_noref(skb, upper->dst_meta);
>
>	return dev_queue_xmit(upper->lower_dev, skb);
>}
>
>int lower_tx(struct sk_buff *skb, struct net_device *netdev)
>{
>	struct metadata_dst *md = skb_metadata_dst(skb);
>	struct lower *lower = netdev_priv(netdev);
>
>	if (md->type == METADATA_HW_PORT_MUX &&
>	    md->u.lower_dev == netdev) {

What else would it be?


>		/* use md->u.port_id to set port in
>		 * descriptor/metadata/do encap
>		 */
>	}
>	...
>}

So if I understand that correctly, this would need some "shared netdev"
which would effectively serve only as a sink for all port netdevices to
tx packets to. On RX, this would be completely avoided. This lower
device looks like half zombie to me. I don't like it :( I wonder if the
solution would not be possible without this lower netdev.

Btw, for the example implementation, you can use mlxsw, as we have exactly
the same scenario there as you describe.

Thanks.

Jiri

>
>Other approaches considered but found inferior:
> - in-data tags - inserting tags into data will be confusing
>   to classifiers which start parsing from mac headers, also
>   in-band data is less perfect and allows sufficiently privileged
>   user to inject control messages from userspace (this is DSA model
>   - note that in SR-IOV switchdev mode I control both upper and lower
>   device which differs from DSA where lower device can be any MAC);
> - per-VFR HW queues - requiring a queue per VF is a little wasteful and
>   less scalable, muxing allows us to use all PF queues to transmit
>   and receive with full RSS (this is model of existing SR-IOV switchdev
>   mode implementations);
> - per-VFR TC queue - we could use per-VFR queue in the lower device,
>   tag traffic and TX on smaller set of HW queues but again scaling
>   would suffer, we would need to lock an extra queue and we have no
>   way to stop all queues when HW queues fill up reliably (this model
>   would piggy back on dev_queue_xmit_accel() to select queue).
>
>
>Any comments, reactions would be much appreciated!
>
>Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
>---
> include/net/dst_metadata.h     | 35 ++++++++++++++++++++++++++++-------
> net/core/dst.c                 | 14 +++++++++-----
> net/core/filter.c              |  1 +
> net/ipv4/ip_tunnel_core.c      |  5 +++--
> net/openvswitch/flow_netlink.c |  3 ++-
> 5 files changed, 43 insertions(+), 15 deletions(-)
>
>diff --git a/include/net/dst_metadata.h b/include/net/dst_metadata.h
>index 6965c8f68ade..6d7e1e4f3acd 100644
>--- a/include/net/dst_metadata.h
>+++ b/include/net/dst_metadata.h
>@@ -5,10 +5,22 @@
> #include <net/ip_tunnels.h>
> #include <net/dst.h>
> 
>+enum metadata_type {
>+	METADATA_IP_TUNNEL,
>+	METADATA_HW_PORT_MUX,
>+};
>+
>+struct hw_port_info {
>+	struct netdevice *lower_dev;
>+	u32 port_id;
>+};
>+
> struct metadata_dst {
> 	struct dst_entry		dst;
>+	enum metadata_type		type;
> 	union {
> 		struct ip_tunnel_info	tun_info;
>+		struct hw_port_info	port_info;
> 	} u;
> };
> 
>@@ -27,7 +39,7 @@ static inline struct ip_tunnel_info *skb_tunnel_info(struct sk_buff *skb)
> 	struct metadata_dst *md_dst = skb_metadata_dst(skb);
> 	struct dst_entry *dst;
> 
>-	if (md_dst)
>+	if (md_dst && md_dst->type == METADATA_IP_TUNNEL)
> 		return &md_dst->u.tun_info;
> 
> 	dst = skb_dst(skb);
>@@ -55,7 +67,14 @@ static inline int skb_metadata_dst_cmp(const struct sk_buff *skb_a,
> 	a = (const struct metadata_dst *) skb_dst(skb_a);
> 	b = (const struct metadata_dst *) skb_dst(skb_b);
> 
>-	if (!a != !b || a->u.tun_info.options_len != b->u.tun_info.options_len)
>+	if (!a != !b || a->type != b->type)
>+		return 1;
>+
>+	if (a->type == METADATA_HW_PORT_MUX)
>+		return memcmp(&a->u.port_info, &b->u.port_info,
>+			      sizeof(a->u.port_info));
>+
>+	if (a->u.tun_info.options_len != b->u.tun_info.options_len)
> 		return 1;
> 
> 	return memcmp(&a->u.tun_info, &b->u.tun_info,
>@@ -63,14 +82,16 @@ static inline int skb_metadata_dst_cmp(const struct sk_buff *skb_a,
> }
> 
> void metadata_dst_free(struct metadata_dst *);
>-struct metadata_dst *metadata_dst_alloc(u8 optslen, gfp_t flags);
>-struct metadata_dst __percpu *metadata_dst_alloc_percpu(u8 optslen, gfp_t flags);
>+struct metadata_dst *metadata_dst_alloc(u8 optslen, enum metadata_type type,
>+					gfp_t flags);
>+struct metadata_dst __percpu *
>+metadata_dst_alloc_percpu(u8 optslen, enum metadata_type type, gfp_t flags);
> 
> static inline struct metadata_dst *tun_rx_dst(int md_size)
> {
> 	struct metadata_dst *tun_dst;
> 
>-	tun_dst = metadata_dst_alloc(md_size, GFP_ATOMIC);
>+	tun_dst = metadata_dst_alloc(md_size, METADATA_IP_TUNNEL, GFP_ATOMIC);
> 	if (!tun_dst)
> 		return NULL;
> 
>@@ -85,11 +106,11 @@ static inline struct metadata_dst *tun_dst_unclone(struct sk_buff *skb)
> 	int md_size;
> 	struct metadata_dst *new_md;
> 
>-	if (!md_dst)
>+	if (!md_dst || md_dst->type != METADATA_IP_TUNNEL)
> 		return ERR_PTR(-EINVAL);
> 
> 	md_size = md_dst->u.tun_info.options_len;
>-	new_md = metadata_dst_alloc(md_size, GFP_ATOMIC);
>+	new_md = metadata_dst_alloc(md_size, METADATA_IP_TUNNEL, GFP_ATOMIC);
> 	if (!new_md)
> 		return ERR_PTR(-ENOMEM);
> 
>diff --git a/net/core/dst.c b/net/core/dst.c
>index b5cbbe07f786..dc8c0c0b197b 100644
>--- a/net/core/dst.c
>+++ b/net/core/dst.c
>@@ -367,7 +367,8 @@ static int dst_md_discard(struct sk_buff *skb)
> 	return 0;
> }
> 
>-static void __metadata_dst_init(struct metadata_dst *md_dst, u8 optslen)
>+static void __metadata_dst_init(struct metadata_dst *md_dst,
>+				enum metadata_type type, u8 optslen)
> {
> 	struct dst_entry *dst;
> 
>@@ -379,9 +380,11 @@ static void __metadata_dst_init(struct metadata_dst *md_dst, u8 optslen)
> 	dst->output = dst_md_discard_out;
> 
> 	memset(dst + 1, 0, sizeof(*md_dst) + optslen - sizeof(*dst));
>+	md_dst->type = type;
> }
> 
>-struct metadata_dst *metadata_dst_alloc(u8 optslen, gfp_t flags)
>+struct metadata_dst *metadata_dst_alloc(u8 optslen, enum metadata_type type,
>+					gfp_t flags)
> {
> 	struct metadata_dst *md_dst;
> 
>@@ -389,7 +392,7 @@ struct metadata_dst *metadata_dst_alloc(u8 optslen, gfp_t flags)
> 	if (!md_dst)
> 		return NULL;
> 
>-	__metadata_dst_init(md_dst, optslen);
>+	__metadata_dst_init(md_dst, type, optslen);
> 
> 	return md_dst;
> }
>@@ -403,7 +406,8 @@ void metadata_dst_free(struct metadata_dst *md_dst)
> 	kfree(md_dst);
> }
> 
>-struct metadata_dst __percpu *metadata_dst_alloc_percpu(u8 optslen, gfp_t flags)
>+struct metadata_dst __percpu *
>+metadata_dst_alloc_percpu(u8 optslen, enum metadata_type type, gfp_t flags)
> {
> 	int cpu;
> 	struct metadata_dst __percpu *md_dst;
>@@ -414,7 +418,7 @@ struct metadata_dst __percpu *metadata_dst_alloc_percpu(u8 optslen, gfp_t flags)
> 		return NULL;
> 
> 	for_each_possible_cpu(cpu)
>-		__metadata_dst_init(per_cpu_ptr(md_dst, cpu), optslen);
>+		__metadata_dst_init(per_cpu_ptr(md_dst, cpu), type, optslen);
> 
> 	return md_dst;
> }
>diff --git a/net/core/filter.c b/net/core/filter.c
>index 0920c2ac1d00..61536a7e932e 100644
>--- a/net/core/filter.c
>+++ b/net/core/filter.c
>@@ -2386,6 +2386,7 @@ bpf_get_skb_set_tunnel_proto(enum bpf_func_id which)
> 		 * that is holding verifier mutex.
> 		 */
> 		md_dst = metadata_dst_alloc_percpu(IP_TUNNEL_OPTS_MAX,
>+						   METADATA_IP_TUNNEL,
> 						   GFP_KERNEL);
> 		if (!md_dst)
> 			return NULL;
>diff --git a/net/ipv4/ip_tunnel_core.c b/net/ipv4/ip_tunnel_core.c
>index 777bc1883870..12ffbc4a4daa 100644
>--- a/net/ipv4/ip_tunnel_core.c
>+++ b/net/ipv4/ip_tunnel_core.c
>@@ -145,10 +145,11 @@ struct metadata_dst *iptunnel_metadata_reply(struct metadata_dst *md,
> 	struct metadata_dst *res;
> 	struct ip_tunnel_info *dst, *src;
> 
>-	if (!md || md->u.tun_info.mode & IP_TUNNEL_INFO_TX)
>+	if (!md || md->type != METADATA_IP_TUNNEL ||
>+	    md->u.tun_info.mode & IP_TUNNEL_INFO_TX)
> 		return NULL;
> 
>-	res = metadata_dst_alloc(0, flags);
>+	res = metadata_dst_alloc(0, METADATA_IP_TUNNEL, flags);
> 	if (!res)
> 		return NULL;
> 
>diff --git a/net/openvswitch/flow_netlink.c b/net/openvswitch/flow_netlink.c
>index ae25ded82b3b..c9971701d0af 100644
>--- a/net/openvswitch/flow_netlink.c
>+++ b/net/openvswitch/flow_netlink.c
>@@ -2072,7 +2072,8 @@ static int validate_and_copy_set_tun(const struct nlattr *attr,
> 	if (start < 0)
> 		return start;
> 
>-	tun_dst = metadata_dst_alloc(key.tun_opts_len, GFP_KERNEL);
>+	tun_dst = metadata_dst_alloc(key.tun_opts_len, METADATA_IP_TUNNEL,
>+				     GFP_KERNEL);
> 	if (!tun_dst)
> 		return -ENOMEM;
> 
>-- 
>1.9.1
>
