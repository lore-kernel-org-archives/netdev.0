From: =?ISO-8859-1?Q?Mika_Penttil=E4?= <mika.penttila@kolumbus.fi>
Subject: Re: [NET_SCHED 03/06]: Fix endless loops caused by inaccurate qlen
 counters (part 1)
Date: Mon, 20 Nov 2006 16:23:55 +0200
Message-ID: <4561BA7B.4060005@kolumbus.fi>
References: <20061120130834.22347.34853.sendpatchset@localhost.localdomain> <20061120130840.22347.54563.sendpatchset@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, devik@cdi.cz, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw1.turkuamk.fi ([195.148.208.125]:17102 "EHLO
	mail-gw1.turkuamk.fi") by vger.kernel.org with ESMTP
	id S934188AbWKTOZ5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 20 Nov 2006 09:25:57 -0500
To: Patrick McHardy <kaber@trash.net>
In-Reply-To: <20061120130840.22347.54563.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


> @@ -348,6 +354,26 @@ dev_graft_qdisc(struct net_device *dev, 
>  	return oqdisc;
>  }
>  
> +void qdisc_tree_decrease_qlen(struct Qdisc *sch, unsigned int n)
> +{
> +	struct Qdisc_class_ops *cops;
> +	unsigned long cl;
> +	u32 parentid;
> +
> +	if (n == 0)
> +		return;
> +	while ((parentid = sch->parent)) {
> +		sch = __qdisc_lookup(sch->dev, TC_H_MAJ(parentid));
> +		cops = sch->ops->cl_ops;
> +		if (cops->qlen_notify) {
> +			cl = cops->get(sch, parentid);
> +			cops->qlen_notify(sch, cl);
> +			cops->put(sch, cl);
> +		}
> +		sch->q.qlen -= n;
> +	}
> +}
> +EXPORT_SYMBOL(qdisc_tree_decrease_qlen);
>  
>   
Are you sure you didn't mean to :

+	while ((parentid = sch->parent)) {
+		sch = __qdisc_lookup(sch->dev, TC_H_MAJ(parentid));
+		cops = sch->ops->cl_ops;
+		if (!(sch->q.qlen -= n) && cops->qlen_notify) {    <----
+			cl = cops->get(sch, parentid);
+			cops->qlen_notify(sch, cl);
+			cops->put(sch, cl);
+		}
+	}


--Mika

