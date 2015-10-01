From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: [RFT v3] geneve: implement support for IPv6-based tunnels
Date: Thu, 1 Oct 2015 16:03:56 -0400
Message-ID: <20151001200355.GF3086@tuxdriver.com>
References: <1443632696-9900-1-git-send-email-linville@tuxdriver.com>
 <1443638045-27229-1-git-send-email-linville@tuxdriver.com>
 <CAEP_g=9g=Bt09+Kf9CWaSuhPFhUVXcesW28ksq+8b5hQwzf6Vw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>,
	Pravin B Shelar <pshelar@nicira.com>,
	Jiri Benc <jbenc@redhat.com>,
	David Miller <davem@davemloft.net>
To: Jesse Gross <jesse@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:46982 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752284AbbJAUPS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Oct 2015 16:15:18 -0400
Content-Disposition: inline
In-Reply-To: <CAEP_g=9g=Bt09+Kf9CWaSuhPFhUVXcesW28ksq+8b5hQwzf6Vw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 01, 2015 at 09:26:59AM -0700, Jesse Gross wrote:
> On Wed, Sep 30, 2015 at 11:34 AM, John W. Linville
> <linville@tuxdriver.com> wrote:
> > diff --git a/drivers/net/geneve.c b/drivers/net/geneve.c
> > index 8f5c02eed47d..291d3d7754a8 100644
> > --- a/drivers/net/geneve.c
> > +++ b/drivers/net/geneve.c
> > +#define GENEVE_F_IPV6          0x00000001
> 
> I wasn't sure why we needed this flag. Can't we just look at the
> remote address family?

Yeah, I had grander plans... :-)  I think it can be removed.

> > -static void geneve_sock_release(struct geneve_sock *gs)
> > +static void __geneve_sock_release(struct geneve_sock *gs)
> >  {
> >         if (--gs->refcnt)
> >                 return;
> 
> Do we need a check for NULL first here?

Sure.

> > +#if IS_ENABLED(CONFIG_IPV6)
> > +static int geneve6_build_skb(struct dst_entry *dst, struct sk_buff *skb,
> > +                            __be16 tun_flags, u8 vni[3], u8 opt_len, u8 *opt,
> > +                            bool csum, bool xnet)
> > +{
> > +       struct genevehdr *gnvh;
> > +       int min_headroom;
> > +       int err;
> > +
> > +       skb_scrub_packet(skb, xnet);
> 
> Is there a reason why this applies to only IPv6? It seems like it
> would be common

The dst vs rt thing was the motivator.  It probably could be refactored
to share some code between geneve_build_skb and geneve6_build_skb.

> > +static struct dst_entry *geneve_get_dst(struct sk_buff *skb,
> 
> It might be worth clarifying this name - it wasn't immediately obvious
> to me the difference between geneve_get_rt() and geneve_get_dst() is
> IPv4 vs. IPv6.

geneve_get_v4_rt and geneve_get_v6_dst?

> > +#if IS_ENABLED(CONFIG_IPV6)
> > +static netdev_tx_t geneve6_xmit_skb(struct sk_buff *skb, struct net_device *dev,
> > +                                   struct ip_tunnel_info *info)
> [...]
> > +       dst = geneve_get_dst(skb, dev, &fl6, info);
> > +       if (IS_ERR(dst)) {
> > +               netdev_dbg(dev, "no route to %pI6\n", &fl6.daddr);
> > +               dev->stats.tx_carrier_errors++;
> > +               goto tx_error;
> > +       }
> 
> It looks like we double log/count this error (although this also
> appears to be a problem for IPv4).

Indeed.  I'll try to fix/refactor that a bit...

> > +       err = udp_tunnel6_xmit_skb(dst, gs6->sock->sk, skb, dev,
> > +                                  &fl6.saddr, &fl6.daddr, 0, ttl,
> > +                                  sport, geneve->dst_port, !udp_csum);
> 
> It seems like TOS is not handled here?

There is no tos parameter for udp_tunnel6_xmit_skb.  Is there some
other way to inject it?  Is there a mapping to priority (i.e. the
0 parameter)?

> > @@ -823,9 +1095,11 @@ static int geneve_configure(struct net *net, struct net_device *dev,
> >         int err;
> >
> >         if (metadata) {
> > -               if (rem_addr || vni || tos || ttl)
> > +               if (remote != &geneve_remote_unspec || vni || tos || ttl)
> >                         return -EINVAL;
> 
> I think this will fail in the non-compat metadata case. The remote
> that is passed in will be a zeroed copy on the stack, so the address
> won't match the static version. I believe the check should be for
> AF_UNSPEC instead.

It is actually checking the pointer value against the address of
that static data structure, which is only reference through the
geneve_dev_create_fb path to calling geneve_configure.  Knowing that
are you still troubled by it?

John

P.S. I may not respond/repost for a while due to some travel during
the next week...
-- 
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.
