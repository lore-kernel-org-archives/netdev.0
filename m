From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [patch net-next v3 02/10] switchdev: introduce transaction item
 queue for attr_set and obj_add
Date: Fri, 25 Sep 2015 11:03:05 -0400
Message-ID: <20150925150303.GA21567@ketchup.mtl.sfl>
References: <1443081769-11193-3-git-send-email-jiri@resnulli.us>
 <20150925043640.GB18915@ketchup.lan>
 <CAE4R7bA=xwfNT1cEp7_B7zfiuqg=PZ421j+GNCP+hi9DrhccAA@mail.gmail.com>
 <20150924.225508.2124748200966556070.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: sfeldma@gmail.com, jiri@resnulli.us, netdev@vger.kernel.org,
	idosch@mellanox.com, eladr@mellanox.com, f.fainelli@gmail.com,
	linux@roeck-us.net, rami.rosen@intel.com,
	roopa@cumulusnetworks.com, pjonnala@broadcom.com, andrew@lunn.ch,
	gospo@cumulusnetworks.com, jiri@mellanox.com,
	vivien.didelot@savoirfairelinux.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ip-208-88-110-44.savoirfairelinux.net ([208.88.110.44]:42817
	"EHLO mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753805AbbIYPDJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Sep 2015 11:03:09 -0400
Content-Disposition: inline
In-Reply-To: <20150924.225508.2124748200966556070.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sep. Thursday 24 (39) 10:55 PM, David Miller wrote:
> From: Scott Feldman <sfeldma@gmail.com>
> Date: Thu, 24 Sep 2015 22:29:43 -0700
> 
> > I'd rather keep 2-phase not optional, or at least make it some what of
> > a pain for drivers to opt-out of 2-phase.  Forcing the driver to see
> > both phases means the driver needs to put some code to skip phase 1
> > (and hopefully has some persistent comment explaining why its being
> > skipped).  Something like:
> > 
> > /* I'm skipping phase 1 prepare for this operation.  I have infinite hardware
> >  * resources and I'm not setting any persistent state in the driver or device
> >  * and I don't need any dynamic resources from the kernel, so its impossible
> >  * for me to fail phase 2 commit.  Nothing to prepare, sorry.
> >  */
> 
> I agree with Scott here.
> 
> If you can opt out of something, you can not think about it and thus
> more likely get it wrong.
> 
> I can just see a driver not implementing prepare at all and then doing
> stupid things in commit when they hit some resource limit or whatever,
> rather than taking care of such issues in prepare.

OK, I have no experience with stacked devices nor what it actually looks
like, but I understand that it is a redundant setup where it makes sense
to ensure that an operation is feasible before programming the hardware.

I agree with both of you on imposing switchdev drivers such notion.

I was confused with the rtnl lock (from bridge netlink requests) which
seemed to limit a lot the usage of this prepare phase.

I don't know the batch mode neither, but I can think about a potentially
powerful usage of the prepare phase in Marvell switches (or any basic
home router switches), please tell me if the following is feasible:

Every hardware VLANs I know of are programmed with all port membership
in one shot. This is not feasible today with the bridge command. If I
could bundle in one request the equivalent of ("VID 100: 0u 1u 5t"):

    bridge vlan add master dev swp0 vid 100 pvid untagged
    bridge vlan add master dev swp1 vid 100 pvid untagged
    bridge vlan add master dev swp5 vid 100 # cpu

In such case the prepare phase could be great to allocate and populate a
VLAN entry structure (i.e. struct mv88e6xxx_vtu_stu_entry) before
programming the hardware *just once*. Is that doable?

Also, I insist on removing the assumption that no error can occure
during the commit phase, for 2 reasons:

 - errors can actually occure (e.g. MDIO calls).
 - it makes no difference to the caller of switchdev_port_attr_set() and
   switchdev_port_obj_add() whether the call failed during the prepare
   or commit phase.

So I will propose a patch to get rid of the WARN(), if you don't mind.

Finally, what do you think about the snippet I proposed in my mail you
are replying to?

Implementing (now mandatory!) port_obj_prepare and port_attr_prepare
switchdev ops will explicit the prepare phase in drivers, simplify their
code and get rid of the prepare boolean and phase helper functions.

Thanks,
-v
