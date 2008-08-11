From: David Witbrodt <dawitbro@sbcglobal.net>
Subject: Re: HPET regression in 2.6.26 versus 2.6.25 -- RCU problem
Date: Mon, 11 Aug 2008 11:01:42 -0700 (PDT)
Message-ID: <49829.86808.qm@web82105.mail.mud.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Peter Zijlstra <peterz@infradead.org>,
	linux-kernel@vger.kernel.org, Yinghai Lu <yhlu.kernel@gmail.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	"H. Peter Anvin" <hpa@zytor.com>, netdev <netdev@vger.kernel.org>
To: Ingo Molnar <mingo@elte.hu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from web82105.mail.mud.yahoo.com ([209.191.84.218]:27013 "HELO
	web82105.mail.mud.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752834AbYHKSBn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Aug 2008 14:01:43 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Thanks for the reply.  Let me address these out of order (cutting
your post):

> David, it would be nice to check whether tip/master still locks up for 
> you:
> 
>     http://people.redhat.com/mingo/tip.git/README
> 
> just to make sure no pending fix resolves your issue. (the bug is 
> probably still present, but might be worth checking nevertheless.)

Just to recap (not sure if you saw the earlier posts in the thread, going
back to Monday a week ago):

- kernel 2.6.25 worked for me without error

- kernel 2.6.26 locked up at boot when it finally became availble in
  Debian

- I was asked to grab Linus' git tree and try that, last Tuesday --
  v2.6.27-rc1 locked up like the 2.6.26 kernels.

OK, now grabbing "tip":
===== BEGIN SHELL STUFF =========
$ git remote add tip git://git.kernel.org/pub/scm/linux/kernel/git/tip/linux-2.6-tip.git
$ git remote update
$ git checkout tip/master

$ git show
commit 5cbd27ebcd387cbc48c47712eb671f35d85a575f
Merge: 2097987... 2ae111c...
Author: Ingo Molnar <mingo@elte.hu>
Date:   Mon Aug 11 16:43:42 2008 +0200

    Merge branch 'x86/core'
===== END SHELL STUFF =========

I copied into .config the configuration that I had prepared for 2.6.26
(which was prepared from my most recent version for 2.6.25) and ran
'make oldconfig'.  The kernel built fine, so I installed it and rebooted.

The kernel locked up as expected at inet_init().  Rebooting, and adding
"hpet=disable", allowed it to boot just fine... as expected.

I understand the need to do this, and was hoping that it would just
magically start working again.  But it didn't ... which means I don't
have to bisect again to find out when, where, and why!  ;)


> You can probably verify this by adding something like this to 
> kernel/timer.c's do_timer() function:
> 
>    if (printk_ratelimit())
>     printk("timer irq hit, jiffies: %ld\n", jiffies);

So I made this change to do_timer(), and rebuilt the kernel.

Unfortunately, I cannot report whether this change made a difference
in the output.  This is a 2.5 GHz AMD X2 4850e processor, and in the
few moments before freeze (maybe < 2 secs) the lines just scroll too
fast for me to read them.  Once the kernel locks up, that's it... no
more printk()'s.

I can report that the do_timer() change worked correctly, though.  I
rebooted with "hpet=disabled", and just happened to hit an automatic
fsck on a 460 GB partition.  The printk()'s interfere with the fsck 
progress indicator: about every 4 secs, ten of those printk()'s fire 
off very quickly.  (Pretty annoying, actually.)


> Yinghai, do you have any ideas about this particular problem? One theory 
> would be that your e820 changes might have caused a shuffling of 
> resources that made the hpet's timer IRQ generation inoperable.

It's so weird that this commit works on so many machines, but fails on
the 2 machines I have (with the same motherboard).  Of course, many
more people/machines might be affected by this issue, but they simply
aren't using 2.6.26 yet... and will find out later, the hard way!


Thanks,
Dave W.
