From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: UDP is bypassing qdisc statistics ....
Date: Tue, 01 Sep 2009 17:34:28 +0200
Message-ID: <4A9D3F04.40409@gmail.com>
References: <20090901063726.GA5222@ff.dom.local> <alpine.DEB.1.10.0909011358030.15578@V090114053VZO-1> <4A9D2DBF.8030200@trash.net> <alpine.DEB.1.10.0909011526480.12112@V090114053VZO-1>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Patrick McHardy <kaber@trash.net>,
	Mark Smith <lk-netdev@lk-netdev.nosense.org>,
	Jarek Poplawski <jarkao2@gmail.com>, netdev@vger.kernel.org,
	davem@linux-foundation.org
To: Christoph Lameter <cl@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:56182 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754460AbZIAPej (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Sep 2009 11:34:39 -0400
In-Reply-To: <alpine.DEB.1.10.0909011526480.12112@V090114053VZO-1>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Christoph Lameter a =E9crit :
> On Tue, 1 Sep 2009, Patrick McHardy wrote:
>=20
>> That explains it. The bnx2 driver uses multiple TX queues, but
>> tc_dump_qdisc() only dumps the statistics from queue number 0.
>=20
> There are no stats in other queues either... This is the result after
> sending 10000 or so packets. Maybe I am not catching all the qdiscs?
>=20
> (this is the result of a pretty raw patch to dump all qdiscs)
>=20
> #cat /proc/net/qdisc_stats
> Type Device State Bytes Packets Qlen Backlog Drops Requeues Overlimit=
s
> TX root <NULL> 0 0 0 0 0 0 0 0
> RX root <NULL> 0 0 0 0 0 0 0 0
> TX root  eth0 0 24830 155 0 0 0 0 0
> RX root <NULL> 0 0 0 0 0 0 0 0
> TX root <NULL> 0 0 0 0 0 0 0 0
> RX root <NULL> 0 0 0 0 0 0 0 0
> TX root <NULL> 0 0 0 0 0 0 0 0
> RX root <NULL> 0 0 0 0 0 0 0 0
> TX root <NULL> 0 0 0 0 0 0 0 0
> RX root <NULL> 0 0 0 0 0 0 0 0
>=20
> ---
>  net/sched/sch_api.c |   64 +++++++++++++++++++++++++++++++++++++++++=
+++++++++++
>  1 file changed, 64 insertions(+)
>=20
> Index: linux-2.6/net/sched/sch_api.c
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> --- linux-2.6.orig/net/sched/sch_api.c	2009-08-31 21:19:04.000000000 =
+0000
> +++ linux-2.6/net/sched/sch_api.c	2009-09-01 14:30:40.000000000 +0000
> @@ -1699,6 +1699,69 @@ static const struct file_operations psch
>  	.llseek =3D seq_lseek,
>  	.release =3D single_release,
>  };
> +
> +static void dump_qdisc(struct seq_file *seq, struct Qdisc *q, char *=
inout, char *text)
> +{
> +	seq_printf(seq, "%2s %2s %5s %lx %lld %d %d %d %d %d %d\n",
> +		inout, text, q->dev_queue->dev->name, q->state,
> +		q->bstats.bytes, q->bstats.packets,
> +		q->qstats.qlen, q->qstats.backlog, q->qstats.drops,
> +		q->qstats.requeues, q->qstats.overlimits);
> +}
> +
> +static void dump_qdisc_root(struct seq_file *seq, struct Qdisc *root=
, char *inout)
> +{
> +	struct Qdisc *q;
> +	int n =3D 0;
> +
> +	if (!root)
> +		return;
> +
> +	dump_qdisc(seq, root, inout, "root");
> +
> +	list_for_each_entry(q, &root->list, list) {
> +		char buffer[10];
> +
> +		sprintf(buffer,"%d", ++n);
> +		dump_qdisc(seq, q, inout, buffer);
> +	}
> +}
> +
> +
> +static int qdisc_show(struct seq_file *seq, void *v)
> +{
> +	struct net_device *dev;
> +
> +	seq_printf(seq, "Type Device State Bytes Packets "
> +			"Qlen Backlog Drops Requeues Overlimits\n");
> +
> +	read_lock(&dev_base_lock);
> +
> +	for_each_netdev(&init_net, dev) {
> +		struct netdev_queue *dev_queue;
> +
> +		dev_queue =3D netdev_get_tx_queue(dev, 0);
> +		dump_qdisc_root(seq, dev_queue->qdisc_sleeping, "TX");

you should iterate here=20

	for (i =3D 0 ; i < dev->real_num_tx_queues; i++) {
		dev_queue =3D netdev_get_tx_queue(dev, i);
		dump_qdisc_root(seq, dev_queue->qdisc_sleeping, "TX");
	}


> +		dev_queue =3D &dev->rx_queue;
> +		dump_qdisc_root(seq, dev_queue->qdisc_sleeping, "RX");
> +	}
> +
> +	read_unlock(&dev_base_lock);
> +	return 0;
> +}
> +
> +static int qdisc_open(struct inode *inode, struct file *file)
> +{
> +	return single_open(file, qdisc_show, PDE(inode)->data);
> +}
> +
> +static const struct file_operations qdisc_fops =3D {
> +	.owner =3D THIS_MODULE,
> +	.open =3D qdisc_open,
> +	.read =3D seq_read,
> +	.llseek =3D seq_lseek,
> +	.release =3D single_release,
> +};
>  #endif
>=20
>  static int __init pktsched_init(void)
> @@ -1706,6 +1769,7 @@ static int __init pktsched_init(void)
>  	register_qdisc(&pfifo_qdisc_ops);
>  	register_qdisc(&bfifo_qdisc_ops);
>  	proc_net_fops_create(&init_net, "psched", 0, &psched_fops);
> +	proc_net_fops_create(&init_net, "qdisc_stats", 0, &qdisc_fops);
>=20
>  	rtnl_register(PF_UNSPEC, RTM_NEWQDISC, tc_modify_qdisc, NULL);
>  	rtnl_register(PF_UNSPEC, RTM_DELQDISC, tc_get_qdisc, NULL);

