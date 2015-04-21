From: Petr Mladek <pmladek@suse.cz>
Subject: Re: [PATCH 04/16] printk: implement support for extended console
 drivers
Date: Tue, 21 Apr 2015 12:03:00 +0200
Message-ID: <20150421100300.GC4589@pathway.suse.cz>
References: <1429225433-11946-1-git-send-email-tj@kernel.org>
 <1429225433-11946-5-git-send-email-tj@kernel.org>
 <20150420154120.GA4589@pathway.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: akpm@linux-foundation.org, davem@davemloft.net,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Kay Sievers <kay@vrfy.org>
To: Tejun Heo <tj@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20150420154120.GA4589@pathway.suse.cz>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon 2015-04-20 17:43:07, Petr Mladek wrote:
> On Thu 2015-04-16 19:03:41, Tejun Heo wrote:
> > printk log_buf keeps various metadata for each message including its
> > sequence number and timestamp.  The metadata is currently available
> > only through /dev/kmsg and stripped out before passed onto console
> > drivers.  We want this metadata to be available to console drivers
> > too.  Immediately, it's to implement reliable netconsole but may be
> > useful for other console devices too.
> > 
> > This patch implements support for extended console drivers.  Consoles
> > can indicate that they process extended messages by setting the new
> > CON_EXTENDED flag and they'll fed messages formatted the same way as
> > /dev/kmsg output as follows.
> > 
> >  <level>,<sequnum>,<timestamp>,<contflag>;<message text>
> > 
> > One special case is fragments.  Message fragments are output
> > immediately to consoles to avoid losing them in case of crashes.  For
> > normal consoles, this is handled by later suppressing the assembled
> > result and /dev/kmsg only shows fully assembled message; however,
> > extended consoles would need both the fragments, to avoid losing
> > message in case of a crash, and the assembled result, to tell how the
> > fragments are assembled and which sequence number got assigned to it.
> > 
> > To help matching up the fragments with the resulting message,
> > fragments are emitted in the following format.
> > 
> >  <level>,-,<timestamp>,-,fragid=<fragid>;<message fragment>
> > 
> > And later when the assembly is complete, the following is transmitted,
> > 
> >  <level>,<sequnum>,<timestamp>,<contflag>,fragid=<fragid>;<message text>
> > 
> > * Extended message formatting for console drivers is enabled iff there

[...]

> Sigh, it adds another twist into the already complex printk code.
> 
> Another solution would be to allow to disable the continuous buffer
> via some boot option or /sys/kernel/debug entry if you want to debug
> such a problem and have problem with the partial flushing.
> 
> Hmm, I wonder what are the typical values passed via "dict" and if we
> need to handle this entry such a special way. It would make sense to
> always print dict values to the ext consoles and handle this as a
> yet another "normal" dict value. It would allow us to remove
> some hacks at least.

Another solution would be to always flush cont buffer when it is being
printed to the console. Then the messages might by distinguished by
the seqnum and fragid won't be needed. The question is if the cont
buffer will still have any affect after this change.

Best Regards,
Petr
