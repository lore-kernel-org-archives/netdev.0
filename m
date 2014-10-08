From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [net-next PATCH v1 1/3] net: sched: af_packet support for direct
 ring access
Date: Wed, 08 Oct 2014 10:20:14 -0700
Message-ID: <5435724E.5090507@gmail.com>
References: <20141006000629.32055.2295.stgit@nitbit.x32> <20141006002951.GA24376@breakpoint.cc> <5431EC82.7010305@gmail.com> <543265A5.8000606@redhat.com> <5432AEE0.9000600@intel.com> <1412615032.3403.27.camel@localhost> <5432FD6D.2020102@intel.com> <1412637971.706532.175886517.077550BE@webmail.messagingengine.com> <20141007185940.GE27719@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	John Fastabend <john.r.fastabend@intel.com>,
	Daniel Borkmann <dborkman@redhat.com>,
	Jesper Dangaard Brouer <jbrouer@redhat.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	Florian Westphal <fw@strlen.de>, gerlitz.or@gmail.com,
	netdev@vger.kernel.org, john.ronciak@intel.com, amirv@mellanox.com,
	eric.dumazet@gmail.com, danny.zhou@intel.com,
	Willem de Bruijn <willemb@google.com>
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f52.google.com ([209.85.218.52]:59512 "EHLO
	mail-oi0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750979AbaJHRUk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Oct 2014 13:20:40 -0400
Received: by mail-oi0-f52.google.com with SMTP id a3so8216490oib.25
        for <netdev@vger.kernel.org>; Wed, 08 Oct 2014 10:20:39 -0700 (PDT)
In-Reply-To: <20141007185940.GE27719@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/07/2014 11:59 AM, Neil Horman wrote:
> On Tue, Oct 07, 2014 at 01:26:11AM +0200, Hannes Frederic Sowa wrote:
>> Hi John,
>>
>> On Mon, Oct 6, 2014, at 22:37, John Fastabend wrote:
>>>> I find the six additional ndo ops a bit worrisome as we are adding more
>>>> and more subsystem specific ndoops to this struct. I would like to see
>>>> some unification here, but currently cannot make concrete proposals,
>>>> sorry.
>>>
>>> I agree it seems like a bit much. One thought was to split the ndo
>>> ops into categories. Switch ops, MACVLAN ops, basic ops and with this
>>> userspace queue ops. This sort of goes along with some of the switch
>>> offload work which is going to add a handful more ops as best I can
>>> tell.
>>
>> Thanks for your mail, you answered all of my questions.
>>
>> Have you looked at <https://code.google.com/p/kernel/wiki/ProjectUnetq>?
>> Willem (also in Cc) used sysfs files which get mmaped to represent the
>> tx/rx descriptors. The representation was independent of the device and
>> IIRC the prototype used a write(fd, "", 1) to signal the kernel it
>> should proceed with tx. I agree, it would be great to be syscall-free
>> here.
>>
>> For the semantics of the descriptors we could also easily generate files
>> in sysfs. I thought about something like tracepoints already do for
>> representing the data in the ringbuffer depending on the event:
>>
>> -- >8 --
>> # cat /sys/kernel/debug/tracing/events/net/net_dev_queue/format
>> name: net_dev_queue
>> ID: 1006
>> format:
>> 	field:unsigned short common_type;       offset:0;       size:2;
>> 	signed:0;
>> 	field:unsigned char common_flags;       offset:2;       size:1;
>> 	signed:0;
>> 	field:unsigned char common_preempt_count;       offset:3;
>> 	size:1; signed:0;
>> 	field:int common_pid;   offset:4;       size:4; signed:1;
>>
>> 	field:void * skbaddr;   offset:8;       size:8; signed:0;
>> 	field:unsigned int len; offset:16;      size:4; signed:0;
>> 	field:__data_loc char[] name;   offset:20;      size:4;
>> 	signed:1;
>>
>> print fmt: "dev=%s skbaddr=%p len=%u", __get_str(name), REC->skbaddr,
>> REC->len
>> -- >8 --
>>
>> Maybe the macros from tracing are reusable (TP_STRUCT__entry), e.g.
>> endianess would need to be added. Hopefully there is already a user
>> space parser somewhere in the perf sources. An easier to parse binary
>> representation could be added easily and maybe even something vDSO alike
>> if people care about that.
>>
>> Maybe this open/mmap per queue also kills some of the ndo_ops?
>>
>> Bye,
>> Hannes
>>
>
>
> John-
> 	I don't know if its of use to you here, but I was experimenting awhile
> ago with af_packet memory mapping, using the protection bits in the page tables
> as a doorbell mechanism.  I scrapped the work as the performance bottleneck for
> af_packet wasn't found in the syscall trap time, but it occurs to me, it might
> be useful for you here, in that, using this mechanism, if you keep the transmit
> ring non-empty, you only encur the cost of a single trap to start the transmit
> process.  Let me know if you want to see it.
>
> Neil
>


Hi Neil,

If you could forward it along I'll take a look. It seems like something
along these lines will be needed.

Thanks,
John


-- 
John Fastabend         Intel Corporation
