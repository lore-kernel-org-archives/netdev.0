From: Hannes Frederic Sowa <hannes@redhat.com>
Subject: Re: [PATCH net-next 5/9] openvswitch: Add conntrack action
Date: Fri, 31 Jul 2015 16:52:41 +0200
Message-ID: <1438354361.20479.15.camel@redhat.com>
References: <1438279963-29563-1-git-send-email-joestringer@nicira.com>
	 <1438279963-29563-6-git-send-email-joestringer@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, pablo@netfilter.org, kaber@trash.net,
	jpettit@nicira.com, pshelar@nicira.com, azhou@nicira.com,
	jesse@nicira.com, fwestpha@redhat.com, tgraf@noironetworks.com
To: Joe Stringer <joestringer@nicira.com>, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1438279963-29563-6-git-send-email-joestringer@nicira.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

On Thu, 2015-07-30 at 11:12 -0700, Joe Stringer wrote:
> diff --git a/net/openvswitch/actions.c b/net/openvswitch/actions.c
> index e50678d..4a62ed4 100644
> --- a/net/openvswitch/actions.c
> +++ b/net/openvswitch/actions.c
> @@ -22,6 +22,7 @@
>  #include <linux/in.h>
>  #include <linux/ip.h>
>  #include <linux/openvswitch.h>
> +#include <linux/netfilter_ipv6.h>
>  #include <linux/sctp.h>
>  #include <linux/tcp.h>
>  #include <linux/udp.h>
> @@ -29,6 +30,7 @@
>  #include <linux/if_arp.h>
>  #include <linux/if_vlan.h>
>  
> +#include <net/dst.h>
>  #include <net/ip.h>
>  #include <net/ipv6.h>
>  #include <net/checksum.h>
> @@ -38,6 +40,7 @@
>  
>  #include "datapath.h"
>  #include "flow.h"
> +#include "conntrack.h"
>  #include "vport.h"
>  
>  static int do_execute_actions(struct datapath *dp, struct sk_buff 
> *skb,
> @@ -52,6 +55,16 @@ struct deferred_action {
>  	struct sw_flow_key pkt_key;
>  };
>  
> +struct ovs_frag_data {
> +	struct dst_entry *dst;

As this is a temporary storage area for skb data, we could simply use an
unsigned long here and don't need to force a reference on the dst_entry
in ovs_vport_output.

> +	struct vport *vport;
> +	struct sw_flow_key *key;
> +	struct ovs_skb_cb cb;
> +	__be16 vlan_proto;
> +};
> +
> +static DEFINE_PER_CPU(struct ovs_frag_data, ovs_frag_data_storage);
> +
>  #define DEFERRED_ACTION_FIFO_SIZE 10
>  struct action_fifo {
>  	int head;
> @@ -594,14 +607,136 @@ static int set_sctp(struct sk_buff *skb, struct 
> sw_flow_key *flow_key,
>  	return 0;
>  }
>  
> -static void do_output(struct datapath *dp, struct sk_buff *skb, int 
> out_port)
> +/* Given an IP frame, reconstruct its MAC header.  */
> +static void ovs_setup_l2_header(struct sk_buff *skb,
> +				const struct ovs_frag_data *data)
> +{
> +	struct sw_flow_key *key = data->key;
> +
> +	skb_push(skb, ETH_HLEN);
> +	skb_reset_mac_header(skb);
> +
> +	ether_addr_copy(eth_hdr(skb)->h_source, key->eth.src);
> +	ether_addr_copy(eth_hdr(skb)->h_dest, key->eth.dst);
> +	eth_hdr(skb)->h_proto = key->eth.type;
> +
> +	if ((data->key->eth.tci & htons(VLAN_TAG_PRESENT)) &&
> +	    !skb_vlan_tag_present(skb))
> +		__vlan_hwaccel_put_tag(skb, data->vlan_proto,
> +				       ntohs(key->eth.tci));
> +}
> +
> +static void prepare_frag(struct vport *vport, struct sw_flow_key 
> *key,
> +			 struct sk_buff *skb)
> +{
> +	unsigned int hlen = ETH_HLEN;
> +	struct ovs_frag_data *data;
> +
> +	data = this_cpu_ptr(&ovs_frag_data_storage);
> +	data->dst = skb_dst(skb);


If data->dst is unsigned long, we could simply use an assignment:

data->dst = skb->_skb_refdst;

At this point we never leave rcu_read_lock section, so we are safe,
maybe we can add a comment for that.

> +	data->vport = vport;
> +	data->key = key;
> +	data->cb = *OVS_CB(skb);
> +
> +	if (key->eth.tci & htons(VLAN_TAG_PRESENT)) {
> +		if (skb_vlan_tag_present(skb)) {
> +			data->vlan_proto = skb->vlan_proto;
> +		} else {
> +			data->vlan_proto = vlan_eth_hdr(skb)
> ->h_vlan_proto;
> +			hlen += VLAN_HLEN;
> +		}
> +	}
> +
> +	memset(IPCB(skb), 0, sizeof(struct inet_skb_parm));
> +	skb_pull(skb, hlen);
> +}
> +
> +static int ovs_vport_output(struct sock *sock, struct sk_buff *skb)
> +{
> +	struct ovs_frag_data *data = 
> this_cpu_ptr(&ovs_frag_data_storage);
> +	struct vport *vport = data->vport;
> +
> +	skb_dst_drop(skb);
> +	skb_dst_set(skb, dst_clone(data->dst));

We don't need to refcount the dst here, then.

> +	*OVS_CB(skb) = data->cb;
> +
> +	ovs_setup_l2_header(skb, data);
> +	ovs_vport_send(vport, skb);
> +
> +	return 0;
> +}
> +
> +unsigned int
> +ovs_dst_get_mtu(const struct dst_entry *dst)
> +{
> +	return dst->dev->mtu;
> +}
> +
> +static struct dst_ops ovs_dst_ops = {
> +	.family = AF_UNSPEC,
> +	.mtu = ovs_dst_get_mtu,
> +};
> +
> +static void do_output(struct datapath *dp, struct sk_buff *skb, int 
> out_port,
> +		      struct sw_flow_key *key)
>  {
>  	struct vport *vport = ovs_vport_rcu(dp, out_port);
>  
> -	if (likely(vport))
> -		ovs_vport_send(vport, skb);
> -	else
> +	if (likely(vport)) {
> +		unsigned int mru = OVS_CB(skb)->mru;
> +		struct dst_entry *orig_dst = dst_clone(skb_dst(skb));
> +
> +		if (!mru || (skb->len <= mru + ETH_HLEN)) {
> +			ovs_vport_send(vport, skb);
> +		} else if (!vport->dev) {
> +			WARN_ONCE(1, "Cannot fragment packets to 
> vport %s\n",
> +				  vport->ops->get_name(vport));
> +			kfree_skb(skb);
> +		} else if (mru > vport->dev->mtu) {
> +			kfree_skb(skb);
> +		} else if (key->eth.type == htons(ETH_P_IP)) {
> +			struct dst_entry ovs_dst;
> +
> +			prepare_frag(vport, key, skb);
> +			dst_init(&ovs_dst, &ovs_dst_ops, vport->dev,
> +				 1, DST_OBSOLETE_NONE, DST_NOCOUNT);

I don't think we should take a ref on the netdev here.

dst_init(&ovs_dst, &ovs_dst_ops, NULL,
         1, DST_OBSOLETE_NONE, DST_NOCOUNT);
ovs_dst.dev = vport->dev;

> +
> +			skb_dst_drop(skb);
> +			skb_dst_set_noref(skb, &ovs_dst);
> +			IPCB(skb)->frag_max_size = mru;
> +
> +			ip_do_fragment(skb->sk, skb, 
> ovs_vport_output);
> +			dev_put(ovs_dst.dev);

Can be removed then.

It seems a little strange to leave the skb->dst attached to the skb but
drop the reference from the netdevice here. Maybe a comment would make
sense, otherwise it smells fishy.

> +		} else if (key->eth.type == htons(ETH_P_IPV6)) {
> +			const struct nf_ipv6_ops *v6ops = 
> nf_get_ipv6_ops();
> +			struct rt6_info ovs_rt;
> +
> +			if (!v6ops) {
> +				kfree_skb(skb);
> +				goto exit;
> +			}
> +
> +			prepare_frag(vport, key, skb);
> +			memset(&ovs_rt, 0, sizeof(ovs_rt));
> +			dst_init(&ovs_rt.dst, &ovs_dst_ops, vport
> ->dev,
> +				 1, DST_OBSOLETE_NONE, DST_NOCOUNT);
> +
> +			skb_dst_drop(skb);
> +			skb_dst_set_noref(skb, &ovs_rt.dst);
> +			IP6CB(skb)->frag_max_size = mru;
> +
> +			v6ops->fragment(skb->sk, skb, 
> ovs_vport_output);
> +			dev_put(ovs_rt.dst.dev);

Same thought applies here.

> +		} else {
> +			WARN_ONCE(1, "Failed fragment to %s: MRU=%d, 
> MTU=%d.",
> +				  ovs_vport_name(vport), mru, vport
> ->dev->mtu);
> +			kfree_skb(skb);
> +		}
> +exit:
> +		dst_release(orig_dst);
> +	} else {
>  		kfree_skb(skb);
> +	}
>  }
>  
>  static int output_userspace(struct datapath *dp, struct sk_buff *skb,
> @@ -615,6 +750,10 @@ static int output_userspace(struct datapath *dp, 
> struct sk_buff *skb,
>  
>  	memset(&upcall, 0, sizeof(upcall));
>  	upcall.cmd = OVS_PACKET_CMD_ACTION;
> +	upcall.userdata = NULL;
> +	upcall.portid = 0;
> +	upcall.egress_tun_info = NULL;
> +	upcall.mru = OVS_CB(skb)->mru;
>  
>  	for (a = nla_data(attr), rem = nla_len(attr); rem > 0;
>  		 a = nla_next(a, &rem)) {
> @@ -874,7 +1013,7 @@ static int do_execute_actions(struct datapath 
> *dp, struct sk_buff *skb,
>  			struct sk_buff *out_skb = skb_clone(skb, 
> GFP_ATOMIC);
>  
>  			if (out_skb)
> -				do_output(dp, out_skb, prev_port);
> +				do_output(dp, out_skb, prev_port, 
> key);
>  
>  			prev_port = -1;
>  		}
> @@ -931,16 +1070,25 @@ static int do_execute_actions(struct datapath 
> *dp, struct sk_buff *skb,
>  		case OVS_ACTION_ATTR_SAMPLE:
>  			err = sample(dp, skb, key, a, attr, len);
>  			break;
> +
> +		case OVS_ACTION_ATTR_CT:
> +			err = ovs_ct_execute(skb, key, nla_data(a));
> +			break;
>  		}
>  
>  		if (unlikely(err)) {
> -			kfree_skb(skb);
> +			/* Hide stolen fragments from user space. */
> +			if (err == -EINPROGRESS)
> +				err = 0;
> +			else
> +				kfree_skb(skb);
> +
>  			return err;
>  		}
>  	}
>  
>  	if (prev_port != -1)
> -		do_output(dp, skb, prev_port);
> +		do_output(dp, skb, prev_port, key);
>  	else
>  		consume_skb(skb);
>  


Bye,
Hannes
