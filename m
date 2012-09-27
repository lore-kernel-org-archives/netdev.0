From: Jesse Gross <jgross@vmware.com>
Subject: Re: [PATCHv4 net-next] vxlan: virtual extensible lan
Date: Thu, 27 Sep 2012 10:20:50 -0700
Message-ID: <CAEP_g=_OuC8DxYAXeGEmOcBS+kz7Y3HhK6a0gHDa-2ZXOna2sA@mail.gmail.com>
References: <20120924184304.727711327@vyatta.com> <20120924185050.162920909@vyatta.com>
 <20120924205822.GI26494@x200.localdomain> <20120924145031.3b0122e6@nehalam.linuxnetplumber.net>
 <CAEP_g=_PQSx_OVcU47OJFKgO_MpWSKStmGnVB76vSm=Z7r6mvg@mail.gmail.com> <20120925213623.39ee67d1@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Chris Wright <chrisw@redhat.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog136.obsmtp.com ([74.125.149.85]:57312 "HELO
	na3sys009aog136.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751918Ab2I0RVL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Sep 2012 13:21:11 -0400
Received: by mail-ob0-f174.google.com with SMTP id uo13so2011475obb.19
        for <netdev@vger.kernel.org>; Thu, 27 Sep 2012 10:21:10 -0700 (PDT)
In-Reply-To: <20120925213623.39ee67d1@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 25, 2012 at 9:36 PM, Stephen Hemminger
<shemminger@vyatta.com> wrote:
> On Tue, 25 Sep 2012 14:55:13 -0700
> Jesse Gross <jesse@nicira.com> wrote:
>
>> On Mon, Sep 24, 2012 at 2:50 PM, Stephen Hemminger
>> <shemminger@vyatta.com> wrote:
>> > +static netdev_tx_t vxlan_xmit(struct sk_buff *skb, struct net_device *dev)
>> [...]
>> > +       /* Do PMTU */
>> > +       if (skb->protocol == htons(ETH_P_IP)) {
>> > +               df |= old_iph->frag_off & htons(IP_DF);
>> > +               if (df && mtu < pkt_len) {
>> > +                       icmp_send(skb, ICMP_DEST_UNREACH, ICMP_FRAG_NEEDED,
>> > +                                 htonl(mtu));
>> > +                       ip_rt_put(rt);
>> > +                       goto tx_error;
>> > +               }
>> > +       }
>> > +#if IS_ENABLED(CONFIG_IPV6)
>> > +       else if (skb->protocol == htons(ETH_P_IPV6)) {
>> > +               if (mtu >= IPV6_MIN_MTU && mtu < pkt_len) {
>> > +                       icmpv6_send(skb, ICMPV6_PKT_TOOBIG, 0, mtu);
>> > +                       ip_rt_put(rt);
>> > +                       goto tx_error;
>> > +               }
>> > +       }
>> > +#endif
>>
>> Won't this black hole packets if we need to generate ICMP messages?
>> Since we're doing switching and not routing here icmp_send() doesn't
>> necessarily have a route to the relevant endpoint.  It looks like
>> Ethernet over GRE has this issue as well.
>
> It is an interesting question about what is the correct way to handle packets
> where the inner header is IPv6 or IPv4 with Don't Fragment set. As you mention
> sending an ICMP response won't work because the tunnel endpoint is not part
> of that IP network.
>
> The simple option is to fragment it in the tunnel and since the fragmentation
> is not visible to the overlay network, that is okay. But for PMTU discovery
> it might be better to just drop the packet and not send a fragmented payload.
>
> Some backbone networks don't allow fragmentation at all (in a futile attempt
> to block DoS attacks and protect fragile Windows hosts). Fragmentation
> brings all sorts of evil problems like the potential of corrupted assembly
> because of sequence wrap; the checksum in the inner packet will defend against
> that but tunnels are not supposed to rely on inner protocol data protection.
>
> Or you can just do what Cisco and Microsoft do and just tell everyone
> to set larger MTU on the backbone.

What I think people usually do in these situations are:
 1. Insist people set the MTU to take into account the tunnel.
 2. Use MSS clamping for TCP traffic.
 3. Either drop or fragment the tunnel packet.  In theory some IP
stacks will probe for a lower MTU if packets are dropping, in practice
things seem to just break.  If the backbone is going to drop
fragmented packets then I guess it doesn't make a difference, modulo
the potential for corruption that you mentioned.  Always dropping
seems worse (although it is the behavior of many hardware devices that
can't do fragmentation at all).

So I think what you have currently is correct.

A couple of other options:
 * In many cases it might be desirable to do fragmentation on the
inner rather than outer packet, especially if there are middleboxes
looking inside the tunnel.  This assumes that the inner packet is IP
and doesn't have the DF bit set.  In theory, you could do it even if
the DF bit is set since we can't do path MTU discovery anyways.
 * A few years ago I wrote an implementation of path MTU discovery in
OVS to handle this situation.  It's pretty effective but it relies on
guessing/faking some addresses.  I think we're going to pull it out
soon in favor of MSS clamping soon though.

I wouldn't implement either of these here, at least at this time though.
