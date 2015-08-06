From: Pravin Shelar <pshelar@nicira.com>
Subject: Re: [PATCHv2 net-next 5/9] openvswitch: Add conntrack action
Date: Thu, 6 Aug 2015 14:36:34 -0700
Message-ID: <CALnjE+pd1PcyBF5i+oL1bkiv6sSzCeBY4OQnP53N3v=FfeB05g@mail.gmail.com>
References: <1438750199-9061-1-git-send-email-joestringer@nicira.com>
	<1438750199-9061-6-git-send-email-joestringer@nicira.com>
	<CALnjE+qbjaFAm8b7zkcQuWBo6SFN=P4XNGg36s3-pg=6JLrt3A@mail.gmail.com>
	<CANr6G5yV6BNN_s40eFkGm09cWYEnrXRbJ5rZd7NX48CEF6sCEg@mail.gmail.com>
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
In-Reply-To: <CANr6G5yV6BNN_s40eFkGm09cWYEnrXRbJ5rZd7NX48CEF6sCEg@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Aug 6, 2015 at 11:07 AM, Joe Stringer <joestringer@nicira.com> wrote:
> On 5 August 2015 at 15:31, Pravin Shelar <pshelar@nicira.com> wrote:
>> On Tue, Aug 4, 2015 at 9:49 PM, Joe Stringer <joestringer@nicira.com> wrote:
>> I got sparse warning:
>>
>> net/openvswitch/actions.c:634:1: warning: symbol 'ovs_dst_get_mtu' was
>> not declared. Should it be static?
>>
>> net/openvswitch/actions.c:703:17: warning: cast from restricted __be16
>>
>> net/openvswitch/actions.c:703:17: warning: incorrect type in argument
>> 1 (different base types)
>>
>> net/openvswitch/actions.c:703:17:    expected unsigned short
>> [unsigned] [usertype] val
>>
>> net/openvswitch/actions.c:703:17:    got restricted __be16 [usertype] ethertype
>>
>> net/openvswitch/actions.c:703:17: warning: cast from restricted __be16
>>
>> net/openvswitch/actions.c:703:17: warning: cast from restricted __be16
>
> Hrm, thanks. I'll figure out why I wasn't getting any warnings and fix these up.
>
I used following sparse parameters:
make C=1 CF="-Wsparse-all -D__CHECKER__ -D__CHECK_ENDIAN__ -Wbitwise"

>>> -static void do_output(struct datapath *dp, struct sk_buff *skb, int out_port)
>>> +static int ovs_vport_output(struct sock *sock, struct sk_buff *skb)
>>> +{
>>> +       struct ovs_frag_data *data = this_cpu_ptr(&ovs_frag_data_storage);
>>> +       struct vport *vport = data->vport;
>>> +
>>> +       if (skb_cow_head(skb, data->l2_len) < 0)
>>> +               return -ENOMEM;
>>> +
>> Need to free skb here.
>
> OK.
>
>>> +       skb->_skb_refdst = data->dst;
>> I think we need to clone dst if there are multiple fragments.
>> Can you test this code with vxlan flow based tunnels?
>
> In prepare_frag(), we're currently doing:
> data->dst = skb->_skb_refdst & SKB_DST_NOREF
>
> Which means that the fragments shouldn't need an additional reference.
> However it also means that the original reference is never freed. I
> think we just need to add the final free of the original reference
> after fragmentation is finished, in ovs_fragment(). I'll do this.
>
Each fragment needs to have its reference on the dst-entry if it is
reference counted dst entry.

> I assume that's the same as just setting up OVS with a vxlan tunnel
> and sending some traffic across it with different sizes. I have a test
> case for that:
> https://github.com/joestringer/openvswitch/blob/dev/ct_20150806/tests/kmod-traffic.at#L964
>
ok


>
>>> +static void ovs_fragment(struct vport *vport, struct sk_buff *skb,
>>> +                        unsigned int mru, __be16 ethertype)
>>> +{
>>> +       if (skb_network_offset(skb) > MAX_L2_LEN) {
>>> +               OVS_NLERR(1, "L2 header too long to fragment");
>>> +               return;
>>> +       }
>>> +
>>> +       if (ethertype == htons(ETH_P_IP)) {
>>> +               struct dst_entry ovs_dst;
>>> +
>>> +               prepare_frag(vport, skb);
>>> +               dst_init(&ovs_dst, &ovs_dst_ops, NULL, 1,
>>> +                        DST_OBSOLETE_NONE, DST_NOCOUNT);
>>> +               ovs_dst.dev = vport->dev;
>>> +
>>> +               skb_dst_set_noref(skb, &ovs_dst);
>>> +               IPCB(skb)->frag_max_size = mru;
>>> +
>>> +               ip_do_fragment(skb->sk, skb, ovs_vport_output);
>>> +       } else if (ethertype == htons(ETH_P_IPV6)) {
>>> +               const struct nf_ipv6_ops *v6ops = nf_get_ipv6_ops();
>>> +               struct rt6_info ovs_rt;
>>> +
>>> +               if (!v6ops) {
>>> +                       kfree_skb(skb);
>>> +                       return;
>>> +               }
>>> +
>>> +               prepare_frag(vport, skb);
>>> +               memset(&ovs_rt, 0, sizeof(ovs_rt));
>>> +               dst_init(&ovs_rt.dst, &ovs_dst_ops, NULL, 1,
>>> +                        DST_OBSOLETE_NONE, DST_NOCOUNT);
>>> +               ovs_rt.dst.dev = vport->dev;
>>> +
>>> +               skb_dst_set_noref(skb, &ovs_rt.dst);
>>> +               IP6CB(skb)->frag_max_size = mru;
>>> +
>>> +               v6ops->fragment(skb->sk, skb, ovs_vport_output);
>>> +       } else {
>>> +               WARN_ONCE(1, "Failed fragment ->%s: eth=%04x, MRU=%d, MTU=%d.",
>>> +                         ovs_vport_name(vport), htons(ethertype), mru,
>>> +                         vport->dev->mtu);
>>> +               kfree_skb(skb);
>>> +       }
>>> +}
>>> +
>> We also need something similar of this packet is going to userspace so
>> that we can send original packets to userspace. Otherwise we would
>> send defragmented packet to userspace.
>
> OK, in that case we'll need to get an MTU from somewhere. I'll look at
> using the MRU as the MTU for this path, since corner cases where the
> MRU is greater than the netlink payload size seems pretty unlikely
> (and the netlink sending code should already handle such cases). The
> other concern I have is exactly how this should be presented to
> userspace. Currently the conntrack action is treated an an implicit
> reassembly, which will implicitly refragment on output. In between, it
> remains defragmented. If we fragment on miss, then lookup will use the
> key representing the defragmented packet (ie no OVS_FRAG_TYPE_* bits
> set), so we should send the same up to userspace. I assume that
> userspace would then re-parse the packets and see that they are
> fragments for representing up to the higher layers like OpenFlow, but
> for flow installation it would reuse the key passed up from the
> kernel. Is that the model you have in mind?
>
Right, Reassembly is transparent to cantrack action, so it should be
to userspace. But this means we will need to fragment in upcall and
defrag the skb again when the packet reenter kernel module from packet
execute code path if we the action need to look at entire packet. So
lets just keep it based on MRU parameter and we can enhance it later
if we need it.
