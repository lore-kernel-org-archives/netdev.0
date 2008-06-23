From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [RFC] NET_SCHED: restore HZ value to /proc/net/psched
Date: Mon, 23 Jun 2008 13:45:51 -0700
Message-ID: <20080623134551.24246494@extreme>
References: <20080623111320.7ddb72b9@extreme>
	<485FFB28.7070503@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([216.93.170.194]:44214 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754141AbYFWUp5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 23 Jun 2008 16:45:57 -0400
In-Reply-To: <485FFB28.7070503@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 23 Jun 2008 21:36:08 +0200
Patrick McHardy <kaber@trash.net> wrote:

> Stephen Hemminger wrote:
> > Some changes back in  2.6.22 broke a number of
> > other places where the iproute2 utilities depended on kernel HZ
> > value. The use of HZ was a bad original ABI design choice; the
> > question is how to fix the impacts.
> > 
> > During 2.6.22 development, the psched clock was converted over
> > to use high resolution timers, and one of the changes was to the
> > return value of /proc/net/psched. This file is used by utilities
> > to determine conversion between time and jiffies.
> > It would be better to go back to the original format
> > output where the fourth field was the kernel HZ.
> > 
> > The motivation for the change was to make the HTB burst size
> > default smaller because the kernel clock resolution was better.  
> > But the change broke the use of jiffies by dst_metrics.
> > 
> > With this revert all the metric RTT values will work again.
> > The only use of hz in htb is to set the buffer and ceiling buffer default,
> > and having the old value would cause a slightly larger value. Note: the comment
> > in q_htb is incorrect, the value calculated is the default not the
> > minimum.  As an example if HTB rate is 1mbit, then the default buffer
> > would be come 11500 (with 100 HZ) vs 1500 (with 2.6.25).
> > 
> > This effectively reverts commit 4361cb17f0df5491fe6e2c3ae1defc98e9a64a79
> > I am not 100% convinced this is the best or only solution.
> 
> Me neither. As you've mentioned yourself, the fact that
> the interfaces use kernel HZ as unit is a bug, and the use
> of /proc/net/psched is another bug (one that isn't present
> for *that* long I should add, the iproute git history
> unfortunately only contains one huge patch which includes
> this change).
> 
> IMO qdiscs shouldn't be punished for bugs in other code
> and the main problem would still remain. Two alternative
> approaches:
> 
> - just fix the interface (something we've done multiple
>    times, even after 2.6 was released).

It is easy if the only thing to worry about is the current kernel
and current iproute2 utilities. But if you want to deal with 3rd
party applications that use the API's already, then the problem
is much harder. I fixed the places where get_hz was used and user hz already.

Do I have to get down to:

static unsigned long kernel_version(void)
{
	struct utsname uts;
	unsigned a, b, c;

	
	uname(&uts);
	sscanf(uts.release, "%u.%u.%u", &a, &b, &c);
	return KERNEL_VERSION(a, b, c);
}
		
static unsigned long kernel_hz(void)
{
	unsigned long version = kernel_version();

	if (version <= KERNEL_VERSION(2,6,21))
		return __get_hz();
	else if (version <= KERNEL_VERSION(2,6,27)) {
		fprintf(stderr, "Your kernel is screwed up and I can't find correct HZ\n");
		exit(1);
	}
	else
		return get_user_hz();	/* interface is now in correct units */
}


Even HTB shouldn't really care what the kernel clock resolution is.

> - add a new proc file to get the value of kernel HZ (the
>    fix needs a kernel change anyway, this would additionally
>    require a new iproute version).

Don't like this might encourage new bad ABI's.
