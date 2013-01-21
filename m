From: Li Yu <raise.sail@gmail.com>
Subject: Re: [PATCH 0/5]: soreuseport: Bind multiple sockets to the same port
Date: Mon, 21 Jan 2013 15:58:41 +0800
Message-ID: <50FCF531.1070900@gmail.com>
References: <alpine.DEB.2.00.1301141138440.959@pokey.mtv.corp.google.com> <AE90C24D6B3A694183C094C60CF0A2F6026B710E@saturn3.aculab.com> <CA+mtBx-DRiSg4z5OUvp4=pJxZ=Ki4pt-vz716ubsJx1PHnD7Nw@mail.gmail.com> <50FCECDE.7060200@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Laight <David.Laight@aculab.com>, netdev@vger.kernel.org,
	davem@davemloft.net, netdev@markandruth.co.uk,
	eric.dumazet@gmail.com
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:39481 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751951Ab3AUH6x (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jan 2013 02:58:53 -0500
Received: by mail-pa0-f50.google.com with SMTP id hz10so3257455pad.23
        for <netdev@vger.kernel.org>; Sun, 20 Jan 2013 23:58:52 -0800 (PST)
In-Reply-To: <50FCECDE.7060200@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=E4=BA=8E 2013=E5=B9=B401=E6=9C=8821=E6=97=A5 15:23, Li Yu =E5=86=99=E9=
=81=93:
> =E4=BA=8E 2013=E5=B9=B401=E6=9C=8817=E6=97=A5 02:22, Tom Herbert =E5=86=
=99=E9=81=93:
>>> Hmmm.... do you need that sort of fairness between the threads?
>>>
>> Yes :-)
>>
>>> If one request takes longer than average to process, then you
>>> don't want other requests to be delayed when there are other
>>> idle worker processes.
>>>
>> On a heavily loaded server processing thousands of requests/second,
>> law of large numbers hopefully applies where each connection
>> represents approximately same unit of work.
>>
>
> It seem that these words are reasonable for some scenarios, we
> backported old version of SO_REUSEPORT patch into RHEL6 2.6.32-220.x
> kernel on CDN platform, and result in better balanced
> CPU utility among some haproxy instances.
>
> Also, we did a performance benchmark for old SO_REUSEPORT. It
>
> indeed bring significant improvement for short connections performanc=
e
> sometimes, but it also has some performance regression another
> sometimes. I think that problem is random selecting policy, the
> selected result may trigger extra CPU cache misses -- I tried to writ=
e
> a SO_BINDCPU patch to directly use RPS/RSS hashed result to select
> listen fd, the performance regression disappear then. but I have send
> it here since I did not implement load balance feature yet ...
> I will send the benchmark results soon.
>

These are results of performance benchmark of old SO_REUSEPORT:

HW of testbed:

Summary:	Dell R720, 2 x Xeon E5-2680 0 2.70GHz, 31.4GB / 32GB 1600MHz D=
DR3
System:		Dell PowerEdge R720 (Dell 02P51C)
Processors:	2 x Xeon E5-2680 0 2.70GHz 8000MHz FSB (2 sockets x 8 cores=
=20
x 2 threads)
Memory:		31.4GB / 32GB 1600MHz DDR3 =3D=3D 8 x 4GB, 16 x empty
Network:	Chelsio Communications T420-CR Unified Wire Ethernet Controlle=
r
OS:		RHEL Server 6.2 (Santiago) x86_64, 64-bit
BIOS:		Dell 1.0.4 02/21/2012

processes/mode - number of worker processes/listen mode
	=09
		4/8/16 :  numbers of worker processes, each process is
			  bound on individual processor.

                 listen mode:
		 -s: RHEL6 without any extra patch
		 -r: RHEL6 with SO_REUSEPORT
		 -R: RHEL6 with both SO_REUSEPORT and SO_BINDCPU

64B|1x		- This benchmark suite just is to simulate simple RPC
		  workload. The client sends RPC request first, the
		  server replies a RPC response (I said such a pair of
		  messages is a RPC transaction ), then client send
		  next RPC request to start another new RPC trans.
	=09
		   64B/1024B : both RPC requests/responses are 64/1024
				bytes length.
		   1x/1024x : each TCP connection has 1 or 1024 RPC
			      trans.

The numbers in below table are represented by 10000 trans per second.

=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
processes/mode	64B|1x	64B|1024x	1024B|1x	1024B|1024x
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
4/-s		18	80		17		78
---------------------------------------------------------------------
4/-r		16	71		15		67
---------------------------------------------------------------------
4/-R		23	96		23		92
---------------------------------------------------------------------
8/-s		18	165		18		160
---------------------------------------------------------------------
8/-r		30	155		29		147
---------------------------------------------------------------------
8/-R		36	185		36		180
---------------------------------------------------------------------
16/-s		15	230		14		220
---------------------------------------------------------------------
16/-r		38	230		38		220
---------------------------------------------------------------------
16/-R		43	230		43		220
---------------------------------------------------------------------

Above data are against RHEL6 2.6.32.279.xx kernel, I also tested=20
upstream 3.6.2 kernel with these patches, the results are similar.

Thanks

Yu

>>> Also having the same thread normally collect a request would
>>> make it more likely that the required code/data be in the
>>> cache of the cpu (assuming that the main reason for multiple
>>> threads is to load balance over multiple cpus, and with the
>>> threads tied to a single cpu).
>>>
>> Right.  Multiple listener sockets also imply that the work on the
>> connected sockets will be in the same thread or at least dispatched =
to
>> thread which is close to the same CPU.  soreuseport moves the start =
of
>> siloed processing into kernel.
>>
>>> If there are a lot of processes sleeping in accept() (on the same
>>> socket) it might be worth looking at which is actually woken
>>> when a new connection arrives. If they are sleeping in poll/select
>>> it is probably more difficult (but not impossible) to avoid waking
>>> all the processes for every incoming connection.
>>
>> We had considered solving this within accept.  The problem is that
>> there's no way to indicate how much work a thread should do via
>> accept.  For instance, an event loop usually would look like:
>>
>> while (1) {
>>      fd =3D accept();
>>      process(fd);
>> }
>>
>> With multiple threads, the number of accepted sockets in a particula=
r
>> thread is non-deterministic.  It is even possible that one thread
>> could end up accepting all the connections, and the others are starv=
ed
>> (wake up but no connection to process.).  Since connections are the
>> unit of work, this creates imbalance among threads.  There was an
>> attempt to fix this in user space by sleeping for a while instead of
>> calling accept on threads for one that have already have a
>> disproportionate number of connections.  This was unpleasant-- it
>> needed shared state in user space and provided no granularity.
>>
>
> I also have some thinks on this imbalance problem ...
>
> At Last, I assumed that every accept-thread holds same numbers of
> listen sockets, so we just can do load balance base on length of acce=
pt
> queue.
>
> Thanks for great SO_REUSEPORT work.
>
>> Tom
>> --
>> To unsubscribe from this list: send the line "unsubscribe netdev" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>
>
