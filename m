From: Neil Brown <neilb@suse.de>
Subject: Re: Top 10 kernel oopses for the week ending January 5th, 2008
Date: Thu, 10 Jan 2008 15:13:48 +1100
Message-ID: <18309.39804.31974.851666@notabene.brown>
References: <477FF149.4070609@linux.intel.com>
	<20080105213935.GN27894@ZenIV.linux.org.uk>
	<20080107174431.GC27741@fieldses.org>
	<4782CF9C.6000508@gmail.com>
	<alpine.LFD.1.00.0801071851120.3148@woody.linux-foundation.org>
	<20080108055917.GZ27894@ZenIV.linux.org.uk>
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
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns2.suse.de ([195.135.220.15]:42421 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754701AbYAJEOA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 Jan 2008 23:14:00 -0500
In-Reply-To: message from Al Viro on Tuesday January 8
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tuesday January 8, viro@ZenIV.linux.org.uk wrote:
> 
> FWIW, I'm going to go through Arjan's collection and post blow-by-blow
> analysis of some of those suckers.  Tonight, probably...
> 
> Let's take e.g. http://www.kerneloops.org/raw.php?rawid=2618

Thanks for that analysis.
...
> 
> Humm...  So we have kobj->parent containing crap.  What about the caller?
> It's from drivers/md/md.c:
> static void delayed_delete(struct work_struct *ws)

This is a good argument for sticking "md_" at the from of all my
function names, even if they are static.  I'm fairly sure I looked at
that trace:

> Call Trace:
>  [<ffffffff803b37e9>] kobject_put+0x19/0x20
>  [<ffffffff803b389b>] kobject_del+0x2b/0x40
>  [<ffffffff804d7d50>] delayed_delete+0x0/0xb0
>  [<ffffffff804d7db9>] delayed_delete+0x69/0xb0
>  [<ffffffff80249775>] run_workqueue+0x175/0x210
>  [<ffffffff8024a411>] worker_thread+0x71/0xb0
>  [<ffffffff8024d9e0>] autoremove_wake_function+0x0/0x40
>  [<ffffffff8024a3a0>] worker_thread+0x0/0xb0
>  [<ffffffff8024d5fd>] kthread+0x4d/0x80
>  [<ffffffff8020c4b8>] child_rip+0xa/0x12
>  [<ffffffff8020bbcf>] restore_args+0x0/0x30
>  [<ffffffff8024d5b0>] kthread+0x0/0x80
>  [<ffffffff8020c4ae>] child_rip+0x0/0x12

but as it doesn't mention 'md' or 'nfs' I moved on.  My bad.

> 
> What guarantees that it doesn't happen before we get to callback?  AFAICS,
> nothing whatsoever...

Yes, that's bad isn't it :-)

I think I should be using sysfs_schedule_callback here.  That makes the 
required 'get' and 'put' calls.... but it can fail with -ENOMEM.  I
wonder what I do if -ENOMEM???  Maybe I'll just continue to roll my
one :-( 

Thanks,
NeilBrown

