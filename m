From: "Johann Baudy" <johaahn@gmail.com>
Subject: Re: Fwd: Packet mmap: TX RING and zero copy
Date: Fri, 5 Sep 2008 14:44:47 +0200
Message-ID: <7e0dd21a0809050544m47deaf0dsf1f31805890ac09@mail.gmail.com>
References: <7e0dd21a0809030800v5e39808bl2f22893bc8214c2a@mail.gmail.com>
	 <7e0dd21a0809030858h7fdc454dj33acc6be25a0aab@mail.gmail.com>
	 <20080903164346.GA6729@2ka.mipt.ru>
	 <7e0dd21a0809031330i1363c4aema9c57ef06a3d5279@mail.gmail.com>
	 <20080903220347.GA22395@2ka.mipt.ru>
	 <7e0dd21a0809040744q3ee65695uc33f6cc26a1fe4dd@mail.gmail.com>
	 <20080905071754.GA25998@2ka.mipt.ru>
	 <7e0dd21a0809050216r65b8f08fm1ad0630790a13a54@mail.gmail.com>
	 <7e0dd21a0809050217v33ecb8fvcadd5e65118d6afe@mail.gmail.com>
	 <20080905113112.GA29926@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "Evgeniy Polyakov" <johnpol@2ka.mipt.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.224]:42630 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752626AbYIEMos (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Sep 2008 08:44:48 -0400
Received: by rv-out-0506.google.com with SMTP id k40so437821rvb.1
        for <netdev@vger.kernel.org>; Fri, 05 Sep 2008 05:44:47 -0700 (PDT)
In-Reply-To: <20080905113112.GA29926@2ka.mipt.ru>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Evgeniy,

>> vmsplice() is short in comparison to splice()  ~ 200us !
>> This was just to show you that even this vmpslice duration of 80us
>> that is needed for each packet is too long to send only 1 packet.
>> I really need a mechanism that allow sending of ~ 40 packets of 7200K
>> in one system call to keep some cpu ressources to do other things.
>> (Not spending time in kernel layers :))
>
> Hmmm... splice()/sendfile() shuold be able to send the whole file in
> single syscall. This looks like a problem in the userspace.
>

I was talking about vmsplice()/splice() which seems to me the only way
to send user buffer (pages) to socket without copy.

>> > kill_fasync() also took too much time (top CPU user
>> > is at bottom I suppose?), do you use SIGIO? Also vma traveling and page
>> > checking is not what will be done in network code and your project, so
>> > it also adds an overhead.
>>
>> Between kill_fasync() sys_gettimeofday() , I thought that we returned
>> to user space.
>> No SIGIO. But FYI, I use PREEMPT_RT patch.
>
> Does it also push softirq processing into threads?
>
I don't understand your point, how can I check?
I'm not handling any IRQ in this test software.

>> >Please try without vmsplice() at all, usual
>> > splice()/sendfile() _has_ to saturate the link, otherwise we have a
>> > serious problem.
>>
>> I've already tried sendfile only with standard TCP/UDP socket. I've
>> not saturated the link.
>> Around same bitrate.
>
> This worries me a lot: sendfile should be a single syscall which very
> optimally creates network packets getting into account MTU and hardware
> capabilities. I do belive it is a problem with userspace code.
>

Yes, and this is what it does (only one single syscall).
No printf, only one sendfile of 10MB file over TCP socket

To resume ongoing test status:
with vmsplice()/splice() I need to do multiple call of vmsplice() and
one call of splice() - ratio seems to be limited to the pipe capacity
(16 pages: 64K)
                                      - vmsplice call specify the size
of the udp packet which means 1 syscall per packet :(
                                      - In UDP, Bitrate is  < 20MB/s


with sendfile() only one system call of 10MB  in TCP (in UDP I have to
split in 61440 bytes).
                                      - In TCP bitrate is limited due to remote
                                      - In UDP,  this 61440 bytes
limit which  is really inferior to my 7200*40 packets that allows me
to saturate the link (during 2ms only...) with my circular buffer.
                                     - Bitrate is  < 20MB/s





Thanks,
Johann

-- 
Johann Baudy
johaahn@gmail.com
