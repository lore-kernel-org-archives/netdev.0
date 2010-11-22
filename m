From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: [PATCH 2/2 v7] xps: Transmit Packet Steering
Date: Mon, 22 Nov 2010 19:42:31 +0800
Message-ID: <AANLkTin4q9oyeRB+ULgMt19sWZXxkVGt4iFDQOB1R8nf@mail.gmail.com>
References: <alpine.DEB.2.00.1011211501430.14906@pokey.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org, eric.dumazet@gmail.com
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:64755 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755014Ab0KVLmx convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Nov 2010 06:42:53 -0500
Received: by fxm13 with SMTP id 13so2515237fxm.19
        for <netdev@vger.kernel.org>; Mon, 22 Nov 2010 03:42:51 -0800 (PST)
In-Reply-To: <alpine.DEB.2.00.1011211501430.14906@pokey.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Nov 22, 2010 at 7:17 AM, Tom Herbert <therbert@google.com> wrot=
e:
> This patch implements transmit packet steering (XPS) for multiqueue
> devices. =A0XPS selects a transmit queue during packet transmission b=
ased
> on configuration. =A0This is done by mapping the CPU transmitting the
> packet to a queue. =A0This is the transmit side analogue to RPS-- whe=
re
> RPS is selecting a CPU based on receive queue, XPS selects a queue
> based on the CPU (previously there was an XPS patch from Eric
> Dumazet, but that might more appropriately be called transmit complet=
ion
> steering).
>
> Each transmit queue can be associated with a number of CPUs which wil=
l
> use the queue to send packets. =A0This is configured as a CPU mask on=
 a
> per queue basis in:
>
> /sys/class/net/eth<n>/queues/tx-<n>/xps_cpus
>
> The mappings are stored per device in an inverted data structure that
> maps CPUs to queues. =A0In the netdevice structure this is an array o=
f
> num_possible_cpu structures where each structure holds and array of
> queue_indexes for queues which that CPU can use.
>
> The benefits of XPS are improved locality in the per queue data
> structures. =A0Also, transmit completions are more likely to be done
> nearer to the sending thread, so this should promote locality back
> to the socket on free (e.g. UDP). =A0The benefits of XPS are dependen=
t on
> cache hierarchy, application load, and other factors. =A0XPS would
> nominally be configured so that a queue would only be shared by CPUs
> which are sharing a cache, the degenerative configuration woud be tha=
t
> each CPU has it's own queue.
>
> Below are some benchmark results which show the potential benfit of
> this patch. =A0The netperf test has 500 instances of netperf TCP_RR t=
est
> with 1 byte req. and resp.
>
> bnx2x on 16 core AMD
> =A0 XPS (16 queues, 1 TX queue per CPU) =A01234K at 100% CPU
> =A0 No XPS (16 queues) =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 996K at 10=
0% CPU
>
> Signed-off-by: Tom Herbert <therbert@google.com>
> ---
> =A0include/linux/netdevice.h | =A0 30 ++++
> =A0net/core/dev.c =A0 =A0 =A0 =A0 =A0 =A0| =A0 53 ++++++-
> =A0net/core/net-sysfs.c =A0 =A0 =A0| =A0369 +++++++++++++++++++++++++=
+++++++++++++++++++-
> =A0net/core/net-sysfs.h =A0 =A0 =A0| =A0 =A03 +
> =A04 files changed, 447 insertions(+), 8 deletions(-)
>
> diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
> index b45c1b8..badf928 100644
> --- a/include/linux/netdevice.h
> +++ b/include/linux/netdevice.h
> @@ -503,6 +503,10 @@ struct netdev_queue {
> =A0 =A0 =A0 =A0struct Qdisc =A0 =A0 =A0 =A0 =A0 =A0*qdisc;
> =A0 =A0 =A0 =A0unsigned long =A0 =A0 =A0 =A0 =A0 state;
> =A0 =A0 =A0 =A0struct Qdisc =A0 =A0 =A0 =A0 =A0 =A0*qdisc_sleeping;
> +#ifdef CONFIG_RPS
> + =A0 =A0 =A0 struct kobject =A0 =A0 =A0 =A0 =A0kobj;
> +#endif
> +

Why do you reuse CONFIG_RPS? I think it is confusing, as the code
enclosed is for XPS not RPS.

--=20
Regards,
Changli Gao(xiaosuo@gmail.com)
