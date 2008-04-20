From: David Woodhouse <dwmw2@infradead.org>
Subject: Re: [PATCH] Expose netdevice dev_id through sysfs
Date: Sun, 20 Apr 2008 11:50:44 +0100
Message-ID: <1208688644.9212.407.camel@pmac.infradead.org>
References: <1208171478.31695.58.camel@pmac.infradead.org>
	 <3ae72650804140455l4bb2afc2i4c54e58f3be1f931@mail.gmail.com>
	 <1208176322.31695.73.camel@pmac.infradead.org>
	 <20080419.183341.46125500.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: kay.sievers@vrfy.org, md@linux.it, harald@redhat.com,
	linux-hotplug@vger.kernel.org, netdev@vger.kernel.org,
	schwidefsky@de.ibm.com
To: David Miller <davem@davemloft.net>
Return-path: <linux-hotplug-owner@vger.kernel.org>
In-Reply-To: <20080419.183341.46125500.davem@davemloft.net>
Sender: linux-hotplug-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 2008-04-19 at 18:33 -0700, David Miller wrote:
> From: David Woodhouse <dwmw2@infradead.org>
> Date: Mon, 14 Apr 2008 13:32:02 +0100
> 
> > Expose dev_id to userspace, because it helps to disambiguate between
> > interfaces where the MAC address is unique.
> > 
> > Signed-off-by: David Woodhouse <dwmw2@infradead.org>
> 
> As far as I can tell there is only one driver, s390's qeth, even
> setting netdev->dev_id.

There was talk of adding it for libertas and ps3_gelic too, since they
also provide devices with the same MAC address.

> And this driver is providing netdev->dev_id uniqueness amongst qeth
> device instances.
> But that's not the problem we're trying to solve.
> 
> We're trying to provide uniqueness amongst all devices in the system
> that are using the same MAC address.
>
> On a Sparc system, for example, ethernet chips driven by several
> different drivers can end up with the same MAC address, as the
> system IDPROM specified ethernet MAC is what will be used by
> default.
> 
> So we need some global scheme. 

Well, kind of. The kernel doesn't need to provide a single, globally
unique device identifier and hand it to udev on a plate.

The kernel just needs to provide a sufficient _set_ of attributes such
that udev can tell the difference between devices. On an S390 system,
that set of attributes should probably include dev_id, which would let
us remove the special-case hack in udev's persistent naming script. 

We _could_ also use dev_id for libertas and ps3_gelic, but in fact udev
is almost capable of using another criterion for matching -- the
basename of the interface (eth%d vs. msh%0 or wlan%d) -- which is
already sufficient to distinguish between those particular logical
devices. We just need to fix udev to use it _consistently_ rather than
spuriously dropping it from the generated rule in certain cases.

But if that gets fixed in udev and addresses my original issues
(libertas, ps3), that still doesn't mean that dev_id shouldn't be
exposed and used as _one_ of udev's criteria for matching devices.

> And this dev_id value would need to be
> persistent.  As best as I can tell, such things aren't available.
> Sure we could do something silly like use the device I/O physical
> address, but that would defeat the whole purpose of making device
> identification agnostic to I/O bus geography.  I could move the
> card to a different slot and it would have a different dev_id.
>
> We therefore need a more concrete and workable plan to resolve
> this issue.

Certainly, it's possible that we'll need _more_ criteria for udev to
match on; that doesn't necessarily mean that dev_id shouldn't be one of
them, does it?

-- 
dwmw2

