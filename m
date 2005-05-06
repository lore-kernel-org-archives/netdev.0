From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: [TG3]: Add tagged status support
Date: Fri, 06 May 2005 15:27:11 -0700
Message-ID: <1115418431.15156.153.camel@rh4>
References: <20050505211735.3829cff2.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20050505211735.3829cff2.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 2005-05-05 at 21:17 -0700, David S. Miller wrote:
> I've been meaning to do this for a long time.
> 
> This adds tagged status support.  With this, we don't need to
> poke the chip 10 times per second via the timer to keep from
> losing interrupts.
> 
> Michael, I didn't know what needs to be done wrt. MSI here.
> So I didn't touch the MSI code until I understand things better,
> which likely means that this patch breaks MSI (actually, I think
> it will cause the MSI case to generate interrupts endlessly).
> 
> My best hunch is that all MSI supporting chips support tagged
> status, therefore I should just make the tg3_msi() interrupt
> handler do the tp->last_tag stuff.

That's right. All MSI capable chips support tagged mode.

I tested the patch and it worked fine. But I'd like to suggest a few
things:

At the beginning of tg3_poll() before any work is done, update tp-
>last_tag with the current tag from the status block. The reason is that
under heavy traffic, tg3_poll() may be called multiple times before
interrupts are re-enabled. During this time, there may be additional
status block updates with updated tags. If tp->last_tag is not updated,
when we finally re-enable interrupts, we may write an old tag that will
cause the chip to interrupt us again unnecessarily.

In tagged mode, when we call tg3_restart_ints(), it is not necessary to
check for additional work and do "coalesce_now". The chip will do that
for us by looking at the tag written to the mailbox.

I think we can keep the same tg3_poll() for tagged and untagged modes by
using a function pointer that gets assigned different versions of
tg3_restart_ints() depending on the mode. The update of tp->last_tag at
the beginning of tg3_poll() can be done unconditionally provided we add
a check in tg3_enable_ints() to determine whether or not to use the tag.
This should be ok since tg3_enable_ints() is not in the fast path.
