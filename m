From: Pravin Shelar <pshelar@nicira.com>
Subject: Re: [PATCHv2 net-next 5/9] openvswitch: Add conntrack action
Date: Wed, 5 Aug 2015 15:31:14 -0700
Message-ID: <CALnjE+qbjaFAm8b7zkcQuWBo6SFN=P4XNGg36s3-pg=6JLrt3A@mail.gmail.com>
References: <1438750199-9061-1-git-send-email-joestringer@nicira.com>
	<1438750199-9061-6-git-send-email-joestringer@nicira.com>
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
In-Reply-To: <1438750199-9061-6-git-send-email-joestringer@nicira.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Aug 4, 2015 at 9:49 PM, Joe Stringer <joestringer@nicira.com> wrote:
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
>
> v2: Don't take references to devs or dsts in output path.
>     Shift ovs_ct_init()/ovs_ct_exit() into this patch
>     Handle output case where flow key is invalidated
>     Store the entire L2 header to apply to fragments
>     Various minor simplifications
>     Improve comments/logs
>     Style fixes
>     Rebase
> ---
>  include/uapi/linux/openvswitch.h |  41 ++++
>  net/openvswitch/Kconfig          |  11 +
>  net/openvswitch/Makefile         |   2 +
>  net/openvswitch/actions.c        | 154 ++++++++++++-
>  net/openvswitch/conntrack.c      | 475 +++++++++++++++++++++++++++++++++++++++
>  net/openvswitch/conntrack.h      |  97 ++++++++
>  net/openvswitch/datapath.c       |  73 ++++--
>  net/openvswitch/datapath.h       |   8 +
>  net/openvswitch/flow.c           |   3 +
>  net/openvswitch/flow.h           |   6 +
>  net/openvswitch/flow_netlink.c   |  72 ++++--
>  net/openvswitch/flow_netlink.h   |   4 +-
>  net/openvswitch/vport.c          |   1 +
>  13 files changed, 910 insertions(+), 37 deletions(-)
>  create mode 100644 net/openvswitch/conntrack.c
>  create mode 100644 net/openvswitch/conntrack.h
>

I got sparse warning:

net/openvswitch/actions.c:634:1: warning: symbol 'ovs_dst_get_mtu' was
not declared. Should it be static?

net/openvswitch/actions.c:703:17: warning: cast from restricted __be16

net/openvswitch/actions.c:703:17: warning: incorrect type in argument
1 (different base types)

net/openvswitch/actions.c:703:17:    expected unsigned short
[unsigned] [usertype] val

net/openvswitch/actions.c:703:17:    got restricted __be16 [usertype] ethertype

net/openvswitch/actions.c:703:17: warning: cast from restricted __be16

net/openvswitch/actions.c:703:17: warning: cast from restricted __be16



> -static void do_output(struct datapath *dp, struct sk_buff *skb, int out_port)
> +static int ovs_vport_output(struct sock *sock, struct sk_buff *skb)
> +{
> +       struct ovs_frag_data *data = this_cpu_ptr(&ovs_frag_data_storage);
> +       struct vport *vport = data->vport;
> +
> +       if (skb_cow_head(skb, data->l2_len) < 0)
> +               return -ENOMEM;
> +
Need to free skb here.

> +       skb->_skb_refdst = data->dst;
I think we need to clone dst if there are multiple fragments.
Can you test this code with vxlan flow based tunnels?

> +       *OVS_CB(skb) = data->cb;
> +
> +       /* Reconstruct the MAC header.  */
> +       skb_push(skb, data->l2_len);
> +       memcpy(skb->data, &data->l2_data, data->l2_len);
> +       skb_reset_mac_header(skb);
> +       skb->protocol = eth_hdr(skb)->h_proto;
why do we need to restore skb->protocol?
> +       skb->vlan_tci = 0;
> +
Why is vlan_tci set to zero.

> +       ovs_vport_send(vport, skb);
> +       return 0;
> +}
> +
> +unsigned int
> +ovs_dst_get_mtu(const struct dst_entry *dst)
> +{
> +       return dst->dev->mtu;
> +}
> +
...

> +static void ovs_fragment(struct vport *vport, struct sk_buff *skb,
> +                        unsigned int mru, __be16 ethertype)
> +{
> +       if (skb_network_offset(skb) > MAX_L2_LEN) {
> +               OVS_NLERR(1, "L2 header too long to fragment");
> +               return;
> +       }
> +
> +       if (ethertype == htons(ETH_P_IP)) {
> +               struct dst_entry ovs_dst;
> +
> +               prepare_frag(vport, skb);
> +               dst_init(&ovs_dst, &ovs_dst_ops, NULL, 1,
> +                        DST_OBSOLETE_NONE, DST_NOCOUNT);
> +               ovs_dst.dev = vport->dev;
> +
> +               skb_dst_set_noref(skb, &ovs_dst);
> +               IPCB(skb)->frag_max_size = mru;
> +
> +               ip_do_fragment(skb->sk, skb, ovs_vport_output);
> +       } else if (ethertype == htons(ETH_P_IPV6)) {
> +               const struct nf_ipv6_ops *v6ops = nf_get_ipv6_ops();
> +               struct rt6_info ovs_rt;
> +
> +               if (!v6ops) {
> +                       kfree_skb(skb);
> +                       return;
> +               }
> +
> +               prepare_frag(vport, skb);
> +               memset(&ovs_rt, 0, sizeof(ovs_rt));
> +               dst_init(&ovs_rt.dst, &ovs_dst_ops, NULL, 1,
> +                        DST_OBSOLETE_NONE, DST_NOCOUNT);
> +               ovs_rt.dst.dev = vport->dev;
> +
> +               skb_dst_set_noref(skb, &ovs_rt.dst);
> +               IP6CB(skb)->frag_max_size = mru;
> +
> +               v6ops->fragment(skb->sk, skb, ovs_vport_output);
> +       } else {
> +               WARN_ONCE(1, "Failed fragment ->%s: eth=%04x, MRU=%d, MTU=%d.",
> +                         ovs_vport_name(vport), htons(ethertype), mru,
> +                         vport->dev->mtu);
> +               kfree_skb(skb);
> +       }
> +}
> +
We also need something similar of this packet is going to userspace so
that we can send original packets to userspace. Otherwise we would
send defragmented packet to userspace.

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
> +
> +               if (likely(!mru || (skb->len <= mru + ETH_HLEN))) {
> +                       ovs_vport_send(vport, skb);
> +               } else if (mru <= vport->dev->mtu) {
> +                       __be16 ethertype = key->eth.type;
> +
> +                       if (!is_flow_key_valid(key)) {
> +                               if (eth_p_mpls(skb->protocol))
> +                                       ethertype = skb->inner_protocol;
> +                               else
> +                                       ethertype = vlan_get_protocol(skb);
> +                       }
> +
This looks nice!

> +                       ovs_fragment(vport, skb, mru, ethertype);
> +               } else {
> +                       kfree_skb(skb);
> +               }
> +       } else {
>                 kfree_skb(skb);
> +       }
>  }
>
...
> diff --git a/net/openvswitch/conntrack.c b/net/openvswitch/conntrack.c
> new file mode 100644
> index 0000000..586ce66
> --- /dev/null
> +++ b/net/openvswitch/conntrack.c
> @@ -0,0 +1,475 @@
...

> +int ovs_ct_copy_action(struct net *net, const struct nlattr *attr,
> +                      const struct sw_flow_key *key,
> +                      struct sw_flow_actions **sfa,  bool log)
> +{
> +       struct ovs_conntrack_info ct_info;
> +       u16 family;
> +       int err;
> +
> +       family = key_to_nfproto(key);
> +       if (family == NFPROTO_UNSPEC) {
> +               OVS_NLERR(log, "ct family unspecified");
> +               return -EINVAL;
> +       }
> +
> +       memset(&ct_info, 0, sizeof(ct_info));
> +       ct_info.family = family;
> +
> +       err = parse_ct(attr, &ct_info, log);
> +       if (err)
> +               return err;
> +
> +       /* Set up template for tracking connections in specific zones. */
> +       ct_info.ct = nf_ct_tmpl_alloc(net, ct_info.zone, GFP_KERNEL);
Do we need to take any lock to add the template?
