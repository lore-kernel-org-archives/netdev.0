From: Oliver Hartkopp <socketcan@hartkopp.net>
Subject: Re: Fighting out-of-order reception with RPS?
Date: Fri, 10 Jul 2015 22:36:43 +0200
Message-ID: <55A02CDB.6000302@hartkopp.net>
References: <559D628C.5020100@hartkopp.net>	<CALx6S35OJHyr6iwfdtYW6P-ke2pmsmQ9BjO-D=qjgCHxwF7oew@mail.gmail.com>	<559E0CDF.7080309@hartkopp.net> <CALx6S37JjusJ=+L3mXT0Dzf8XuU0+dgJQ7_Xn4U0nBtkf0gCHQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	"linux-can@vger.kernel.org" <linux-can@vger.kernel.org>,
	Sunil Kovvuri <sunil.kovvuri@gmail.com>,
	Jonathon Reinhart <jonathon.reinhart@gmail.com>
To: Tom Herbert <tom@herbertland.com>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <CALx6S37JjusJ=+L3mXT0Dzf8XuU0+dgJQ7_Xn4U0nBtkf0gCHQ@mail.gmail.com>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 07/10/2015 04:48 AM, Tom Herbert wrote:
> On Wed, Jul 8, 2015 at 10:55 PM, Oliver Hartkopp <socketcan@hartkopp.net> wrote:
>> Both drivers do not use NAPI. The just follow the way
>>
>> interrupt -> alloc_skb() -> fill skb -> netif_rx(skb)
>>
>> I'm usually testing with the USB adapters as the PCIe setup is not very
>> handy.
>>
> Okay, I see what is happening. In netif_rx when RPS is not enabled
> that packet is queued to the backlog queue for the local CPU. Since
> you're doing round robin on the interrupts then OOO packets can be a
> result. Unfortunately, this is the expected behavior. The correct
> kernel fix would be to move to these drivers to use NAPI.

Hm. Doesn't sound like a good solution when there's a difference between NAPI
and non-NAPI drivers in matters of OOO, right?

> RPS
> eliminates the OOO, but if there is no ability to derive a flow hash
> from packets everything will wind up one queue without load balancing.

Correct.

That's why I added

	skb_set_hash(skb, dev->ifindex, PKT_HASH_TYPE_L2);

in my driver, because the only relevant flow identifiction is the number of
the incoming CAN interface.

> Besides that, automatically setting RPS in drivers is a difficult
> proposition since there is no definitively "correct" way to do that in
> an arbitrary configuration.

What about checking in netif_rx() if the non-NAPI driver has set a hash (aka
the driver is OOO sensitive)?
And if so we could automatically set rps_cpus for this interface in a way that
all CPUs are enabled to take skbs following the hash.

Best regards,
Oliver


