From: Patrick McHardy <kaber@trash.net>
Subject: Re: 2.6: QoS scheduling not working with IP-over-IP
Date: Wed, 18 Feb 2004 12:21:22 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <40334AB2.30701@trash.net>
References: <Pine.LNX.4.44.0402101324350.810-100000@atlantis.knm.org.pl>	<20040211200549.736fa8b3.davem@redhat.com>	<1076561489.1032.65.camel@jzny.localdomain>	<1076561998.1035.72.camel@jzny.localdomain>	<1076562282.1033.76.camel@jzny.localdomain>	<20040211211536.23e97997.davem@redhat.com>	<1076563502.1031.85.camel@jzny.localdomain>	<1076564638.1033.91.camel@jzny.localdomain>	<20040211215142.7f817513.davem@redhat.com>	<1076566176.1033.94.camel@jzny.localdomain>	<20040211222259.776ad818.davem@redhat.com>	<402D54D6.5070708@trash.net>	<20040213213606.5a13cc76.davem@redhat.com>	<1076762757.1060.4.camel@jzny.localdomain>	<1076763997.1059.13.camel@jzny.localdomain>	<1076766981.1059.16.camel@jzny.localdomain>	<20040214124958.499294a6.davem@redhat.com>	<402F4A2D.1070405@trash.net> <20040217191011.012a749e.davem@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------040906040203050704050807"
Cc: hadi@cyberus.ca, qnex@atlantis.knm.org.pl, netdev@oss.sgi.com,
        shemminger@osdl.org
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20040217191011.012a749e.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------040906040203050704050807
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

David S. Miller wrote:
> On Sun, 15 Feb 2004 11:30:05 +0100
> Patrick McHardy <kaber@trash.net> wrote:
> 
> 
>>I guess he meant something like this, but I still think it encourages
>>broken configurations in combination with non-work-conserving
>>schedulers.
> 
> 
> Patrick, "(x || 1)" is not the same as "(x ? x : 1)"
> :-)

Doh! I must have been programming in perl before .. ;)

> 
> Please make a new patch.
> 

Attached.

Regards
Patrick

--------------040906040203050704050807
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

===== net/sched/sch_fifo.c 1.7 vs edited =====
--- 1.7/net/sched/sch_fifo.c	Wed Nov 19 02:37:34 2003
+++ edited/net/sched/sch_fifo.c	Wed Feb 18 12:06:06 2004
@@ -141,10 +141,12 @@
 	struct fifo_sched_data *q = (void*)sch->data;
 
 	if (opt == NULL) {
+		unsigned int limit = sch->dev->tx_queue_len ? : 1;
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
===== net/sched/sch_gred.c 1.13 vs edited =====
--- 1.13/net/sched/sch_gred.c	Wed Nov 19 02:37:34 2003
+++ edited/net/sched/sch_gred.c	Wed Feb 18 12:06:56 2004
@@ -110,7 +110,7 @@
 	unsigned long	qave=0;	
 	int i=0;
 
-	if (!t->initd && skb_queue_len(&sch->q) < sch->dev->tx_queue_len) {
+	if (!t->initd && skb_queue_len(&sch->q) < (sch->dev->tx_queue_len ? : 1)) {
 		D2PRINTK("NO GRED Queues setup yet! Enqueued anyway\n");
 		goto do_enqueue;
 	}

--------------040906040203050704050807--
