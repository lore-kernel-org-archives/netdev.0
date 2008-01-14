From: Neil Brown <neilb@suse.de>
Subject: Re: Top 10 kernel oopses for the week ending January 5th, 2008
Date: Mon, 14 Jan 2008 12:36:10 +1100
Message-ID: <18314.48266.220382.180206@notabene.brown>
References: <477FF149.4070609@linux.intel.com>
	<20080105213935.GN27894@ZenIV.linux.org.uk>
	<20080107174431.GC27741@fieldses.org>
	<4782CF9C.6000508@gmail.com>
	<alpine.LFD.1.00.0801071851120.3148@woody.linux-foundation.org>
	<20080108055917.GZ27894@ZenIV.linux.org.uk>
	<18309.39804.31974.851666@notabene.brown>
	<20080110055359.GA27894@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	Kevin Winchester <kjwinchester@gmail.com>,
	"J. Bruce Fields" <bfields@fieldses.org>,
	Arjan van de Ven <arjan@linux.intel.com>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	NetDev <netdev@vger.kernel.org>, gregkh@suse.de
To: Al Viro <viro@ZenIV.linux.org.uk>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755385AbYANBgj@vger.kernel.org>
In-Reply-To: message from Al Viro on Thursday January 10
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thursday January 10, viro@ZenIV.linux.org.uk wrote:
> On Thu, Jan 10, 2008 at 03:13:48PM +1100, Neil Brown wrote:
> > > What guarantees that it doesn't happen before we get to callback?  AFAICS,
> > > nothing whatsoever...
> > 
> > Yes, that's bad isn't it :-)
> > 
> > I think I should be using sysfs_schedule_callback here.  That makes the 
> > required 'get' and 'put' calls.... but it can fail with -ENOMEM.  I
> > wonder what I do if -ENOMEM???  Maybe I'll just continue to roll my
> > one :-( 
> 
> How about this instead (completely untested)
> 
> 	* split failure exits
> 	* switch to kick_rdev_from_array()
> 	* fold unbind_rdev_from_array() into it (no other callers anymore)
> 	* take export_rdev() into failure case in bind_rdev_to_array()
> 	* in kick_rdev_from_array() do what export_rdev() does sans
> kobject_put() and do that before schedule_work().  Take kobject_put() into
> delayed_delete().

While there are probably some good ideas in there, I think fixing this
particular bug is much simpler.  Just take a reference to the object
before scheduling the worker, and drop it when the worker has done
its work.

I have a closer look at the idea of no required export_rdev after a
failed bind_rdev_to_array.  On the surface it does seem to make the
code nicer.

Thanks,
NeilBrown
