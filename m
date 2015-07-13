From: Tom Herbert <tom@herbertland.com>
Subject: Re: Fighting out-of-order reception with RPS?
Date: Mon, 13 Jul 2015 12:08:26 -0700
Message-ID: <CALx6S36G1hkS+Fg5joSiMHNo+UvJ2DBsTp91kyr3eqm2vuLq0Q@mail.gmail.com>
References: <559D628C.5020100@hartkopp.net>
	<CALx6S35OJHyr6iwfdtYW6P-ke2pmsmQ9BjO-D=qjgCHxwF7oew@mail.gmail.com>
	<559E0CDF.7080309@hartkopp.net>
	<CALx6S37JjusJ=+L3mXT0Dzf8XuU0+dgJQ7_Xn4U0nBtkf0gCHQ@mail.gmail.com>
	<55A02CDB.6000302@hartkopp.net>
	<1436589345.24939.56.camel@edumazet-glaptop2.roam.corp.google.com>
	<55A2BCD8.4020303@hartkopp.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	"linux-can@vger.kernel.org" <linux-can@vger.kernel.org>,
	Sunil Kovvuri <sunil.kovvuri@gmail.com>,
	Jonathon Reinhart <jonathon.reinhart@gmail.com>
To: Oliver Hartkopp <socketcan@hartkopp.net>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <55A2BCD8.4020303@hartkopp.net>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Jul 12, 2015 at 12:15 PM, Oliver Hartkopp
<socketcan@hartkopp.net> wrote:
> Hello Eric,
>
> On 07/11/2015 06:35 AM, Eric Dumazet wrote:
>> On Fri, 2015-07-10 at 22:36 +0200, Oliver Hartkopp wrote:
>
>>> Hm. Doesn't sound like a good solution when there's a difference between NAPI
>>> and non-NAPI drivers in matters of OOO, right?
>>
>> Isn't OOO a problem for you ? Then you either have to :
>>
>> 1) Use a single CPU to handle IRQ from the device
>> 2) Use NAPI
>>
>
> See below ...
>
>>> What about checking in netif_rx() if the non-NAPI driver has set a hash (aka
>>> the driver is OOO sensitive)?
>>> And if so we could automatically set rps_cpus for this interface in a way that
>>> all CPUs are enabled to take skbs following the hash.
>>
>> Wow, netif_rx() is packet processing fast path, certainly not the place
>> to add controlling path decisions.
>
> My only requirement is to be able to pick CAN frames (contained in skbs) from
> the socket in the same order they have been received.
>
>> Please convert your driver to NAPI. You might then even benefit from
>> GRO.
>
> Just some remarks about CAN and CAN frames as you suggest GRO which is
> completely pointless for CAN.
>
> CAN frames have a 11 or 29 bit CAN Identifier (no MAC but content addressing)
> and 0 to 64 bytes of payload. Therefore the MTU for CAN interfaces is 16 or 72
> byte (see struct can(fd)_frame). Each skbuff contains a single CAN frame.
>
> There are CAN controllers which have a FIFO for up to 32 CAN frames, e.g.
> flexcan.c which also implements NAPI. Others (e.g. sja1000.c) don't have any
> FIFO and the reading of the CAN frame from the memory mapped registers needs
> to be processed in the irq context instantly. So 'fast path' netif_rx() is
> reasonable, right?
>
> So why is it not possible to pass netif_rx() skbs from a specific CAN network
> interface to whatever queue where they are processed in order?
>
> E.g. with
>
>         skb_set_hash(skb, dev->ifindex, PKT_HASH_TYPE_L2);
>
> and
>
>         echo f > /sys/class/net/can0/queues/rx-0/rps_cpus
>
> I get properly ordered CAN frames - even with netif_rx() processed skbs. I
> just want to have this stuff to be enabled by default for CAN interfaces to
> kill the OOO frame issue.
>
If you really must process the CAN FIFO in the hard interrupt then
create a private sk_buf queue. In the interrupt, dequeue from FIFO and
enqueue on the sk_buf queue. Then schedule NAPI, and when that runs
process the sk_buf queue calling call netif_receive_skb for each
enqueued skb. Pretty simple actually :-)

> Regards,
> Oliver
>
