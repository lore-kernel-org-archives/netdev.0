From: Luciano Coelho <luciano.coelho@nokia.com>
Subject: Re: [PATCH v3] netfilter: Xtables: idletimer target implementation
Date: Thu, 10 Jun 2010 00:28:40 +0300
Message-ID: <1276118920.11199.53.camel@powerslave>
References: <1275592445-15555-1-git-send-email-luciano.coelho@nokia.com>
	 <4C0F9B17.10504@trash.net> <1276096275.31892.117.camel@chilepepper>
	 <alpine.LSU.2.01.1006091716170.30265@obet.zrqbmnf.qr>
	 <1276105707.11199.12.camel@powerslave>
	 <1276108939.11199.23.camel@powerslave>
	 <alpine.LSU.2.01.1006092304270.16916@obet.zrqbmnf.qr>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: ext Patrick McHardy <kaber@trash.net>,
	"netfilter-devel@vger.kernel.org" <netfilter-devel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Timo Teras <timo.teras@iki.fi>
To: ext Jan Engelhardt <jengelh@medozas.de>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <alpine.LSU.2.01.1006092304270.16916@obet.zrqbmnf.qr>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2010-06-09 at 23:05 +0200, ext Jan Engelhardt wrote:
> On Wednesday 2010-06-09 20:42, Luciano Coelho wrote:
> >
> >> I'll move the sysfs file creation to outside that function so I can keep
> >> the lock until after the timer is added to the list.  Thanks for
> >> clarifying!
> >
> >Hmmm... after struggling with this for a while, I think it's not really
> >possible to simply create the sysfs file outside of the lock, because if
> >the sysfs creation fails, we will again risk a race condition.
> 
> Well if sysfs_add can return an error code when a file already
> exists (instead of adding it again), it's much easier. Try checking.

Unfortunately sysfs_add and sysfs_create will throw a kernel warning if
we try to create a file that already exists.  But this was not really
the problem.

Now I just throw an WARN_ON if the sysfs file creation fails, the other
sysfs functions I'm calling can handle this situation.  This shouldn't
happen in normal cases and, if it does, the timer will run normally, but
there won't be a sysfs file associated with it (and there won't be any
notification).

As I just wrote in another email, I thought I had figured out a way to
do it without a workqueue.  But now that I looked into the code again, I
think there might still be some race conditions... For example: If
someone deletes the timer immediately after I released the lock and
before I created the sysfs entry... The deletion won't cause problems if
the file is not there, it will just nop.  But the creation of the file
after the timer has been deleted will cause the file to be dangling in
sysfs without any timer associated with it... :(


-- 
Cheers,
Luca.

