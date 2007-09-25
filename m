From: "john ye" <johny@asimco.com.cn>
Subject: Re: [PATCH: 2.6.13-15-SMP 3/3] network: concurrently runsoftirqnetwork code on SMP
Date: Tue, 25 Sep 2007 23:36:25 +0800
Message-ID: <007201c7ff89$d5db4cf0$d6ddfea9@JOHNYE1>
References: <004901c7fd9c$94370df0$d6ddfea9@JOHNYE1> <1190551422.4256.36.camel@localhost>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<kuznet@ms2.inr.ac.ru>, <pekkas@netcore.fi>, <jmorris@namei.org>,
	<kaber@coreworks.de>, <iceburgue@gmail.com>,
	"John Ye" <johny@asimco.com.cn>
To: <hadi@cyberus.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.asimco-na.com ([207.138.153.195]:37567 "EHLO
	mail.asimco-na.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758317AbXIYPfc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Sep 2007 11:35:32 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jamal,

You pointed out a key point: it's NOT acceptable if massive packet re-o=
rdering couldn=A1=AFt be avoided.
I debugged function tcp_ofo_queue in net/ipv4/tcp_input.c & monitored o=
ut_of_order_queue, found that re-ordering
becomes unacceptable with the softirq load grows.

It's simple to avoid out-of-order packets by changing random dispatch i=
nto dispatch based on source ip address.
e.g. cpu =3D iph->saddr % nr_cpus. while cpu is like a hash entry.
Considering that BS patch is mainly used on server with many incoming c=
onnections,
dispatch by IP should balance CPU load well.

The test is under way, it's not bad so far.
The queue spin_lock seems not cost much.

Below is the bcpp beautified module code. Last time code mess is caused=
 by outlook express which killed tabs.

Thanks.

John Ye



/*
 *  BOTTOM_SOFTIRQ_NET
 *              An implementation of bottom softirq concurrent executio=
n on SMP
 *              This is implemented by splitting current net softirq in=
to top half
 *              and bottom half, dispatch the bottom half to each cpu's=
 workqueue.
 *              Hopefully, it can raise the throughput of NIC when runn=
ing iptalbes
 *              on SMP machine.
 *
 *  Version:    $Id: bs_smp.c, v 2.6.13-15 for kernel 2.6.13-15-smp
 *
 *  Authors:    John Ye & QianYu Ye, 2007.08.27
 */

#include <asm/debugreg.h>
#include <asm/desc.h>
#include <asm/i387.h>
#include <asm/ldt.h>
#include <asm/pgtable.h>
#include <asm/processor.h>
#include <asm/system.h>
#include <asm/uaccess.h>
#include <asm/unaligned.h>
#include <linux/aio.h>
#include <linux/backing-dev.h>
#include <linux/bio.h>
#include <linux/buffer_head.h>
#include <linux/config.h>
#include <linux/delay.h>
#include <linux/devfs_fs_kernel.h>
#include <linux/device.h>
#include <linux/errno.h>
#include <linux/etherdevice.h>
#include <linux/fs.h>
#include <linux/highmem.h>
#include <linux/in.h>
#include <linux/inet.h>
#include <linux/inetdevice.h>
#include <linux/init.h>
#include <linux/input.h>
#include <linux/interrupt.h>
#include <linux/ipsec.h>
#include <linux/kernel.h>
#include <linux/kmod.h>
#include <linux/list.h>
#include <linux/major.h>
#include <linux/mm.h>
#include <linux/module.h>
#include <linux/moduleparam.h>
#include <linux/mroute.h>
#include <linux/net.h>
#include <linux/netdevice.h>
#include <linux/netfilter_ipv4.h>
#include <linux/netlink.h>
#include <linux/pagemap.h>
#include <linux/pm.h>
#include <linux/poll.h>
#include <linux/proc_fs.h>
#include <linux/ptrace.h>
#include <linux/random.h>
#include <linux/romfs_fs.h>
#include <linux/sched.h>
#include <linux/security.h>
#include <linux/skbuff.h>
#include <linux/slab.h>
#include <linux/smp.h>
#include <linux/smp_lock.h>
#include <linux/socket.h>
#include <linux/sockios.h>
#include <linux/string.h>
#include <linux/swap.h>
#include <linux/sysctl.h>
#include <linux/types.h>
#include <linux/user.h>
#include <linux/vfs.h>
#include <linux/workqueue.h>
#include <net/arp.h>
#include <net/checksum.h>
#include <net/icmp.h>
#include <net/inet_common.h>
#include <net/ip.h>
#include <net/protocol.h>
#include <net/raw.h>
#include <net/route.h>
#include <net/snmp.h>
#include <net/sock.h>
#include <net/tcp.h>
#include <net/xfrm.h>

static spinlock_t *p_ptype_lock;
static struct list_head *p_ptype_base;            /* 16 way hashed list=
 */

int (*Pip_options_rcv_srr)(struct sk_buff *skb);
int (*Pnf_rcv_postxfrm_nonlocal)(struct sk_buff *skb);
struct ip_rt_acct *ip_rt_acct;
struct ipv4_devconf *Pipv4_devconf;

#define ipv4_devconf (*Pipv4_devconf)
//#define ip_rt_acct Pip_rt_acct
#define ip_options_rcv_srr Pip_options_rcv_srr
#define nf_rcv_postxfrm_nonlocal Pnf_rcv_postxfrm_nonlocal
//extern int nf_rcv_postxfrm_local(struct sk_buff *skb);
//extern int ip_options_rcv_srr(struct sk_buff *skb);
static struct workqueue_struct **Pkeventd_wq;
#define keventd_wq (*Pkeventd_wq)

#define INSERT_CODE_HERE

static inline int ip_rcv_finish(struct sk_buff *skb)
{
        struct net_device *dev =3D skb->dev;
        struct iphdr *iph =3D skb->nh.iph;
        int err;

        /*
         * Initialise the virtual path cache for the packet. It describ=
es
         * how the packet travels inside Linux networking.
         */
        if (skb->dst =3D=3D NULL)
        {
                if ((err =3D ip_route_input(skb, iph->daddr, iph->saddr=
, iph->tos, dev)))
                {
                        if (err =3D=3D -EHOSTUNREACH)
                                IP_INC_STATS_BH(IPSTATS_MIB_INADDRERROR=
S);
                        goto drop;
                }
        }

        if (nf_xfrm_nonlocal_done(skb))
                return nf_rcv_postxfrm_nonlocal(skb);

#ifdef CONFIG_NET_CLS_ROUTE
        if (skb->dst->tclassid)
        {
                struct ip_rt_acct *st =3D ip_rt_acct + 256*smp_processo=
r_id();
                u32 idx =3D skb->dst->tclassid;
                st[idx&0xFF].o_packets++;
                st[idx&0xFF].o_bytes+=3Dskb->len;
                st[(idx>>16)&0xFF].i_packets++;
                st[(idx>>16)&0xFF].i_bytes+=3Dskb->len;
        }
#endif

        if (iph->ihl > 5)
        {
                struct ip_options *opt;

                /* It looks as overkill, because not all
                   IP options require packet mangling.
                   But it is the easiest for now, especially taking
                   into account that combination of IP options
                   and running sniffer is extremely rare condition.
                                                      --ANK (980813)
                */

                if (skb_cow(skb, skb_headroom(skb)))
                {
                        IP_INC_STATS_BH(IPSTATS_MIB_INDISCARDS);
                        goto drop;
                }
                iph =3D skb->nh.iph;

                if (ip_options_compile(NULL, skb))
                        goto inhdr_error;

                opt =3D &(IPCB(skb)->opt);
                if (opt->srr)
                {
                        struct in_device *in_dev =3D in_dev_get(dev);
                        if (in_dev)
                        {
                                if (!IN_DEV_SOURCE_ROUTE(in_dev))
                                {
                                        if (IN_DEV_LOG_MARTIANS(in_dev)=
 && net_ratelimit())
                                                printk(KERN_INFO "sourc=
e route option %u.%u.%u.%u -> %u.%u.%u.%u\n",
                                                        NIPQUAD(iph->sa=
ddr), NIPQUAD(iph->daddr));
                                        in_dev_put(in_dev);
                                        goto drop;
                                }
                                in_dev_put(in_dev);
                        }
                        if (ip_options_rcv_srr(skb))
                                goto drop;
                }
        }

        return dst_input(skb);

        inhdr_error:
        IP_INC_STATS_BH(IPSTATS_MIB_INHDRERRORS);
        drop:
        kfree_skb(skb);
        return NET_RX_DROP;
}


#define CONFIG_BOTTOM_SOFTIRQ_SMP
#define CONFIG_BOTTOM_SOFTIRQ_SMP_SYSCTL

#ifdef CONFIG_BOTTOM_SOFTIRQ_SMP

#ifdef COMMENT____________
/*
[PATCH: 2.6.13-15-SMP 1/2] network: concurrently run softirq network co=
de on SMP
Bottom Softirq Implementation. John Ye, 2007.08.27

Why this patch:
Make kernel be able to concurrently execute softirq's net code on SMP s=
ystem.
Take full advantages of SMP to handle more packets and greatly raises N=
IC throughput.
The current kernel's net packet processing logic is:
1) The CPU which handles a hardirq must be executing its related softir=
q.
2) One softirq instance(irqs handled by 1 CPU) can't be executed on mor=
e than 2 CPUs
at the same time.
The limitation make kernel network be hard to take the advantages of SM=
P.

How this patch:
It splits the current softirq code into 2 parts: the cpu-sensitive top =
half,
and the cpu-insensitive bottom half, then make bottom half(calld BS) be
executed on SMP concurrently.
The two parts are not equal in terms of size and load. Top part has con=
stant code
size(mainly, in net/core/dev.c and NIC drivers), while bottom part invo=
lves
netfilter(iptables) whose load varies very much. An iptalbes with 1000 =
rules to match
will make the bottom part's load be very high. So, if the bottom part s=
oftirq
can be distributed to processors and run concurrently on them, the netw=
ork will
gain much more packet handling capacity, network throughput will be be =
increased
remarkably.

Where useful:
It's useful on SMP machines that meet the following 2 conditions:
1) have high kernel network load, for example, running iptables with th=
ousands of rules, etc).
2) have more CPUs than active NICs, e.g. a 4 CPUs machine with 2 NICs).
On these system, with the increase of softirq load, some CPUs will be i=
dle
while others(number is equal to # of NIC) keeps busy.
IRQBALANCE will help, but it only shifts IRQ among CPUS, makes no softi=
rq concurrency.
Balancing the load of each cpus will not remarkably increase network sp=
eed.

Where NOT useful:
If the bottom half of softirq is too small(without running iptables), o=
r the network
is too idle, BS patch will not be seen to have visible effect. But It h=
as no
negative affect either.
User can turn on/off BS functionality by /proc/sys/net/bs_enable switch=
=2E

How to test:
On a linux box, run iptables, add 2000 rules to table filter & table na=
t to simulate huge
softirq load. Then, open 20 ftp sessions to download big file. On anoth=
er machine(who
use this test machine as gateway), open 20 more ftp download sessions. =
Compare the speed,
without BS enabled, and with BS enabled.
cat /proc/sys/net/bs_enable. this is a switch to turn on/off BS
cat /proc/sys/net/bs_status. this shows the usage of each CPUs
Test shown that when bottom softirq load is high, the network throughpu=
t can be nearly
doubled on 2 CPUs machine. hopefully it may be quadrupled on a 4 cpus l=
inux box.

Bugs:
It will NOT allow hotplug CPU.
It only allows incremental CPUs ids, starting from 0 to num_online_cpus=
().
for example, 0,1,2,3 is OK. 0,1,8,9 is KO.

Some considerations in the future:
1) With BS patch, the irq balance code on arch/i386/kernel/io_apic.c se=
ems no need any more,
at least not for network irq.
2) Softirq load will become very small. It only run the top half of old=
 softirq, which
is much less expensive than bottom half---the netfilter program.
To let top softirq process more packets, can these 3 network parameters=
 be given a larger value?
extern int netdev_max_backlog =3D 1000;
extern int netdev_budget =3D 300;
extern int weight_p =3D 64;
3) Now, BS are running on built-in keventd thread, we can create new wo=
rkqueues to let it run on?

Signed-off-by: John Ye (Seeker) <johny@asimco.com.cn>
*/
#endif

#define BS_USE_PERCPU_DATA
struct cpu_stat
{
        unsigned long irqs;                       //total irqs
        unsigned long dids;                       //I did,
        unsigned long others;
        unsigned long works;
};
#define BS_CPU_STAT_DEFINED

static int nr_cpus =3D 0;
static int bs_enable =3D 1;

#define BS_POL_SRCIP    1
#define BS_POL_RANDOM   2
static int bs_policy =3D BS_POL_SRCIP;

                                                  // cacheline_aligned_=
in_smp;
static DEFINE_PER_CPU(struct sk_buff_head, bs_cpu_queues);
static DEFINE_PER_CPU(struct work_struct, bs_works);
//static DEFINE_PER_CPU(struct cpu_stat, bs_cpu_status);
struct cpu_stat bs_cpu_status[NR_CPUS];

static int ip_rcv1(struct sk_buff *skb, struct net_device *dev)
{
        return NF_HOOK_COND(PF_INET, NF_IP_PRE_ROUTING, skb, dev, NULL,=
 ip_rcv_finish, nf_hook_input_cond(skb));
}


static void bs_func(void *data)
{
        int flags, num, cpu;
        struct sk_buff *skb;
        struct work_struct *bs_works;
        struct sk_buff_head *q;
        cpu =3D smp_processor_id();

        bs_works =3D &per_cpu(bs_works, cpu);
        q =3D &per_cpu(bs_cpu_queues, cpu);

        local_bh_disable();
        restart:

        num =3D 0;
        while(1)
        {
                spin_lock_irqsave(&q->lock, flags);
                skb =3D __skb_dequeue(q);
                spin_unlock_irqrestore(&q->lock, flags);
                if(!skb) break;
                num++;

                /* local_bh_disable(); */
                ip_rcv1(skb, skb->dev);
                /* __local_bh_enable(); */      // sub_preempt_count(SO=
=46TIRQ_OFFSET - 1);
        }

        bs_cpu_status[cpu].others +=3D num;
        // if(num > 2) printk("%d %d\n", num, cpu);
        if(num > 0)
                goto restart;

        __local_bh_enable();
        bs_works->func =3D 0;

        return;
}


/* COPY_IN_START_FROM kernel/workqueue.c */
struct cpu_workqueue_struct
{

        spinlock_t lock;

        long remove_sequence;                     /* Least-recently add=
ed (next to run) */
        long insert_sequence;                     /* Next to add */

        struct list_head worklist;
        wait_queue_head_t more_work;
        wait_queue_head_t work_done;

        struct workqueue_struct *wq;
        task_t *thread;

        int run_depth;                            /* Detect run_workque=
ue() recursion depth */
} ____cacheline_aligned;

struct workqueue_struct
{
        struct cpu_workqueue_struct cpu_wq[NR_CPUS];
        const char *name;
        struct list_head list;                    /* Empty if single th=
read */
};
/* COPY_IN_END_FROM kernel/worqueue.c */

extern struct workqueue_struct *keventd_wq;

/* Preempt must be disabled. */
static void __queue_work(struct cpu_workqueue_struct *cwq,
struct work_struct *work)
{
        unsigned long flags;

        spin_lock_irqsave(&cwq->lock, flags);
        work->wq_data =3D cwq;
        list_add_tail(&work->entry, &cwq->worklist);
        cwq->insert_sequence++;
        wake_up(&cwq->more_work);
        spin_unlock_irqrestore(&cwq->lock, flags);
}
#endif                                            //CONFIG_BOTTOM_SOFTI=
RQ_SMP

/*
 * Main IP Receive routine.
 */
/* hard irq are in CPU1, why this get called from CPU0?, __do_IRQ() did=
 so?
 *
 */
int REP_ip_rcv(struct sk_buff *skb, struct net_device *dev, struct pack=
et_type *pt)
{
        struct iphdr *iph;

        /* When the interface is in promisc. mode, drop all the crap
         * that it receives, do not try to analyse it.
         */
        if (skb->pkt_type =3D=3D PACKET_OTHERHOST)
                goto drop;

        IP_INC_STATS_BH(IPSTATS_MIB_INRECEIVES);

        if ((skb =3D skb_share_check(skb, GFP_ATOMIC)) =3D=3D NULL)
        {
                IP_INC_STATS_BH(IPSTATS_MIB_INDISCARDS);
                goto out;
        }

        if (!pskb_may_pull(skb, sizeof(struct iphdr)))
                goto inhdr_error;

        iph =3D skb->nh.iph;

        /*
         * RFC1122: 3.1.2.2 MUST silently discard any IP frame that fai=
ls the checksum.
         *
         * Is the datagram acceptable?
         *
         * 1. Length at least the size of an ip header
         * 2. Version of 4
         * 3. Checksums correctly. [Speed optimisation for later, skip =
loopback checksums]
         * 4. Doesn't have a bogus length
         */

        if (iph->ihl < 5 || iph->version !=3D 4)
                goto inhdr_error;

        if (!pskb_may_pull(skb, iph->ihl*4))
                goto inhdr_error;

        iph =3D skb->nh.iph;

        if (ip_fast_csum((u8 *)iph, iph->ihl) !=3D 0)
                goto inhdr_error;

        {
                __u32 len =3D ntohs(iph->tot_len);
                if (skb->len < len || len < (iph->ihl<<2))
                        goto inhdr_error;

                /* Our transport medium may have padded the buffer out.=
 Now we know it
                 * is IP we can trim to the true length of the frame.
                 * Note this now means skb->len holds ntohs(iph->tot_le=
n).
                 */
                if (pskb_trim_rcsum(skb, len))
                {
                        IP_INC_STATS_BH(IPSTATS_MIB_INDISCARDS);
                        goto drop;
                }
        }

#ifdef CONFIG_BOTTOM_SOFTIRQ_SMP
        if(!nr_cpus)
                nr_cpus =3D num_online_cpus();

        if(bs_enable && nr_cpus > 1 && iph->protocol !=3D IPPROTO_ICMP)
        {
                unsigned int flags, cur, cpu;
                struct work_struct *bs_works;
                struct sk_buff_head *q;

                cur =3D smp_processor_id();

                bs_cpu_status[cur].irqs++;

                /*
                 * good point from Jamal. thanks no reordering
                 */
                if(bs_policy =3D=3D BS_POL_SRCIP)
                        cpu =3D iph->saddr % nr_cpus;

                /* random distribute. for speed test */
                else if(bs_policy =3D=3D BS_POL_RANDOM)
                        cpu =3D (bs_cpu_status[cur].irqs % nr_cpus);

                if(cpu =3D=3D cur)
                {
                        bs_cpu_status[cpu].dids++;
                        return ip_rcv1(skb, dev);
                }

                q =3D &per_cpu(bs_cpu_queues, cpu);

                if(!q->next)
                        skb_queue_head_init(q);

                bs_works =3D &per_cpu(bs_works, cpu);

                spin_lock_irqsave(&q->lock, flags);
                __skb_queue_tail(q, skb);
                spin_unlock_irqrestore(&q->lock, flags);

                if (!bs_works->func)
                {
                        INIT_WORK(bs_works, bs_func, q);
                        bs_cpu_status[cpu].works++;
                        preempt_disable();
                        __queue_work(keventd_wq->cpu_wq + cpu, bs_works=
);
                        preempt_enable();
                }
        }
        else
        {
                int cpu =3D smp_processor_id();
                bs_cpu_status[cpu].irqs++;
                bs_cpu_status[cpu].dids++;
                return ip_rcv1(skb, dev);
        }
        return 0;
#else
        return NF_HOOK_COND(PF_INET, NF_IP_PRE_ROUTING, skb, dev, NULL,=
 ip_rcv_finish, nf_hook_input_cond(skb));
#endif                                    /* CONFIG_BOTTOM_SOFTIRQ_SMP =
*/

        inhdr_error:
        IP_INC_STATS_BH(IPSTATS_MIB_INHDRERRORS);
        drop:
        kfree_skb(skb);
        out:
        return NET_RX_DROP;
}


/*
 * for standard patch, those lines should be moved into ../../net/sysct=
l_net.c
 */

/* COPY_OUT_START_TO net/sysctl_net.c */
#ifdef CONFIG_BOTTOM_SOFTIRQ_SMP_SYSCTL
#if !defined(BS_CPU_STAT_DEFINED)
struct cpu_stat
{
        unsigned long irqs;                       /* total irqs on me *=
/
        unsigned long dids;                       /* I did, */
        unsigned long others;                     /* other did, */
        unsigned long works;                      /* q works */
};
#endif
extern struct cpu_stat bs_cpu_status[NR_CPUS];

extern int bs_enable;
/* COPY_OUT_END_TO net/sysctl_net.c */

static ctl_table bs_ctl_table[] =3D
{
        /* COPY_OUT_START_TO net/sysctl_net.c */
        {
                .ctl_name       =3D 99,
                .procname       =3D "bs_status",
                .data           =3D &bs_cpu_status,
                .maxlen         =3D sizeof(bs_cpu_status),
                .mode           =3D 0644,
                .proc_handler   =3D &proc_dointvec,
        },
        {
                .ctl_name       =3D 99,
                .procname       =3D "bs_policy",
                .data           =3D &bs_policy,
                .maxlen         =3D sizeof(int),
                .mode           =3D 0644,
                .proc_handler   =3D &proc_dointvec,
        },
        {
                .ctl_name       =3D 99,
                .procname       =3D "bs_enable",
                .data           =3D &bs_enable,
                .maxlen         =3D sizeof(int),
                .mode           =3D 0644,
                .proc_handler   =3D &proc_dointvec,
        },
        /* COPY_OUT_END_TO net/net_sysctl.c */

        { 0, },
};

static ctl_table bs_sysctl_root[] =3D
{
        {
                .ctl_name       =3D CTL_NET,
                .procname       =3D "net",
                .mode           =3D 0555,
                .child          =3D bs_ctl_table,
        },
        { 0, },
};

struct ctl_table_header *bs_sysctl_hdr;
register_bs_sysctl(void)
{
        bs_sysctl_hdr =3D register_sysctl_table(bs_sysctl_root, 0);
        return 0;
}


unregister_bs_sysctl(void)
{
        unregister_sysctl_table(bs_sysctl_hdr);
}
#endif                                            //CONFIG_BOTTOM_SOFTI=
RQ_SMP_SYSCTL

seeker_init()
{
        int i;
        if(nr_cpus =3D=3D 0)
                nr_cpus =3D num_online_cpus();
        register_bs_sysctl();
}


seeker_exit()
{
        unsigned long now;
        unregister_bs_sysctl();
        bs_enable =3D 0;
        msleep(1000);
        flush_scheduled_work();
        now =3D jiffies;
        msleep(1000);
        printk("%u exited.\n", jiffies - now);
}


/*---------------------------------------------------------------------=
-----
 */
struct packet_type *dev_find_pack(int type)
{
        struct list_head *head;
        struct packet_type *pt1;

        spin_lock_bh(p_ptype_lock);

        head =3D &p_ptype_base[type & 15];

        list_for_each_entry(pt1, head, list)
        {
                if (pt1->type =3D=3D htons(type))
                {
                        goto out;
                }
        }
        pt1 =3D 0;
        printk( "ERROR: dev_remove_pack: %p not found. type %x %x %x\n"=
, pt1, type, ETH_P_IP, htons(ETH_P_IP));
        out:
        spin_unlock_bh(p_ptype_lock);
        return pt1;
}


static char system_map[128] =3D "/boot/System.map-";
static unsigned long sysmap_size;
static char *sysmap_buf;

unsigned long sysmap_name2addr(char *name)
{
        char *cp, *dp;
        unsigned long addr;
        int len, n;

        if(!sysmap_buf) return 0;
        if(!name || !name[0]) return 0;
        n =3D strlen(name);
        for(cp =3D sysmap_buf; ;)
        {
                cp =3D strstr(cp, name);
                if(!cp) return 0;

                for(dp =3D cp; *dp && *dp !=3D '\n' && *dp !=3D ' ' && =
*dp !=3D '\t'; dp++);

                len =3D dp - cp;
                if(len < n) goto cont;
                if(cp > sysmap_buf && cp[-1] !=3D ' ' && cp[-1] !=3D '\=
t')
                {
                        goto cont;
                }
                if(len > n)
                {
                        goto cont;
                }
                break;
                cont:
                if(*dp =3D=3D 0) break;
                cp +=3D (len+1);
        }

        cp -=3D 11;
        if(cp > sysmap_buf && cp[-1] !=3D '\n')
        {
                printk("_ERROR_ in name2addr cp =3D %p base %p\n", cp, =
sysmap_buf);
                return 0;
        }
        sscanf(cp, "%x", &addr);
        return addr;
}


static int kas_init()
{
        struct file *fp;
        int i;
        long addr;
        struct kstat st;
        mm_segment_t old_fs;

        strcat(system_map, system_utsname.release);

        old_fs =3D get_fs();
        set_fs(get_ds());                         /* systemp_map is __u=
ser variable */
        i =3D vfs_stat(system_map, &st);
        set_fs(old_fs);
        if(i) return 1;

        sysmap_size =3D st.size + 32;
        fp =3D filp_open(system_map, O_RDONLY, FMODE_READ);
        if(!fp) return 1;

        sysmap_buf =3D vmalloc(sysmap_size);
        if(!sysmap_buf) return 2;
        i =3D kernel_read(fp, 0, sysmap_buf, sysmap_size);
        if(i <=3D 0)
        {
                filp_close(fp, 0);
                vfree(sysmap_buf);
                sysmap_buf =3D 0;
                return 3;
        }
        sysmap_size =3D i;
        *(int*)&sysmap_buf[i] =3D 0;
        filp_close(fp, 0);

        p_ptype_lock =3D sysmap_name2addr("ptype_lock");
        p_ptype_base =3D sysmap_name2addr("ptype_base");
        Pkeventd_wq =3D sysmap_name2addr("keventd_wq");
        Pip_options_rcv_srr =3D sysmap_name2addr("ip_options_rcv_srr");
        Pnf_rcv_postxfrm_nonlocal =3D sysmap_name2addr("nf_rcv_postxfrm=
_nonlocal");
        ip_rt_acct =3D sysmap_name2addr("ip_rt_acct");
        Pipv4_devconf =3D sysmap_name2addr("ipv4_devconf");
        vfree(sysmap_buf);
        return 0;

}


struct packet_type *ip_handler;
static int  __init init()
{
        struct packet_type *pt;

        if(kas_init())
                return -1;
        pt =3D dev_find_pack(ETH_P_IP);
        if(!pt)
                return -1;
        /*printk("pt %p func ip_rcv %p should be %p\n", pt, pt->func, i=
p_rcv);
         */

        lock_kernel();
        if(pt->func =3D=3D ip_rcv)
        {
                pt->func =3D REP_ip_rcv;
                ip_handler =3D pt;
        }
        else
        {
                printk("error: can't find handler.\n");
                ip_handler =3D pt;
                unlock_kernel();
                return -1;
        }
        unlock_kernel();
        seeker_init();
        return 0;
}


static void __exit exit(void)
{
        seeker_exit();
        lock_kernel();
        if(ip_handler->func =3D=3D REP_ip_rcv)
                ip_handler->func =3D ip_rcv;
        else
                printk("error...\n");
        unlock_kernel();
}


module_init(init)
module_exit(exit)
MODULE_LICENSE("GPL");=20


