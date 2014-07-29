From: Dmitry Popov <ixaphire@qrator.net>
Subject: Re: [PATCH] ip_tunnel(ipv4): fix tunnels with
 "local any remote $remote_ip"
Date: Tue, 29 Jul 2014 21:49:31 +0400
Message-ID: <20140729214931.9ae11fe3ddfd49ca6f499db6@qrator.net>
References: <20140729030752.d156e9522754e8a6262541ec@qrator.net>
	<CAHA+R7P3gN6Xd==bF9r=396DBi=sTab7tHgZr4agiLxDBdrk+g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Sergey Popov <pinkbyte@gentoo.org>,
	Eric Dumazet <edumazet@google.com>,
	Tom Herbert <therbert@google.com>
To: Cong Wang <cwang@twopensource.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f175.google.com ([209.85.217.175]:48477 "EHLO
	mail-lb0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751085AbaG2Rtg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Jul 2014 13:49:36 -0400
Received: by mail-lb0-f175.google.com with SMTP id 10so4441lbg.20
        for <netdev@vger.kernel.org>; Tue, 29 Jul 2014 10:49:35 -0700 (PDT)
In-Reply-To: <CAHA+R7P3gN6Xd==bF9r=396DBi=sTab7tHgZr4agiLxDBdrk+g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 28 Jul 2014 16:39:23 -0700
Cong Wang <cwang@twopensource.com> wrote:

> On Mon, Jul 28, 2014 at 4:07 PM, Dmitry Popov <ixaphire@qrator.net> wrote:
> > --- a/include/net/ip_tunnels.h
> > +++ b/include/net/ip_tunnels.h
> > @@ -40,6 +40,7 @@ struct ip_tunnel_prl_entry {
> >
> >  struct ip_tunnel_dst {
> >         struct dst_entry __rcu          *dst;
> > +       __be32                           saddr;
> >  };
> 
> 
> It looks odd to save a source address in some struct named dst,
> maybe it's the time to rename it.

Yes, maybe a bit odd, but ip_tunnel_flow/ip_tunnel_route doesn't look much 
better for me, so I decided to keep it with old name. David is ok with this
name too.

> >         if (dst) {
> > -               if (dst->obsolete && dst->ops->check(dst, cookie) == NULL) {
> > +               if (!dst->obsolete || dst->ops->check(dst, cookie)) {
> > +                       *saddr = idst->saddr;
> > +               } else {
> 
> I am wondering if this always works, that is, if saddr could be still valid
> as long as dst is valid?

Right, this is not a very smooth place, but a) it should work with current ipv4
route implementation (it obsoletes all dst_entries on any route/addr change).
Yes, we shouldn't rely on implementation, but b) I don't know how (and why) this
implementation should be changed to break it. I think the assumption that
dst_entry is obsoleted when saddr is changed is pretty natural.
Please correct me if I'm wrong.
