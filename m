From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [NET] Add proc file to display the state of all qdiscs.
Date: Wed, 2 Sep 2009 08:14:29 +0000
Message-ID: <20090902081429.GB4878@ff.dom.local>
References: <alpine.DEB.1.10.0909011943430.12066@V090114053VZO-1>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: eric.dumazet@gmail.com, David Miller <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org
To: Christoph Lameter <cl@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f219.google.com ([209.85.218.219]:43801 "EHLO
	mail-bw0-f219.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752033AbZIBIOf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Sep 2009 04:14:35 -0400
Received: by bwz19 with SMTP id 19so540104bwz.37
        for <netdev@vger.kernel.org>; Wed, 02 Sep 2009 01:14:36 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <alpine.DEB.1.10.0909011943430.12066@V090114053VZO-1>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[Resent with fixed netdev@ address]

On 02-09-2009 01:52, Christoph Lameter wrote:
> [NET] Add proc file to display the state of all qdiscs
> 
> TC is a complicated tool and it currently does not allow the display of all
> qdisc states. It does not support multiple tx queues and also not
> localhost, nor does it display the current operating state of the queues.

I think, tc should've no problem with displaying summary stats of
multiqueue qdiscs or even all of them separately, as mentioned by
Patrick. And, maybe I still miss something, but there should be
nothing special with tc vs. localhost either.

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

As I wrote earlier, it's a nice work, but since it makes a new API I
guess we shouldn't hurry with merging this patch, and publish it as an
RFC first.

Then my humble suggestions would be to reserve more space for most of
the columns to make it readable not only for scripts when more TX#,
bytes, packets etc. Users of non-default qdiscs would also miss things
like: q->ops->id, q->handle, and q->parent at least. Plus, as I
mentioned earlier, q->qstats.qlen update with q->q.qlen (or using it
directly) is needed.

Jarek P.

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
> @@ -1699,6 +1699,135 @@ static const struct file_operations psch
>  	.llseek = seq_lseek,
>  	.release = single_release,
>  };
> +
> +static void dump_qdisc(struct seq_file *seq, struct net_device *dev,
> +				struct Qdisc *q, char *inout, char *text)
> +{
> +	char state[5];
> +	char *p = state;
> +
> +	if (test_bit(__QDISC_STATE_RUNNING, &q->state))
> +		*p++ = 'R';
> +	if (test_bit(__QDISC_STATE_SCHED, &q->state))
> +		*p++ = 'S';
> +	if (test_bit(__QDISC_STATE_DEACTIVATED, &q->state))
> +		*p++ = 'D';
> +	if (q->state == 0)
> +		*p++ = '-';
> +	*p = 0;
> +
> +	seq_printf(seq, "%3s/%2s %6s %3s %10lld %8d %4d %4d %7d %7d %7d\n",
> +		inout, text, dev->name, state,
> +		q->bstats.bytes, q->bstats.packets,
> +		q->qstats.qlen, q->qstats.backlog, q->qstats.drops,
> +		q->qstats.requeues, q->qstats.overlimits);
> +}
> +
> +static void dump_qdisc_root(struct seq_file *seq, struct net_device *dev,
> +					 struct Qdisc *root, char *inout)
> +{
> +	struct Qdisc *q;
> +	int n = 0;
> +
> +	if (!root)
> +		return;
> +
> +	dump_qdisc(seq, dev, root, inout, "root");
> +
> +	list_for_each_entry(q, &root->list, list) {
> +		char buffer[10];
> +
> +		sprintf(buffer,"Q%d", ++n);
> +		dump_qdisc(seq, dev, q, inout, buffer);
> +	}
> +}
> +
> +
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
> +	dev_queue = &dev->rx_queue;
> +	dump_qdisc_root(seq, dev, dev_queue->qdisc_sleeping, "RX");
> +}
> +
> +static int qdisc_seq_show(struct seq_file *seq, void *v)
> +{
> +	if (v == SEQ_START_TOKEN) {
> +		seq_printf(seq, "Queue    Device  State   Bytes  Packets "
> +			"Qlen Blog   Drops Requeue Overlimit\n");
> +	} else
> +		qdisc_seq_out(seq, v);
> +
> +	return 0;
> +}
> +
> +static void *qdisc_seq_start(struct seq_file *seq, loff_t *pos)
> +	__acquires(dev_base_lock)
> +{
> +	struct net *net = seq_file_net(seq);
> +	loff_t off;
> +	struct net_device *dev;
> +
> +	read_lock(&dev_base_lock);
> +
> +	if (!*pos)
> +		return SEQ_START_TOKEN;
> +
> +	off = 1;
> +
> +	for_each_netdev(net, dev)
> +		if (off++ == *pos)
> +			return dev;
> +
> +	return NULL;
> +}
> +
> +static void *qdisc_seq_next(struct seq_file *seq, void *v, loff_t *pos)
> +{
> +	struct net *net = seq_file_net(seq);
> +
> +	++*pos;
> +	return v == SEQ_START_TOKEN ?
> +		first_net_device(net) : next_net_device((struct net_device *)v);
> +}
> +
> +static void qdisc_seq_stop(struct seq_file *seq, void *v)
> +	__releases(dev_base_lock)
> +{
> +	read_unlock(&dev_base_lock);
> +}
> +
> +
> +static const struct seq_operations qdisc_seq_ops = {
> +	.start	= qdisc_seq_start,
> +	.next	= qdisc_seq_next,
> +	.stop	= qdisc_seq_stop,
> +	.show	= qdisc_seq_show,
> +};
> +
> +static int qdisc_open(struct inode *inode, struct file *file)
> +{
> +	return seq_open_net(inode, file, &qdisc_seq_ops,
> +			sizeof(struct seq_net_private));
> +}
> +
> +
> +static const struct file_operations qdisc_fops = {
> +	.owner = THIS_MODULE,
> +	.open = qdisc_open,
> +	.read = seq_read,
> +	.llseek = seq_lseek,
> +	.release = seq_release,
> +};
>  #endif
> 
>  static int __init pktsched_init(void)
> @@ -1706,6 +1835,7 @@ static int __init pktsched_init(void)
>  	register_qdisc(&pfifo_qdisc_ops);
>  	register_qdisc(&bfifo_qdisc_ops);
>  	proc_net_fops_create(&init_net, "psched", 0, &psched_fops);
> +	proc_net_fops_create(&init_net, "qdisc_stats", 0, &qdisc_fops);
> 
>  	rtnl_register(PF_UNSPEC, RTM_NEWQDISC, tc_modify_qdisc, NULL);
>  	rtnl_register(PF_UNSPEC, RTM_DELQDISC, tc_get_qdisc, NULL);
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
