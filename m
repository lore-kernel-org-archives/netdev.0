From: James Ketrenos <jketreno@linux.intel.com>
Subject: Re: [PATCH] ieee80211 subsystem
Date: Tue, 08 Feb 2005 03:26:14 -0600
Message-ID: <420885B6.7090606@linux.intel.com>
References: <4203C32A.70402@linux.intel.com> <20050208042950.GD8366@jm.kir.nu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
To: Jouni Malinen <jkmaline@cc.hut.fi>
In-Reply-To: <20050208042950.GD8366@jm.kir.nu>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Jouni Malinen wrote:

>On Fri, Feb 04, 2005 at 12:47:06PM -0600, James Ketrenos wrote:
>
>  
>
>>Support for HW/FW crypto and fragmentation offload, in a HW independent 
>>fashion, is also on the short-term list.
>>    
>>
>
>Do you already have some detailed plans on how to implement this? There
>are number of different implementations of TKIP hardware acceleration
>and it would be nice to support all of them. For example, some cards
>expect to get Ethernet 802.3 frames and take care of everything, others
>take IEEE 802.11 frames with possible padding between header and
>payload, some can take care of TKIP encryption part, but leave Michael
>MIC to software, some can take care of both for some packets, but not
>all (e.g., fragmentented frames), and so on..
>  
>
I don't have any detailed planning on this currently.  I agree it should 
be done in a way to support as much hardware as possible -- the most 
difficult will likely be support of adapters that require 802.3 frames 
since all thinking to this point has been to make the stack such that 
wireless drivers never need to know about 802.3.  

Is it only for the data Tx/Rx that the 802.11/802.3 transform is handled 
by the device?  Or does the device internalize all 802.11 features such 
that 802.11 frames are never exposed externally?  The ipw2100 is similar 
in some regard to this -- although it doesn't take either 802.3 or 
802.11; it takes a raw data payload and a data structure that contains 
the dest addr, etc. 

>>When you look through the patch you'll likely notice the #ifdef 
>>NOTYET/#endif sequences surrounding portions of code from the hostap 
>>project.  Portions of this subsystem were based on an earlier version of 
>>the hostap project.  Those areas that weren't directly supported by the 
>>ipw* projects weren't ported to be completely hardware independent 
>>(since I don't have the hardware to test it), and so are still wrapped 
>>in the ifdefs.  These sections mainly cover support for MASTER and WDS 
>>modes.
>>    
>>
>
>We will need to take care of these areas in order to be able to call
>this "generic IEEE 802.11 networking stack".. I would like to be able to
>test replacing the upper level code in Host AP driver with this and
>verify that all functionality is still available. Another useful test
>case would be to go through what needs to be done to make this work with
>the madwifi driver (i.e., merge some parts of net80211 code with this
>and make the low-level parts of the driver use the combination for IEEE
>802.11 processing).
>  
>
Agreed.  Hopefully as more folks start seeing these patches others will 
be encouraged to try and help out, pulling the best of all the existing 
drivers together.

>>diff -Nur --exclude=RCS --exclude=CVS --exclude=SCCS --exclude=BitKeeper --exclude=ChangeSet netdev-2.6/drivers/net/wireless/Kconfig netdev-2.6-ipw/drivers/net/wireless/Kconfig
>>--- netdev-2.6/drivers/net/wireless/Kconfig	2005-02-04 10:10:44 -06:00
>>+++ netdev-2.6-ipw/drivers/net/wireless/Kconfig	2005-02-04 10:20:02 -06:00
>>@@ -28,6 +28,8 @@
>> 	  special kernel support are available from
>> 	  <ftp://shadow.cabi.net/pub/Linux/>.
>> 
>>+source "drivers/net/wireless/ieee80211/Kconfig"
>>    
>>
>
>The generic IEEE 802.11 implementatio should go to net/ieee80211 or
>net/80211 etc. like mentioned before.
>  
>
I'll rework it into net/ieee80211. 

>>+config IEEE80211_DEBUG
>>+	  This option will enable debug tracing output for the 
>>+	  ieee80211 network stack.  
>>    
>>
>
>  
>
>>+	  % echo 0x00000FFO > /sys/bus/pci/drivers/ipw2200/debug_level
>>    
>>
>
>Generic IEEE 802.11 code should not refer to specific driver.. Should
>there be a per network device option for setting debug level or is a
>global one enough?
>  
>
This was an oversite when last I updated the Kconfig for the ieee80211 
components.  The debug level for ieee80211 is configured in 
/proc/net/ieee80211/debug_level.

Currently there is a script provided in the ipw2100 and ipw2200 projects 
that greps the various debug levels supported for ieee80211 and dumps 
them to the console so the user doesn't have to manually look in 
ieee80211.h to try and figure out what bit masks in the debug_level 
correspond to what aspects. 

That script should be provided in a utility pacakge for the ieee80211 
stack -- a question is if it should simply grep on the running kernel's 
ieee80211.h to find the debug levels, or if the ieee80211 subsystem 
should contain in it the strings to export to the utility its internal 
debug levels via sysfs.

Having the debug flexibility in the module has been extremely useful in 
tracking issues and resolving bugs, while not flooding everyone's kernel 
logs with unneeded messages.

>>+	  For a list of values you can assign to debug_level, simply 
>>+   	  perform:
>>+
>>+	  % . idvals
>>+	  
>>+	  From within drivers/net/wireless/ipw2200
>>+
>>+	  If you are not trying to debug or develop the IPW2200 driver, 
>>+	  you 
>>+	  most likely want to say N here.
>>    
>>
>
>This sounds like something that should be moved to ipw2200 specific
>configuration option.
>  
>
Same oversite as above -- it should change to:

----
For a list of values you can assign to debug_level, you can need to use 
the ieee80211 utility package available at <URL>.  Once installed, you 
can then run:

% ieee80211_dvals

To obtain a list of supported debug masks.   You can also read/write the 
debug mask via

/proc/net/ieee80211/debug_level

If you are not trying to debug or develop the ieee80211 subsystem,
you most likely want to say N here.

---

and then I need to put up an ieee80211 utility package somewhere...

>>+config IEEE80211_WPA
>>+	tristate "IEEE 802.11 WPA"
>>+	depends on IEEE80211_CRYPT
>>+	---help---
>>+	Software implementation of IEEE 802.11 WPA.  You will need
>>+	to select the WPA algorithms you wish to use.
>>    
>>
>
>Software implementation? Is there a hardware implementation of WPA? ;-)
>"WPA algorithms" should be replaced with cipher suites or something like
>that since WPA uses number of algorithms for key management and
>authentication and those are not included in the kernel code.
>  
>
>Is this configuration option needed or should WPA support be included by
>default? If this remains, we should at least included WPA2 and IEEE
>802.11i in the description, since this code is not only for WPA.
>  
>
802.11i should be provided by default (it currently isn't).  If we 
provide the option for selecting the cipher suites, any issues with this 
text?:

CONFIG_IEEE80211_WEP
Include software based cipher suites in support of IEEE 802.11's WEP.  
This is needed for WEP as well as 802.1x.  This selects ARC4 under 
kernel crypto libraries, and CRC32 under kernel libraries.

CONFIG_IEEE80211_CCMP
Include software based cipher suites in support of IEEE 802.11i (aka 
TGi, WPA, WPA2, WPA-PSK, etc.) for use with CCMP enabled networks.  This 
selects AES support under kernel crypto libraries.

CONFIG_IEEE80211_TKIP
Include software based cipher suites in support of IEEE 802.11i (aka 
TGi, WPA, WPA2, WPA-PSK, etc.) for use with TKIP enabled networks.  This 
selects Michael Mic support under kernel crypto libraries.
...


All of the above should default to 'Y'.


>>+config IEEE80211_CRYPT_CCMP
>>+	tristate "IEEE 802.11 CCMP encryption"
>>+	depends on IEEE80211_WPA
>>+	select CRYPTO_AES_586
>>    
>>
>
>Is CRYPTO_AES_586 the proper way of selecting this? 586 sounds like
>x86-specific optimization, but I would like to use this on, say, xscale.
>  
>
How do you set up a dependency to be "one of"?

depends on CRYPTO_AES or CRYPTO_AES_586

?

>>+++ netdev-2.6-ipw/drivers/net/wireless/ieee80211/ieee80211_crypt.c	2005-02-04 10:20:03 -06:00
>>    
>>
>
>  
>
>>+#include "../ieee80211.h"
>>    
>>
>
>Should that be moved to include/net/ieee80211.h? I.e., this would be
>#include <net/ieee80211.h>.
>  
>
Will do.

>>+++ netdev-2.6-ipw/drivers/net/wireless/ieee80211/ieee80211_crypt_ccmp.c	2005-02-04 10:20:03 -06:00
>>    
>>
>
>  
>
>>+#ifndef CONFIG_CRYPTO
>>+#error CONFIG_CRYPTO is required to build this module.
>>+#endif
>>    
>>
>
>This can be removed, IEEE80211_CRYPT had "select CRYPTO" in Kconfig.
>  
>
Removed.

>>+static void * ieee80211_ccmp_init(int key_idx)
>>+{
>>+	struct ieee80211_ccmp_data *priv;
>>+
>>+	priv = kmalloc(sizeof(*priv), GFP_ATOMIC);
>>    
>>
>
>You do not seem to include try_module_get(THIS_MODULE) here (and
>matching module_put in deinit) like the version in Host AP driver is
>using. What is protecting the CCMP/TKIP modules from being unloaded when
>they are still used?
>  
>
The handler that loads the crypto module performs a try_module_get().  
Currently that code isn't contained in ieee80211_wx.c and is in drivers 
loading the ciphers for WPA -- it needs to be moved to the ieee80211_wx.

Which raises the question -- should we continue to support dynamically 
loading cipher suite handlers, or just statically compile them in if the 
user has requested them to be included?  Originally, the cipher suites 
contained all the crypto code within them, which increased their size 
and complexity.  Now, however, the suites are essentially shims that 
wrap the kernel crypto libraries.

There is the obvious aspect of flexibility that arises from supporting 
arbitrary and dynamic loading of crypto shims, but it does complicate 
the code somewhat.

Thoughts?

>That's for the first 1840 lines of the patch and enough for today.. I'll
>try to continue later this week.
>  
>
Thanks,
James
