From: Patrick McHardy <kaber@trash.net>
Subject: Re: 2.6: QoS scheduling not working with IP-over-IP
Date: Sun, 15 Feb 2004 11:30:05 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <402F4A2D.1070405@trash.net>
References: <Pine.LNX.4.44.0402101324350.810-100000@atlantis.knm.org.pl>	<20040211200549.736fa8b3.davem@redhat.com>	<1076561489.1032.65.camel@jzny.localdomain>	<1076561998.1035.72.camel@jzny.localdomain>	<1076562282.1033.76.camel@jzny.localdomain>	<20040211211536.23e97997.davem@redhat.com>	<1076563502.1031.85.camel@jzny.localdomain>	<1076564638.1033.91.camel@jzny.localdomain>	<20040211215142.7f817513.davem@redhat.com>	<1076566176.1033.94.camel@jzny.localdomain>	<20040211222259.776ad818.davem@redhat.com>	<402D54D6.5070708@trash.net>	<20040213213606.5a13cc76.davem@redhat.com>	<1076762757.1060.4.camel@jzny.localdomain>	<1076763997.1059.13.camel@jzny.localdomain>	<1076766981.1059.16.camel@jzny.localdomain> <20040214124958.499294a6.davem@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------030704030600030003030207"
Cc: hadi@cyberus.ca, qnex@atlantis.knm.org.pl, netdev@oss.sgi.com,
        shemminger@osdl.org
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20040214124958.499294a6.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------030704030600030003030207
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

David S. Miller wrote:

> I don't know how wise this tx_queue_len fiddling is.
> 
> With this, if user modifies tx_queue_len himself, on ifdown this configuration
> change is lost if user sets it explicitly to '1'.  See?  In fact you could
> call it corruption :-)
> 
> I think Alexey maybe meant something different, achieving the ends by some other
> means than directly fiddling with tx_queue_len.
> 

I guess he meant something like this, but I still think it encourages
broken configurations in combination with non-work-conserving
schedulers.

Regards,
Patrick

--------------030704030600030003030207
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

===== sch_fifo.c 1.7 vs edited =====
--- 1.7/net/sched/sch_fifo.c	Wed Nov 19 02:37:34 2003
+++ edited/sch_fifo.c	Sun Feb 15 11:06:08 2004
@@ -141,10 +141,12 @@
 	struct fifo_sched_data *q = (void*)sch->data;
 
 	if (opt == NULL) {
+		unsigned int limit = sch->dev->tx_queue_len || 1;
+
 		if (sch->ops == &bfifo_qdisc_ops)
-			q->limit = sch->dev->tx_queue_len*sch->dev->mtu;
+			q->limit = limit*sch->dev->mtu;
 		else	
-			q->limit = sch->dev->tx_queue_len;
+			q->limit = limit;
 	} else {
 		struct tc_fifo_qopt *ctl = RTA_DATA(opt);
 		if (opt->rta_len < RTA_LENGTH(sizeof(*ctl)))
===== sch_gred.c 1.13 vs edited =====
--- 1.13/net/sched/sch_gred.c	Wed Nov 19 02:37:34 2003
+++ edited/sch_gred.c	Sun Feb 15 11:09:42 2004
@@ -110,7 +110,7 @@
 	unsigned long	qave=0;	
 	int i=0;
 
-	if (!t->initd && skb_queue_len(&sch->q) < sch->dev->tx_queue_len) {
+	if (!t->initd && skb_queue_len(&sch->q) < (sch->dev->tx_queue_len || 1)) {
 		D2PRINTK("NO GRED Queues setup yet! Enqueued anyway\n");
 		goto do_enqueue;
 	}

--------------030704030600030003030207--
