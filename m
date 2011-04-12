From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Kernel panic when using bridge
Date: Tue, 12 Apr 2011 06:22:52 +0200
Message-ID: <1302582172.3603.18.camel@edumazet-laptop>
References: <4D9E62D9.5010400@scotdoyle.com>
	 <20110408121700.0aad53fe@nehalam>	<4D9FE5BE.6060600@scotdoyle.com>
	 <20110409161908.a2aca120.shimoda.hiroaki@gmail.com>
	 <4DA39330.2030102@scotdoyle.com> <20110411183105.46e86684@nehalam>
	 <4DA3CB4B.9090506@scotdoyle.com> <1302581384.3603.14.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	Hiroaki SHIMODA <shimoda.hiroaki@gmail.com>,
	netdev@vger.kernel.org
To: Scot Doyle <lkml@scotdoyle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:62676 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751078Ab1DLEXX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Apr 2011 00:23:23 -0400
Received: by wya21 with SMTP id 21so5356942wya.19
        for <netdev@vger.kernel.org>; Mon, 11 Apr 2011 21:23:22 -0700 (PDT)
In-Reply-To: <1302581384.3603.14.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 12 avril 2011 =C3=A0 06:09 +0200, Eric Dumazet a =C3=A9crit :
> Le lundi 11 avril 2011 =C3=A0 22:47 -0500, Scot Doyle a =C3=A9crit :
> > On 04/11/2011 08:31 PM, Stephen Hemminger wrote:
> > >
> > > It would help if you gave a little more context (like diff -up)
> > > next time.
> > >
> > > I think the correct fix is for the skb handed to ip_compile_optio=
ns
> > > to match the layout expected by ip_compile_options.
> > >
> > > This patch is compile tested only, please validate.
> > >
> > >
> > > Subject: [PATCH] bridge: set pseudo-route table before calling ip=
_comple_options
> > >
> > > For some ip options, ip_compile_options assumes it can find the a=
ssociated
> > > route table. The bridge to iptables code doesn't supply the neces=
sary
> > > reference causing NULL dereference.
> > >
> > > Signed-off-by: Stephen Hemminger<shemminger@vyatta.com>
> > >
> > > ---
> > > Patch against net-next-2.6, but if validated should go to net-2.6
> > > and stable.
> > >
> > > --- a/net/bridge/br_netfilter.c	2011-04-11 18:18:22.534837859 -07=
00
> > > +++ b/net/bridge/br_netfilter.c	2011-04-11 18:25:15.427244826 -07=
00
> > > @@ -221,6 +221,7 @@ static int br_parse_ip_options(struct sk
> > >   	struct ip_options *opt;
> > >   	struct iphdr *iph;
> > >   	struct net_device *dev =3D skb->dev;
> > > +	struct rtable *rt;
> > >   	u32 len;
> > >
> > >   	iph =3D ip_hdr(skb);
> > > @@ -255,6 +256,14 @@ static int br_parse_ip_options(struct sk
> > >   		return 0;
> > >   	}
> > >
> > > +	/* Associate bogus bridge route table */
> > > +	rt =3D bridge_parent_rtable(dev);
> > > +	if (!rt) {
> > > +		kfree_skb(skb);
> > > +		return 0;
> > > +	}
> > > +	skb_dst_set(skb,&rt->dst);
>=20
> Please try skb_dst_set_noref() here instead of skb_dst_set()
>=20
> Or increment rt refcount.

Also, I would first check if skb->dst already set to not leak a dst

if (!skb->dst) {
	rt =3D bridge_parent_rtable(dev);
	if (!rt) {
		kfree_skb(skb);
		return 0;
	}
	skb_dst_set_noref(skb,&rt->dst);
}



