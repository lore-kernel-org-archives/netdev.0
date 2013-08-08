From: Jesse Gross <jesse@nicira.com>
Subject: Re: [PATCH v2.35 6/6] datapath: Add basic MPLS support to kernel
Date: Wed, 7 Aug 2013 17:39:55 -0700
Message-ID: <CAEP_g=-4gvJEbQ68=gBUpa-j2Kz_DX_zkV4KKvtewa=rbsSZiw@mail.gmail.com>
References: <1374289623-17056-1-git-send-email-horms@verge.net.au> <1374289623-17056-7-git-send-email-horms@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "dev@openvswitch.org" <dev@openvswitch.org>,
	netdev <netdev@vger.kernel.org>, Ravi K <rkerur@gmail.com>,
	Isaku Yamahata <yamahata@valinux.co.jp>,
	Pravin B Shelar <pshelar@nicira.com>,
	Jarno Rajahalme <jarno.rajahalme@nsn.com>,
	Joe Stringer <joe@wand.net.nz>
To: Simon Horman <horms@verge.net.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog119.obsmtp.com ([74.125.149.246]:49785 "HELO
	na3sys009aog119.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S933367Ab3HHAkS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Aug 2013 20:40:18 -0400
Received: by mail-lb0-f179.google.com with SMTP id v1so1982283lbd.38
        for <netdev@vger.kernel.org>; Wed, 07 Aug 2013 17:40:15 -0700 (PDT)
In-Reply-To: <1374289623-17056-7-git-send-email-horms@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jul 19, 2013 at 8:07 PM, Simon Horman <horms@verge.net.au> wrote:
> diff --git a/datapath/actions.c b/datapath/actions.c
> index 0a2def6..99e02cf 100644
> --- a/datapath/actions.c
> +++ b/datapath/actions.c
> +/* The end of the mac header.
> + *
> + * For non-MPLS skbs this will correspond to the network header.
> + * For MPLS skbs it will be berfore the network_header as the MPLS
> + * label stack lies between the end of the mac header and the network
> + * header. That is, for MPLS skbs the end of the mac header
> + * is the top of the MPLS label stack.
> + */
> +static unsigned char *mac_header_end(const struct sk_buff *skb)
> +{
> +       return skb_mac_header(skb) + skb->mac_len;
> +}
> +
> +static void set_ethertype(struct sk_buff *skb, __be16 ethertype, bool inner)
> +{
> +       struct ethhdr *hdr;
> +       if (inner)
> +               /* mac_header_end() is used to locate the ethertype
> +                * field correctly in the presence of VLAN tags. */
> +               hdr = (struct ethhdr *)(mac_header_end(skb) - ETH_HLEN);
> +       else
> +               hdr = (struct ethhdr *)(skb_mac_header(skb));
> +       hdr->h_proto = ethertype;
> +}
> +
> +/* Push MPLS after the ethernet header. We blindly ignore any other tags,
> + * assuming that actions are ordered correctly. */
> +static int push_mpls(struct sk_buff *skb,
> +                    const struct ovs_action_push_mpls *mpls)
> +{
> +       __be32 *new_mpls_lse;
> +       int err;
> +
> +       if (skb_cow_head(skb, MPLS_HLEN) < 0)
> +               return -ENOMEM;
> +
> +       err = make_writable(skb, skb->mac_len);
> +       if (unlikely(err))
> +               return err;
> +
> +       skb_push(skb, MPLS_HLEN);
> +       memmove(skb_mac_header(skb) - MPLS_HLEN, skb_mac_header(skb),
> +               ETH_HLEN);
> +       skb_reset_mac_header(skb);
> +
> +       new_mpls_lse = (__be32 *)(skb_mac_header(skb) + ETH_HLEN);
> +       *new_mpls_lse = mpls->mpls_lse;
> +
> +       if (get_ip_summed(skb) == OVS_CSUM_COMPLETE)
> +               skb->csum = csum_add(skb->csum, csum_partial(new_mpls_lse,
> +                                                            MPLS_HLEN, 0));
> +
> +       set_ethertype(skb, mpls->mpls_ethertype, false);
> +       if (skb->protocol != htons(ETH_P_8021Q))
> +               skb->protocol = mpls->mpls_ethertype;

It seems to me that there is a fair amount of stuff left over from
before the tag ordering conversion. For example, shouldn't we set the
EtherType unconditionally now if we are pushing tags onto the front?
Do we still need to dig into the packet to find the last EtherType if
we are now working on the outer tag? How does this interact with vlan
offloading, etc.?
