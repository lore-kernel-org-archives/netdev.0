From: Greg KH <greg@kroah.com>
Subject: Re: [1/3] 2.6.21-rc6: known regressions
Date: Sat, 14 Apr 2007 00:25:42 -0700
Message-ID: <20070414072542.GB6344@kroah.com>
References: <Pine.LNX.4.64.0704051944230.6730@woody.linux-foundation.org>
	<20070414003625.GS5907@stusta.de>
	<Pine.LNX.4.64.0704131821020.28042@woody.linux-foundation.org>
	<20070414062143.GA12707@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Ayaz Abdulla <aabdulla@nvidia.com>,
	e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	Adrian Bunk <bunk@stusta.de>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Dave Jones <davej@redhat.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Jeff Garzik <jgarzik@pobox.com>,
	"David S. Miller" <davem@davemloft.net>
To: Ingo Molnar <mingo@elte.hu>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
Content-Disposition: inline
In-Reply-To: <20070414062143.GA12707@elte.hu>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Sender: e1000-devel-bounces@lists.sourceforge.net
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On Sat, Apr 14, 2007 at 08:21:43AM +0200, Ingo Molnar wrote:
> 
> * Linus Torvalds <torvalds@linux-foundation.org> wrote:
> 
> > Note: Ingo also reports what looks like a memory corruption due to the 
> > 6b6b6b6b pattern on presumably the same box.
> > 
> > The 6b6b6b6b pattern is POISON_FREE, implying some kind of slab 
> > misuse, most likely a use-after-free, although possibly just due to 
> > overrunning a slab into the next one or something like that.
> 
> unfortunately, while being at -rc6 based kernel #445 meanwhile, this 
> incident was the only time i saw this problem. Note: while it's a 
> CONFIG_SMP kernel, in that bootup i was using maxcpus=1:
> 
>    WARNING: maxcpus limit of 1 reached. Processor ignored.
> 
> so it's a pure UP problem. Plus i used PREEMPT_NONE. So this really must 
> be something fundamental.
> 
> > What I'm leading up to is that I'm wondering if these mysterious 
> > network driver bugs aren't due to the network drivers themselves, but 
> > due to some higher-level problem. I think the hangs that Ingo sees 
> > with forcedeth were preceded by mysterious and "impossible" NULL 
> > pointer oopses. Ingo?
> 
> hm. I would tend to exclude networking, because the oops happened right 
> during bootup (i saw it happen real time on the serial console), 
> possibly before networking was brought up. It was udevd that crashed, 
> and rarely does udevd do anything after its initial /dev hierarchy setup 
> frenzy. (But this testbox boots very fast so it might have been near 
> network bringup.)
> 
> note that i can pretty much freely force the forcedeth problem to occur 
> on -rt [but all the reports i sent about it were done on a vanilla 
> kernel]. I triggered that problem at least a couple of dozen times, and 
> it _never_ caused any other effect besides the skb NULL dereference - or 
> lately (with the latest forcedeth.c version), a pure forcedeth interface 
> hang. That doesnt exclude networking driver badness, but makes it less 
> likely.
> 
> to me this crash has the feeling of being sysfs related: not just 
> because the crash itself is within sysfs:
> 
>  EIP is at module_put+0x19/0x2d
> 
>  [<c0104c44>] show_trace_log_lvl+0x19/0x2e
>  [<c0104cf4>] show_stack_log_lvl+0x9b/0xa3
>  [<c0104fdd>] show_registers+0x1c8/0x29a
>  [<c01052d0>] die+0x119/0x1f0
>  [<c03cd075>] do_page_fault+0x4e3/0x5b8
>  [<c03cb7a4>] error_code+0x7c/0x84
>  [<c019e832>] sysfs_release+0x55/0x76
>  [<c0167c7f>] __fput+0xb9/0x15e
>  [<c0167d3b>] fput+0x17/0x19
>  [<c01658b2>] filp_close+0x52/0x5a
>  [<c01660a3>] sys_close+0x76/0xad
>  [<c0103dc0>] syscall_call+0x7/0xb
> 
> but also because udevd itself is _very_ sysfs intense - an in fact on 
> this bzImage kernel it's perhaps the _only_ true sysfs activity that 
> happens. (there are no loadable modules whatsoever, all drivers are 
> built in)

What version of udev are you using?  Newer versions of udev don't hit
sysfs as much as they get the majority of their information from the
uevent message instead.

thanks,

greg k-h

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
