From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 2/2 v5] xps: Transmit Packet Steering
Date: Sun, 07 Nov 2010 21:40:55 +0100
Message-ID: <1289162455.2478.295.camel@edumazet-laptop>
References: <alpine.DEB.1.00.1011071146390.29978@pokey.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:56071 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751767Ab0KGUlA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 7 Nov 2010 15:41:00 -0500
Received: by wwb39 with SMTP id 39so3149529wwb.1
        for <netdev@vger.kernel.org>; Sun, 07 Nov 2010 12:40:59 -0800 (PST)
In-Reply-To: <alpine.DEB.1.00.1011071146390.29978@pokey.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le dimanche 07 novembre 2010 =C3=A0 11:52 -0800, Tom Herbert a =C3=A9cr=
it :
> This patch implements transmit packet steering (XPS) for multiqueue
> devices.  XPS selects a transmit queue during packet transmission bas=
ed
> on configuration.  This is done by mapping the CPU transmitting the
> packet to a queue.  This is the transmit side analogue to RPS-- where
> RPS is selecting a CPU based on receive queue, XPS selects a queue
> based on the CPU (previously there was an XPS patch from Eric
> Dumazet, but that might more appropriately be called transmit complet=
ion
> steering).
>=20
> Each transmit queue can be associated with a number of CPUs which wil=
l
> use the queue to send packets.  This is configured as a CPU mask on a
> per queue basis in:
>=20
> /sys/class/net/eth<n>/queues/tx-<n>/xps_cpus
>=20
> The mappings are stored per device in an inverted data structure that
> maps CPUs to queues.  In the netdevice structure this is an array of
> num_possible_cpu structures where each structure holds and array of
> queue_indexes for queues which that CPU can use.
>=20
> The benefits of XPS are improved locality in the per queue data
> structures.  Also, transmit completions are more likely to be done
> nearer to the sending thread, so this should promote locality back
> to the socket on free (e.g. UDP).  The benefits of XPS are dependent =
on
> cache hierarchy, application load, and other factors.  XPS would
> nominally be configured so that a queue would only be shared by CPUs
> which are sharing a cache, the degenerative configuration woud be tha=
t
> each CPU has it's own queue.
>=20
> Below are some benchmark results which show the potential benfit of
> this patch.  The netperf test has 500 instances of netperf TCP_RR tes=
t
> with 1 byte req. and resp.
>=20
> bnx2x on 16 core AMD
>    XPS (16 queues, 1 TX queue per CPU)  1234K at 100% CPU
>    No XPS (16 queues)                   996K at 100% CPU
>=20
> Signed-off-by: Tom Herbert <therbert@google.com>
> ---
>  include/linux/netdevice.h |   32 ++++
>  net/core/dev.c            |   54 +++++++-
>  net/core/net-sysfs.c      |  367 +++++++++++++++++++++++++++++++++++=
+++++++++-
>  net/core/net-sysfs.h      |    3 +
>  4 files changed, 450 insertions(+), 6 deletions(-)
>=20
> diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
> index 072652d..b2ea7c0 100644
> --- a/include/linux/netdevice.h
> +++ b/include/linux/netdevice.h
> @@ -503,6 +503,13 @@ struct netdev_queue {
>  	struct Qdisc		*qdisc;
>  	unsigned long		state;
>  	struct Qdisc		*qdisc_sleeping;
> +#ifdef CONFIG_RPS
> +	struct netdev_queue	*first;
> +	atomic_t		count;
> +	struct xps_dev_maps	*xps_maps;

Tom, I still dont understand why *xps_maps is here, and not in
net_device ?

I am asking because netdev_get_xps_maps(dev) might be slowed down
because queue 0 state might change often (__QUEUE_STATE_XOFF)

This means _tx[0] becomes a very hot cache line, needed to access all
queues (from get_xps_queue())

Other than that, your patch seems fine (not tested yet)

Thanks


