From: Wesley Chow <wchow@athenacr.com>
Subject: Re: Multicast packet loss
Date: Thu, 5 Feb 2009 08:46:46 -0500
Message-ID: <955CD08B-690D-42CF-A04D-FA618BA95B5A@athenacr.com>
References: <49837F56.2020502@athenacr.com> <49838213.90700@cosmosbay.com> <20090131160333.GC23100@localhost.localdomain> <498723D9.5020509@athenacr.com> <20090203115502.GB28117@hmsreliant.think-freely.org> <498860AD.5010702@athenacr.com> <20090204011541.GB3650@localhost.localdomain> <4989BD31.306@athenacr.com> <EA667848-C7EA-4409-B64D-9752C8ACECB6@athenacr.com> <4989DA58.3060203@cosmosbay.com> <20090205133341.GC15621@hmsreliant.think-freely.org>
Mime-Version: 1.0 (Apple Message framework v930.3)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <dada1@cosmosbay.com>,
	Kenny Chang <kchang@athenacr.com>,
	Neil Horman <nhorman@tuxdriver.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from li36-253.members.linode.com ([207.192.72.253]:54507 "EHLO
	shablam.senortoad.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751693AbZBENqt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Feb 2009 08:46:49 -0500
In-Reply-To: <20090205133341.GC15621@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


>>
>>
>> Maybe its time to change user side, and not try to find an  
>> appropriate kernel :)
>>
>> If you know you have to receive N frames per 20us units, then its  
>> better to :
>> Use non blocking sockets, and doing such loop :
>>
>> {
>> usleep(20); // or try to compensate if this thread is slowed too  
>> much by following code
>> for (i = 0 ; i < N ; i++) {
>> 	while (revfrom(socket[N], ....) != -1)
>> 		receive_frame(...);
>> 	}
>> }
>>
>> That way, you are pretty sure network softirq handler wont have to  
>> spend time trying
>> to wakeup 400.000 time per second one thread. All cpu cycles can be  
>> spent in NIC driver
>> and network stack.
>>
>> Your thread will do 50.000 calls to nanosleep() per second, that is  
>> not really expensive,
>> then N recvfrom() per iteration. It should work on all past ,  
>> current and future kernels.
>>
> +1 to this idea.  Since the last oprofile traces showed significant  
> variance in
> the time spent in schedule(), it might be worthwhile to investigate  
> the affects
> of the application behavior on this.  I might also be worth adding a  
> systemtap
> probe to sys_recvmsg, to count how many times we receive frames on a  
> working and
> non-working system.  If the app is behaving differently on different  
> kernels,
> and its affecting the number of times you go to get a frame out of  
> the stack,
> that would affect your drop rates, and it would show up in sys_recvmsg
>


I did some work to our test program to spin on a non-blocking socket  
and it indeed seems to fix the problem, at least for 2.6.28.1, which  
was a kernel we had problems with. The number of context switches  
drastically drops -- from 200,000+ to less than 50!

I haven't done totally comprehensive tests yet, so I don't want to  
officially state any results. I'm also out today, but Kenny may get a  
chance to play with it. Spinning on the socket is looking like an  
interesting solution, but we're a bit nervous about seeing our  
processes constantly running at 100% CPU. Does C++ have a  
MachineOnFire exception?


Wes

