From: mcgrof@studorgs.rutgers.edu (Luis R. Rodriguez)
Subject: Re: Ethernet MAC address question
Date: Tue, 15 Jun 2004 00:17:37 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040615041737.GF6253@ruslug.rutgers.edu>
References: <200406142202.i5EM2bh19464@localhost.localdomain> <40CE361A.9060707@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Don Fry <brazilnut@us.ibm.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
In-Reply-To: <40CE361A.9060707@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, Jun 14, 2004 at 07:34:50PM -0400, Jeff Garzik wrote:
> Don Fry wrote:
> >When and/or why would an ethernet driver not use the MAC address from
> >the PROM associated with the adapter?
> >
> >Since the MAC address can be specified via "ifconfig ethN ether ...."
> >why not use the PROM value, and override it later if needed?
> >
> >I have received several complaints that the pcnet32 adapter is using
> >the 'wrong' MAC address.  By looking back through older kernels, the
> >pcnet32 code was changed between November 2001 and February 2002 to
> >read the MAC address from PROM, but to use whatever value was read
> >from some volatile chip registers, which early chip versions do not
> >even initialize.
> >
> >It seems to me the driver should always use the PROM address, assuming
> >it has one.  What am I missing?
> 
> In general, you are correct.
> 
> However there are a few cases where some magic platform means loads the 
> MAC address into the (volatile) MAC address registers, and that's the 
> only source of an accurate MAC address for those people.
> 
> 	Jeff

In Prism54's case, since we need to first load a firmware to first obtain the MAC
address, there's a time period where the default mac address is set to a
temporary: 00:30:B4:00:00:00. This value was chosen by Jean (from HP).
He sent in a patch to do this and added the following comment:

/* Temporary dummy MAC address to use until firmware is loaded.
 * The idea there is that some tools (such as nameif) may query
 * the MAC address before the netdev is 'open'. By using a valid
 * OUI prefix, they can process the netdev properly.
 * Of course, this is not the final/real MAC address. It doesn't
 * matter, as you are suppose to be able to change it anytime via
 * ndev->set_mac_address. Jean II */

The real mac address will be populated currently if you modprobe prism54, the
firmware is loaded as a result and then there is a netdev open (ifconfig eth0 up). 
There after the mac address is saved unless you rmmod the driver. 

PS. A bit off topic but I'll soon send in a patch for review about loading
the firmware @ device probe Vs only at netdevice open time. This will
allow the mac address to always be correctly populated if the firmware
is present with the downside that you'll see a kernel message complaining it 
didn't find the firmware if it was not found (to try to reload the firmware 
all you would have to do is just try to bring the device up, so this is
not an issue for a built-in). I'll also shut the radio off at probe
though to not waste precious energy when on battery-powered laptops.

	Luis

-- 
GnuPG Key fingerprint = 113F B290 C6D2 0251 4D84  A34A 6ADD 4937 E20A 525E
