From: Anirban Sinha <asinha@zeugmasystems.com>
Subject: Re: Kernel oops when clearing bgp neighbor info with TCP MD5SUM
 enabled
Date: Sat, 17 Oct 2009 10:57:21 -0700 (PDT)
Message-ID: <Pine.LNX.4.64.0910171035340.2364@sleet.zeugmasystems.local>
References: <Pine.LNX.4.64.0910081514050.18315@sleet.zeugmasystems.local>
 <20091008.155429.02850661.davem@davemloft.net>
 <Pine.LNX.4.64.0910081622400.18315@sleet.zeugmasystems.local>
 <20091008.175703.83006470.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	ani@anirban.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.zeugmasystems.com ([70.79.96.174]:21017 "EHLO
	zeugmasystems.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753250AbZJQR5R (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 17 Oct 2009 13:57:17 -0400
In-Reply-To: <20091008.175703.83006470.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 8 Oct 2009, David Miller wrote:

> >> > We are noticing a kernel OOPS on 2.6.26 kernel when we issue the command
> >> > "clear ip bgp <bgp-peer-ip>" on Quagga BGP routing software.
> >>
> >> You will need to update your kernel, there have been many TCP
> >> MD5 bug fixes since 2.6.26
> >>
> >
> > Sigh ... wish that were that easy!
>
> Contact your vendor for support :-)

but we *are* the vendors for our distribution and even though I may not be
a networking guru, I have little bit knowledge in working my way through the
kernel code. I have traced down the cause of the BUG() and when I did a git
pull against Linus' tree, I see the same issue in teh git tip as well.

The BUG() is triggered from kernel/timer.c, line 1037 within the
function __run_timers(). I am reporting these line numbers from the latest git
tip.

What happens is that before and after the callback, the code grabs the preempt
count and catches unbalanced preempt_enable() and preempt_disable() calls from
within the callback function.  In this case, the callback function is
inet_twdr_hangman() as can be seen from this instrumented log:

[02:15:15.941981] Kernel panic - not syncing: <3>huh, entered ffffffff803fbd60
(inet_twdr_hangman+0x0/0xe0)with preempt_count 00000102, exited with 00000101?

Clearly there is an extra unbalanced preempt_enable() somewhere within the
callback function.

When I looked at the function, I see that in net/ipv4/inet_timewait_sock.c
line 215, the function calls schedule_work(). schedule_work() calls
queue_work() which in turn calls put_cpu() that ultimately does a
preempt_enable(). It is this unbalanced preempt_enable() that decriments the
preempt_count by one as can be seen from the above trace.

I suspect that workqueue related operatios are illegal from a timer callback
function. In that case, the above mentioned callback function needs to be
fixed.

Yes, I can't explain why others are also not seeing the same bug crash. We
don't have the luxury to pull in the latest and greatest kernel from the git
tree everytime an update is made and try it out. So I am unable to repo the
issue with the latest kernel. But if that means that this issue should be
ignored, then that is fine by me. We will fix our private kenrel with an
appropriate patch as we continue to investigate more.

Cheers,

Ani

