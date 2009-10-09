From: Matt Domsch <Matt_Domsch@dell.com>
Subject: Re: PATCH: Network Device Naming mechanism and policy
Date: Fri, 9 Oct 2009 12:17:24 -0500
Message-ID: <20091009171724.GA11004@auslistsprd01.us.dell.com>
References: <EDA0A4495861324DA2618B4C45DCB3EE5894ED@blrx3m08.blr.amer.dell.com> <20091009140000.GA18765@mock.linuxdev.us.dell.com> <20091009163613.GA3414@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Narendra K <narendra_k@dell.com>, netdev@vger.kernel.org,
	linux-hotplug@vger.kernel.org, jordan_hargrave@dell.com
To: Greg KH <greg@kroah.com>
Return-path: <linux-hotplug-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20091009163613.GA3414@kroah.com>
Sender: linux-hotplug-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Oct 09, 2009 at 09:36:13AM -0700, Greg KH wrote:
> On Fri, Oct 09, 2009 at 09:00:01AM -0500, Narendra K wrote:
> > On Fri, Oct 09, 2009 at 07:12:07PM +0530, K, Narendra wrote:
> > > > example udev config:
> > > > SUBSYSTEM=="net",
> > > SYMLINK+="net/by-mac/$sysfs{ifindex}.$sysfs{address}"
> > > 
> > > work as well.  But coupling the ifindex to the MAC address like this
> > > doesn't work.  (In general, coupling any two unrelated attributes when
> > > trying to do persistent names doesn't work.)
> > > 
> > Attaching the latest patch incorporating review comments.
> > 
> > By creating character devices for every network device, we can use
> > udev to maintain alternate naming policies for devices, including
> > additional names for the same device, without interfering with the
> > name that the kernel assigns a device.
> > 
> > This is conditionalized on CONFIG_NET_CDEV.  If enabled (the default),
> > device nodes will automatically be created in /dev/netdev/ for each
> > network device.  (/dev/net/ is already populated by the tun device.)
> > 
> > These device nodes are not functional at the moment - open() returns
> > -ENOSYS.  Their only purpose is to provide userspace with a kernel
> > name to ifindex mapping, in a form that udev can easily manage.
> 
> How does this patch work with the network namespace functionality?

There is a monitonically increasing static ifindex kept in
net/core/dev.c:dev_new_index(), which is shared across all namespaces.
struct net_device ifindex field is assigned from this.  So two devices
in two different namespaces can't share an ifindex value.  However,
the device can be present (or not) in the per-namespace dev_name_hash
and dev_index_hashes.  This patch doesn't change this at all.

uevents aren't namespaced.  Presumably that means /dev can't be
polyinstantiated.  Therefore, all devnodes in /dev/netdev/* will be
visible to all processes, where 'ifconfig' and friends would only show
device names in the processes namespace.  This doesn't mean the app
can _do_ anything (it's the same as if it tried to act on a device
using an ifindex for a device not in its namespace), but yes, the fact
that such a device exists will be exposed.

-- 
Matt Domsch
Technology Strategist, Dell Office of the CTO
linux.dell.com & www.dell.com/linux
