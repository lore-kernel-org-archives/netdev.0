From: Michael Ma <make0818@gmail.com>
Subject: Re: qdisc spin lock
Date: Wed, 13 Apr 2016 11:23:23 -0700
Message-ID: <CAAmHdhx-nW_eAuTy_0z9j6fc-3RebyntMk9yFyAfndmkgSbtVA@mail.gmail.com>
References: <CAAmHdhw9bQkCm7uehRZ9mTetMzafdXxWhYj16f8W-YvSz8V4=g@mail.gmail.com>
	<CAM_iQpVSHqLcGjrErAsh54+iD8uwGH5QNGwiJVOQOTsk=dwDbw@mail.gmail.com>
	<CAAmHdhxagKnLP1_5ZW7HTsVBu0TSFYKCvNstAEWN-NHrdnvvVQ@mail.gmail.com>
	<56FDEE85.3020505@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f196.google.com ([209.85.223.196]:36696 "EHLO
	mail-io0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755216AbcDMSX3 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Apr 2016 14:23:29 -0400
Received: by mail-io0-f196.google.com with SMTP id s2so7940179iod.3
        for <netdev@vger.kernel.org>; Wed, 13 Apr 2016 11:23:29 -0700 (PDT)
In-Reply-To: <56FDEE85.3020505@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2016-03-31 20:44 GMT-07:00 John Fastabend <john.fastabend@gmail.com>:
> On 16-03-31 04:48 PM, Michael Ma wrote:
>> I didn't really know that multiple qdiscs can be isolated using MQ s=
o
>> that each txq can be associated with a particular qdisc. Also we don=
't
>> really have multiple interfaces...
>
> MQ will assign a default qdisc to each txq and the default qdisc can
> be changed to htb or any other qdisc of your choice.
>
>>
>> With this MQ solution we'll still need to assign transmit queues to
>> different classes by doing some math on the bandwidth limit if I
>> understand correctly, which seems to be less convenient compared wit=
h
>> a solution purely within HTB.
>>
>
> Agreed.
>
>> I assume that with this solution I can still share qdisc among
>> multiple transmit queues - please let me know if this is not the cas=
e.
>
> Nope sorry doesn't work that way unless you employ some sort of stack=
ed
> netdevice strategy which does start to get a bit complex. The basic h=
int
> would be to stack some type of virtual netdev on top of a device and
> run the htb qdisc there. Push traffic onto the netdev depending on th=
e
> class it belongs to. Its ugly yes.

Thanks for the input - is it possible to implement a MQ to allow one
qdisc to be associated with multiple TXQ belonging to one inner class?
Does that require any additional synchronization in qdisc routines? I
think it shouldn't because the common use of TC already associates one
qdisc with all the TXQ. This would simplify the way that qdisc is
crafted since it doesn't need to be created for each queue.

Also is it possible to allow multiple qdiscs to be associated with one
TXQ? I can see one issue with this - the TC interface for MQ today
doesn't allow one TXQ to be associated with multiple classes, but this
seems to be a restriction only from the tc command interface
perspective. MQ anyway only establishes a connection between TXQ and
qdisc so theoretically we can associate one TXQ to multiple
classes/qdiscs and use priority/classid of the packet to do the
pre-selection of qdisc. Again, I might have missed some potential
synchronization issue when this actually happens because today TXQ is
not shared by multiple qdiscs in any case.

>
> Noting all that I posted an RFC patch some time back to allow writing
> qdiscs that do not require taking the lock. I'll try to respin these
> and submit them when net-next opens again. The next logical step is t=
o
> write a "better" HTB probably using a shared counter and dropping the
> requirement that it be exact.
>
> Sorry I didn't get a chance to look at the paper in your post so not
> sure if they suggest something similar or not.
>
> Thanks,
> John
>
>>
>> 2016-03-31 15:16 GMT-07:00 Cong Wang <xiyou.wangcong@gmail.com>:
>>> On Wed, Mar 30, 2016 at 12:20 AM, Michael Ma <make0818@gmail.com> w=
rote:
>>>> As far as I understand the design of TC is to simplify locking sch=
ema
>>>> and minimize the work in __qdisc_run so that throughput won=E2=80=99=
t be
>>>> affected, especially with large packets. However if the scenario i=
s
>>>> that multiple classes in the queueing discipline only have the sha=
ping
>>>> limit, there isn=E2=80=99t really a necessary correlation between =
different
>>>> classes. The only synchronization point should be when the packet =
is
>>>> dequeued from the qdisc queue and enqueued to the transmit queue o=
f
>>>> the device. My question is =E2=80=93 is it worth investing on avoi=
ding the
>>>> locking contention by partitioning the queue/lock so that this
>>>> scenario is addressed with relatively smaller latency?
>>>
>>> If your HTB classes don't share bandwidth, why do you still make th=
em
>>> under the same hierarchy? IOW, you can just isolate them either wit=
h some
>>> other qdisc or just separated interfaces.
>
