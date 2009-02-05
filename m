From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: Multicast packet loss
Date: Thu, 5 Feb 2009 08:29:56 -0500
Message-ID: <20090205132956.GB15621@hmsreliant.think-freely.org>
References: <49833DBC.7040607@athenacr.com> <20090130200330.GA12659@hmsreliant.think-freely.org> <49837F56.2020502@athenacr.com> <49838213.90700@cosmosbay.com> <20090131160333.GC23100@localhost.localdomain> <498723D9.5020509@athenacr.com> <20090203115502.GB28117@hmsreliant.think-freely.org> <498860AD.5010702@athenacr.com> <20090204011541.GB3650@localhost.localdomain> <4989BD31.306@athenacr.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Kenny Chang <kchang@athenacr.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:50623 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755751AbZBENaG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Feb 2009 08:30:06 -0500
Content-Disposition: inline
In-Reply-To: <4989BD31.306@athenacr.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Feb 04, 2009 at 11:07:13AM -0500, Kenny Chang wrote:
> Neil Horman wrote:
>> On Tue, Feb 03, 2009 at 10:20:13AM -0500, Kenny Chang wrote:
>>  =20
>>> Neil Horman wrote:
>>>    =20
>>>> On Mon, Feb 02, 2009 at 11:48:25AM -0500, Kenny Chang wrote:
>>>>        =20
>>>>> Neil Horman wrote:
>>>>>            =20
>>>>>> On Fri, Jan 30, 2009 at 11:41:23PM +0100, Eric Dumazet wrote:
>>>>>>                  =20
>>>>>>> Kenny Chang a =E9crit :
>>>>>>>                        =20
>>>>>>>> Ah, sorry, here's the test program attached.
>>>>>>>>
>>>>>>>> We've tried 2.6.28.1, but no, we haven't tried the 2.6.28.2 or=
 the
>>>>>>>> 2.6.29.-rcX.
>>>>>>>>
>>>>>>>> Right now, we are trying to step through the kernel versions u=
ntil we
>>>>>>>> see where the performance drops significantly.  We'll try 2.6.=
29-rc soon
>>>>>>>> and post the result.
>>>>>>>>                              =20
>>>>>>> 2.6.29-rc contains UDP receive improvements (lockless)
>>>>>>>
>>>>>>> Problem is multicast handling was not yet updated, but could be=
 :)
>>>>>>>
>>>>>>>
>>>>>>> I was asking you "cat /proc/interrupts" because I believe you m=
ight
>>>>>>> have a problem NIC interrupts being handled by one CPU only (wh=
en having problems)
>>>>>>>
>>>>>>>                        =20
>>>>>> That would be expected (if irqbalance is running), and desireabl=
e, since
>>>>>> spreading high volume interrupts like NICS accross multiple core=
s (or more
>>>>>> specifically multiple L2 caches), is going increase your cache l=
ine miss rate
>>>>>> significantly and decrease rx throughput.
>>>>>>
>>>>>> Although you do have a point here, if the system isn't running i=
rqbalance, and
>>>>>> the NICS irq affinity is spread accross multiple L2 caches, that=
 would be a
>>>>>> point of improvement performance-wise. =20
>>>>>>
>>>>>> Kenny, if you could provide the /proc/interrupts info along with=
 /proc/cpuinfo
>>>>>> and your stats that I asked about earlier, that would be a big h=
elp.
>>>>>>
>>>>>> Regards
>>>>>> Neil
>>>>>>
>>>>>>                  =20
>>>>> This is for a working setup.
>>>>>
>>>>>            =20
>>>> Are these quad core systems?  Or dual core w/ hyperthreading?  I a=
sk because in
>>>> your working setup you have 1/2 the number of cpus' and was not su=
re if you
>>>> removed an entire package of if you just disabled hyperthreading.
>>>>
>>>>
>>>> Neil
>>>>
>>>>        =20
>>> Yeah, these are quad core systems.  The 8 cpu system is a=20
>>> dual-processor  quad-core.  The other is my desktop, single cpu qua=
d=20
>>> core.
>>>
>>>    =20
>> Ok, so their separate systms then.  Did you actually experience drop=
s on the
>> 8-core system since the last reboot?  I ask because even when its di=
stributed
>> across all 8 cores, you only have about 500 total interrupts from th=
e NIC, and
>> if you did get drops, something more than just affinity is wrong.
>>
>> Regardless, spreading interrupts across cores is definately a proble=
m.  As eric
>> says, quad core chips are actually 2x2 cores, so you'll want to eith=
er just run
>> irqbalance to assign an apropriate affinity to the NIC, or manually =
look at each
>> cores physical id and sibling id, to assign affininty to a core or c=
ores that
>> share an L2 cache.  If you need to, as you've found, you may need to=
 disable msi
>> interrupt mode on your bnx2 driver.  That kinda stinks, but bnx2 IIR=
C isn't
>> multiqueue, so its not like msi provides you any real performance ga=
in.
>>
>> Neil
>>
>>  =20
> Hi Neil,
>
> Yeah, we've been rebooting this system left and right switch kernels.=
  =20
> The results are fairly consistent.  We were able to set the irq =20
> affinities, and as Wes had mentioned, what we see is that if we pin t=
he =20
> softirq to 1 core, and pin the app to its sibling, we see really good=
 =20
> performance, but as we load up other cores, the machine reaches a =20
> breaking point where all hell breaks loose and we drop a bunch.  (we =
=20
> hadn't turned off msi btw..)
>
> While we were able to tune and adjust performance like that, in the e=
nd, =20
> it doesn't really explain the difference between earlier and recent =20
> kernels, also it doesn't quite explain the difference between machine=
s.
>
> You mentioned it would be good to see the interrupts for each kernel,=
 in =20
> light of the above information, would it still be useful for me to =20
> provide that?
>
In light of what you said, I probably don't need to see it no, although=
 if you
go through testing on all these kernels again, I would suggest you take=
 a look
at the /proc/interrupt numbers yourself.  Like you said, its odd that t=
his
behavior changed, since the fast receive path is fairly consistent.  It=
 may be
that te nic driver your using (bnx2 I think?), had a change that either=
 broke
the ability to set affinity for msi interrupts, forcing an irq spread a=
nd
killing performance, or perhaps some large inefficiency was introduced =
either in
the interrupt handler itself, or in the napi poll method of the driver.=
  Another
good analysis technique would be to grab the latest kernel (which is 'b=
roken' I
think your chart indicated), and the nic driver from the last working k=
ernel.
Merge the driver into the latest kernel and see if the problem persists=
=2E  If
not, thats a pretty good indicator that a change in the driver has at l=
east some
culpability.

Best
Neil

> Kenny
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
