From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCHv4 net-next] vxlan: virtual extensible lan
Date: Tue, 25 Sep 2012 15:03:54 -0700
Message-ID: <20120925150354.319a6ba3@nehalam.linuxnetplumber.net>
References: <20120924184304.727711327@vyatta.com>
	<20120924185050.162920909@vyatta.com>
	<20120924205822.GI26494@x200.localdomain>
	<20120924145031.3b0122e6@nehalam.linuxnetplumber.net>
	<CAEP_g=_PQSx_OVcU47OJFKgO_MpWSKStmGnVB76vSm=Z7r6mvg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Chris Wright <chrisw@redhat.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Jesse Gross <jesse@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:57178 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751330Ab2IYWE2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 25 Sep 2012 18:04:28 -0400
In-Reply-To: <CAEP_g=_PQSx_OVcU47OJFKgO_MpWSKStmGnVB76vSm=Z7r6mvg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 25 Sep 2012 14:55:13 -0700
Jesse Gross <jesse@nicira.com> wrote:

> On Mon, Sep 24, 2012 at 2:50 PM, Stephen Hemminger
> <shemminger@vyatta.com> wrote:
> > +static netdev_tx_t vxlan_xmit(struct sk_buff *skb, struct net_device *dev)
> [...]
> > +       /* Do PMTU */
> > +       if (skb->protocol == htons(ETH_P_IP)) {
> > +               df |= old_iph->frag_off & htons(IP_DF);
> > +               if (df && mtu < pkt_len) {
> > +                       icmp_send(skb, ICMP_DEST_UNREACH, ICMP_FRAG_NEEDED,
> > +                                 htonl(mtu));
> > +                       ip_rt_put(rt);
> > +                       goto tx_error;
> > +               }
> > +       }
> > +#if IS_ENABLED(CONFIG_IPV6)
> > +       else if (skb->protocol == htons(ETH_P_IPV6)) {
> > +               if (mtu >= IPV6_MIN_MTU && mtu < pkt_len) {
> > +                       icmpv6_send(skb, ICMPV6_PKT_TOOBIG, 0, mtu);
> > +                       ip_rt_put(rt);
> > +                       goto tx_error;
> > +               }
> > +       }
> > +#endif
> 
> Won't this black hole packets if we need to generate ICMP messages?
> Since we're doing switching and not routing here icmp_send() doesn't
> necessarily have a route to the relevant endpoint.  It looks like
> Ethernet over GRE has this issue as well.

Good catch. The IP network space of the tunneled network will likely be
completely separate from the overlay network.
