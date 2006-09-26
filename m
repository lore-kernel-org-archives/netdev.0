From: Rainer Baumann <baumann@tik.ee.ethz.ch>
Subject: Re: [PATCH 2.6.17.13 2/2] LARTC: trace control for netem: kernelspace
Date: Tue, 26 Sep 2006 22:17:57 +0200
Message-ID: <45198AF5.9090909@tik.ee.ethz.ch>
References: <4514DC9A.2000505@tik.ee.ethz.ch> <20060925132800.09856e10@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@VGER.KERNEL.ORG, netem@osdl.org
Return-path: <netdev-owner@vger.kernel.org>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20060925132800.09856e10@dxpl.pdx.osdl.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Stephens

We merged your changes into our patch
http://tcn.hypert.net/tcn_kernel_2_6_18.patch
Please let us know if we should do further adoptions to our
implementation and/or resubmit the adapted patch.

Cheers+thanx,
Rainer

Stephen Hemminger wrote:
> Some changes:
>
> 1. need to select CONFIGFS into configuration
> 2. don't add declarations after code.
> 3. use unsigned not int for counters and mask.
> 4. don't return a structure (ie pkt_delay)
> 5. use enum for magic values
> 6. don't use GFP_ATOMIC unless you have to
> 7. check error values on configfs_init
> 8. map initialization is unneeded. static's always init to zero.
>
> ------------------
> diff --git a/include/linux/pkt_sched.h b/include/linux/pkt_sched.h
> index d10f353..a51de64 100644
> --- a/include/linux/pkt_sched.h
> +++ b/include/linux/pkt_sched.h
> @@ -430,6 +430,8 @@ enum
>  	TCA_NETEM_DELAY_DIST,
>  	TCA_NETEM_REORDER,
>  	TCA_NETEM_CORRUPT,
> +	TCA_NETEM_TRACE,
> +	TCA_NETEM_STATS,
>  	__TCA_NETEM_MAX,
>  };
>  
> @@ -445,6 +447,35 @@ struct tc_netem_qopt
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
> +	int novaliddata;
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
> +
> +struct tc_netem_trace
> +{
> +	__u32   fid;             /*flowid */
> +	__u32   def;          	 /* default action 0 = no delay, 1 = drop*/
> +	__u32   ticks;	         /* number of ticks corresponding to 1ms */
> +};
> +
>  struct tc_netem_corr
>  {
>  	__u32	delay_corr;	/* delay correlation */
> diff --git a/net/sched/Kconfig b/net/sched/Kconfig
> index 8298ea9..aee4bc6 100644
> --- a/net/sched/Kconfig
> +++ b/net/sched/Kconfig
> @@ -232,6 +232,7 @@ config NET_SCH_DSMARK
>  
>  config NET_SCH_NETEM
>  	tristate "Network emulator (NETEM)"
> +	select CONFIGFS_FS
>  	---help---
>  	  Say Y if you want to emulate network delay, loss, and packet
>  	  re-ordering. This is often useful to simulate networks when
> diff --git a/net/sched/sch_netem.c b/net/sched/sch_netem.c
> index 45939ba..521b9e3 100644
> --- a/net/sched/sch_netem.c
> +++ b/net/sched/sch_netem.c
> @@ -11,6 +11,9 @@
>   *
>   * Authors:	Stephen Hemminger <shemminger@osdl.org>
>   *		Catalin(ux aka Dino) BOIE <catab at umbrella dot ro>
> + *              netem trace enhancement: Ariane Keller <arkeller@ee.ethz.ch> ETH Zurich
> + *                                       Rainer Baumann <baumann@hypert.net> ETH Zurich
> + *                                       Ulrich Fiedler <fiedler@tik.ee.ethz.ch> ETH Zurich
>   */
>  
>  #include <linux/module.h>
> @@ -21,10 +24,16 @@ #include <linux/errno.h>
>  #include <linux/netdevice.h>
>  #include <linux/skbuff.h>
>  #include <linux/rtnetlink.h>
> +#include <linux/init.h>
> +#include <linux/slab.h>
> +#include <linux/configfs.h>
> +#include <linux/vmalloc.h>
>  
>  #include <net/pkt_sched.h>
>  
> -#define VERSION "1.2"
> +#include "net/flowseed.h"
> +
> +#define VERSION "1.3"
>  
>  /*	Network Emulation Queuing algorithm.
>  	====================================
> @@ -50,6 +59,11 @@ #define VERSION "1.2"
>  
>  	 The simulator is limited by the Linux timer resolution
>  	 and will create packet bursts on the HZ boundary (1ms).
> +
> +	 The trace option allows us to read the values for packet delay,
> +	 duplication, loss and corruption from a tracefile. This permits
> +	 the modulation of statistical properties such as long-range 
> +	 dependences. See http://tcn.hypert.net.
>  */
>  
>  struct netem_sched_data {
> @@ -65,6 +79,11 @@ struct netem_sched_data {
>  	u32 duplicate;
>  	u32 reorder;
>  	u32 corrupt;
> +	u32 tcnstop;
> +	u32 trace;
> +	u32 ticks;
> +	u32 def;
> +	u32 newdataneeded;
>  
>  	struct crndstate {
>  		unsigned long last;
> @@ -72,9 +91,13 @@ struct netem_sched_data {
>  	} delay_cor, loss_cor, dup_cor, reorder_cor, corrupt_cor;
>  
>  	struct disttable {
> -		u32  size;
> +		u32 size;
>  		s16 table[0];
>  	} *delay_dist;
> +
> +	struct tcn_statistic *statistic;
> +	struct tcn_control *flowbuffer;
> +	wait_queue_head_t my_event;
>  };
>  
>  /* Time stamp put into socket buffer control block */
> @@ -82,6 +105,18 @@ struct netem_skb_cb {
>  	psched_time_t	time_to_send;
>  };
>  
> +
> +struct confdata {
> +	int fid;
> +	struct netem_sched_data * sched_data;
> +};
> +
> +static struct confdata map[MAX_FLOWS];
> +
> +#define MASK_BITS	29
> +#define MASK_DELAY	((1<<MASK_BITS)-1)
> +#define MASK_HEAD       ~MASK_DELAY
> +
>  /* init_crandom - initialize correlated random number generator
>   * Use entropy source for initial seed.
>   */
> @@ -139,6 +174,103 @@ static long tabledist(unsigned long mu, 
>  	return  x / NETEM_DIST_SCALE + (sigma / NETEM_DIST_SCALE) * t + mu;
>  }
>  
> +/* don't call this function directly. It is called after 
> + * a packet has been taken out of a buffer and it was the last. 
> + */
> +static int reload_flowbuffer (struct netem_sched_data *q)
> +{
> +	struct tcn_control *flow = q->flowbuffer;
> +
> +	if (flow->buffer_in_use == flow->buffer1) {
> +		flow->buffer1_empty = flow->buffer1;
> +		if (flow->buffer2_empty) {
> +			q->statistic->switch_to_emptybuffer2++;
> +			return -EFAULT;
> +		}
> +
> +		q->statistic->tobuffer2_switch++;
> +
> +		flow->buffer_in_use = flow->buffer2;
> +		flow->offsetpos = flow->buffer2;
> +
> +	} else {
> +		flow->buffer2_empty = flow->buffer2;
> +
> +		if (flow->buffer1_empty) {
> +		 	q->statistic->switch_to_emptybuffer1++;
> +			return -EFAULT;
> +		} 
> +
> +		q->statistic->tobuffer1_switch++;
> +
> +		flow->buffer_in_use = flow->buffer1;
> +		flow->offsetpos = flow->buffer1;
> +
> +	}
> +	/*the flowseed process can send more data*/
> +	q->tcnstop = 0;
> +	q->newdataneeded = 1;
> +	wake_up(&q->my_event);
> +	return 0;
> +}
> +
> +/* return pktdelay with delay and drop/dupl/corrupt option */
> +static int get_next_delay(struct netem_sched_data *q, enum tcn_flow *head)
> +{
> +	struct tcn_control *flow = q->flowbuffer;
> +	u32 variout;
> +
> +	/*choose whether to drop or 0 delay packets on default*/
> +	*head = q->def;
> +
> +	if (!flow) {
> +		printk(KERN_ERR "netem: read from an uninitialized flow.\n");
> +		q->statistic->uninitialized++;
> +		return 0;
> +	}
> +
> +	q->statistic->packetcount++;
> +
> +	/* check if we have to reload a buffer */
> +	if (flow->offsetpos - flow->buffer_in_use == DATA_PACKAGE)
> +		reload_flowbuffer(q);
> +
> +	/* sanity checks */
> +	if ((flow->buffer_in_use == flow->buffer1 && flow->validdataB1) 
> +	    || ( flow->buffer_in_use == flow->buffer2 && flow->validdataB2)) {
> +
> +		if (flow->buffer1_empty && flow->buffer2_empty) {
> +			q->statistic->bufferunderrun++;
> +			return 0;
> +		}
> +
> +		if (flow->buffer1_empty == flow->buffer_in_use ||
> +		    flow->buffer2_empty == flow->buffer_in_use) {
> +			q->statistic->bufferinuseempty++;
> +			return 0;
> +		}
> +
> +		if (flow->offsetpos - flow->buffer_in_use >=
> +		    DATA_PACKAGE) {
> +			q->statistic->readbehindbuffer++;
> +			return 0;
> +		}
> +		/*end of tracefile reached*/	
> +	} else {
> +		q->statistic->novaliddata++;
> +		return 0;
> +	}
> +
> +	/* now it's safe to read */
> +	variout = *flow->offsetpos++;
> +	*head = (variout & MASK_HEAD) >> MASK_BITS;
> +
> +	(&q->statistic->normaldelay)[*head] += 1;
> +	q->statistic->packetok++;
> +
> +	return ((variout & MASK_DELAY) * q->ticks) / 1000;
> +}
> +
>  /*
>   * Insert one skb into qdisc.
>   * Note: parent depends on return value to account for queue length.
> @@ -148,20 +280,25 @@ static long tabledist(unsigned long mu, 
>  static int netem_enqueue(struct sk_buff *skb, struct Qdisc *sch)
>  {
>  	struct netem_sched_data *q = qdisc_priv(sch);
> -	/* We don't fill cb now as skb_unshare() may invalidate it */
>  	struct netem_skb_cb *cb;
>  	struct sk_buff *skb2;
> -	int ret;
> -	int count = 1;
> +	enum tcn_flow action = FLOW_NORMAL;
> +	psched_tdiff_t delay;
> +	int ret, count = 1;
>  
>  	pr_debug("netem_enqueue skb=%p\n", skb);
>  
> -	/* Random duplication */
> -	if (q->duplicate && q->duplicate >= get_crandom(&q->dup_cor))
> +	if (q->trace) 
> +		action = get_next_delay(q, &delay);
> +
> + 	/* Random duplication */
> +	if (q->trace ? action == FLOW_DUP :
> +	    (q->duplicate && q->duplicate >= get_crandom(&q->dup_cor)))
>  		++count;
>  
>  	/* Random packet drop 0 => none, ~0 => all */
> -	if (q->loss && q->loss >= get_crandom(&q->loss_cor))
> +	if (q->trace ? action == FLOW_DROP :
> +	    (q->loss && q->loss >= get_crandom(&q->loss_cor)))
>  		--count;
>  
>  	if (count == 0) {
> @@ -190,7 +327,8 @@ static int netem_enqueue(struct sk_buff 
>  	 * If packet is going to be hardware checksummed, then
>  	 * do it now in software before we mangle it.
>  	 */
> -	if (q->corrupt && q->corrupt >= get_crandom(&q->corrupt_cor)) {
> +	if (q->trace ? action == FLOW_MANGLE :
> +	    (q->corrupt && q->corrupt >= get_crandom(&q->corrupt_cor))) {
>  		if (!(skb = skb_unshare(skb, GFP_ATOMIC))
>  		    || (skb->ip_summed == CHECKSUM_PARTIAL
>  			&& skb_checksum_help(skb))) {
> @@ -206,10 +344,10 @@ static int netem_enqueue(struct sk_buff 
>  	    || q->counter < q->gap 	/* inside last reordering gap */
>  	    || q->reorder < get_crandom(&q->reorder_cor)) {
>  		psched_time_t now;
> -		psched_tdiff_t delay;
>  
> -		delay = tabledist(q->latency, q->jitter,
> -				  &q->delay_cor, q->delay_dist);
> +		if (!q->trace)
> +			delay = tabledist(q->latency, q->jitter,
> +					  &q->delay_cor, q->delay_dist);
>  
>  		PSCHED_GET_TIME(now);
>  		PSCHED_TADD2(now, delay, cb->time_to_send);
> @@ -343,6 +481,65 @@ static int set_fifo_limit(struct Qdisc *
>  	return ret;
>  }
>  
> +static void reset_stats(struct netem_sched_data * q)
> +{
> +	memset(q->statistic, 0, sizeof(*(q->statistic)));
> +	return;
> +}
> +
> +static void free_flowbuffer(struct netem_sched_data * q)
> +{
> +	if (q->flowbuffer != NULL) {
> +		q->tcnstop = 1;
> +		q->newdataneeded = 1;
> +		wake_up(&q->my_event);
> +
> +		if (q->flowbuffer->buffer1 != NULL) {
> +			kfree(q->flowbuffer->buffer1);
> +		}
> +		if (q->flowbuffer->buffer2 != NULL) {
> +			kfree(q->flowbuffer->buffer2);
> +		}
> +		kfree(q->flowbuffer);
> +		kfree(q->statistic);
> +		q->flowbuffer = NULL;
> +		q->statistic = NULL;
> +	}
> +}
> +
> +static int init_flowbuffer(unsigned int fid, struct netem_sched_data * q)
> +{
> +	int i, flowid = -1;
> +
> +	q->statistic = kzalloc(sizeof(*(q->statistic)), GFP_KERNEL;
> +	init_waitqueue_head(&q->my_event);
> +
> +	for(i = 0; i < MAX_FLOWS; i++) {
> +		if(map[i].fid == 0) {
> +			flowid = i;
> +			map[i].fid = fid;
> +			map[i].sched_data = q;
> +			break;
> +		}
> +	}
> +
> +	if (flowid != -1) {
> +		q->flowbuffer = kmalloc(sizeof(*(q->flowbuffer)), GFP_KERNEL);
> +		q->flowbuffer->buffer1 = kmalloc(DATA_PACKAGE, GFP_KERNEL);
> +		q->flowbuffer->buffer2 = kmalloc(DATA_PACKAGE, GFP_KERNEL);
> +
> +		q->flowbuffer->buffer_in_use = q->flowbuffer->buffer1;
> +		q->flowbuffer->offsetpos = q->flowbuffer->buffer1;
> +		q->flowbuffer->buffer1_empty = q->flowbuffer->buffer1;
> +		q->flowbuffer->buffer2_empty = q->flowbuffer->buffer2;
> +		q->flowbuffer->flowid = flowid; 
> +		q->flowbuffer->validdataB1 = 0;
> +		q->flowbuffer->validdataB2 = 0;
> +	}
> +
> +	return flowid;
> +}
> +
>  /*
>   * Distribution data is a variable size payload containing
>   * signed 16 bit values.
> @@ -414,6 +611,32 @@ static int get_corrupt(struct Qdisc *sch
>  	return 0;
>  }
>  
> +static int get_trace(struct Qdisc *sch, const struct rtattr *attr)
> +{
> +	struct netem_sched_data *q = qdisc_priv(sch);
> +	const struct tc_netem_trace *traceopt = RTA_DATA(attr);
> +
> +	if (RTA_PAYLOAD(attr) != sizeof(*traceopt))
> +		return -EINVAL;
> +
> +	if (traceopt->fid) {
> +		/*correction us -> ticks*/
> +		q->ticks = traceopt->ticks;
> +		int ind;
> +		ind = init_flowbuffer(traceopt->fid, q);
> +		if(ind < 0) {
> +			printk("netem: maximum number of traces:%d"
> +			       " change in net/flowseedprocfs.h\n", MAX_FLOWS);
> +			return -EINVAL;
> +		}
> +		q->trace = ind + 1;
> +
> +	} else
> +		q->trace = 0;
> +	q->def = traceopt->def;
> +	return 0;
> +}
> +
>  /* Parse netlink message to set options */
>  static int netem_change(struct Qdisc *sch, struct rtattr *opt)
>  {
> @@ -431,6 +654,14 @@ static int netem_change(struct Qdisc *sc
>  		return ret;
>  	}
>  	
> +	if (q->trace) {
> +		int temp = q->trace - 1;
> +		q->trace = 0;
> +		map[temp].fid = 0;
> +		reset_stats(q);
> +		free_flowbuffer(q);
> +	}
> +
>  	q->latency = qopt->latency;
>  	q->jitter = qopt->jitter;
>  	q->limit = qopt->limit;
> @@ -477,6 +708,11 @@ static int netem_change(struct Qdisc *sc
>  			if (ret)
>  				return ret;
>  		}
> +		if (tb[TCA_NETEM_TRACE-1]) {
> +			ret = get_trace(sch, tb[TCA_NETEM_TRACE-1]);
> +			if (ret)
> +				return ret;
> +		}
>  	}
>  
>  	return 0;
> @@ -572,6 +808,7 @@ static int netem_init(struct Qdisc *sch,
>  	q->timer.function = netem_watchdog;
>  	q->timer.data = (unsigned long) sch;
>  
> +	q->trace = 0;
>  	q->qdisc = qdisc_create_dflt(sch->dev, &tfifo_qdisc_ops);
>  	if (!q->qdisc) {
>  		pr_debug("netem: qdisc create failed\n");
> @@ -590,6 +827,12 @@ static void netem_destroy(struct Qdisc *
>  {
>  	struct netem_sched_data *q = qdisc_priv(sch);
>  
> +	if (q->trace) {
> +		int temp = q->trace - 1;
> +		q->trace = 0;
> +		map[temp].fid = 0;
> +		free_flowbuffer(q);
> +	}
>  	del_timer_sync(&q->timer);
>  	qdisc_destroy(q->qdisc);
>  	kfree(q->delay_dist);
> @@ -604,6 +847,7 @@ static int netem_dump(struct Qdisc *sch,
>  	struct tc_netem_corr cor;
>  	struct tc_netem_reorder reorder;
>  	struct tc_netem_corrupt corrupt;
> +	struct tc_netem_trace traceopt;
>  
>  	qopt.latency = q->latency;
>  	qopt.jitter = q->jitter;
> @@ -626,6 +870,35 @@ static int netem_dump(struct Qdisc *sch,
>  	corrupt.correlation = q->corrupt_cor.rho;
>  	RTA_PUT(skb, TCA_NETEM_CORRUPT, sizeof(corrupt), &corrupt);
>  
> +	traceopt.fid = q->trace;
> +	traceopt.def = q->def;
> +	traceopt.ticks = q->ticks;
> +	RTA_PUT(skb, TCA_NETEM_TRACE, sizeof(traceopt), &traceopt);
> +
> +	if (q->trace) {
> +		struct tc_netem_stats tstats;
> +
> +		tstats.packetcount = q->statistic->packetcount;
> +		tstats.packetok = q->statistic->packetok;
> +		tstats.normaldelay = q->statistic->normaldelay;
> +		tstats.drops = q->statistic->drops;
> +		tstats.dupl = q->statistic->dupl;
> +		tstats.corrupt = q->statistic->corrupt;
> +		tstats.novaliddata = q->statistic->novaliddata;
> +		tstats.uninitialized = q->statistic->uninitialized;
> +		tstats.bufferunderrun = q->statistic->bufferunderrun;
> +		tstats.bufferinuseempty = q->statistic->bufferinuseempty;
> +		tstats.noemptybuffer = q->statistic->noemptybuffer;
> +		tstats.readbehindbuffer = q->statistic->readbehindbuffer;
> +		tstats.buffer1_reloads = q->statistic->buffer1_reloads;
> +		tstats.buffer2_reloads = q->statistic->buffer2_reloads;
> +		tstats.tobuffer1_switch = q->statistic->tobuffer1_switch;
> +		tstats.tobuffer2_switch = q->statistic->tobuffer2_switch;
> +		tstats.switch_to_emptybuffer1 = q->statistic->switch_to_emptybuffer1;
> +		tstats.switch_to_emptybuffer2 = q->statistic->switch_to_emptybuffer2;
> +		RTA_PUT(skb, TCA_NETEM_STATS, sizeof(tstats), &tstats);
> +	}
> +
>  	rta->rta_len = skb->tail - b;
>  
>  	return skb->len;
> @@ -709,6 +982,173 @@ static struct tcf_proto **netem_find_tcf
>  	return NULL;
>  }
>  
> +/*configfs to read tcn delay values from userspace*/
> +struct tcn_flow {
> +	struct config_item item;
> +};
> +
> +static struct tcn_flow *to_tcn_flow(struct config_item *item)
> +{
> +	return item ? container_of(item, struct tcn_flow, item) : NULL;
> +}
> +
> +static struct configfs_attribute tcn_flow_attr_storeme = {
> +	.ca_owner = THIS_MODULE,
> +	.ca_name = "delayvalue",
> +	.ca_mode = S_IRUGO | S_IWUSR,
> +};
> +
> +static struct configfs_attribute *tcn_flow_attrs[] = {
> +	&tcn_flow_attr_storeme,
> +	NULL,
> +};
> +
> +static ssize_t tcn_flow_attr_store(struct config_item *item,
> +				       struct configfs_attribute *attr,
> +				       const char *page, size_t count)
> +{
> +	char *p = (char *)page;
> +	int fid, i, validData = 0;
> +	int flowid = -1;
> +	struct tcn_control *checkbuf;
> +
> +	if (count != DATA_PACKAGE_ID) {
> +		printk("netem: Unexpected data received. %d\n", count);
> +		return -EMSGSIZE;
> +	}
> +
> +	memcpy(&fid, p + DATA_PACKAGE, sizeof(int));
> +	memcpy(&validData, p + DATA_PACKAGE + sizeof(int), sizeof(int));
> +
> +	/* check whether this flow is registered */
> +	for (i = 0; i < MAX_FLOWS; i++) {
> +		if (map[i].fid == fid) {
> +			flowid = i;
> +			break;
> +		}
> +	}
> +	/* exit if flow is not registered */
> +	if (flowid < 0) {
> +		printk("netem: Invalid FID received. Killing process.\n");
> +		return -EINVAL;
> +	}
> +
> +	checkbuf = map[flowid].sched_data->flowbuffer;
> +	if (checkbuf == NULL) {
> +		printk("netem: no flow registered");
> +		return -ENOBUFS;
> +	}
> +
> +	/* check if flowbuffer has empty buffer and copy data into it */
> +	if (checkbuf->buffer1_empty != NULL) {
> +		memcpy(checkbuf->buffer1, p, DATA_PACKAGE);
> +		checkbuf->buffer1_empty = NULL;
> +		checkbuf->validdataB1 = validData;
> +		map[flowid].sched_data->statistic->buffer1_reloads++;
> +
> +	} else if (checkbuf->buffer2_empty != NULL) {
> +		memcpy(checkbuf->buffer2, p, DATA_PACKAGE);
> +		checkbuf->buffer2_empty = NULL;
> +		checkbuf->validdataB2 = validData;
> +		map[flowid].sched_data->statistic->buffer2_reloads++;
> +
> +	} else {
> +		printk("netem: flow %d: no empty buffer. data loss.\n", flowid);
> +		map[flowid].sched_data->statistic->noemptybuffer++;
> +	}
> +
> +	if (validData) {
> +		/* on initialization both buffers need data */
> +		if (checkbuf->buffer2_empty != NULL) {
> +			return DATA_PACKAGE_ID;
> +		}
> +		/* wait until new data is needed */
> +		wait_event(map[flowid].sched_data->my_event,
> +			   map[flowid].sched_data->newdataneeded);
> +		map[flowid].sched_data->newdataneeded = 0;
> +
> +	}
> +
> +	if (map[flowid].sched_data->tcnstop) {
> +		return -ECANCELED;
> +	}
> +
> +	return DATA_PACKAGE_ID;
> +
> +}
> +
> +static void tcn_flow_release(struct config_item *item)
> +{
> +	kfree(to_tcn_flow(item));
> +
> +}
> +
> +static struct configfs_item_operations tcn_flow_item_ops = {
> +	.release = tcn_flow_release,
> +	.store_attribute = tcn_flow_attr_store,
> +};
> +
> +static struct config_item_type tcn_flow_type = {
> +	.ct_item_ops = &tcn_flow_item_ops,
> +	.ct_attrs = tcn_flow_attrs,
> +	.ct_owner = THIS_MODULE,
> +};
> +
> +static struct config_item * tcn_make_item(struct config_group *group,
> +						     const char *name)
> +{
> +	struct tcn_flow *tcn_flow;
> +
> +	tcn_flow = kmalloc(sizeof(struct tcn_flow), GFP_KERNEL);
> +	if (!tcn_flow)
> +		return NULL;
> +
> +	memset(tcn_flow, 0, sizeof(struct tcn_flow));
> +
> +	config_item_init_type_name(&tcn_flow->item, name,
> +				   &tcn_flow_type);
> +	return &tcn_flow->item;
> +}
> +
> +static struct configfs_group_operations tcn_group_ops = {
> +	.make_item = tcn_make_item,
> +};
> +
> +static struct config_item_type tcn_type = {
> +	.ct_group_ops = &tcn_group_ops,
> +	.ct_owner = THIS_MODULE,
> +};
> +
> +static struct configfs_subsystem tcn_subsys = {
> +	.su_group = {
> +		     .cg_item = {
> +				 .ci_namebuf = "tcn",
> +				 .ci_type = &tcn_type,
> +				 },
> +		     },
> +};
> +
> +static __init int configfs_init(void)
> +{
> +	int ret;
> +	struct configfs_subsystem *subsys = &tcn_subsys;
> +
> +	config_group_init(&subsys->su_group);
> +	init_MUTEX(&subsys->su_sem);
> +	ret = configfs_register_subsystem(subsys);
> +	if (ret) {
> +		printk(KERN_ERR "Error %d while registering subsystem %s\n",
> +		       ret, subsys->su_group.cg_item.ci_namebuf);
> +		configfs_unregister_subsystem(&tcn_subsys);
> +	}
> +	return ret;
> +}
> +
> +static void configfs_exit(void)
> +{
> +	configfs_unregister_subsystem(&tcn_subsys);
> +}
> +
>  static struct Qdisc_class_ops netem_class_ops = {
>  	.graft		=	netem_graft,
>  	.leaf		=	netem_leaf,
> @@ -740,11 +1180,17 @@ static struct Qdisc_ops netem_qdisc_ops 
>  
>  static int __init netem_module_init(void)
>  {
> +	int err;
> +
>  	pr_info("netem: version " VERSION "\n");
> +	err = configfs_init();
> +	if (err)
> +		return err;
>  	return register_qdisc(&netem_qdisc_ops);
>  }
>  static void __exit netem_module_exit(void)
>  {
> +	configfs_exit();
>  	unregister_qdisc(&netem_qdisc_ops);
>  }
>  module_init(netem_module_init)
>   


