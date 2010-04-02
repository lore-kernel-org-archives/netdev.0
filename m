From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] rfs: Receive Flow Steering
Date: Fri, 02 Apr 2010 09:58:42 +0200
Message-ID: <1270195122.1936.106.camel@edumazet-laptop>
References: <alpine.DEB.1.00.1004012045560.4252@pokey.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f209.google.com ([209.85.218.209]:48508 "EHLO
	mail-bw0-f209.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754426Ab0DBH6r (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Apr 2010 03:58:47 -0400
Received: by bwz1 with SMTP id 1so1351114bwz.21
        for <netdev@vger.kernel.org>; Fri, 02 Apr 2010 00:58:46 -0700 (PDT)
In-Reply-To: <alpine.DEB.1.00.1004012045560.4252@pokey.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 01 avril 2010 =C3=A0 20:59 -0700, Tom Herbert a =C3=A9crit :

> +static void rps_dev_flow_table_release_work(struct work_struct *work=
)
> +{
> +	struct rps_dev_flow_table *table =3D container_of(work,
> +	    struct rps_dev_flow_table, free_work);
> +
> +	vfree(table);
> +}
> +
> +static void rps_dev_flow_table_release(struct rcu_head *rcu)
> +{
> +	struct rps_dev_flow_table *table =3D container_of(rcu,
> +	    struct rps_dev_flow_table, rcu);
> +
> +	INIT_WORK(&table->free_work, rps_dev_flow_table_release_work);
> +	schedule_work(&table->free_work);
> +}
> +
> +ssize_t store_rps_dev_flow_table_cnt(struct netdev_rx_queue *queue,
> +				     struct rx_queue_attribute *attr,
> +				     const char *buf, size_t len)
> +{

=2E...

> +	if (old_table)
> +		call_rcu(&old_table->rcu, rps_dev_flow_table_release);
> +
> +	return len;
> +}
> +

Instead of this complex logic (yet fine), you might try :

if (old_table) {
	synchronize_rcu();
	vfree(old_table);
	}

(and remove free_work from struct rps_dev_flow_table)

We dont write this file that often, we can afford the synchronize_rcu()
here...



