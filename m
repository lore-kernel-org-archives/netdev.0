From: Joe Stringer <joestringer@nicira.com>
Subject: Re: [PATCHv2 net-next 5/9] openvswitch: Add conntrack action
Date: Mon, 10 Aug 2015 13:36:17 -0700
Message-ID: <CANr6G5wM+v0NkbsA5fVnU3qZgoDLoDbRkEgktcJsYyWS=-Sj7w@mail.gmail.com>
References: <1438750199-9061-1-git-send-email-joestringer@nicira.com>
 <1438750199-9061-6-git-send-email-joestringer@nicira.com> <CALnjE+qbjaFAm8b7zkcQuWBo6SFN=P4XNGg36s3-pg=6JLrt3A@mail.gmail.com>
 <CANr6G5yV6BNN_s40eFkGm09cWYEnrXRbJ5rZd7NX48CEF6sCEg@mail.gmail.com> <CALnjE+pd1PcyBF5i+oL1bkiv6sSzCeBY4OQnP53N3v=FfeB05g@mail.gmail.com>
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
To: Pravin Shelar <pshelar@nicira.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CALnjE+pd1PcyBF5i+oL1bkiv6sSzCeBY4OQnP53N3v=FfeB05g@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 6 August 2015 at 14:36, Pravin Shelar <pshelar@nicira.com> wrote:
>>>> +static void ovs_fragment(struct vport *vport, struct sk_buff *skb,
>>>> +                        unsigned int mru, __be16 ethertype)
>>>> +{
>>>> +       if (skb_network_offset(skb) > MAX_L2_LEN) {
>>>> +               OVS_NLERR(1, "L2 header too long to fragment");
>>>> +               return;
>>>> +       }
>>>> +
>>>> +       if (ethertype == htons(ETH_P_IP)) {
>>>> +               struct dst_entry ovs_dst;
>>>> +
>>>> +               prepare_frag(vport, skb);
>>>> +               dst_init(&ovs_dst, &ovs_dst_ops, NULL, 1,
>>>> +                        DST_OBSOLETE_NONE, DST_NOCOUNT);
>>>> +               ovs_dst.dev = vport->dev;
>>>> +
>>>> +               skb_dst_set_noref(skb, &ovs_dst);
>>>> +               IPCB(skb)->frag_max_size = mru;
>>>> +
>>>> +               ip_do_fragment(skb->sk, skb, ovs_vport_output);
>>>> +       } else if (ethertype == htons(ETH_P_IPV6)) {
>>>> +               const struct nf_ipv6_ops *v6ops = nf_get_ipv6_ops();
>>>> +               struct rt6_info ovs_rt;
>>>> +
>>>> +               if (!v6ops) {
>>>> +                       kfree_skb(skb);
>>>> +                       return;
>>>> +               }
>>>> +
>>>> +               prepare_frag(vport, skb);
>>>> +               memset(&ovs_rt, 0, sizeof(ovs_rt));
>>>> +               dst_init(&ovs_rt.dst, &ovs_dst_ops, NULL, 1,
>>>> +                        DST_OBSOLETE_NONE, DST_NOCOUNT);
>>>> +               ovs_rt.dst.dev = vport->dev;
>>>> +
>>>> +               skb_dst_set_noref(skb, &ovs_rt.dst);
>>>> +               IP6CB(skb)->frag_max_size = mru;
>>>> +
>>>> +               v6ops->fragment(skb->sk, skb, ovs_vport_output);
>>>> +       } else {
>>>> +               WARN_ONCE(1, "Failed fragment ->%s: eth=%04x, MRU=%d, MTU=%d.",
>>>> +                         ovs_vport_name(vport), htons(ethertype), mru,
>>>> +                         vport->dev->mtu);
>>>> +               kfree_skb(skb);
>>>> +       }
>>>> +}
>>>> +
>>> We also need something similar of this packet is going to userspace so
>>> that we can send original packets to userspace. Otherwise we would
>>> send defragmented packet to userspace.
>>
>> OK, in that case we'll need to get an MTU from somewhere. I'll look at
>> using the MRU as the MTU for this path, since corner cases where the
>> MRU is greater than the netlink payload size seems pretty unlikely
>> (and the netlink sending code should already handle such cases). The
>> other concern I have is exactly how this should be presented to
>> userspace. Currently the conntrack action is treated an an implicit
>> reassembly, which will implicitly refragment on output. In between, it
>> remains defragmented. If we fragment on miss, then lookup will use the
>> key representing the defragmented packet (ie no OVS_FRAG_TYPE_* bits
>> set), so we should send the same up to userspace. I assume that
>> userspace would then re-parse the packets and see that they are
>> fragments for representing up to the higher layers like OpenFlow, but
>> for flow installation it would reuse the key passed up from the
>> kernel. Is that the model you have in mind?
>>
> Right, Reassembly is transparent to cantrack action, so it should be
> to userspace. But this means we will need to fragment in upcall and
> defrag the skb again when the packet reenter kernel module from packet
> execute code path if we the action need to look at entire packet. So
> lets just keep it based on MRU parameter and we can enhance it later
> if we need it.

OK, we'll retain the upcall MRU and keep it assembled for the moment,
so the implicit "conntrack will reassemble" behaviour is retained from
this version. I'll fix up the other issues and send v3, thanks.
