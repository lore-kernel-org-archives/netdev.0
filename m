From: Jouni Malinen <jkmaline@cc.hut.fi>
Subject: Re: [PATCH] ieee80211 subsystem
Date: Mon, 7 Feb 2005 20:29:50 -0800
Message-ID: <20050208042950.GD8366@jm.kir.nu>
References: <4203C32A.70402@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
To: James Ketrenos <jketreno@linux.intel.com>
Content-Disposition: inline
In-Reply-To: <4203C32A.70402@linux.intel.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, Feb 04, 2005 at 12:47:06PM -0600, James Ketrenos wrote:

> Support for HW/FW crypto and fragmentation offload, in a HW independent 
> fashion, is also on the short-term list.

Do you already have some detailed plans on how to implement this? There
are number of different implementations of TKIP hardware acceleration
and it would be nice to support all of them. For example, some cards
expect to get Ethernet 802.3 frames and take care of everything, others
take IEEE 802.11 frames with possible padding between header and
payload, some can take care of TKIP encryption part, but leave Michael
MIC to software, some can take care of both for some packets, but not
all (e.g., fragmentented frames), and so on..

> When you look through the patch you'll likely notice the #ifdef 
> NOTYET/#endif sequences surrounding portions of code from the hostap 
> project.  Portions of this subsystem were based on an earlier version of 
> the hostap project.  Those areas that weren't directly supported by the 
> ipw* projects weren't ported to be completely hardware independent 
> (since I don't have the hardware to test it), and so are still wrapped 
> in the ifdefs.  These sections mainly cover support for MASTER and WDS 
> modes.

We will need to take care of these areas in order to be able to call
this "generic IEEE 802.11 networking stack".. I would like to be able to
test replacing the upper level code in Host AP driver with this and
verify that all functionality is still available. Another useful test
case would be to go through what needs to be done to make this work with
the madwifi driver (i.e., merge some parts of net80211 code with this
and make the low-level parts of the driver use the combination for IEEE
802.11 processing).


> diff -Nur --exclude=RCS --exclude=CVS --exclude=SCCS --exclude=BitKeeper --exclude=ChangeSet netdev-2.6/drivers/net/wireless/Kconfig netdev-2.6-ipw/drivers/net/wireless/Kconfig
> --- netdev-2.6/drivers/net/wireless/Kconfig	2005-02-04 10:10:44 -06:00
> +++ netdev-2.6-ipw/drivers/net/wireless/Kconfig	2005-02-04 10:20:02 -06:00
> @@ -28,6 +28,8 @@
>  	  special kernel support are available from
>  	  <ftp://shadow.cabi.net/pub/Linux/>.
>  
> +source "drivers/net/wireless/ieee80211/Kconfig"

The generic IEEE 802.11 implementatio should go to net/ieee80211 or
net/80211 etc. like mentioned before.

> +config IEEE80211_DEBUG
> +	  This option will enable debug tracing output for the 
> +	  ieee80211 network stack.  

> +	  % echo 0x00000FFO > /sys/bus/pci/drivers/ipw2200/debug_level

Generic IEEE 802.11 code should not refer to specific driver.. Should
there be a per network device option for setting debug level or is a
global one enough?

> +	  For a list of values you can assign to debug_level, simply 
> +   	  perform:
> +
> +	  % . idvals
> +	  
> +	  From within drivers/net/wireless/ipw2200
> +
> +	  If you are not trying to debug or develop the IPW2200 driver, 
> +	  you 
> +	  most likely want to say N here.

This sounds like something that should be moved to ipw2200 specific
configuration option.

> +config IEEE80211_WPA
> +	tristate "IEEE 802.11 WPA"
> +	depends on IEEE80211_CRYPT
> +	---help---
> +	Software implementation of IEEE 802.11 WPA.  You will need
> +	to select the WPA algorithms you wish to use.

Software implementation? Is there a hardware implementation of WPA? ;-)
"WPA algorithms" should be replaced with cipher suites or something like
that since WPA uses number of algorithms for key management and
authentication and those are not included in the kernel code.

Is this configuration option needed or should WPA support be included by
default? If this remains, we should at least included WPA2 and IEEE
802.11i in the description, since this code is not only for WPA.

> +config IEEE80211_CRYPT_CCMP
> +	tristate "IEEE 802.11 CCMP encryption"
> +	depends on IEEE80211_WPA
> +	select CRYPTO_AES_586

Is CRYPTO_AES_586 the proper way of selecting this? 586 sounds like
x86-specific optimization, but I would like to use this on, say, xscale.

> +++ netdev-2.6-ipw/drivers/net/wireless/ieee80211/ieee80211_crypt.c	2005-02-04 10:20:03 -06:00

> +#include "../ieee80211.h"

Should that be moved to include/net/ieee80211.h? I.e., this would be
#include <net/ieee80211.h>.

> +++ netdev-2.6-ipw/drivers/net/wireless/ieee80211/ieee80211_crypt_ccmp.c	2005-02-04 10:20:03 -06:00

> +#ifndef CONFIG_CRYPTO
> +#error CONFIG_CRYPTO is required to build this module.
> +#endif

This can be removed, IEEE80211_CRYPT had "select CRYPTO" in Kconfig.

> +static void * ieee80211_ccmp_init(int key_idx)
> +{
> +	struct ieee80211_ccmp_data *priv;
> +
> +	priv = kmalloc(sizeof(*priv), GFP_ATOMIC);

You do not seem to include try_module_get(THIS_MODULE) here (and
matching module_put in deinit) like the version in Host AP driver is
using. What is protecting the CCMP/TKIP modules from being unloaded when
they are still used?


That's for the first 1840 lines of the patch and enough for today.. I'll
try to continue later this week.

-- 
Jouni Malinen                                            PGP id EFC895FA
