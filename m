From: Tom Herbert <tom@herbertland.com>
Subject: Re: Fighting out-of-order reception with RPS?
Date: Tue, 14 Jul 2015 11:02:16 -0700
Message-ID: <CALx6S37TMbi0s4LK_j=VyZB0-vEHBWF4nFJsNSfQOz5D-Q0ksw@mail.gmail.com>
References: <559D628C.5020100@hartkopp.net>
	<CALx6S35OJHyr6iwfdtYW6P-ke2pmsmQ9BjO-D=qjgCHxwF7oew@mail.gmail.com>
	<559E0CDF.7080309@hartkopp.net>
	<CALx6S37JjusJ=+L3mXT0Dzf8XuU0+dgJQ7_Xn4U0nBtkf0gCHQ@mail.gmail.com>
	<55A02CDB.6000302@hartkopp.net>
	<1436589345.24939.56.camel@edumazet-glaptop2.roam.corp.google.com>
	<55A2BCD8.4020303@hartkopp.net>
	<1436763470.24939.66.camel@edumazet-glaptop2.roam.corp.google.com>
	<55A5424B.2000803@hartkopp.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	"linux-can@vger.kernel.org" <linux-can@vger.kernel.org>,
	Sunil Kovvuri <sunil.kovvuri@gmail.com>,
	Jonathon Reinhart <jonathon.reinhart@gmail.com>
To: Oliver Hartkopp <socketcan@hartkopp.net>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <55A5424B.2000803@hartkopp.net>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jul 14, 2015 at 10:09 AM, Oliver Hartkopp
<socketcan@hartkopp.net> wrote:
> On 13.07.2015 06:57, Eric Dumazet wrote:
>>
>> On Sun, 2015-07-12 at 21:15 +0200, Oliver Hartkopp wrote:
>>
>>> E.g. with
>>>
>>>         skb_set_hash(skb, dev->ifindex, PKT_HASH_TYPE_L2);
>>>
>>> and
>>>
>>>         echo f > /sys/class/net/can0/queues/rx-0/rps_cpus
>>>
>>> I get properly ordered CAN frames - even with netif_rx() processed skbs.
>>> I
>>> just want to have this stuff to be enabled by default for CAN interfaces
>>> to
>>> kill the OOO frame issue.
>>
>>
>> I doubt your skb_set_hash() makes any difference.
>>
>> RPS prefers a L4 hash anyway (skb_get_hash()), so flow dissection
>> happens.
>>
>
> Please take a look into netif_rx_internal() in net/core/dev.c
>
> http://git.kernel.org/cgit/linux/kernel/git/stable/linux-stable.git/tree/net/core/dev.c?id=v4.2-rc1#n3486
>
> with CONFIG_RPS netif_rx() takes care about the rps cpu and puts the skb
> into the correct hash specific queue.
>
> As we usually have several PF_CAN sockets which get CAN frames from a
> specific CAN interface it makes no sense to enqueue packets into queues
> sorted by receiving sockets or L4 hash (we don't have L4 addressing on CAN).
>
> The skb_set_hash(skb, dev->ifindex, PKT_HASH_TYPE_L2) makes sure that the
> skbs from a specific CAN netdev are always processed in the same queue.
>
> When this is not wanted in 'fastpath netif_rx()' why is the CONFIG_RPS
> section in there?
>
> What is the advantage of implementing NAPI and a 'private sk_buf queue'
> suggested by Tom in http://marc.info/?l=linux-can&m=143681458003381&w=2 to
> set the hash as shown and enable rps_cpus?
>
> The latter just looks just like a complexity boost to have a functionality
> that already exists in netif_rx(). I just want to understand it.
>

netif_rx allows OOO packets and the way you're fixing that with RPS
and setting a "flow hash" are nothing more than hacks. Sorry, but
there is no way we are going to change RPS just to satisfy this your
case. If you want to do this right and get something in the kernel,
then implement NAPI for CAN drivers as has been suggested now by three
very experienced developers. This solves the your OOO problem and
moves drivers to NAPI which is the greatly preferred interface. I
really don't see why there needs to be any more discussion on this.

Tom



> Regards,
> Oliver
>
>
