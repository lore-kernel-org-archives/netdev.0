From: jamal <hadi@cyberus.ca>
Subject: Re: Kernel BUG: Qos seg. fault
Date: 24 May 2004 15:47:13 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1085428033.1040.24.camel@jzny.localdomain>
References: <20040524192956.89024.qmail@web80510.mail.yahoo.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Jaume Catarineu <jaume.catarineu@upf.edu>,
        "David S. Miller" <davem@redhat.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Dmitry Torokhov <dtor_core@ameritech.net>
In-Reply-To: <20040524192956.89024.qmail@web80510.mail.yahoo.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 2004-05-24 at 15:29, Dmitry Torokhov wrote:
> Hi,

> 
> Yes, it is new tbf... It does not have tcf_chain implementation so
> when someone tries to add a filter to TBF it barfs. I need little
> help here - does TBF need fill-blown filter support? 

Well to claim it can be classful which is what that effort, yes you
would be useful to have. Take a look at the prio qdisc which is also
able to run when there are no filters attached.

> TBF can only
> have one qdisc connected to it, and if that qdisc is classful then
> filters should be attached to that qdisc. Is there any need to attach
> filter to TBF itself?

Refer to what i said above.

> If TBF does not need its own filter support then the patch below
> should take care of tc segfaulting (uncompiled, untested).
> 
> Dmitry
> 
> ______________________________________________________________________
> 
> diff -urN 2.6.6/net/sched/sch_tbf.c linux-2.6.6/net/sched/sch_tbf.c
> --- 2.6.6/net/sched/sch_tbf.c	2004-05-11 11:24:33.777996800 -0500
> +++ linux-2.6.6/net/sched/sch_tbf.c	2004-05-24 14:18:41.099267200 -0500
> @@ -472,7 +472,7 @@
>  {
>  }
>  
> -static int tbf_change_class(struct Qdisc *sch, u32 classid, u32 parentid, 
> +static int tbf_change_class(struct Qdisc *sch, u32 classid, u32 parentid,
>  			    struct rtattr **tca, unsigned long *arg)
>  {
>  	return -ENOSYS;
> @@ -495,6 +495,11 @@
>  	}
>  }
>  
> +static struct tcf_proto **tbf_find_tcf(struct Qdisc *sch, unsigned long cl)
> +{
> +	return NULL;
> +}
> +
>  static struct Qdisc_class_ops tbf_class_ops =
>  {
>  	.graft		=	tbf_graft,
> @@ -504,6 +509,7 @@
>  	.change		=	tbf_change_class,
>  	.delete		=	tbf_delete,
>  	.walk		=	tbf_walk,
> +	.tcf_chain	=	tbf_find_tcf,
>  	.dump		=	tbf_dump_class,
>  };

looks more like a bandaid.

Try this (untested, uncompiled).
--- /usr/src/261/net/sched/sch_tbf.c	2004-01-09 01:59:06.000000000 -0500
+++ /usr/src/261/net/sched/mod-tbf.c	2004-05-24 15:44:46.000000000 -0400
@@ -130,6 +130,7 @@
 	psched_time_t	t_c;		/* Time check-point */
 	struct timer_list wd_timer;	/* Watchdog timer */
 	struct Qdisc	*qdisc;		/* Inner qdisc, default - bfifo queue */
+	struct tcf_proto        *filter_list;
 };
 
 #define L2T(q,L)   ((q)->R_tab->data[(L)>>(q)->R_tab->rate.cell_log])
@@ -458,6 +459,12 @@
 	return 0;
 }
 
+static struct Qdisc *tbf_find_tcf(struct Qdisc *sch, unsigned long arg)
+{
+	struct tbf_sched_data *q = (struct tbf_sched_data *)sch->data;
+	return q->filter_list;
+}
+
 static struct Qdisc *tbf_leaf(struct Qdisc *sch, unsigned long arg)
 {
 	struct tbf_sched_data *q = (struct tbf_sched_data *)sch->data;
@@ -507,6 +514,7 @@
 	.change		=	tbf_change_class,
 	.delete		=	tbf_delete,
 	.walk		=	tbf_walk,
+	.tcf_chain	=	tbf_find_tcf,
 	.dump		=	tbf_dump_class,
 };
 


cheers,
jamal
