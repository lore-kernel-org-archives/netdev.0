From: "Randy.Dunlap" <rddunlap@osdl.org>
Subject: Re: [PATCH] ieee80211 subsystem
Date: Fri, 04 Feb 2005 22:07:56 -0800
Message-ID: <420462BC.6010903@osdl.org>
References: <4203C32A.70402@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
To: James Ketrenos <jketreno@linux.intel.com>
In-Reply-To: <4203C32A.70402@linux.intel.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

James Ketrenos wrote:
> Attached is the patch against 2.6.11-rc3-mm1 that adds the ieee80211 
> subsystem used by the ipw2100 and ipw2200 projects.
> 
> I'll be sending out the patches for ipw2100-1.0.0 and ipw2200-1.0.0 that 
> use thist stack to the list on Monday.
> 
> In terms of what the stack currently does:
> 
> * HW independent -- it only knows about 802.11 data and structures
> * Performs an 802.3 <-> 802.11 transform for data Tx/Rx
> * Host based support for fragmentation, WEP, and WPA using the kernel's 
> crypto functions
> * Beacon and probe response collection and parsing
> * Default implementation of some of the WE handlers that can be managed 
> without hardware knowledge
> 
> We are working to merge in Dave Miller's p80211 code into the ieee80211 
> subsystem so that it hooks into the kernel as a true network layer as 
> opposed to a mutated offspring of ethernet.
> Once that is done, hopefully the skb to txb code can be reworked and 
> 802.11 fragments can be treated either as normal skbs, or skbs can be 
> modified to directly support them (ideally so that encrypted 802.11 
> frames in support of IP packets can be cached by the stack instead of 
> having to be re-encrypted on TCP retries)
> 
> Support for HW/FW crypto and fragmentation offload, in a HW independent 
> fashion, is also on the short-term list.
> 
> When you look through the patch you'll likely notice the #ifdef 
> NOTYET/#endif sequences surrounding portions of code from the hostap 
> project.  Portions of this subsystem were based on an earlier version of 
> the hostap project.  Those areas that weren't directly supported by the 
> ipw* projects weren't ported to be completely hardware independent 
> (since I don't have the hardware to test it), and so are still wrapped 
> in the ifdefs.  These sections mainly cover support for MASTER and WDS 
> modes.
> 
> Anyway, please let me know what you think.  Hopefully I built the patch 
> right...

It applies fine.

A few comments:

1.  config IEEE80211_DEBUG
	bool "Enable full debugging output"
	depends on IEEE80211

+	  /proc/net/ieee80211/debug_level
+
+	  For example:
+
+	  % echo 0x00000FFO > /sys/bus/pci/drivers/ipw2200/debug_level

I get the impression that one of these file names is incorrect:
/proc vs. /sys.....

+	  % . idvals
+	
+	  From within drivers/net/wireless/ipw2200

Is there some good place for this other than in
drivers/net/wireless?  I don't know.

+	  If you are not trying to debug or develop the IPW2200 driver,
+	  you
+	  most likely want to say N here.

Combine those last 2 lines.

2.  	This can be compiled as a modules and it will be called
+	"ieee80211_crypt.ko".

Don't use the ".ko" suffix at all (anywhere).

3.  +static int __init ieee80211_crypto_init(void)
+	(void) ieee80211_register_crypto_ops(&ieee80211_crypt_null);

That register call can fail, so I'd rather see it checked, as in all
of the other similar register calls.

4.  +static void * ieee80211_ccmp_init(int key_idx)
+	if (priv == NULL) {
+		goto fail;
+	}

Lose the braces.  Same for:
ieee80211_ccmp_init()

5.  +static void ccmp_init_blocks()

+	/* CCM Initial Block:
+	 * Flag (Include authentication header, M=3 (8-octet MIC),
+	 *       L=1 (2-octet Dlen))
+	 * Nonce: 0x00 | A2 | PN
+	 * Dlen */

Kernel long comment style begins with "/*" by itself and
ends with "*/" by itself.

6.  +struct ieee80211_ccmp_data {

+	u32 dot11RSNAStatsCCMPFormatErrors;
+	u32 dot11RSNAStatsCCMPReplays;
+	u32 dot11RSNAStatsCCMPDecryptErrors;

Are these MIB-mandated names?  otherwise the studlyCaps should go.

7.  +static int ieee80211_ccmp_decrypt()

Does anything care about the various negative/error case return
values?

8.  What calls the .print_stats functions?
static char * ieee80211_ccmp_print_stats()

Is it possible to use seq_file there instead of sprintf(),
or is this in /sysfs (so seq_file is not possible)?
Are there any overflow possibilities?


Enough for tonight...

-- 
~Randy
