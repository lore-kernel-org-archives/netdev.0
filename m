From: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Subject: Re: [PATCH] e1000: enhance frame fragment detection
Date: Tue, 12 Jan 2010 17:56:28 -0800 (Pacific Standard Time)
Message-ID: <alpine.WNT.2.00.1001121720300.3168@jbrandeb-desk1.amr.corp.intel.com>
References: <20091228201005.GC18422@hmsreliant.think-freely.org>
	<alpine.WNT.2.00.1001051341110.4056@jbrandeb-desk1.amr.corp.intel.com>
	<alpine.WNT.2.00.1001061525050.4056@jbrandeb-desk1.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "e1000-devel@lists.sourceforge.net" <e1000-devel@lists.sourceforge.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>, "Allan,
	Bruce W" <bruce.w.allan@intel.com>, "Ronciak,
	John" <john.ronciak@intel.com>, "Kirsher,
	Jeffrey T" <jeffrey.t.kirsher@intel.com>
To: Neil Horman <nhorman@tuxdriver.com>, davem@davemloft.net
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <alpine.WNT.2.00.1001061525050.4056@jbrandeb-desk1.amr.corp.intel.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On Wed, 6 Jan 2010, Brandeburg, Jesse wrote:
> a counter patch, without atomic ops, since we are protected by napi when 
> modifying this variable.
> 
> Originally From: Neil Horman <nhorman@tuxdriver.com>
> Modified by: Jesse Brandeburg <jesse.brandeburg@intel.com>
> 
> <original message>
> Hey all-
> 	A security discussion was recently given:
> http://events.ccc.de/congress/2009/Fahrplan//events/3596.en.html
> And a patch that I submitted awhile back was brought up.  Apparently some of
> their testing revealed that they were able to force a buffer fragment in e1000
> in which the trailing fragment was greater than 4 bytes.  As a result the
> fragment check I introduced failed to detect the fragement and a partial
> invalid frame was passed up into the network stack.  I've written this patch
> to correct it.  I'm in the process of testing it now, but it makes good
> logical sense to me.  Effectively it maintains a per-adapter state variable
> which detects a non-EOP frame, and discards it and subsequent non-EOP frames
> leading up to _and_ _including_ the next positive-EOP frame (as it is by
> definition the last fragment).  This should prevent any and all partial frames
> from entering the network stack from e1000.
> 
> Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>

I would like to withdraw this patch, at least for 2.6.32+ e1000 and e1000e 
are both not susceptible to this attack.  We have verified the below with 
testing, including code modifications to guarantee the correct paths were 
taken when receiving overlong frames.

What has happened is that in commit 
edbbb3ca107715067b27a71e6ea7f58750912aa2 the e1000 driver had a feature 
added to use 4kB data buffers when in jumbo mode.  This code understands 
chains of data buffers, (in fact depends on it) so even when receiving a 
packet that is longer than 4kB, the packet is handed in its entirety to 
the stack.

I believe RedHat has not backported this patch, and kernels <= 2.6.31 
still need the fix, so both need some version of this workaround, but 
2.6.32 does not.

As for e1000e, in jumbo mode it has always used what we call "packet split 
mode" in the driver, where hardware uses a special descriptor that can 
contain 4 dma fragments, a header buffer of 256 bytes and up to 3 4kB data 
buffers.  If a packet that arrives is > (12kB + 256) then it will overflow 
into the next descriptor, using only the first 4kB data buffer of the 
second descriptor (our hardware has a hard limit of 16kB for any ethernet 
frame, longer are dropped at the hardware level)

The code correctly handles the !EOP packet and drops it, and the next 
packet will hit the !length (of the header buffer) condition and also be 
dropped.

Other Intel hardware is not susceptible to this attack.  Hardware 
supported by the e100 (no jumbo frames), the ixgb driver (MFS register), 
the igb driver (RLPML register), and ixgbe (MHADD/MAXFRS register) do not 
have this issue.

Hope this clears up some things,

 Jesse

------------------------------------------------------------------------------
This SF.Net email is sponsored by the Verizon Developer Community
Take advantage of Verizon's best-in-class app development support
A streamlined, 14 day to market process makes app distribution fast and easy
Join now and get one step closer to millions of Verizon customers
http://p.sf.net/sfu/verizon-dev2dev 
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
