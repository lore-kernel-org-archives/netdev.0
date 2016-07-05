From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: WARNING: CPU: 0 PID: 0 at net/ipv4/af_inet.c:155
 inet_sock_destruct+0x1c4/0x1dc
Date: Tue, 5 Jul 2016 09:20:30 -0700
Message-ID: <577BDE4E.7090509@gmail.com>
References: <577BB72E.3020904@free.fr> <577BC94A.4060204@free.fr>
 <577BD201.2040202@gmail.com> <577BD8BB.7060306@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Sebastian Frias <sf84@laposte.net>
To: Mason <slash.tmp@free.fr>, linux-pm <linux-pm@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
Return-path: <linux-pm-owner@vger.kernel.org>
In-Reply-To: <577BD8BB.7060306@free.fr>
Sender: linux-pm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 07/05/2016 08:56 AM, Mason wrote:
> On 05/07/2016 17:28, Florian Fainelli wrote:
> 
>> nb8800.c does not currently show suspend/resume hooks implemented, are
>> you positive that when you suspend, you properly tear down all HW, stop
>> transmit queues, etc. and do the opposite upon resumption?
> 
> I am currently testing the error path for my suspend routine.
> Firmware is, in fact, denying the suspend request, and immediately
> returns control to Linux, without having powered anything down.
> 
> I expected not having to save any context in that situation.
> Am I mistaken?

It depends what power state you are going to and resuming from, and how
much of this is platform dependent, on the platforms I work with S2
preserves register states for our On/Off domain, while S3 only keeps an
always-on power island and shuts off the On/Off domain, you therefore
need to have your drivers in the On/Off domain suspend any activity and
preserve important register states, or re-initialize them from scratch
whichever is the most convenient.


> 
> You mention "stop transmit queues". Can you say more about this?

See drivers/net/ethernet/broadcom/genet/bcmgenet.c which is a driver
that takes care of that for instance, look for bcmgenet_{suspend,resume}

> 
>> Is your system clocksource also correctly saved/restored, or if you go
>> through a firmware in-between could it be changing the counter values
>> and make Linux think that more time as elapsed than it really happened?
> 
> Thanks for pointing this out, I was not aware I was supposed to save
> and restore the tick counter on suspend/resume. (This is not an issue
> in this specific situation, as the platform is NOT suspended.)

You don't have to save and restore the clocksource counter, although if
you want proper time accounting to be done across suspend states, you
would want to use a clocksource which is persistent across these suspend
states.

> 
> However, your remark has brought some more confusion to my mind.
> Linux is expecting time to stand still when it suspends?
> What if the tick counter is in an always-on power domain, and other
> processors depend on the counter? I can't just overwrite the reg
> when Linux resumes...

The point is more that if the firmware initializes the timer, or even
re-initializes it, Linux could think that events expired because the
timebase has a big offset compared to where it was. Just pointing out
that this *could* be a problem. If your timer is in the always on domain
and your firmware does not touch it, that should be fine without
anything specific (except adding an "always-on" boolean property to the
timer nodes in DT maybe).
-- 
Florian
