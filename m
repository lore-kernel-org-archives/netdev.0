From: Saeed Mahameed via iovisor-dev <iovisor-dev-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org>
Subject: Re: [PATCH RFC 11/11] net/mlx5e: XDP TX xmit more
Date: Wed, 7 Sep 2016 18:08:04 +0300
Message-ID: <CALzJLG8G1SvmHKLm2Oqn3v8FUAOjScS+=tsbOaixkPUY4JFDPQ@mail.gmail.com>
References: <1473252152-11379-1-git-send-email-saeedm@mellanox.com>
	<1473252152-11379-12-git-send-email-saeedm@mellanox.com>
	<1473259302.10725.31.camel@edumazet-glaptop3.roam.corp.google.com>
Reply-To: Saeed Mahameed <saeedm-LDSdmyG8hGV8YrgS2mwiifqBs+8SCbDb@public.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	iovisor-dev <iovisor-dev-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org>,
	Jamal Hadi Salim <jhs-jkUAjuhPggJWk0Htik3J/w@public.gmane.org>, Saeed Mahameed <saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Eric Dumazet <edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Tom Herbert <tom-BjP2VixgY4xUbtYUoyoikg@public.gmane.org>
To: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <iovisor-dev-bounces-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org>
In-Reply-To: <1473259302.10725.31.camel-XN9IlZ5yJG9HTL0Zs8A6p+yfmBU6pStAUsxypvmhUTTZJqsBc5GL+g@public.gmane.org>
List-Unsubscribe: <https://lists.iovisor.org/mailman/options/iovisor-dev>,
	<mailto:iovisor-dev-request-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.iovisor.org/pipermail/iovisor-dev/>
List-Post: <mailto:iovisor-dev-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org>
List-Help: <mailto:iovisor-dev-request-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org?subject=help>
List-Subscribe: <https://lists.iovisor.org/mailman/listinfo/iovisor-dev>,
	<mailto:iovisor-dev-request-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org?subject=subscribe>
Sender: iovisor-dev-bounces-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org
Errors-To: iovisor-dev-bounces-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, Sep 7, 2016 at 5:41 PM, Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
> On Wed, 2016-09-07 at 15:42 +0300, Saeed Mahameed wrote:
>> Previously we rang XDP SQ doorbell on every forwarded XDP packet.
>>
>> Here we introduce a xmit more like mechanism that will queue up more
>> than one packet into SQ (up to RX napi budget) w/o notifying the hardware.
>>
>> Once RX napi budget is consumed and we exit napi RX loop, we will
>> flush (doorbell) all XDP looped packets in case there are such.
>
> Why is this idea depends on XDP ?
>
> It looks like we could apply it to any driver having one IRQ servicing
> one RX and one TX, without XDP being involved.
>

Yes but it is more complicated than XDP case, where the RX ring posts
the TX descriptors and once done
the RX ring hits the doorbell once for all the TX descriptors it
posted, and it is the only possible place to hit a doorbell
for XDP TX ring.

For regular TX and RX ring sharing the same IRQ, there is no such
simple connection between them, and hitting a doorbell
from RX ring napi would race with xmit ndo function of the TX ring.

How do you synchronize in such case ?
isn't the existing xmit more mechanism sufficient enough ? maybe we
can have a fence from napi RX function
that will hold the xmit queue until done and then flush the TX queue
with the setting the right xmit more flags, without the need
of explicitly intervening with TX flow (hitting the doorbell).
