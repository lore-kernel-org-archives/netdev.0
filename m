From: Javier Domingo <javierdo1@gmail.com>
Subject: Re: Network soft and hard irqs statistics
Date: Thu, 22 Nov 2012 02:08:42 +0100
Message-ID: <CALZVapkwAhMiLczM1orKzfaoj=u1F3UEoC7XwKLSvFZDg6wgTQ@mail.gmail.com>
References: <CALZVapnXkUvdst0sC5sWCFkiLEGq5RXg6=0Lyt+nT-SheaxiSg@mail.gmail.com>
 <CALZVapkHda-tYNJALJWjhGwFBjAet84gxJam2UoK9WzMKQE6Bw@mail.gmail.com> <CALZVapky_zgCOQzafyi6iAyxf4LobiqEDP6Sw3uVQvD9+fBUDQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vc0-f174.google.com ([209.85.220.174]:52814 "EHLO
	mail-vc0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757444Ab2KVUCn convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Nov 2012 15:02:43 -0500
Received: by mail-vc0-f174.google.com with SMTP id m18so5003757vcm.19
        for <netdev@vger.kernel.org>; Thu, 22 Nov 2012 12:02:43 -0800 (PST)
In-Reply-To: <CALZVapky_zgCOQzafyi6iAyxf4LobiqEDP6Sw3uVQvD9+fBUDQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello once again.

I work out another way to do the same, but it is still giving me
kernel panics, and now I don't know why.

I think that the kernel panic is due to a cache fault between the
local_irq_disable() and the local_irq_enable(). Thinking on this, the
first commit I sent yesterday was doing no check to see if it was in
the processor's cache.

I really thought that the check that line 3394 was doing some type of
check to get assured that the netdevice it was going to access was in
the softirq context (in the processor cach=C3=A9), but that isn't becau=
se
if I do the same sanity check, it doesn't work (with another type of
algorithm)

So I now have worked on an alternative solution to get sure that the
napi_struct I am using is to be attended in that softirq. I have
changed the capture_stats structure to napi_struct. The idea is that
everytime I poll an interface, I add it to a list, in the way that
when I get out, I can go to that list and make a list_for_each to
easily grab all the polled napi_struct and then just update the values
I need.

This is how I implemented the solution:
https://github.com/txomon/linux/blob/aba285f3804f96256bb6ad2537832e50c8=
70b956/net/core/dev.c#L3954

But it isn't working either.

I would appreciate any type of help, tip or idea. Don't know what more
to do/read.

Regards,

Javier Domingo


2012/11/20 Javier Domingo <javierdo1@gmail.com>:
> I have released the mentioned code in
>
> https://github.com/txomon/linux
>
> It now is giving some kernel panics due to some page fault during
> net_rx_action because I didn't know how to put this in current kernel=
,
> but I am currently working in an alternative solution
>
> https://github.com/txomon/linux/blob/affde7645451eb62cdd1993a8cef7b53=
25e30b96/net/core/dev.c#L3944
>
> Hope someone can help me now :D
>
> Javier Domingo
>
>
>
> 2012/11/15 Javier Domingo <javierdo1@gmail.com>
>>
>> Hello all,
>>
>> I am migrating some statistics we use in our research group to v3.6.
>> This I don't think it will be usefull for anyone, as they measure
>> softirqs, hardirqs, times on them, etc.
>>
>> We modified net_device structure to contain a structure that has
>> several field of statistics.
>>
>> Patched the e1000 and tg3 drivers to measure hardirq times, and
>> polling times. We also patched net_rx_action (the softirq) to check =
if
>> we get out per budget, per jiffies and netif_receive_skb to measure
>> times and how many packets are captured.
>>
>> At the moment, we have been working with a external module that
>> accessed this vars, creating proc entries, and allowing us to reset
>> those measures.
>>
>> Now, I am trying to make it the most standard way, with the intentio=
n
>> that when I talk to my boss, he will allow me to release the code.
>>
>> The main aim of this is to get some feedback about the interest this
>> can have and to ask a few questions:
>>
>> -> Where may I create the proc entry? we currently use
>> /proc/net/stats/<netdev>. I have also thought introducing that entry
>> in fs/proc/proc_net.c, but I am not too sure which conventions there
>> are...
>>
>> -> When migrating the net_rx_action, I found that we used this line:
>> if(cpus_equal(mask,irq_desc[timedev->irq].affinity))
>> before counting if we get out by budget or by jiffies to (I suppose)
>> check that the softirq was the one assigned to this processor. Is th=
at
>> needed? I mean the softirq is run in just one of them... I don't
>> really understand why it is important, so if anyone can explain me, =
I
>> would be glad.
>>
>> -> We have patched the hardirqs in the driver, and the polling times
>> too. I know the hardirqs are the only place in which we can measure
>> them, but would it be posible to, instead of measuring the polls in
>> e1000_clean (for example) measuring in dev.c net_rx_action, measure
>> them around n->poll() call?
>>    Have been doing like this because they told me that the context
>> change was important... But I am not too sure on how important it is=
,
>> if someone could give me any tip on this.
>>
>> -> In tg3.c I have seen that there are several hardirq function,
>> though we usually only patched tg3_interrupt_tagged, I have patched
>> all of them (for what they might be). Why are so many of them? Is th=
at
>> due to preparation for multiqueue cards?
>>
>> I hope someone can attend my doubts, and that I dont have asked too
>> many newbie questions.
>>
>> Best regards,
>>
>> Javier Domingo
