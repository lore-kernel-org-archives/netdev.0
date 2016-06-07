From: Simon Horman <simon.horman@netronome.com>
Subject: Re: [PATCH net-next v10 2/5] openvswitch: set skb protocol and
 mac_len when receiving on internal device
Date: Tue, 7 Jun 2016 12:08:11 +0900
Message-ID: <20160607030809.GE31696@vergenet.net>
References: <1464848686-7656-1-git-send-email-simon.horman@netronome.com>
 <1464848686-7656-3-git-send-email-simon.horman@netronome.com>
 <CAOrHB_Aqdkr-26GxGh=W0AsojOMzDXYf5zif=kaFbWBty5uHKA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	ovs dev <dev@openvswitch.org>
To: pravin shelar <pshelar@ovn.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f175.google.com ([209.85.192.175]:35876 "EHLO
	mail-pf0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750933AbcFGDIV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Jun 2016 23:08:21 -0400
Received: by mail-pf0-f175.google.com with SMTP id z187so18943337pfz.3
        for <netdev@vger.kernel.org>; Mon, 06 Jun 2016 20:08:21 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <CAOrHB_Aqdkr-26GxGh=W0AsojOMzDXYf5zif=kaFbWBty5uHKA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jun 02, 2016 at 03:01:47PM -0700, pravin shelar wrote:
> On Wed, Jun 1, 2016 at 11:24 PM, Simon Horman
> <simon.horman@netronome.com> wrote:
> > * Set skb protocol based on contents of packet. I have observed this is
> >   necessary to get actual protocol of a packet when it is injected into an
> >   internal device e.g. by libnet in which case skb protocol will be set to
> >   ETH_ALL.
> >
> > * Set the mac_len which has been observed to not be set up correctly when
> >   an ARP packet is generated and sent via an openvswitch bridge.
> >   My test case is a scenario where there are two open vswtich bridges.
> >   One outputs to a tunnel port which egresses on the other.
> >
> > The motivation for this is that support for outputting to layer 3 (non-tap)
> > GRE tunnels as implemented by a subsequent patch depends on protocol and
> > mac_len being set correctly on receive.
> >
> > Signed-off-by: Simon Horman <simon.horman@netronome.com>
> >
> > ---
> > v10
> > * Set mac_len
> >
> > v9
> > * New patch
> > ---
> >  net/openvswitch/vport-internal_dev.c | 4 ++++
> >  1 file changed, 4 insertions(+)
> >
> > diff --git a/net/openvswitch/vport-internal_dev.c b/net/openvswitch/vport-internal_dev.c
> > index 2ee48e447b72..f89b1efa88f1 100644
> > --- a/net/openvswitch/vport-internal_dev.c
> > +++ b/net/openvswitch/vport-internal_dev.c
> > @@ -48,6 +48,10 @@ static int internal_dev_xmit(struct sk_buff *skb, struct net_device *netdev)
> >  {
> >         int len, err;
> >
> > +       skb->protocol = eth_type_trans(skb, netdev);
> > +       skb_push(skb, ETH_HLEN);
> > +       skb_reset_mac_len(skb);
> > +
> resetting mac-len breaks the assumption about mac_len for referencing
> MPLS header ref: skb_mpls_header().

Thanks I had overlooked this. I think it is actually safe as
the mac_len is recalculated quite soon in key_extract() and IIRC
the most important thing is for mac_len to be 0 or non-zero
for the benefit of ovs_flow_key_extract(). None the less it does
seem untidy and moreover inconsistent with the handling in
netdev_port_receive() by a latter patch which does the following:

	eth_type = eth_type_trans(skb, skb->dev);
	skb->mac_len = skb->data - skb_mac_header(skb);
	__skb_push(skb, skb->mac_len);

	if (eth_type == htons(ETH_P_8021Q))
		skb->mac_len += VLAN_HLEN;

Perhaps that logic ought to be in a helper used by both internal_dev_xmit()
and netdev_port_receive(). Or somehow centralised in ovs_vport_receive().
