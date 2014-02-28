From: Rick Jones <rick.jones2@hp.com>
Subject: Re: Packet drops observed @ LINUX_MIB_TCPBACKLOGDROP
Date: Thu, 27 Feb 2014 16:34:52 -0800
Message-ID: <530FD9AC.6000506@hp.com>
References: <CAJzFV35=wUOA+pQCkAwV2+oF79VAmbsRY08gZUiFz-Vtw-898w@mail.gmail.com> <530F6AE8.1030307@hp.com> <CAJzFV36VXFuk1tiEYL8t0ypXWk424OdOdpE_bTjEXHRHYeuQZg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, harout@hedeshian.net
To: Sharat Masetty <sharat04@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t3425.houston.hp.com ([15.201.208.53]:22103 "EHLO
	g4t3425.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751685AbaB1Aez (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Feb 2014 19:34:55 -0500
In-Reply-To: <CAJzFV36VXFuk1tiEYL8t0ypXWk424OdOdpE_bTjEXHRHYeuQZg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/27/2014 12:50 PM, Sharat Masetty wrote:
> Hi Rick,
>
> Category 4 is 150Mbps Downlink and 50 Mbps Uplink. We are using iperf
> in our test and it seems that its the most widely used tool out there.
> We have not used netperf before and we will definitely give it a shot.
> Would you know how different is iperf from netperf? Should we expect
> similar results?

I would expect them to show similar results for similar test types.  I 
am not familiar with iperf's CPU utilization reporting.  If it doesn't 
have any, you can always run top at the same time - be certain to have 
it show all CPUs.  One can have a saturated CPU on a multiple CPU system 
and still have a low overall CPU utilization.  That is what all that -o 
<list> stuff was about showing - both overall and the ID and utilization 
of the most utilized CPU.  (Of course if your system is a single core 
all that becomes moot...)

> The TCP throughput is consistently slower and these drops are not
> helping either. We see huge dips consistently which I am positive is
> due to these drops.

Iperf may have a rate limiting option you could use to control how fast 
it sends and then walk that up until you see the peak.  All while 
looking at CPU util I should thing.

The netperf benchmark has rate limiting, but as an optional 
configuration parameter (configure --enable-intervals ...) and then a 
rebuild of the netperf binary.  If you want to take that path, contact 
me offline and I can go through the steps.

> Do you know how to tune the length of this socket backlog queue?

I think Eric mentioned that how much of that queue is used will (also) 
relate to the size of the socket buffer, so you might try creating a 
much larger SO_RCVBUF on the receive side.  I assume that iperf has 
options for that.  If you were using netperf it would be:

netperf -H <arm> -- -S 1M

though for that to "work" you will probably have to tweak 
net.core.rmem_max because for an explicit socket buffer size setting 
that sysctl will act as a bound.

If I've got the right backlog queue, there is also a sysctl for it - 
net.core.netdev_max_backlog .

happy benchmarking,

rick jones

> I am trying to correlate the iperf behavior(potential slowness) with
> this backlog drops. Any help in understanding this would be really
> helpful in looking for more clues.
>
> Thanks
> Sharat
>
>
>
> On Thu, Feb 27, 2014 at 9:42 AM, Rick Jones <rick.jones2@hp.com> wrote:
>> On 02/26/2014 06:00 PM, Sharat Masetty wrote:
>>>
>>> Hi,
>>>
>>> We are trying to achieve category 4 data rates on an ARM device.
>>
>>
>> Please forgive my ignorance, but what are "category 4 data rates?"
>>
>>
>>> We see that with an incoming TCP stream(IP packets coming in and
>>> acks going out) lots of packets are getting dropped when the backlog
>>> queue is full. This is impacting overall data TCP throughput. I am
>>> trying to understand the full context of why this queue is getting
>>> full so often.
>>>
>>>  From my brief look at the code, it looks to me like the user space
>>> process is slow and busy in pulling the data from the socket buffer,
>>> therefore the TCP stack is using this backlog queue in the mean time.
>>> This queue is also charged against the main socket buffer allocation.
>>>
>>> Can you please explain this backlog queue, and possibly confirm if my
>>> understanding this  matter is accurate?
>>> Also can you suggest any ideas on how to mitigate these drops?
>>
>>
>> Well, there is always the question of why the user process is slow pulling
>> the data out of the socket.  If it is unable to handle this "category 4 data
>> rate" on a sustained basis, then something has got to give.  If it is only
>> *sometimes* unable to keep-up but otherwise is able to go as fast and faster
>> (to be able to clear-out a backlog) then you could consider tweaking the
>> size of the queue.  But it would be better still to find the cause of the
>> occasional slowness and address it.
>>
>> If you run something which does no processing on the data (eg netperf) are
>> you able to achieve the data rates you seek?  At what level of CPU
>> utilization?  From a system you know can generate the desired data rate,
>> something like:
>>
>> netperf -H <yourARMsystem> -t TCP_STREAM -C  -- -m <what your application
>> sends each time>
>>
>> If the ARM system is multi-core, I might go with
>>
>> netperf -H <yourARMsystem> -t TCP_STREAM -C  -- -m <sendsize> -o
>> throughput,remote_cpu_util,remote_cpu_peak_util,remote_cpu_peak_id,remote_sd
>>
>> so netperf will tell you the ID and utilization of the most utilized CPU on
>> the receiver in addition to the overall CPU utilization.
>>
>> There might be other netperf options to use depending on just what the
>> sender is doing - to know which would require knowing more about this stream
>> of traffic.
>>
>> happy benchmarking,
>>
>> rick jones
