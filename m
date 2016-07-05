From: Mason <slash.tmp@free.fr>
Subject: Re: WARNING: CPU: 0 PID: 0 at net/ipv4/af_inet.c:155
 inet_sock_destruct+0x1c4/0x1dc
Date: Tue, 5 Jul 2016 23:51:44 +0200
Message-ID: <577C2BF0.7030409@free.fr>
References: <577BB72E.3020904@free.fr> <577BC94A.4060204@free.fr>
 <577BD201.2040202@gmail.com> <577BD8BB.7060306@free.fr>
 <577BDE4E.7090509@gmail.com> <577C17F5.4020106@free.fr>
 <577C2506.5030300@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Sebastian Frias <sf84@laposte.net>
To: Florian Fainelli <f.fainelli@gmail.com>,
	linux-pm <linux-pm@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
Return-path: <linux-pm-owner@vger.kernel.org>
In-Reply-To: <577C2506.5030300@gmail.com>
Sender: linux-pm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 05/07/2016 23:22, Florian Fainelli wrote:
> On 07/05/2016 01:26 PM, Mason wrote:
>> On 05/07/2016 18:20, Florian Fainelli wrote:
>>> On 07/05/2016 08:56 AM, Mason wrote:
>>>> On 05/07/2016 17:28, Florian Fainelli wrote:
>>>>
>>>>> nb8800.c does not currently show suspend/resume hooks implemented, are
>>>>> you positive that when you suspend, you properly tear down all HW, stop
>>>>> transmit queues, etc. and do the opposite upon resumption?
>>>>
>>>> I am currently testing the error path for my suspend routine.
>>>> Firmware is, in fact, denying the suspend request, and immediately
>>>> returns control to Linux, without having powered anything down.
>>>>
>>>> I expected not having to save any context in that situation.
>>>> Am I mistaken?
>>>
>>> It depends what power state you are going to and resuming from, and how
>>> much of this is platform dependent, on the platforms I work with S2
>>> preserves register states for our On/Off domain, while S3 only keeps an
>>> always-on power island and shuts off the On/Off domain, you therefore
>>> need to have your drivers in the On/Off domain suspend any activity and
>>> preserve important register states, or re-initialize them from scratch
>>> whichever is the most convenient.
>>
>> Thanks for bringing these details to my attention, they will
>> definitely prove useful when I test an actual suspend/resume
>> sequence. However, I must stress that the platform did NOT
>> power down in my test case, because the firmware currently
>> denies all suspend requests.
>>
>> Therefore, loss of context cannot possibly explain the
>> warning I am seeing.
> 
> No, but if you go all the way down to trying to suspend and the last
> step is the firmware failing, anything you have suspended needs to be
> unwinded, for your ethernet driver that means that you went through a
> successful suspend then resume cycle even if it failed down later when
> the platform attempted to suspend.

So it is the driver's responsibility to "shut down" on resume?
(I had the vague impression that the suspend framework would
"disable" the device through the appropriate callback.)

>>> See drivers/net/ethernet/broadcom/genet/bcmgenet.c which is a driver
>>> that takes care of that for instance, look for bcmgenet_{suspend,resume}
>>
>> Thanks. I will look into it.
>>
>> If I understand correctly, something is missing in the
>> network interface code? (My system is using an NFS root
>> filesystem, so network is an important subsystem.)
> 
> The typical things are detaching the network device and stopping
> transmit queues, but without knowing what changes you have done to
> nb8800.c, hard to tell what else is needed.

I'm using the driver unaltered. So I guess I need to figure out
the exact steps required for suspending a network device.
(I'll look at bcmgenet.c tomorrow.)

>>>>> Is your system clocksource also correctly saved/restored, or if you go
>>>>> through a firmware in-between could it be changing the counter values
>>>>> and make Linux think that more time as elapsed than it really happened?
>>>>
>>>> Thanks for pointing this out, I was not aware I was supposed to save
>>>> and restore the tick counter on suspend/resume. (This is not an issue
>>>> in this specific situation, as the platform is NOT suspended.)
>>>
>>> You don't have to save and restore the clocksource counter, although if
>>> you want proper time accounting to be done across suspend states, you
>>> would want to use a clocksource which is persistent across these suspend
>>> states.
>>
>> The clocksource is a 27 MHz 32-bit tick counter. In other words,
>> the counter wraps around every 159 seconds. If Linux suspends
>> for several hours, how can it determine how much time went by?
> 
> Well, that's unfortunate, then you are pretty much either doomed to
> accepting to lose time in between and rely on e.g: NTP to resync your
> time upon resumption, or, if you had smarter hardware you could have a
> prescaler or something that makes this counter wrap far ahead (like
> years or days after).

Maybe the hardware devs thought of that problem, because they
"widened" the counter to 64 bits on newer platforms.

Regards.

