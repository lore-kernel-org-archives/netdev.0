From: Cong Wang <amwang@redhat.com>
Subject: Re: [PATCH] netconsole: queue console messages to send later
Date: Tue, 08 Jun 2010 16:59:49 +0800
Message-ID: <4C0E0685.9040908@redhat.com>
References: <24059.1275417767@death.nxdomain.ibm.com> <1275938692-26997-1-git-send-email-fleitner@redhat.com> <20100607.165024.135517125.davem@davemloft.net> <20100608003707.GA30604@sysclose.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	fubar@us.ibm.com, mpm@selenic.com, gospo@redhat.com,
	nhorman@tuxdriver.com, jmoyer@redhat.com,
	shemminger@linux-foundation.org, linux-kernel@vger.kernel.org,
	bridge@lists.linux-foundation.org,
	bonding-devel@lists.sourceforge.net
To: Flavio Leitner <fbl@sysclose.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100608003707.GA30604@sysclose.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Thanks for your fix, Flavio!

On 06/08/10 08:37, Flavio Leitner wrote:
>> There may not be another timer or workqueue able to execute after the
>> printk() we're trying to emit.  We may never get to that point.
>
> What if in the netpoll, before we push the skb to the driver, we check
> for a bit saying that it's already pushing another skb. In this case,
> queue the new skb inside of netpoll and soon as the first call returns
> and try to clear the bit, it will send the next skb?
>
> printk("message 1")
> ...
> netconsole called
> netpoll sets the flag bit
> pushes to the bonding driver which does another printk("message 2")
> netconsole called again
> netpoll checks for the flag, queue the message, returns.
> so, bonding can finish up to send the first message
> netpoll is about to return, checks for new queued messages, and pushes them.
> bonding finishes up to send the second message
> ....
>
> No deadlocks, skbs are ordered and still under the same opportunity
> to send something. Does it sound acceptable?
> It's off the top of my head, so probably this idea has some problems.
>


I am not a net expert, I am not sure if this solution really addresses
David's concern, but it makes sense for me.

>
>> Fix the locking in the drivers or layers that cause the issue instead
>> of breaking netconsole.
>
> Someday, somewhere, I know because I did this before, someone will
> use a debugging printk() and will see the entire box hanging with
> absolutely no message in any console because of this problem.
> I'm not saying that fixing driver isn't the right way to go but
> it seems not enough to me.

Well, I think netconsole is not alone, other console drivers could
have the same problem, printk() is not always available in some
situation like this.

Thanks.
