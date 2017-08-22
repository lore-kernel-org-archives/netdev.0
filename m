From: Vallish Vaidyeshwara <vallish@amazon.com>
Subject: Re: [PATCH RESEND 0/2] enable hires timer to timeout datagram socket
Date: Tue, 22 Aug 2017 11:17:23 +0000
Message-ID: <20170822111723.GB102755@amazon.com>
References: <1503081850-10671-1-git-send-email-vallish@amazon.com>
 <20170818201854.xes246oviptinwvq@localhost>
 <20170818222756.GB28737@amazon.com>
 <20170819062145.vtr63ri4v577cymz@localhost>
 <20170820014744.GA43685@amazon.com> <20170821182210.GA2983@amazon.com>
 <20170822062311.okn7coroki2fjgyc@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <davem@davemloft.net>, <shuah@kernel.org>,
        <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
        <eduval@amazon.com>, <anchalag@amazon.com>, <tglx@linutronix.de>
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170822062311.okn7coroki2fjgyc@localhost>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Aug 22, 2017 at 08:23:11AM +0200, Richard Cochran wrote:
> On Mon, Aug 21, 2017 at 06:22:10PM +0000, Vallish Vaidyeshwara wrote:
> > AWS Lambda is affected by this change in behavior in
> > system call. Following links has more information:
> > https://en.wikipedia.org/wiki/AWS_Lambda
> 
> Quote:
> 
>     Unlike Amazon EC2, which is priced by the hour, AWS Lambda is
>     metered in increments of 100 milliseconds.
>
> So I guess you want the accurate timeout in order to support billing?
> In any case, even with the old wheel you didn't have guarantees WRT
> timeout latency, and so the proper way for the application to handle
> this is to use a timerfd together with HIGH_RES_TIMERS, and PREEMPT_RT
> in order to have sub-millisecond latency.
> 
> Thanks,
> Richard

Hello Richard,

4.4 kernel implementation of datagram socket wait code is calling
schedule_timeout() which in-turn calls __mod_timer(). __mod_timer()
does not add any slack. mod_timer() is the function that adds slack.
This gives good consistent results for event handling response time
on datagram socket timeouts.

strace from 4.4 test run of waiting for 180 seconds:
10:25:48.239685 setsockopt(3, SOL_SOCKET, SO_RCVTIMEO, "\264\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0", 16) = 0
10:25:48.239755 recvmsg(3, 0x7ffd0a3beec0, 0) = -1 EAGAIN (Resource temporarily unavailable)
10:28:48.236989 fstat(1, {st_mode=S_IFCHR|0620, st_rdev=makedev(136, 0), ...}) = 0

strace from 4.9 test run of waiting for 180 seconds times out close to 195 seconds:
setsockopt(3, SOL_SOCKET, SO_RCVTIMEO, "\264\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0", 16) = 0 <0.000028>
recvmsg(3, 0x7ffd6a2c4380, 0)           = -1 EAGAIN (Resource temporarily unavailable) <194.852000>
fstat(1, {st_mode=S_IFCHR|0620, st_rdev=makedev(136, 0), ...}) = 0 <0.000018>

This change of behavior in system call is breaking the application logic and
response time.

Thanks.
-Vallish
