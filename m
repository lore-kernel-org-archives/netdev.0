From: Vladimir Kondratiev <vkondra@mail.ru>
Subject: Re: in-driver QoS
Date: Tue, 15 Jun 2004 19:35:04 +0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200406151935.08568.vkondra@mail.ru>
References: <20040608184831.GA18462@bougret.hpl.hp.com> <200406142353.28277.vkondra@mail.ru> <1087302412.1042.46.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 8bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com, hadi@cyberus.ca
In-Reply-To: <1087302412.1042.46.camel@jzny.localdomain>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

On Tuesday 15 June 2004 15:26, jamal wrote:
> On Mon, 2004-06-14 at 16:53, Vladimir Kondratiev wrote:
> > Jamal,
> > let's list the features need to be provided for 802.11 QoS, and problems.
> >
> > It is worth to provide standard interface with wireless stack; otherwise
> > each driver will invent its own solution.
> >
> > 1. NIC have number of Tx DMA channels, with different channels used for
> > different priorities. It is dictated by standard (TGe).
> >
> > Most likely, it should be 4 queues for EDCA traffic (4 priorities), 1 for
> > HCCA (polled, pre-agreed streams) and optionally 1 for multicast traffic
> > (AP need it).
> >
> > Each queue need to start/stop separately. For flexibility, it should be
> > some way for driver to request queues and specify mapping to these
> > queues.
> >
> > Ideas for how to implement it in stack?
>
> Refer to my earlier note on implementation.
> The only challenge is in starting and stopping each hardware DMA/FIFO
> separately. Thats whats missing today.
> The mapping between s/ware level queues and DMA/FIFO level is done via
> skb tags and is enforced via tc policies entered by the admin. Some of
> the current tags could be used or a new one created just for this.
Sure, skb->priority is what I use currently to map packets to queue.
>
> > Meanwhile, ideas how to get separate per-priority control with existing
> > infrastructure?
>
> like i said the qdisc infrastruture is in place.
Examples? Do you know some driver that uses it?
>
> > 2. There is traffic that require admission control. Unless driver
> > performs allocation with AP, this traffic is not allowed.
>
> Is this admission control something like 802.1x/EAP?
> I think stuff like that belongs to user space. You could use the new tc
> extensions i have to redirect packets to a user space process which then
> installs tc policies based on some compute the user space app does (eg
> lookup some LDAP/RADIUS attributes etc)
It is different kind of admission. 802.1x is about opening port, and is done 
above MAC using data packets. It is exactly like TSPEC below. For TSPEC, it 
is MAC level protocol, implemented with management packets.
Idea here is that high priority EDCA(contention access) channels should be 
controlled. Otherwise one can Tx all traffic at high priority.
>
> > TGe standard dictates it.
> >
> > Driver should participate in bandwidth allocation (via RSVP?). It should
> > get some form of request (IOCTL?) which it will serve by performing
> > allocation on link layer. It is easy to do proprietary IOCTL and white
> > custom RSVP daemon, but it is much better to do something generic for all
> > drivers to use.
>
> There is nothing new here as far as linux is concerned. Driver doesnt
> participate in any of this directly. Traffic control is done by a layer
> above driver. By the time the packet gets to the driver, it just looks
> at the skb tag and maps it to the right DMA/FIFO (may stop the
> netif_queue for the FIFO etc)
My point is, in order to made this stream valid, driver should perform some 
handshake with AP. Driver should send management packet and get response.
If handshake is not done, this packet will be rejected by AP, and station will 
be thrown out of network for protocol violation.

> I dont know many people running RSVP or COPS for that matter. But we
> have the mechanisms for them in place. I know a lot of fscked people who
> will wanna do this via SNMP. And dont forget your bash scripts of
> course.
> Now imagine you trying to make all the above be aware of whatever your
> driver is supposed to be doing via ioctls. Not a very scalable idea.
>
> cheers,
> jamal
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.4 (GNU/Linux)

iD8DBQFAzyU8qxdj7mhC6o0RAizzAKCsd2wZcSqMa3pJ7FKduTdUU2lPawCfdcg8
RaW20rmN9hwifwwIFjgKHRE=
=MpoC
-----END PGP SIGNATURE-----
