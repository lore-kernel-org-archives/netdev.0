From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [NET] Add proc file to display the state of all qdiscs.
Date: Wed, 2 Sep 2009 23:27:08 +0200
Message-ID: <20090902212708.GC3018@ami.dom.local>
References: <alpine.DEB.1.10.0909011943430.12066@V090114053VZO-1>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>
To: Christoph Lameter <cl@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f217.google.com ([209.85.220.217]:40263 "EHLO
	mail-fx0-f217.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751964AbZIBV1j (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Sep 2009 17:27:39 -0400
Received: by fxm17 with SMTP id 17so1118622fxm.37
        for <netdev@vger.kernel.org>; Wed, 02 Sep 2009 14:27:39 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <alpine.DEB.1.10.0909011943430.12066@V090114053VZO-1>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Christoph Lameter wrote, On 09/02/2009 01:52 AM:

> [NET] Add proc file to display the state of all qdiscs
> 
> TC is a complicated tool and it currently does not allow the display of all
> qdisc states. It does not support multiple tx queues and also not
> localhost, nor does it display the current operating state of the queues.
> 
> This functionality could be added to tc / netlink but the tool is already
> complex to handle. The simple proc file here allows easy scanning by
> scripts and other tools. However, tc still needs to be updated to allow
> the modifications of multiqueue TX settings. tc's main focus is the
> configuration of qdiscs. The qdisc_stats file just shows the current
> state.
> 
> This patch adds
> 
> 	/proc/net/qdisc_stats
> 
> which displays the current state of all qdiscs on the system.
> 
> F.e.
> 
> $ cat /proc/net/qdisc_stats
> Queue    Device  State   Bytes  Packets Qlen Blog   Drops Requeue Overlimit
> TX0/root     lo   -          0        0    0    0       0       0       0
>  RX/root     lo   -          0        0    0    0       0       0       0
> TX0/root   eth0   -       5518       60    0    0       0       0       0
> TX1/root   eth0   -       2549       37    0    0       0       0       0
> TX2/root   eth0   -      63625      272    0    0       0       0       0
> TX3/root   eth0   -       1580       21    0    0       0       0       0
> TX4/root   eth0   R   88979440   260183    0 3532   43176    2111       0
> TX5/root   eth0   -       4698       56    0    0       0       0       0
> TX6/root   eth0   - 3598883129 10523140    0    0       0       0       0
> TX7/root   eth0   -       1750       21    0    0       0       0       0
> 
> 
> Signed-off-by: Christoph Lameter <cl@linux-foundation.org>
> 
> ---
>  net/sched/sch_api.c |  130 ++++++++++++++++++++++++++++++++++++++++++++++++++++
>  1 file changed, 130 insertions(+)
> 
> Index: linux-2.6/net/sched/sch_api.c
> ===================================================================
> --- linux-2.6.orig/net/sched/sch_api.c	2009-09-01 12:27:24.000000000 -0500
> +++ linux-2.6/net/sched/sch_api.c	2009-09-01 14:39:27.000000000 -0500
...
> +static void qdisc_seq_out(struct seq_file *seq, struct net_device *dev)
> +{
> +	struct netdev_queue *dev_queue;
> +	int i;
> +
> +	for (i = 0; i < dev->real_num_tx_queues; i++) {
> +		char buffer[10];
> +
> +		dev_queue = netdev_get_tx_queue(dev, i);
> +		sprintf(buffer, "TX%d", i);
> +		dump_qdisc_root(seq, dev, dev_queue->qdisc_sleeping, buffer);
> +	}
...

Btw, Patrick's comments reminded me this is probably not what you want
in case of non-default qdiscs: the root qdisc like prio will be
repeated for each tx queue with the same stats. I guess you need to do
here an additional query e.g. by comparing dev_queue->qdisc_sleeping
with that of i = 0.

Jarek P.
