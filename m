From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [net-next-2.6 PATCH v5 1/2] net: implement mechanism for HW
 based QOS
Date: Thu, 06 Jan 2011 19:31:30 +0100
Message-ID: <1294338690.3074.91.camel@edumazet-laptop>
References: <20110104185600.13692.47967.stgit@jf-dev1-dcblab>
	 <1294338015.11825.26.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: John Fastabend <john.r.fastabend@intel.com>, davem@davemloft.net,
	jarkao2@gmail.com, hadi@cyberus.ca, shemminger@vyatta.com,
	tgraf@infradead.org, nhorman@tuxdriver.com, netdev@vger.kernel.org
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:64462 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752868Ab1AFSbz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Jan 2011 13:31:55 -0500
Received: by wwa36 with SMTP id 36so17689898wwa.1
        for <netdev@vger.kernel.org>; Thu, 06 Jan 2011 10:31:54 -0800 (PST)
In-Reply-To: <1294338015.11825.26.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 06 janvier 2011 =C3=A0 18:20 +0000, Ben Hutchings a =C3=A9crit=
 :
> On Tue, 2011-01-04 at 10:56 -0800, John Fastabend wrote:
> [...]
> > diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
> > index 0f6b1c9..ae51323 100644
> > --- a/include/linux/netdevice.h
> > +++ b/include/linux/netdevice.h
> > @@ -646,6 +646,14 @@ struct xps_dev_maps {
> >      (nr_cpu_ids * sizeof(struct xps_map *)))
> >  #endif /* CONFIG_XPS */
> > =20
> > +#define TC_MAX_QUEUE	16
> > +#define TC_BITMASK	15
> > +/* HW offloaded queuing disciplines txq count and offset maps */
> > +struct netdev_tc_txq {
> > +	u16 count;
> > +	u16 offset;
> > +};
> > +
> >  /*
> >   * This structure defines the management hooks for network devices=
=2E
> >   * The following hooks can be defined; unless noted otherwise, the=
y are
> > @@ -1146,6 +1154,9 @@ struct net_device {
> >  	/* Data Center Bridging netlink ops */
> >  	const struct dcbnl_rtnl_ops *dcbnl_ops;
> >  #endif
> > +	u8 num_tc;
> > +	struct netdev_tc_txq tc_to_txq[TC_MAX_QUEUE];
> > +	u8 prio_tc_map[TC_BITMASK+1];
> [...]
>=20
> I'm still concerned by the addition of all this state to every
> net_device.  From previous discussion, Eric wanted this, citing 'fals=
e
> sharing' while Stephen thought it should be accessed indirectly.
>=20
> Eric, when you refer to 'false sharing' do you mean that the TC state
> might end up sharing a cache line with some other data?  That seems
> quite unlikely as the allocation size will be 128 bytes, and it could=
 be
> padded to fill a cache line if that's still a concern.

At the time I made a comment, the allocated data was less than 64 bytes

Problem is adding so many indirections here and here reduce latencies o=
n
workloads handling a few packets per second.

sizeof(struct net_device)=3D0x600

We currently have 512 unused bytes (because of kmalloc() power of two)

(Most virtual devices have small private part added to net_device.
The real devices are probably crossing the 0x800 limit (or even 0x1000)=
)



