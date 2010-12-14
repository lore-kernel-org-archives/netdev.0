From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 4/5 v2] ifb: add multiqueue support
Date: Tue, 14 Dec 2010 16:59:18 +0100
Message-ID: <1292342358.5934.10.camel@edumazet-laptop>
References: <1292340098-25537-1-git-send-email-xiaosuo@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jamal Hadi Salim <hadi@cyberus.ca>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f45.google.com ([209.85.215.45]:36835 "EHLO
	mail-ew0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757429Ab0LNP7Y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Dec 2010 10:59:24 -0500
Received: by ewy10 with SMTP id 10so456618ewy.4
        for <netdev@vger.kernel.org>; Tue, 14 Dec 2010 07:59:22 -0800 (PST)
In-Reply-To: <1292340098-25537-1-git-send-email-xiaosuo@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 14 d=C3=A9cembre 2010 =C3=A0 23:21 +0800, Changli Gao a =C3=A9=
crit :


> +static struct rtnl_link_stats64 *ifb_get_stats64(struct net_device *=
dev,
> +		struct rtnl_link_stats64 *stats)
> +{
> +	struct ifb_q_private *q;
> +	struct netdev_queue *txq;
> +	int cpu;
> +	u64 rx_packets, rx_bytes, rx_dropped;
> +	u64 tx_packets, tx_bytes, tx_dropped;
> +	unsigned int start;
> +
> +	for_each_possible_cpu(cpu) {
> +		q =3D per_cpu_ptr(ifb_priv(dev), cpu);
> +		txq =3D q->txq;
> +		do {
> +			start =3D u64_stats_fetch_begin_bh(&q->syncp);
> +			rx_packets =3D q->rx_packets;
> +			rx_bytes =3D q->rx_bytes;
> +			rx_dropped =3D q->rx_dropped;
> +			tx_packets =3D txq->tx_packets;
> +			tx_bytes =3D txq->tx_bytes;
> +			tx_dropped =3D txq->tx_dropped;
> +		} while (u64_stats_fetch_retry_bh(&q->syncp, start));
> +		stats->rx_packets +=3D rx_packets;
> +		stats->rx_bytes +=3D rx_bytes;
> +		stats->rx_dropped +=3D rx_dropped;
> +		stats->tx_packets +=3D tx_packets;
> +		stats->tx_bytes +=3D tx_bytes;
> +		stats->tx_dropped +=3D tx_dropped;
> +	}
> +
> +	return stats;
> +}
> +


There is a problem here.

You should sum in the loop rx_counters only, (the counters syncp
protected), and use dev_txq_stats_fold() to get the tx_counters from
core network.

dev_txq_stats_fold(dev, stats);
for_each_possible_cpu(cpu) {
	q =3D per_cpu_ptr(ifb_priv(dev), cpu);
	txq =3D q->txq;
	do {
		start =3D u64_stats_fetch_begin_bh(&q->syncp);
		rx_packets =3D q->rx_packets;
		rx_bytes   =3D q->rx_bytes;
		rx_dropped =3D q->rx_dropped;
	} while (u64_stats_fetch_retry_bh(&q->syncp, start));
	stats->rx_packets +=3D rx_packets;
	stats->rx_bytes   +=3D rx_bytes;
	stats->rx_dropped +=3D rx_dropped;
}
return stats;


