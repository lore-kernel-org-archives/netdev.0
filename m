From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: Kernel oops when clearing bgp neighbor info with TCP MD5SUM
	enabled
Date: Mon, 19 Oct 2009 14:13:27 +0200
Message-ID: <20091019121327.GA11423@redhat.com>
References: <Pine.LNX.4.64.0910081514050.18315@sleet.zeugmasystems.local> <20091008.155429.02850661.davem@davemloft.net> <Pine.LNX.4.64.0910081622400.18315@sleet.zeugmasystems.local> <20091008.175703.83006470.davem@davemloft.net> <Pine.LNX.4.64.0910171035340.2364@sleet.zeugmasystems.local> <4ADA7EDC.5010402@anirban.org> <4ADB7856.7000803@anirban.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, David Miller <davem@davemloft.net>,
	netdev@vger.kernel.org, Anirban Sinha <asinha@zeugmasystems.com>
To: Anirban Sinha <ani@anirban.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:56782 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755529AbZJSMSA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 19 Oct 2009 08:18:00 -0400
Content-Disposition: inline
In-Reply-To: <4ADB7856.7000803@anirban.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Anirban,

On 10/18, Anirban Sinha wrote:
>
> I have a question for you. The queue_work() routine which is called from
> schedule_work() does a put_cpu() which in turn does a enable_preempt(). Is
> this an attempt to trigger the scheduler?

No. please note that queue_work() does get_cpu() + put_cpu() to protect
against cpu_down() in between.

This can trigger the scheduler of course, but everything should be OK.

> One of the side affects of
> this enable_preempt() is the crash that we see below. What is happening
> is that  a timer callback routine, in  this case inet_twdr_hangman(),
> tries a bunch of cleanup until a threshold is reached. If further cleanups
> needs to be done beyond the threshold, it queues a work function. Now when
> the timer callback is run in __run_timers(), the routine grabs the value
> of preempt_count before and after the callback function call. If the two
> counts do not match, it calls BUG() (line 1037 in kernel/timer.c).

Yes, but I can't see how queue_work() can be involved, it doesn't change
->preempt_count. Note again it does put after get.

> Is is
> it illegal to schedule a work function from within a timer callback?

Yes sure.

I'd suppose that this unbalance comes from inet_twdr_hangman() pathes.

Could you verify this?

Oleg.

