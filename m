From: Denys Fedoryshchenko <nuclearcat@nuclearcat.com>
Subject: Re: kernel panic in 4.2.3, rb_erase in sch_fq
Date: Wed, 04 Nov 2015 07:13:24 +0200
Message-ID: <99c4b2ab62df950de391ee7987781461@visp.net.lb>
References: <d66d455afe6dd28bed32ed3e17f797b7@visp.net.lb>
 <CAHA+R7MNxEkMfyQa56d0HRk2HxeqsduUfM3BkBh=Oxm2yNBVaA@mail.gmail.com>
 <0705e2b76150c28341d7e1915433450d@visp.net.lb>
 <1446612381.4184.7.camel@edumazet-glaptop2.roam.corp.google.com>
 <1446613120.4184.9.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII;
 format=flowed
Content-Transfer-Encoding: 7bit
Cc: Cong Wang <cwang@twopensource.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	"David S. Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>, linux-kernel@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hosting.visp.net.lb ([194.146.153.11]:43525 "EHLO
	hosting.visp.net.lb" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751105AbbKDFN2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Nov 2015 00:13:28 -0500
Received: from hosting.visp.net.lb (localhost [127.0.0.1])
	by hosting.visp.net.lb (Postfix) with ESMTP id C102B481717
	for <netdev@vger.kernel.org>; Wed,  4 Nov 2015 07:13:26 +0200 (EET)
In-Reply-To: <1446613120.4184.9.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2015-11-04 06:58, Eric Dumazet wrote:
> On Tue, 2015-11-03 at 20:46 -0800, Eric Dumazet wrote:
>> On Wed, 2015-11-04 at 06:25 +0200, Denys Fedoryshchenko wrote:
>> > On 2015-11-04 00:06, Cong Wang wrote:
>> > > On Mon, Nov 2, 2015 at 6:11 AM, Denys Fedoryshchenko
>> > > <nuclearcat@nuclearcat.com> wrote:
>> > >> Hi!
>> > >>
>> > >> Actually seems i was getting this panic for a while (once per week) on
>> > >> loaded pppoe server, but just now was able to get full panic message.
>> > >> After checking commit logs on sch_fq.c i didnt seen any fixes, so
>> > >> probably
>> > >> upgrading to newer kernel wont help?
>> > >
>> > >
>> > > Can you share your `tc qdisc show dev xxxx` with us? And how to
>> > > reproduce
>> > > it? I tried to setup htb+fq and then flip the interface back and forth
>> > > but I don't
>> > > see any crash.
>> > My guess it wont be easy to reproduce, it is happening on box with 4.5k
>> > interfaces, that constantly create/delete interfaces,
>> > and even with that this problem may happen once per day, or may not
>> > happen for 1 week.
>> >
>> > Here is script that is being fired after new ppp interface detected. But
>> > pppoe process are independent from
>> > process that are "establishing" shapers.
>> 
>> 
>> It is probably a generic bug. sch_fq seems OK to me.
>> 
>> Somehow nobody tries to change qdisc hundred times per second ;)
>> 
>> Could you try following patch ?
>> 
>> It seems to 'fix' the issue for me.
> 
> Following patch would be more appropriate.
> Prior one was meant to 'show' the issue.
> 
> diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
> index cb5d4ad32946..7f5f3e8a10f5 100644
> --- a/net/sched/sch_generic.c
> +++ b/net/sched/sch_generic.c
> @@ -706,9 +706,11 @@ struct Qdisc *dev_graft_qdisc(struct netdev_queue
> *dev_queue,
>  	spin_lock_bh(root_lock);
> 
>  	/* Prune old scheduler */
> -	if (oqdisc && atomic_read(&oqdisc->refcnt) <= 1)
> -		qdisc_reset(oqdisc);
> -
> +	if (oqdisc) {
> +		if (atomic_read(&oqdisc->refcnt) <= 1)
> +			qdisc_reset(oqdisc);
> +		set_bit(__QDISC_STATE_DEACTIVATED, &oqdisc->state);
> +	}
>  	/* ... and graft new one */
>  	if (qdisc == NULL)
>  		qdisc = &noop_qdisc;

Applied, will test it, but this bug might be triggered rarely.
I will try to push it to more pppoe servers in order to stress test them 
(and 4.3) more.
