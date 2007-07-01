From: James Chapman <jchapman@katalix.com>
Subject: Re: e1000: backport ich9 support from 7.5.5 ?
Date: Sun, 01 Jul 2007 11:45:53 +0100
Message-ID: <468785E1.7050801@katalix.com>
References: <1183138159.17243.16.camel@blaa>	
	<20070629175006.GB3917@falooley.org>
	<468571C6.3090305@garzik.org>	 <46857C08.4030303@intel.com>	
	<20070629150350.414553d4.akpm@linux-foundation.org>	
	<4685838D.9080108@garzik.org>
	<c0a09e5c0706291657kd5e4baawb113a17ca5ab2191@mail.gmail.com>
	<46859F3F.305@garzik.org> <4685C09B.7040908@intel.com>
	<4686692E.5080604@katalix.com> <468684E1.6080901@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Mark McLoughlin <markmc@redhat.com>,
	Jeff Garzik <jeff@garzik.org>, e1000-devel@lists.sourceforge.net,
	netdev@vger.kernel.org, Andrew Grover <andy.grover@gmail.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Jason Lunz <lunz@reflexsecurity.com>
To: "Kok, Auke" <auke-jan.h.kok@intel.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <468684E1.6080901@intel.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Sender: e1000-devel-bounces@lists.sourceforge.net
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

Kok, Auke wrote:
> James Chapman wrote:
>> I briefly looked over your new driver. I think it might benefit by 
>> moving common parts into one or more libraries (or modules) and have 
>> separate chip-specific drivers for 82540, 82541, 82542, 82543, 82571 
>> etc. Put all the chip-specific bits in a chip-specific driver and have 
>> each driver call into the common (shared) code. The device 
>> probe/init/remove would be done by the chip-specific code, not the 
>> common code like it is now. When built as a module, the chip-specific 
>> parts and the common parts could be built as separate modules; 
>> modprobe would load the common parts automatically. Most of the code 
>> would be in the common part since these chips are very similar.
> 
> splitting beyond the obvious does not make any sense and will just add 
> confusion.

Users wouldn't need to know which driver to load - the right driver 
would be loaded automatically. Distros would ship all of them (and the 
common bits). The few users who know which device(s) they have could 
build only the required drivers if they wanted to do so.

> I'm not against a pcie/pre-pcie split or even going a step 
> further and looking into using PHYlib as you suggest below, but we 
> should really avoid trying to create an unmaintainable mess where we 
> have to patch 7 drivers for each generic issue we find.

The generic issues would be in the common part so would be patched once.

Looking at your new driver code, there are separate source files for the 
5 chips I mention, hence my leaning towards a driver per device. I 
counted 24 funcptrs that are set up in order for the common code to call 
out to driver-private chip specific functions. Wouldn't most of these go 
away if the chip-specific code called common code, not the other way round?

Let me use an example to illustrate what I mean. e1000_setup_link() is 
common code. It simply calls a function pointed to by func.setup_link, 
which was initialized to a chip-specific function, e.g. 
e1000_setup_link_82543() in e1000_init_mac_params_82543(). It turns out 
that e1000_setup_link() is called by chip-specific code from 
e1000_init_hw_82543() so the abstraction through e1000_setup_link() 
wouldn't be needed for init. However, e1000_setup_link() is also called 
from the common driver/ethtool entry points e1000_open() and 
e1000_set_pause_params(). These entry points could be moved in to the 
chip specific code, calling out to common code when necessary: the 
funcptrs/abstractions wouldn't then be needed. This would obviously lead 
to some common boilerplate code in each chip specific driver for the 
driver entry points open/close etc and occasionally some common changes 
might be needed in that code. However, I'm sure most bugs will be in the 
guts of the driver, not the boilerplate code so the duplication of the 
driver boilerplate code wouldn't matter so much. I think maintenance 
effort would actually reduce with this kind of structure.

I don't want to sound negative though; it's great that you and Intel are 
putting a lot of work into this driver. You know much more about the 
actual chip feature differences/workarounds than I do so if you don't 
think the approach I suggest will work, I'm happy to just drop this thread.

-- 
James Chapman
Katalix Systems Ltd
http://www.katalix.com
Catalysts for your Embedded Linux software development



-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
