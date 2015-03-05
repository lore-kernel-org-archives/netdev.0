From: Vivek Venkatraman <vivek@cumulusnetworks.com>
Subject: Re: [PATCH net-next 2/7] mpls: Basic routing support
Date: Thu, 5 Mar 2015 08:36:58 -0800
Message-ID: <CAMs_D1-RkdA_Fy7VoY105vjEkkFZaAV_bvKtw9+qQFWsRyKRaQ@mail.gmail.com>
References: <874mq22imc.fsf_-_@x220.int.ebiederm.org>
	<20150303.144509.1694022322984204895.davem@davemloft.net>
	<87mw3tzv8u.fsf@x220.int.ebiederm.org>
	<20150303.153310.624302583835136622.davem@davemloft.net>
	<87h9u1y8y8.fsf_-_@x220.int.ebiederm.org>
	<87vbihtvts.fsf_-_@x220.int.ebiederm.org>
	<87k2yxtvmw.fsf_-_@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	roopa <roopa@cumulusnetworks.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	santiago@crfreenet.org, Simon Horman <horms@verge.net.au>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f182.google.com ([209.85.212.182]:36020 "EHLO
	mail-wi0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750789AbbCEQg7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Mar 2015 11:36:59 -0500
Received: by widem10 with SMTP id em10so40022670wid.1
        for <netdev@vger.kernel.org>; Thu, 05 Mar 2015 08:36:58 -0800 (PST)
In-Reply-To: <87k2yxtvmw.fsf_-_@x220.int.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 3, 2015 at 5:10 PM, Eric W. Biederman <ebiederm@xmission.com> wrote:
>
> This change adds a new Kconfig option MPLS_ROUTING.
>
> The core of this change is the code to look at an mpls packet received
> from another machine.  Look that packet up in a routing table and
> forward the packet on.
>
> Support of MPLS over ATM is not considered or attempted here.  This
> implemntation follows RFC3032 and implements the MPLS shim header that
> can pass over essentially any network.
>
> What RFC3021 refers to as the as the Incoming Label Map (ILM) I call
> net->mpls.platform_label[].  What RFC3031 refers to as the Next Label
> Hop Forwarding Entry (NHLFE) I call mpls_route.  Though calling it the
> label fordwarding information base (lfib) might also be valid.
>

This currently does not allow for ECMP when acting as a transit, correct?

> Further the implemntation forwards packets as described in RFC3032.
> There is no need and given the original motivation for MPLS a strong
> discincentive to have a flexible label forwarding path.  In essence
> the logic is the topmost label is read, looked up, removed, and
> replaced by 0 or more new lables and the sent out the specified
> interface to it's next hop.
>
> Quite a few optional features are not implemented here.  Among them
> are generation of ICMP errors when the TTL is exceeded or the packet
> is larger than the next hop MTU (those conditions are detected and the
> packets are dropped instead of generating an icmp error).  The traffic
> class field is always set to 0.  The implementation focuses on IP over
> MPLS and does not handle egress of other kinds of protocols.
>
> Instead of implementing coordination with the neighbour table and
> sorting out how to input next hops in a different address family (for
> which there is value).  I was lazy and implemented a next hop mac
> address instead.  The code is simpler and there are flavor of MPLS
> such as MPLS-TP where neither an IPv4 nor an IPv6 next hop is
> appropriate so a next hop by mac address would need to be implemented
> at some point.
>

I guess the above is no longer the case with this revised patch which
can support a IPv4 or IPv6 next hop too, right?

> Two new definitions AF_MPLS and PF_MPLS are exposed to userspace.
>
> Decoding the mpls header must be done by first byeswapping a 32bit bit
> endian word into the local cpu endian and then bit shifting to extract
> the pieces.  There is no C bit-field that can represent a wire format
> mpls header on a little endian machine as the low bits of the 20bit
> label wind up in the wrong half of third byte.  Therefore internally
> everything is deal with in cpu native byte order except when writing
> to and reading from a packet.
>
> For management simplicity if a label is configured to forward out
> an interface that is down the packet is dropped early.  Similarly
> if an network interface is removed rt_dev is updated to NULL
> (so no reference is preserved) and any packets for that label
> are dropped.  Keeping the label entries in the kernel allows
> the kernel label table to function as the definitive source
> of which labels are allocated and which are not.
>
> Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
> ---
>  include/linux/socket.h      |   2 +
>  include/net/net_namespace.h |   4 +
>  include/net/netns/mpls.h    |  15 ++
>  net/mpls/Kconfig            |   5 +
>  net/mpls/Makefile           |   1 +
>  net/mpls/af_mpls.c          | 349 ++++++++++++++++++++++++++++++++++++++++++++
>  net/mpls/internal.h         |  56 +++++++
>  7 files changed, 432 insertions(+)
>  create mode 100644 include/net/netns/mpls.h
>  create mode 100644 net/mpls/af_mpls.c
>  create mode 100644 net/mpls/internal.h
>
> <snip>
> +
> +static int mpls_forward(struct sk_buff *skb, struct net_device *dev,
> +                       struct packet_type *pt, struct net_device *orig_dev)
> +{
> +       struct net *net = dev_net(dev);
> +       struct mpls_shim_hdr *hdr;
> +       struct mpls_route *rt;
> +       struct mpls_entry_decoded dec;
> +       struct net_device *out_dev;
> +       unsigned int hh_len;
> +       unsigned int new_header_size;
> +       unsigned int mtu;
> +       int err;
> +
> +       /* Careful this entire function runs inside of an rcu critical section */
> +
> +       if (skb->pkt_type != PACKET_HOST)
> +               goto drop;
> +
> +       if ((skb = skb_share_check(skb, GFP_ATOMIC)) == NULL)
> +               goto drop;
> +
> +       if (!pskb_may_pull(skb, sizeof(*hdr)))
> +               goto drop;
> +
> +       /* Read and decode the label */
> +       hdr = mpls_hdr(skb);
> +       dec = mpls_entry_decode(hdr);
> +
> +       /* Pop the label */
> +       skb_pull(skb, sizeof(*hdr));
> +       skb_reset_network_header(skb);
> +
> +       skb_orphan(skb);
> +
> +       rt = mpls_route_input_rcu(net, dec.label);
> +       if (!rt)
> +               goto drop;
> +
> +       /* Find the output device */
> +       out_dev = rt->rt_dev;
> +       if (!mpls_output_possible(out_dev))
> +               goto drop;
> +
> +       if (skb_warn_if_lro(skb))
> +               goto drop;
> +
> +       skb_forward_csum(skb);
> +
> +       /* Verify ttl is valid */
> +       if (dec.ttl <= 2)

Why is this "<= 2"?

> +               goto drop;
> +       dec.ttl -= 1;
> +
> +       /* Verify the destination can hold the packet */
> +       new_header_size = mpls_rt_header_size(rt);
> +       mtu = mpls_dev_mtu(out_dev);
> +       if (mpls_pkt_too_big(skb, mtu - new_header_size))
> +               goto drop;
> +
> +       hh_len = LL_RESERVED_SPACE(out_dev);
> +       if (!out_dev->header_ops)
> +               hh_len = 0;
> +
> +       /* Ensure there is enough space for the headers in the skb */
> +       if (skb_cow(skb, hh_len + new_header_size))
> +               goto drop;
> +
> +       skb->dev = out_dev;
> +       skb->protocol = htons(ETH_P_MPLS_UC);
> +
> +       if (unlikely(!new_header_size && dec.bos)) {
> +               /* Penultimate hop popping */
> +               if (!mpls_egress(rt, skb, dec))
> +                       goto drop;
> +       } else {
> +               bool bos;
> +               int i;
> +               skb_push(skb, new_header_size);
> +               skb_reset_network_header(skb);
> +               /* Push the new labels */
> +               hdr = mpls_hdr(skb);
> +               bos = dec.bos;
> +               for (i = rt->rt_labels - 1; i >= 0; i--) {
> +                       hdr[i] = mpls_entry_encode(rt->rt_label[i], dec.ttl, 0, bos);
> +                       bos = false;
> +               }
> +       }
> +
> +       err = neigh_xmit(rt->rt_via_family, out_dev, rt->rt_via, skb);
> +       if (err)
> +               net_dbg_ratelimited("%s: packet transmission failed: %d\n",
> +                                   __func__, err);
> +       return 0;
> +
> +drop:
> +       kfree_skb(skb);
> +       return NET_RX_DROP;
> +}
> +

Vivek
