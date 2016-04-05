From: Guillaume Nault <g.nault@alphalink.fr>
Subject: Re: [RFC PATCH 0/6] ppp: add rtnetlink support
Date: Tue, 5 Apr 2016 23:05:58 +0200
Message-ID: <20160405210558.GB1305@alphalink.fr>
References: <cover.1459807527.git.g.nault@alphalink.fr>
 <20160405082745.6d2d2aa6@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-ppp@vger.kernel.org,
	Paul Mackerras <paulus@samba.org>,
	David Miller <davem@davemloft.net>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <linux-ppp-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20160405082745.6d2d2aa6@xeon-e3>
Sender: linux-ppp-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

.On Tue, Apr 05, 2016 at 08:27:45AM -0700, Stephen Hemminger wrote:
> On Tue, 5 Apr 2016 02:56:17 +0200
> Guillaume Nault <g.nault@alphalink.fr> wrote:
> 
> > The rtnetlink handlers implemented in this series are minimal, and can
> > only replace the PPPIOCNEWUNIT ioctl. The rest of PPP ioctls remains
> > necessary for any other operation on channels and units.
> > It is perfectly to possible to mix PPP devices created by rtnl
> > and by ioctl(PPPIOCNEWUNIT). Devices will behave in the same way,
> > except for a few specific cases (as detailed in patch #6).
> 
> What blocks PPP from being fully netlink (use attributes),
> 
I just didn't implement other netlink attributes because I wanted to
get the foundations validated first. Implementing PPP unit ioctls with
rtnetlink attributes shouldn't be a problem because there's a 1:1
mapping between units and netdevices. So we could have some kind of
feature parity (I'm not sure if all ioctls are worth a netlink
attribute though).

But there's the problem of getting the unit identifier of a PPP device.
If that device was created with kernel assigned name and index, then
the user space daemon has no ifindex or ifname for building an
RTM_GETLINK message. So the ability to retrieve the unit identifer with
rtnetlink wouldn't be enough to fully replace ioctls on unit.

If by "fully netlink", you also meant implementing a netlink
replacement for all supported ioctls, then that's going to be even
trickier. A genetlink API would probably need to be created for
handling generic operations on PPP channels. But that wouldn't be
enough since unknown ioctls on channels are passed to the
chan->ops->ioctl() callback. So netlink support would also have to be
added to the channel handlers (pptp, pppoatm, sync_ppp, irda...).

> and work with same API set independent of how device was created.
> Special cases are nuisance and source of bugs.
> 
It looks like handling rtnetlink messages in ioctl based PPP devices is
just a matter of assigning ->rtnl_link_ops in ppp_create_interface().
I'll consider that for v3.

> > I'm sending the series only as RFC this time, because there are a few
> > points I'm unsatisfied with.
> > 
> > First, I'm not fond of passing file descriptors as netlink attributes,
> > as done with IFLA_PPP_DEV_FD (which is filled with a /dev/ppp fd). But
> > given how PPP units work, we have to associate a /dev/ppp fd somehow.
> > 
> > More importantly, the locking constraints of PPP are quite problematic.
> > The rtnetlink handler has to associate the new PPP unit with the
> > /dev/ppp file descriptor passed as parameter. This requires holding the
> > ppp_mutex (see e8e56ffd9d29 "ppp: ensure file->private_data can't be
> > overridden"), while the rtnetlink callback is already protected by
> > rtnl_lock(). Since other parts of the module take these locks in
> > reverse order, most of this series deals with preparing the code for
> > inverting the dependency between rtnl_lock and ppp_mutex. Some more
> > work is needed on that part (see patch #4 for details), but I wanted
> > to be sure that approach it worth it before spending some more time on
> > it.
> 
> One other way to handle the locking is to use trylock. Yes it justs
> pushs the problem back to userspace, but that is how lock reordering was
> handled in sysfs.
>
If that's considered a valid approach, then I'll use it for v3. That'd
simplify things nicely.
