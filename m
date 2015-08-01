From: Pravin Shelar <pshelar@nicira.com>
Subject: Re: [PATCH net-next 5/9] openvswitch: Add conntrack action
Date: Fri, 31 Jul 2015 19:08:07 -0700
Message-ID: <CALnjE+qdMA08zWRj_uDw0BQvQ1Q6H+C9Pz+ey1cM7_xX2EawFg@mail.gmail.com>
References: <1438279963-29563-1-git-send-email-joestringer@nicira.com>
	<1438279963-29563-6-git-send-email-joestringer@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>, pablo <pablo@netfilter.org>,
	Patrick McHardy <kaber@trash.net>,
	Justin Pettit <jpettit@nicira.com>,
	Andy Zhou <azhou@nicira.com>, Jesse Gross <jesse@nicira.com>,
	Florian Westphal <fwestpha@redhat.com>,
	Hannes Sowa <hannes@redhat.com>,
	Thomas Graf <tgraf@noironetworks.com>
To: Joe Stringer <joestringer@nicira.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1438279963-29563-6-git-send-email-joestringer@nicira.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jul 30, 2015 at 11:12 AM, Joe Stringer <joestringer@nicira.com> wrote:
> Expose the kernel connection tracker via OVS. Userspace components can
> make use of the "ct()" action, followed by "recirculate", to populate
> the conntracking state in the OVS flow key, and subsequently match on
> that state.
>
> Example ODP flows allowing traffic from 1->2, only replies from 2->1:
> in_port=1,tcp,action=ct(commit,zone=1),2
> in_port=2,ct_state=-trk,tcp,action=ct(zone=1),recirc(1)
> recirc_id=1,in_port=2,ct_state=+trk+est-new,tcp,action=1
>
> IP fragments are handled by transparently assembling them as part of the
> ct action. The maximum received unit (MRU) size is tracked so that
> refragmentation can occur during output.
>
> IP frag handling contributed by Andy Zhou.
>
> Signed-off-by: Joe Stringer <joestringer@nicira.com>
> Signed-off-by: Justin Pettit <jpettit@nicira.com>
> Signed-off-by: Andy Zhou <azhou@nicira.com>
> ---
> This can be tested with the corresponding userspace component here:
> https://www.github.com/justinpettit/openvswitch conntrack
> ---
>  include/uapi/linux/openvswitch.h |  41 ++++
>  net/openvswitch/Kconfig          |  11 +
>  net/openvswitch/Makefile         |   1 +
>  net/openvswitch/actions.c        | 162 ++++++++++++-
>  net/openvswitch/conntrack.c      | 480 +++++++++++++++++++++++++++++++++++++++
>  net/openvswitch/conntrack.h      |  82 +++++++
>  net/openvswitch/datapath.c       |  62 +++--
>  net/openvswitch/datapath.h       |   6 +
>  net/openvswitch/flow.c           |   3 +
>  net/openvswitch/flow.h           |   6 +
>  net/openvswitch/flow_netlink.c   |  73 ++++--
>  net/openvswitch/flow_netlink.h   |   4 +-
>  net/openvswitch/vport.c          |   1 +
>  13 files changed, 897 insertions(+), 35 deletions(-)
>  create mode 100644 net/openvswitch/conntrack.c
>  create mode 100644 net/openvswitch/conntrack.h
>
...

> diff --git a/net/openvswitch/actions.c b/net/openvswitch/actions.c
> index e50678d..4a62ed4 100644
> --- a/net/openvswitch/actions.c
> +++ b/net/openvswitch/actions.c
> @@ -22,6 +22,7 @@
>  #include <linux/in.h>
>  #include <linux/ip.h>

..
>  static int do_execute_actions(struct datapath *dp, struct sk_buff *skb,
> @@ -52,6 +55,16 @@ struct deferred_action {
>         struct sw_flow_key pkt_key;
>  };
>
> +struct ovs_frag_data {
> +       struct dst_entry *dst;
> +       struct vport *vport;
> +       struct sw_flow_key *key;
> +       struct ovs_skb_cb cb;
> +       __be16 vlan_proto;
> +};
> +
> +static DEFINE_PER_CPU(struct ovs_frag_data, ovs_frag_data_storage);
> +
>  #define DEFERRED_ACTION_FIFO_SIZE 10
>  struct action_fifo {
>         int head;
> @@ -594,14 +607,136 @@ static int set_sctp(struct sk_buff *skb, struct sw_flow_key *flow_key,
>         return 0;
>  }
>
> -static void do_output(struct datapath *dp, struct sk_buff *skb, int out_port)
> +/* Given an IP frame, reconstruct its MAC header.  */
> +static void ovs_setup_l2_header(struct sk_buff *skb,
> +                               const struct ovs_frag_data *data)
> +{
> +       struct sw_flow_key *key = data->key;
> +
> +       skb_push(skb, ETH_HLEN);
> +       skb_reset_mac_header(skb);
> +
> +       ether_addr_copy(eth_hdr(skb)->h_source, key->eth.src);
> +       ether_addr_copy(eth_hdr(skb)->h_dest, key->eth.dst);
> +       eth_hdr(skb)->h_proto = key->eth.type;
> +
> +       if ((data->key->eth.tci & htons(VLAN_TAG_PRESENT)) &&
> +           !skb_vlan_tag_present(skb))
> +               __vlan_hwaccel_put_tag(skb, data->vlan_proto,
> +                                      ntohs(key->eth.tci));
> +}
> +
> +static void prepare_frag(struct vport *vport, struct sw_flow_key *key,
> +                        struct sk_buff *skb)
> +{
> +       unsigned int hlen = ETH_HLEN;
> +       struct ovs_frag_data *data;
> +
> +       data = this_cpu_ptr(&ovs_frag_data_storage);
> +       data->dst = skb_dst(skb);
> +       data->vport = vport;
> +       data->key = key;
> +       data->cb = *OVS_CB(skb);
> +
> +       if (key->eth.tci & htons(VLAN_TAG_PRESENT)) {
> +               if (skb_vlan_tag_present(skb)) {
> +                       data->vlan_proto = skb->vlan_proto;
> +               } else {
> +                       data->vlan_proto = vlan_eth_hdr(skb)->h_vlan_proto;
> +                       hlen += VLAN_HLEN;
> +               }
> +       }
Not all actions keep flow key uptodate, so here you can access stale values.

> +
> +       memset(IPCB(skb), 0, sizeof(struct inet_skb_parm));
> +       skb_pull(skb, hlen);
> +}
> +
> +static int ovs_vport_output(struct sock *sock, struct sk_buff *skb)
> +{
> +       struct ovs_frag_data *data = this_cpu_ptr(&ovs_frag_data_storage);
> +       struct vport *vport = data->vport;
> +
> +       skb_dst_drop(skb);
> +       skb_dst_set(skb, dst_clone(data->dst));
> +       *OVS_CB(skb) = data->cb;
> +
> +       ovs_setup_l2_header(skb, data);
> +       ovs_vport_send(vport, skb);
> +
> +       return 0;
> +}
> +
...
> +static void do_output(struct datapath *dp, struct sk_buff *skb, int out_port,
> +                     struct sw_flow_key *key)
>  {
>         struct vport *vport = ovs_vport_rcu(dp, out_port);
>
> -       if (likely(vport))
> -               ovs_vport_send(vport, skb);
> -       else
> +       if (likely(vport)) {
> +               unsigned int mru = OVS_CB(skb)->mru;
> +               struct dst_entry *orig_dst = dst_clone(skb_dst(skb));
> +
> +               if (!mru || (skb->len <= mru + ETH_HLEN)) {
This should be marked as likely() case.

> +                       ovs_vport_send(vport, skb);
> +               } else if (!vport->dev) {
> +                       WARN_ONCE(1, "Cannot fragment packets to vport %s\n",
> +                                 vport->ops->get_name(vport));
> +                       kfree_skb(skb);
> +               } else if (mru > vport->dev->mtu) {
> +                       kfree_skb(skb);
> +               } else if (key->eth.type == htons(ETH_P_IP)) {
> +                       struct dst_entry ovs_dst;
> +
> +                       prepare_frag(vport, key, skb);
> +                       dst_init(&ovs_dst, &ovs_dst_ops, vport->dev,
> +                                1, DST_OBSOLETE_NONE, DST_NOCOUNT);
> +
> +                       skb_dst_drop(skb);
> +                       skb_dst_set_noref(skb, &ovs_dst);
> +                       IPCB(skb)->frag_max_size = mru;
> +
> +                       ip_do_fragment(skb->sk, skb, ovs_vport_output);
> +                       dev_put(ovs_dst.dev);
> +               } else if (key->eth.type == htons(ETH_P_IPV6)) {
> +                       const struct nf_ipv6_ops *v6ops = nf_get_ipv6_ops();
> +                       struct rt6_info ovs_rt;
> +
> +                       if (!v6ops) {
> +                               kfree_skb(skb);
> +                               goto exit;
> +                       }
> +
> +                       prepare_frag(vport, key, skb);
> +                       memset(&ovs_rt, 0, sizeof(ovs_rt));
> +                       dst_init(&ovs_rt.dst, &ovs_dst_ops, vport->dev,
> +                                1, DST_OBSOLETE_NONE, DST_NOCOUNT);
> +
> +                       skb_dst_drop(skb);
> +                       skb_dst_set_noref(skb, &ovs_rt.dst);
> +                       IP6CB(skb)->frag_max_size = mru;
> +
> +                       v6ops->fragment(skb->sk, skb, ovs_vport_output);
> +                       dev_put(ovs_rt.dst.dev);
> +               } else {
> +                       WARN_ONCE(1, "Failed fragment to %s: MRU=%d, MTU=%d.",
> +                                 ovs_vport_name(vport), mru, vport->dev->mtu);
It would be helpful if the msg also mentions key->eth.type.

> +                       kfree_skb(skb);
> +               }
> +exit:
> +               dst_release(orig_dst);
> +       } else {
>                 kfree_skb(skb);
> +       }
>  }
>
>  static int output_userspace(struct datapath *dp, struct sk_buff *skb,
> @@ -615,6 +750,10 @@ static int output_userspace(struct datapath *dp, struct sk_buff *skb,
>
>         memset(&upcall, 0, sizeof(upcall));
>         upcall.cmd = OVS_PACKET_CMD_ACTION;
> +       upcall.userdata = NULL;
> +       upcall.portid = 0;
> +       upcall.egress_tun_info = NULL;
> +       upcall.mru = OVS_CB(skb)->mru;
>
>         for (a = nla_data(attr), rem = nla_len(attr); rem > 0;
>                  a = nla_next(a, &rem)) {
> @@ -874,7 +1013,7 @@ static int do_execute_actions(struct datapath *dp, struct sk_buff *skb,
>                         struct sk_buff *out_skb = skb_clone(skb, GFP_ATOMIC);
>
>                         if (out_skb)
> -                               do_output(dp, out_skb, prev_port);
> +                               do_output(dp, out_skb, prev_port, key);
>
>                         prev_port = -1;
>                 }
> @@ -931,16 +1070,25 @@ static int do_execute_actions(struct datapath *dp, struct sk_buff *skb,
>                 case OVS_ACTION_ATTR_SAMPLE:
>                         err = sample(dp, skb, key, a, attr, len);
>                         break;
> +
> +               case OVS_ACTION_ATTR_CT:
> +                       err = ovs_ct_execute(skb, key, nla_data(a));
> +                       break;
>                 }
>
>                 if (unlikely(err)) {
> -                       kfree_skb(skb);
> +                       /* Hide stolen fragments from user space. */
> +                       if (err == -EINPROGRESS)
> +                               err = 0;
This does not look safe for error returned from all cases, Can you
check this case specifically for the CT action case.

> +                       else
> +                               kfree_skb(skb);
> +
>                         return err;
>                 }
>         }
>
>         if (prev_port != -1)
> -               do_output(dp, skb, prev_port);
> +               do_output(dp, skb, prev_port, key);
>         else
>                 consume_skb(skb);
>
> diff --git a/net/openvswitch/conntrack.c b/net/openvswitch/conntrack.c
> new file mode 100644
> index 0000000..284b89e
> --- /dev/null
> +++ b/net/openvswitch/conntrack.c
> @@ -0,0 +1,480 @@

...
> +
> +static struct net *ovs_get_net(const struct sk_buff *skb)
> +{
> +       struct vport *vport;
> +
> +       vport = OVS_CB(skb)->input_vport;
> +       if (!vport) {
I do not think this is possible, OVS always initialize input_vport.

> +               WARN_ONCE(1, "Can't obtain netns from vport");
> +               return ERR_PTR(-EINVAL);
> +       }
> +
> +       return read_pnet(&vport->dp->net);
> +}
> +
...

> +
> +static inline void ovs_ct_free_action(const struct nlattr *a) { }
> +#endif
> +#endif /* ovs_conntrack.h */
> diff --git a/net/openvswitch/datapath.c b/net/openvswitch/datapath.c
> index d5b5473..23717a3 100644
> --- a/net/openvswitch/datapath.c
> +++ b/net/openvswitch/datapath.c
> @@ -275,6 +275,8 @@ void ovs_dp_process_packet(struct sk_buff *skb, struct sw_flow_key *key)
>                 memset(&upcall, 0, sizeof(upcall));
>                 upcall.cmd = OVS_PACKET_CMD_MISS;
>                 upcall.portid = ovs_vport_find_upcall_portid(p, skb);
> +               upcall.egress_tun_info = NULL;
There is no need to set egress_tun_info to NULL.

> +               upcall.mru = OVS_CB(skb)->mru;
>                 error = ovs_dp_upcall(dp, skb, key, &upcall);
>                 if (unlikely(error))
>                         kfree_skb(skb);
> @@ -400,9 +402,23 @@ static size_t upcall_msg_size(const struct dp_upcall_info *upcall_info,
