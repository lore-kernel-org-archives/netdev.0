From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [PATCH 2.6.16.19 0/2] LARTC: trace control for netem
Date: Tue, 22 Aug 2006 14:37:39 -0700
Message-ID: <20060822143739.40b145bf@localhost.localdomain>
References: <44EB1581.9090304@tik.ee.ethz.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@VGER.KERNEL.ORG, netem@osdl.org
Return-path: <netdev-owner@vger.kernel.org>
To: Rainer Baumann <baumann@tik.ee.ethz.ch>
In-Reply-To: <44EB1581.9090304@tik.ee.ethz.ch>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 22 Aug 2006 16:32:33 +0200
Rainer Baumann <baumann@tik.ee.ethz.ch> wrote:

> This is the revised trace extension to the network emulator netem.
> This extension provides emulation control based on pregenerated traces.
> 
> We first submitted this patch on 2nd of August, in the mean time 
> we integrated the comments from Stephen and fixed the listed things.
> 
> Cheers,
> Rainer

Please put patches inline, commenting is easier.

The biggest problem with this is architectural. I don't like having kernel
tightly bound to a user level control process.  If the kernel needs to keep
track of the pid of the process, the API is wrong. What about multiple instances
with multiple devices?

A better way would be to just let the user process keep filling with something
like netlink, configfs/debugfs or even character device. Just block the process
(let it hang on write), until a buffer of trace data is used up. If the process
dies or doesn't give more data then either reuse last flow or stop flowing.

Please do the diff from the proper base (see Documentation/SubmittingPatches).
You have nested one too directories.

> diff -u'rNF^function' olinux/linux-2.6.16.19/include/linux/pkt_sched.h otlinux/linux-2.6.16.19/include/linux/pkt_sched.h
> --- olinux/linux-2.6.16.19/include/linux/pkt_sched.h	2006-05-31 02:31:44.000000000 +0200
> +++ otlinux/linux-2.6.16.19/include/linux/pkt_sched.h	2006-08-22 11:03:11.000000000 +0200
> @@ -430,11 +430,15 @@
>  	TCA_NETEM_DELAY_DIST,
>  	TCA_NETEM_REORDER,
>  	TCA_NETEM_CORRUPT,
> +	TCA_NETEM_TRACE,
> +	TCA_NETEM_DATA,
> +	TCA_NETEM_STATS,
>  	__TCA_NETEM_MAX,
>  };
>  
>  #define TCA_NETEM_MAX (__TCA_NETEM_MAX - 1)
> -
> +#define DATA_PACKAGE 4000
> +#define MAX_FLOWS 4
>  struct tc_netem_qopt
>  {
>  	__u32	latency;	/* added delay (us) */
> @@ -445,6 +449,40 @@
>  	__u32	jitter;		/* random jitter in latency (us) */
>  };
>  
> +struct tc_netem_stats
> +{
> +	int packetcount;
> +	int packetok;
> +	int normaldelay;
> +	int drops;
> +	int dupl;
> +	int corrupt;
> +	int noValidData;
> +	int uninitialized;
> +	int bufferunderrun;
> +	int bufferinuseempty;
> +	int noemptybuffer;
> +	int readbehindbuffer;
> +	int buffer1_reloads;
> +	int buffer2_reloads;
> +	int tobuffer1_switch;
> +	int tobuffer2_switch;
> +	int switch_to_emptybuffer1;
> +	int switch_to_emptybuffer2;				   		
> +};	
> +struct tc_netem_data
> +{
> +	char buf[DATA_PACKAGE];
> +	int fpid;
> +	int validData;

lower case structure tags please.
don't create a "blob" interface.
why not variable length? since netlink has Type Length Data


> +};
> +struct tc_netem_trace
> +{
> +	 __u32   fpid;           /* pid of flowseedprocess*/
> +	 __u32   def;          	 /* default action 0=no delay, 1=drop*/
> +	 __u32   ticks;	         /* number of ticks corresponding to 1us*/
> +};
> +
>  struct tc_netem_corr
>  {
>  	__u32	delay_corr;	/* delay correlation */
> diff -u'rNF^function' olinux/linux-2.6.16.19/include/net/flowseed.h otlinux/linux-2.6.16.19/include/net/flowseed.h
> --- olinux/linux-2.6.16.19/include/net/flowseed.h	1970-01-01 01:00:00.000000000 +0100
> +++ otlinux/linux-2.6.16.19/include/net/flowseed.h	2006-08-22 11:03:33.000000000 +0200
> @@ -0,0 +1,65 @@
> +/* flowseedprocfs.h     header file for the netem trace enhancement
> + */
> +
> +#ifndef _FLOWSEEDPROCFS_H
> +#define _FLOWSEEDPROCFS_H
> +#include <net/sch_generic.h>
> +
> +/* must be divisible by 4 (=#pkts)*/
> +#define DATA_PACKAGE 4000
> +
> +/* maximal amount of parallel flows */
> +#define MAX_FLOWS 4
> +
> +/* struct per flow - kernel */
> +typedef struct _flowbuffer {
> +        char * buffer1;
> +        char * buffer2;
> +        char * buffer_in_use;   // buffer that is used by consumer
> +        char * offsetpos;       // pointer to actual pos in the buffer in use
> +        char * buffer1_empty;   // *buffer1 if buffer is empty, NULL else
> +        char * buffer2_empty;   // *buffer2 if buffer is empty, NULL else
> +        int flowid;             // NIST Net flow id [array index]
> +        int upid;               // pid of the user process corresponding to this flowbuffer
> +        int validDataB1;        // 1 if Data in buffer1 is valid, 0 if tracefile reached end and rubish is in B1
> +        int validDataB2;        // 1 if Data in buffer2 is valid, 0 if tracefile reached end and rubish is in B2
> +} flowbuffer;

Kernel style is to not use C++ style comments.
Are the buffer's really characters or are you just using
'char *' as an opaque pointer.

> +
> +typedef struct _strdelay {
> +  	u_int8_t head;
> +  	int delay;
> +} strdelay;
> +

Kernel style is not to use typedef's and use u8 instead of u_int8_t
The choice of name 'strdelay' implies something related to strings
of characters in C.

> +struct proc_stats {
Why not a more decscriptive name than proc_stats.

> +  	int packetcount;
> +  	int packetok;
> +	int normaldelay;
> +	int drops;
> +	int dupl;
> +	int corrupt;
> +	int noValidData;
> +	int uninitialized;
> +	int bufferunderrun;
> +	int bufferinuseempty;
> +	int noemptybuffer;
> +	int readbehindbuffer;
> +	int buffer1_reloads;
> +	int buffer2_reloads;
> +	int tobuffer1_switch;
> +	int tobuffer2_switch;
> +  	int switch_to_emptybuffer1;
> +	int switch_to_emptybuffer2;
> +};
> +
> +
> +static strdelay get_next_delay(struct Qdisc *sch, flowbuffer *myrbuf,unsigned int index);
> +
> +static int init_flowbuffer(unsigned int pid);
> +
> +static void free_flowbuffer(flowbuffer *victim);
> +
> +static void reset_stats(struct Qdisc *sch);
> +static int init_flow(void);
> +static void cleanup_flow(void);
> +

Declaring static functions in a header file is wrong.

> +#endif
> diff -u'rNF^function' olinux/linux-2.6.16.19/net/sched/sch_netem.c otlinux/linux-2.6.16.19/net/sched/sch_netem.c
> --- olinux/linux-2.6.16.19/net/sched/sch_netem.c	2006-05-31 02:31:44.000000000 +0200
> +++ otlinux/linux-2.6.16.19/net/sched/sch_netem.c	2006-08-22 11:02:47.000000000 +0200
> @@ -11,6 +11,9 @@
>   *
>   * Authors:	Stephen Hemminger <shemminger@osdl.org>
>   *		Catalin(ux aka Dino) BOIE <catab at umbrella dot ro>
> + *              netem trace enhancement: Ariane Keller <arkeller@ee.ethz.ch> ETH Zurich
> + *                                       Rainer Baumann <baumann@hypert.net> ETH Zurich
> + *                                       Ulrich Fiedler <fiedler@tik.ee.ethz.ch> ETH Zurich
>   */
>  
>  #include <linux/config.h>
> @@ -22,10 +25,14 @@
>  #include <linux/netdevice.h>
>  #include <linux/skbuff.h>
>  #include <linux/rtnetlink.h>
> -
> +#include <linux/vmalloc.h>
>  #include <net/pkt_sched.h>
>  
> -#define VERSION "1.2"
> +#include "net/flowseed.h"
> +
> +#define VERSION "1.3.3"
> +
> +//-----------------------------------------
>  
>  /*	Network Emulation Queuing algorithm.
>  	====================================
> @@ -51,6 +58,11 @@
>  
>  	 The simulator is limited by the Linux timer resolution
>  	 and will create packet bursts on the HZ boundary (1ms).
> +
> +	 The trace option allows us to read the values for packet delay,
> +         duplication, loss and corruption from a tracefile. This permits
> +	 the modulation of statistical properties such as long-range 
> +	 dependences. See tcn.hypert.net.

Full URL please

>  */
>  
>  struct netem_sched_data {
> @@ -66,6 +78,9 @@
>  	u32 duplicate;
>  	u32 reorder;
>  	u32 corrupt;
> +        u32 trace;
> +        u32 index;
> +        u32 ticks;
Use tab instead of spaces for indentation

>  
>  	struct crndstate {
>  		unsigned long last;
> @@ -76,6 +91,7 @@
>  		u32  size;
>  		s16 table[0];
>  	} *delay_dist;
> +	struct proc_stats procstats;
>  };
>  
>  /* Time stamp put into socket buffer control block */
> @@ -83,6 +99,16 @@
>  	psched_time_t	time_to_send;
>  };
>  
> +
> +/*trace extension*/

It's part of the code now, not an extension no need to flag it
with comments.

> +int mask_head = -536870912; // 11100000000000000000000000000000
> +int mask_delay = 536870911; // 00011111111111111111111111111111
> +char * procbuf = NULL;
> +flowbuffer *flowbufferptr[MAX_FLOWS];
don't use typedef's
> +unsigned int map[MAX_FLOWS];

These are all local and therefore should be static

> +/*end trace extension*/
> +
> +
>  /* init_crandom - initialize correlated random number generator
>   * Use entropy source for initial seed.
>   */
> @@ -153,18 +179,26 @@
>  	struct sk_buff *skb2;
>  	int ret;
>  	int count = 1;
> -
> +	flowbuffer *mybuf;
> +	strdelay mydelay;
> +	mydelay.delay=0; //inizialize to 0 delay and no duplication

spull communts correctly

> +	mydelay.head=0;
indent around operators use the file scripts/Lindent if necessary.

>  	pr_debug("netem_enqueue skb=%p\n", skb);
>  
> +	if(q->trace){
spaces please	'if (q->trace) {'

> +		mybuf=flowbufferptr[(q->trace)-1];
> +		mydelay=get_next_delay(sch,mybuf,q->index);
> +	}
> +
>  	/* Random duplication */
> -	if (q->duplicate && q->duplicate >= get_crandom(&q->dup_cor))
> +	if (mydelay.head==2||(q->duplicate && q->duplicate >= get_crandom(&q->dup_cor)))
>  		++count;
>  
>  	/* Random packet drop 0 => none, ~0 => all */
> -	if (q->loss && q->loss >= get_crandom(&q->loss_cor))
> +	if (!q->trace&&q->loss && q->loss >= get_crandom(&q->loss_cor))
>  		--count;
>  
> -	if (count == 0) {
> +	if (count == 0||(mydelay.head==1)) {
>  		sch->qstats.drops++;
>  		kfree_skb(skb);
>  		return NET_XMIT_DROP;
> @@ -175,11 +209,11 @@
>  	 * qdisc tree, since parent queuer expects that only one
>  	 * skb will be queued.
>  	 */
> -	if (count > 1 && (skb2 = skb_clone(skb, GFP_ATOMIC)) != NULL) {
> +
> +	if ((count > 1 && (skb2 = skb_clone(skb, GFP_ATOMIC)) != NULL)) {
>  		struct Qdisc *rootq = sch->dev->qdisc;
> -		u32 dupsave = q->duplicate; /* prevent duplicating a dup... */
> +		u32 dupsave = q->duplicate; /* prevent duplicating a dup...*/

You seem to have changed nothing interesting here. So don't make it be
part of your patch

>  		q->duplicate = 0;
> -

Please read patch and don't include gratuitous whitespace changes.
>  		rootq->enqueue(skb2, rootq);
>  		q->duplicate = dupsave;
>  	}
> @@ -190,7 +224,8 @@
>  	 * If packet is going to be hardware checksummed, then
>  	 * do it now in software before we mangle it.
>  	 */
> -	if (q->corrupt && q->corrupt >= get_crandom(&q->corrupt_cor)) {
> +
> +	if ((!q->trace&&q->corrupt && q->corrupt >= get_crandom(&q->corrupt_cor))||mydelay.head==3) {
>  		if (!(skb = skb_unshare(skb, GFP_ATOMIC))
>  		    || (skb->ip_summed == CHECKSUM_HW
>  			&& skb_checksum_help(skb, 0))) {
> @@ -201,17 +236,22 @@
>  		skb->data[net_random() % skb_headlen(skb)] ^= 1<<(net_random() % 8);
>  	}
>  
> -	if (q->gap == 0 		/* not doing reordering */
> +	if ((q->gap == 0 		/* not doing reordering */
>  	    || q->counter < q->gap 	/* inside last reordering gap */
> -	    || q->reorder < get_crandom(&q->reorder_cor)) {
> +	    || q->reorder < get_crandom(&q->reorder_cor))) {
>  		psched_time_t now;
>  		psched_tdiff_t delay;
>  
> -		delay = tabledist(q->latency, q->jitter,
> +		if(q->trace){
> +			delay=mydelay.delay;
> +			delay=delay*q->ticks;
> +			delay=delay/1000;
> +		}else{
> +			delay = tabledist(q->latency, q->jitter,
>  				  &q->delay_cor, q->delay_dist);
> -
> +		}
>  		PSCHED_GET_TIME(now);
> -		PSCHED_TADD2(now, delay, cb->time_to_send);
> +		PSCHED_TADD2(now, delay, cb->time_to_send);     //add delay to packet
>  		++q->counter;
>  		ret = q->qdisc->enqueue(skb, q->qdisc);
>  	} else {
> @@ -233,6 +273,7 @@
>  
>  	pr_debug("netem: enqueue ret %d\n", ret);
>  	return ret;
> +

More random whitespace changes
>  }
>  
>  /* Requeue packets but don't change time stamp */
> @@ -282,7 +323,6 @@
>  			return skb;
>  		} else {
>  			psched_tdiff_t delay = PSCHED_TDIFF(cb->time_to_send, now);
> -
>  			if (q->qdisc->ops->requeue(skb, q->qdisc) != NET_XMIT_SUCCESS) {
>  				sch->qstats.drops++;
>  
> @@ -304,7 +344,6 @@
>  static void netem_watchdog(unsigned long arg)
>  {
>  	struct Qdisc *sch = (struct Qdisc *)arg;
> -
>  	pr_debug("netem_watchdog qlen=%d\n", sch->q.qlen);
>  	sch->flags &= ~TCQ_F_THROTTLED;
>  	netif_schedule(sch->dev);
> @@ -313,7 +352,6 @@
>  static void netem_reset(struct Qdisc *sch)
>  {
>  	struct netem_sched_data *q = qdisc_priv(sch);
> -
>  	qdisc_reset(q->qdisc);
>  	sch->q.qlen = 0;
>  	sch->flags &= ~TCQ_F_THROTTLED;
> @@ -323,9 +361,8 @@
>  /* Pass size change message down to embedded FIFO */
>  static int set_fifo_limit(struct Qdisc *q, int limit)
>  {
> -        struct rtattr *rta;
> +	struct rtattr *rta;
>  	int ret = -ENOMEM;
> -
>  	/* Hack to avoid sending change message to non-FIFO */
>  	if (strncmp(q->ops->id + 1, "fifo", 4) != 0)
>  		return 0;
> @@ -335,7 +372,7 @@
>  		rta->rta_type = RTM_NEWQDISC;
>  		rta->rta_len = RTA_LENGTH(sizeof(struct tc_fifo_qopt)); 
>  		((struct tc_fifo_qopt *)RTA_DATA(rta))->limit = limit;
> -		
> +
>  		ret = q->ops->change(q, rta);
>  		kfree(rta);
>  	}
> @@ -364,7 +401,7 @@
>  	d->size = n;
>  	for (i = 0; i < n; i++)
>  		d->table[i] = data[i];
> -	
> +
>  	spin_lock_bh(&sch->dev->queue_lock);
>  	d = xchg(&q->delay_dist, d);
>  	spin_unlock_bh(&sch->dev->queue_lock);
> @@ -413,41 +450,129 @@
>  	return 0;
>  }
>  
> +static int get_trace(struct Qdisc *sch, const struct rtattr *attr)
> +{
> +	struct netem_sched_data *q=qdisc_priv(sch);
> +	const struct tc_netem_trace *traceopt = RTA_DATA(attr);
> +	if (RTA_PAYLOAD(attr) != sizeof(*traceopt))
> +		return -EINVAL;
> +	/*if there is an old flowseed process running -> kill it*/
> +	if(q->trace){
> +		int temp=q->trace-1;
> +		q->trace=0;
> +		reset_stats(sch);
> +		free_flowbuffer(flowbufferptr[temp]);
> +	}
> +	if(traceopt->fpid){
> +		/*correction us -> ticks*/
> +		q->ticks=traceopt->ticks;
> +		int ind;
> +		ind=init_flowbuffer(traceopt->fpid);
> +		if(ind<0){ /*there is no more space*/
> +			printk(KERN_ERR "netem: maximum number of traces:%d" 
> +                               "change it in net/flowseed.h\n",MAX_FLOWS);
> +			kill_proc(traceopt->fpid,SIGKILL,1);
> +			kill_proc(traceopt->fpid,SIGCONT,1);
> +			return -EINVAL;
> +		}
> +		q->trace=ind+1;
> +	}else
> +		q->trace = 0;
> +	q->index=traceopt->def;
> +
> +	return 0;
> +}
> +
> +static int get_data(struct Qdisc *sch, const struct rtattr *attr)
> +{
> +	struct netem_sched_data *q = qdisc_priv(sch);
> +	const struct tc_netem_data *mydata = RTA_DATA(attr);
> +	int i=0;
> +	int upid,validData=0;
> +	int flowid=-1;
> +	if (RTA_PAYLOAD(attr) != sizeof(*mydata)){
> +		printk(KERN_ERR "netem: size does not match");
> +		return -EINVAL;
> +	}
> +	memcpy(procbuf, mydata->buf, DATA_PACKAGE);
> +	upid=mydata->fpid;
> +	validData=mydata->validData;
> +	flowbuffer *mybufA;
> +
> +	/*check whether this process is allowed to send data*/
> +	for(i=0;i<MAX_FLOWS;i++){
> +		if(map[i]==upid){ /*ok*/
> +			flowid=i;
> +			break;
> +		}
> +	} 
> +	/*exit if process is not allowed to send*/
> +	if (flowid < 0) {
> +		printk(KERN_ERR "netem: Invalid flowid received.... exit.\n");
> +		kill_proc(upid,SIGKILL,1);
> +		return -EFAULT;   /*not allowed process*/
> +	}
> +
> +	/* ahhh, i don't like long names */
> +	mybufA = flowbufferptr[flowid];
> +
> +	/* check if flowbuffer has empty buffer and copy data into it */
> +	if (mybufA->buffer1_empty != NULL) {
> +		memcpy(mybufA->buffer1, procbuf, DATA_PACKAGE);
> +		mybufA->buffer1_empty = NULL;
> +		mybufA->validDataB1=validData;
> +		q->procstats.buffer1_reloads++;
> +
> +	} else if (mybufA->buffer2_empty != NULL) {
> +		memcpy(mybufA->buffer2, procbuf, DATA_PACKAGE);
> +		mybufA->buffer2_empty = NULL;
> +		mybufA->validDataB2=validData;
> +		q->procstats.buffer2_reloads++;
> +	} else {
> +		printk(KERN_ERR "netem flow %d: no empty buffer. data loss. exit.\n",flowid);
> +		q->procstats.noemptybuffer++;
> +	}
> +
> +	if(validData){
> +		/* send stop signal to process if no more empty buffers exist */
> +		kill_proc(upid,SIGSTOP,1);
> +		/* if buffers are loaded the first time, only buffer1 gets data. the
> +		 * following call sends a start for the process to send again data for buffer2 */
> +		if (mybufA->buffer2_empty != NULL) {
> +			kill_proc(upid,SIGCONT,1);
> +		}
> +	}
> +	return 0;
> +}
> +
>  /* Parse netlink message to set options */
>  static int netem_change(struct Qdisc *sch, struct rtattr *opt)
>  {
>  	struct netem_sched_data *q = qdisc_priv(sch);
>  	struct tc_netem_qopt *qopt;
>  	int ret;
> -	
>  	if (opt == NULL || RTA_PAYLOAD(opt) < sizeof(*qopt))
>  		return -EINVAL;
>  
>  	qopt = RTA_DATA(opt);
> -	ret = set_fifo_limit(q->qdisc, qopt->limit);
> -	if (ret) {
> -		pr_debug("netem: can't set fifo limit\n");
> -		return ret;
> -	}
> -	
> +
>  	q->latency = qopt->latency;
>  	q->jitter = qopt->jitter;
> -	q->limit = qopt->limit;
>  	q->gap = qopt->gap;
>  	q->counter = 0;
>  	q->loss = qopt->loss;
>  	q->duplicate = qopt->duplicate;
>  
>  	/* for compatiablity with earlier versions.
> -	 * if gap is set, need to assume 100% probablity
> -	 */
> +         * if gap is set, need to assume 100% probablity
> +         */
>  	q->reorder = ~0;
>  
>  	/* Handle nested options after initial queue options.
>  	 * Should have put all options in nested format but too late now.
>  	 */ 
> +	struct rtattr *tb[TCA_NETEM_MAX];
>  	if (RTA_PAYLOAD(opt) > sizeof(*qopt)) {
> -		struct rtattr *tb[TCA_NETEM_MAX];
>  		if (rtattr_parse(tb, TCA_NETEM_MAX, 
>  				 RTA_DATA(opt) + sizeof(*qopt),
>  				 RTA_PAYLOAD(opt) - sizeof(*qopt)))
> @@ -476,6 +601,31 @@
>  			if (ret)
>  				return ret;
>  		}
> +
> +		if (tb[TCA_NETEM_TRACE-1]) {
> +			ret = get_trace(sch, tb[TCA_NETEM_TRACE-1]);
> +			if (ret)
> +				return ret;
> +		}
> +		if (tb[TCA_NETEM_DATA-1]) {
> +			ret = get_data(sch, tb[TCA_NETEM_DATA-1]);
> +			if (ret)
> +				return ret;
> +		}
> +	}
> +	if(!(tb[TCA_NETEM_DATA-1])){
> +		q->limit = qopt->limit;
> +		ret = set_fifo_limit(q->qdisc, qopt->limit);
> +		if (ret) {
> +			pr_debug("netem: can't set fifo limit\n");
> +			return ret;
> +		}
> +		if(q->trace&&!(tb[TCA_NETEM_TRACE-1])){   //kill old flowseed process
> +			int temp=q->trace-1;
> +			q->trace=0;
> +			reset_stats(sch);
> +			free_flowbuffer(flowbufferptr[temp]);
> +		}
>  	}
>  
>  	return 0;
> @@ -570,7 +720,7 @@
>  	init_timer(&q->timer);
>  	q->timer.function = netem_watchdog;
>  	q->timer.data = (unsigned long) sch;
> -
> +	q->trace=0;
>  	q->qdisc = qdisc_create_dflt(sch->dev, &tfifo_qdisc_ops);
>  	if (!q->qdisc) {
>  		pr_debug("netem: qdisc create failed\n");
> @@ -589,6 +739,12 @@
>  {
>  	struct netem_sched_data *q = qdisc_priv(sch);
>  
> +	if(q->trace){
> +		int temp=q->trace-1;
> +		q->trace=0;  //first: stop reading values form buffer
> +		free_flowbuffer(flowbufferptr[temp]); //second: delete buffer
> +	}
> +
>  	del_timer_sync(&q->timer);
>  	qdisc_destroy(q->qdisc);
>  	kfree(q->delay_dist);
> @@ -597,12 +753,14 @@
>  static int netem_dump(struct Qdisc *sch, struct sk_buff *skb)
>  {
>  	const struct netem_sched_data *q = qdisc_priv(sch);
> -	unsigned char	 *b = skb->tail;
> +	unsigned char *b = skb->tail;
>  	struct rtattr *rta = (struct rtattr *) b;
>  	struct tc_netem_qopt qopt;
>  	struct tc_netem_corr cor;
>  	struct tc_netem_reorder reorder;
>  	struct tc_netem_corrupt corrupt;
> +	struct tc_netem_trace traceopt;
> +	struct tc_netem_stats tracestats;
>  
>  	qopt.latency = q->latency;
>  	qopt.jitter = q->jitter;
> @@ -610,8 +768,14 @@
>  	qopt.loss = q->loss;
>  	qopt.gap = q->gap;
>  	qopt.duplicate = q->duplicate;
> +
>  	RTA_PUT(skb, TCA_OPTIONS, sizeof(qopt), &qopt);
>  
> +	traceopt.fpid = q->trace;
> +	traceopt.def = q->index;
> +	traceopt.ticks = q->ticks;
> +	RTA_PUT(skb, TCA_NETEM_TRACE, sizeof(traceopt), &traceopt);
> +
>  	cor.delay_corr = q->delay_cor.rho;
>  	cor.loss_corr = q->loss_cor.rho;
>  	cor.dup_corr = q->dup_cor.rho;
> @@ -625,6 +789,26 @@
>  	corrupt.correlation = q->corrupt_cor.rho;
>  	RTA_PUT(skb, TCA_NETEM_CORRUPT, sizeof(corrupt), &corrupt);
>  
> +	tracestats.packetcount=q->procstats.packetcount;
> +	tracestats.packetok=q->procstats.packetok;
> +	tracestats.normaldelay=q->procstats.normaldelay;
> +	tracestats.drops=q->procstats.drops;
> +	tracestats.dupl=q->procstats.dupl;
> +	tracestats.corrupt=q->procstats.corrupt;
> +	tracestats.noValidData=q->procstats.noValidData;
> +	tracestats.uninitialized=q->procstats.uninitialized;
> +	tracestats.bufferunderrun=q->procstats.bufferunderrun;
> +	tracestats.bufferinuseempty=q->procstats.bufferinuseempty;
> +	tracestats.noemptybuffer=q->procstats.noemptybuffer;
> +	tracestats.readbehindbuffer=q->procstats.readbehindbuffer;
> +	tracestats.buffer1_reloads=q->procstats.buffer1_reloads;
> +	tracestats.buffer2_reloads=q->procstats.buffer2_reloads;
> +	tracestats.tobuffer1_switch=q->procstats.tobuffer1_switch;
> +	tracestats.tobuffer2_switch=q->procstats.tobuffer2_switch;
> +	tracestats.switch_to_emptybuffer1=q->procstats.switch_to_emptybuffer1;
> +	tracestats.switch_to_emptybuffer2=q->procstats.switch_to_emptybuffer2;
> +	RTA_PUT(skb, TCA_NETEM_STATS, sizeof(tracestats), &tracestats);
> +
>  	rta->rta_len = skb->tail - b;
>  
>  	return skb->len;
> @@ -708,6 +892,215 @@
>  	return NULL;
>  }
>  
> +
> +/*functions of the trace enhancement*/
> +
> +/* don't call this function directly. it is called after a packet has been taken out
> + * of a buffer and it was the last. */
> +static int reload_flowbuffer (struct netem_sched_data *q, flowbuffer *myrbuf)
> +{
> +	if (myrbuf->buffer_in_use ==  myrbuf->buffer1) {
> +		myrbuf->buffer1_empty = myrbuf->buffer1;
> +
> +		if (myrbuf->buffer2_empty!=NULL) {
> +			q->procstats.switch_to_emptybuffer2++;
> +			return -EFAULT;
> +		}else{
> +			q->procstats.tobuffer2_switch++;
> +		}
> +
> +		myrbuf->buffer_in_use = myrbuf->buffer2;
> +		myrbuf->offsetpos =myrbuf->buffer2;
> +
> +	}else {
> +		myrbuf->buffer2_empty = myrbuf->buffer2;
> +
> +		if (myrbuf->buffer1_empty!=NULL) {
> +		 	q->procstats.switch_to_emptybuffer1++;
> +			return -EFAULT;
> +		}else{
> +			q->procstats.tobuffer1_switch++;
> +		}
> +
> +		myrbuf->buffer_in_use = myrbuf->buffer1;
> +		myrbuf->offsetpos = myrbuf->buffer1;
> +
> +	}
> +	/*the flowseed process can send more data*/
> +	kill_proc(myrbuf->upid,SIGCONT,1);
> +
> +	return 0;
> +}
> +
> +/* return delay struct with delay and drop/dupl/corrupt option */
> +static strdelay get_next_delay(struct Qdisc *sch, flowbuffer *myrbuf, unsigned int index)
> +{
> +	struct netem_sched_data *q=qdisc_priv(sch);
> +	strdelay retval;
> +	memset(&retval, 0, sizeof(retval));
> +
> +	int variout;
> +
> +	/*choose whether to drop or 0 delay packets on default*/
> +	retval.head = index;
> +	retval.delay=0;
> +
> +	if (myrbuf == NULL) {
> +		printk(KERN_ERR "netem: read from an uninitialized flow.\n");
> +		q->procstats.uninitialized++;
> +		return retval;
> +	}
> +
> +	q->procstats.packetcount++;
> +
> +	/* check if we have to reload a buffer */
> +	if (myrbuf->offsetpos - myrbuf->buffer_in_use == DATA_PACKAGE) {
> +		reload_flowbuffer(q,myrbuf);
> +	}
> +	/* sanity checks */
> +	if((myrbuf->buffer_in_use ==  myrbuf->buffer1&&myrbuf->validDataB1)||
> +	     ( myrbuf->buffer_in_use ==  myrbuf->buffer2&&myrbuf->validDataB2)){
> +
> +		if ((myrbuf->buffer1_empty != NULL) && (myrbuf->buffer2_empty != NULL)) {
> +			q->procstats.bufferunderrun++;
> +			return retval;
> +		}
> +
> +		if (myrbuf->buffer1_empty == myrbuf->buffer_in_use ||
> +		    myrbuf->buffer2_empty == myrbuf->buffer_in_use) {
> +			q->procstats.bufferinuseempty++;
> +			return retval;
> +		}
> +
> +		if (myrbuf->offsetpos - myrbuf->buffer_in_use >= DATA_PACKAGE) {
> +			q->procstats.readbehindbuffer++;
> +			return retval;
> +		}
> +	}else{                                       //end of tracefile reached
> +		q->procstats.noValidData++;
> +		return retval;
> +	}
> +	/* now it's safe to read */
> +	memcpy(&variout, myrbuf->offsetpos, 4);
> +	myrbuf->offsetpos+=4;
> +
> +	retval.delay = variout & mask_delay;
> +	retval.head =  (variout & mask_head) >> 29;
> +
> +	/* head 00 (0) -> normal delay
> +	 *	01 (1) -> drop packet
> +	 *	10 (2) -> duplicate
> +	 *	11 (3) -> currupt
> +	 */
> +
> +	switch (retval.head) {
> +	case 0:
> +		q->procstats.normaldelay++;
> +		break;
> +	case 1:
> +		q->procstats.drops++;
> +		break;
> +	case 2:
> +		q->procstats.dupl++;
> +		break;
> +	case 3:
> +	        q->procstats.corrupt++;
> +	        break;
> +	}
> +
> +	q->procstats.packetok++;
> +
> +	return retval;
> +}
> +
> +
> +static void free_flowbuffer(flowbuffer *victim)
> +{
> +	int flowid=0, upid=0;
> +	if (victim != NULL) {
> +		upid = victim->upid;
> +		if (upid > 0) {
> +			kill_proc(upid,SIGKILL,1);
> +			kill_proc(upid,SIGCONT,1);
> +		}
> +
> +		flowid=victim->flowid;
> +		map[flowid]=0;
> +		flowbufferptr[flowid]=NULL;
> +
> +	if(victim->buffer1!=NULL){
> +		kfree(victim->buffer1);
> +		}
> +		if(victim->buffer2!=NULL)
> +			kfree(victim->buffer2);
> +		kfree(victim);
> +		victim=NULL;
> +	}else{
> +		printk(KERN_ERR "netem: can't free given flowbuffer, nullpointer\n");
> +	}
> +}
> +
> +static int init_flowbuffer(unsigned int pid)
> +{
> +	int i,flowid=-1;
> +	flowbuffer *mybufB;
> +
> +	for(i=0;i<MAX_FLOWS;i++){
> +		if(map[i]==0){
> +			flowid=i;
> +			map[i]=pid;
> +			break;
> +		}
> +	}
> +
> +	if(flowid!=-1){
> +		flowbufferptr[flowid] = kmalloc(sizeof(flowbuffer),GFP_ATOMIC);
> +		mybufB = flowbufferptr[flowid];
> +		mybufB->buffer1 = kmalloc(DATA_PACKAGE,GFP_ATOMIC);
> +		mybufB->buffer2 = kmalloc(DATA_PACKAGE,GFP_ATOMIC);
> +		mybufB->buffer_in_use = mybufB->buffer1;
> +		mybufB->offsetpos = mybufB->buffer1;
> +		mybufB->buffer1_empty = mybufB->buffer1;
> +		mybufB->buffer2_empty = mybufB->buffer2;
> +		mybufB->flowid=flowid; 
> +		mybufB->upid=pid;
> +		mybufB->validDataB1=0;
> +		mybufB->validDataB2=0;
> +	}
> +	return flowid;
> +}
> +
> +static void reset_stats(struct Qdisc *sch)
> +{
> +	struct netem_sched_data *q=qdisc_priv(sch);
> +	memset(&q->procstats,0,sizeof(q->procstats));
> +	return;
> +}
> +
> +static int init_flow(void)
> +{
> +	procbuf = vmalloc(DATA_PACKAGE);
> +	int i;
> +	for (i = 0; i < MAX_FLOWS; i++){
> +		flowbufferptr[i] = NULL;
> +		map[i]=0;
> +	}
> +	return 0;
> +}
> +
> +
> +static void cleanup_flow(void)
> +{
> +	int i;
> +	for (i = 0; i < MAX_FLOWS; i++) {
> +		if (flowbufferptr[i] != NULL) {
> +			kfree(flowbufferptr[i]->buffer1);
> +			kfree(flowbufferptr[i]->buffer2);
> +		}
> +	}
> +}
> +/*end functions of trace enhancement*/
> +
>  static struct Qdisc_class_ops netem_class_ops = {
>  	.graft		=	netem_graft,
>  	.leaf		=	netem_leaf,
> @@ -740,12 +1133,19 @@
>  static int __init netem_module_init(void)
>  {
>  	pr_info("netem: version " VERSION "\n");
> +	init_flow();
>  	return register_qdisc(&netem_qdisc_ops);
>  }
>  static void __exit netem_module_exit(void)
>  {
>  	unregister_qdisc(&netem_qdisc_ops);
> +	cleanup_flow();
>  }
>  module_init(netem_module_init)
>  module_exit(netem_module_exit)
>  MODULE_LICENSE("GPL");
> +
> +
> +
> +
> +

