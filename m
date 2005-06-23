From: Arthur Kepner <akepner@sgi.com>
Subject: [RFC/PATCH] "safer ipv4 reassembly" (fwd)
Date: Thu, 23 Jun 2005 09:33:35 -0700 (PDT)
Message-ID: <Pine.LNX.4.61.0506230930350.15406@resonance.WorkGroup>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Rick Jones <rick.jones2@hp.com>, Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


What with the recent migration to vger.kernel.org, I'm 
forwarding this to oss.sgi.com, just in case any interested 
parties missed it.

---------- Forwarded message ----------
Date: Wed, 22 Jun 2005 16:00:55 -0700 (PDT)
From: Arthur Kepner <akepner@sgi.com>
To: netdev@vger.kernel.org
Subject: [RFC/PATCH] "safer ipv4 reassembly"


A little more than a month ago I sent a RFC/PATCH for 
something I called "strict ipv4 reassembly". This was 
an attempt to make it much less likely that IP fragments 
from different IP datagrams were reassembled together 
when the IP id wraps. That patch was considered 
unacceptable because it required fragments to arrive in 
order or they'd be dropped. 

One idea that resulted from that thread was to keep a 
count of IP datagrams for a (src,dst,proto) and use that 
as a kind of sequence number to check that a fragment is 
valid. (I believe that Rick Jones and Herbert Xu each 
independently came up with this idea, or something very 
close to it.)

Following is a patch which implements that idea. 

A new sysctl "sysctl_ip_reassembly_count" is used to control 
how much reordering of IP fragments we'll tolerate. If it's 
zero, the patch is a no-op. If sysctl_ip_reassembly_count is 
non-zero, it defines a "window size" for IP fragments. When 
a new fragment queue is made, the "bottom" of the window is 
defined by the number if IP packets which have been received 
for the associated (src,dst,proto), and each time a fragment 
is added to the queue, the bottom of the window is advanced. 
But before adding a fragment to the queue, a check is made 
that the number of IP fragments in the queue falls within the 
window. If not, the queue is dropped. 

Comments?

 include/linux/sysctl.h     |    1
 include/net/ip.h           |    1
 net/ipv4/ip_fragment.c     |  206 +++++++++++++++++++++++++++++++++++++++++++++
 net/ipv4/ip_input.c        |   24 ++++-
 net/ipv4/sysctl_net_ipv4.c |   11 ++
 5 files changed, 240 insertions(+), 3 deletions(-)

Signed-off-by: Arthur Kepner <akepner@sgi.com>

diff -rup linux.orig/include/linux/sysctl.h linux.new/include/linux/sysctl.h
--- linux.orig/include/linux/sysctl.h	2005-06-14 11:35:18.611069887 -0700
+++ linux.new/include/linux/sysctl.h	2005-06-22 14:04:17.384853993 -0700
@@ -347,6 +347,7 @@ enum
 	NET_TCP_MODERATE_RCVBUF=106,
 	NET_TCP_TSO_WIN_DIVISOR=107,
 	NET_TCP_BIC_BETA=108,
+	NET_IPV4_REASM_COUNT=109,
 };
 
 enum {
diff -rup linux.orig/include/net/ip.h linux.new/include/net/ip.h
--- linux.orig/include/net/ip.h	2005-06-14 11:52:09.878700520 -0700
+++ linux.new/include/net/ip.h	2005-06-22 14:04:33.508057469 -0700
@@ -300,6 +300,7 @@ enum ip_defrag_users
 };
 
 struct sk_buff *ip_defrag(struct sk_buff *skb, u32 user);
+void ip_count(u32 saddr, u32 daddr, u8 protocol);
 extern int ip_frag_nqueues;
 extern atomic_t ip_frag_mem;
 
diff -rup linux.orig/net/ipv4/ip_fragment.c linux.new/net/ipv4/ip_fragment.c
--- linux.orig/net/ipv4/ip_fragment.c	2005-06-13 16:49:55.290992303 -0700
+++ linux.new/net/ipv4/ip_fragment.c	2005-06-22 14:17:54.136940893 -0700
@@ -56,6 +56,8 @@
 int sysctl_ipfrag_high_thresh = 256*1024;
 int sysctl_ipfrag_low_thresh = 192*1024;
 
+extern int sysctl_ip_reassembly_count;
+
 /* Important NOTE! Fragment queue must be destroyed before MSL expires.
  * RFC791 is wrong proposing to prolongate timer each fragment arrival by TTL.
  */
@@ -69,6 +71,25 @@ struct ipfrag_skb_cb
 
 #define FRAG_CB(skb)	((struct ipfrag_skb_cb*)((skb)->cb))
 
+/* struct ipc contains a count of the number of IP datagrams 
+ * received for a (saddr, daddr, protocol) tuple - but one of 
+ * these structures exists for a given (saddr, daddr, protocol) 
+ * if and only if there is a queue of IP fragments associated 
+ * with that 3-tuple and sysctl_ip_reassembly_count is non-zero.
+ */
+struct ipc {
+	struct hlist_node	node;
+	u32			saddr;
+	u32			daddr;
+	u8			protocol;
+	atomic_t		refcnt;	/* how many ipqs hold refs to us */
+	atomic_t		seq;	/* how many ip datagrams for this 
+					 * (saddr,daddr,protocol) since we 
+					 * were created */
+	struct timer_list	timer;
+	struct rcu_head		rcu;
+};
+
 /* Describe an entry in the "incomplete datagrams" queue. */
 struct ipq {
 	struct ipq	*next;		/* linked list pointers			*/
@@ -92,6 +113,14 @@ struct ipq {
 	struct ipq	**pprev;
 	int		iif;
 	struct timeval	stamp;
+	struct ipc	*ipc;
+	atomic_t	seq;		
+	/* ipq->seq defines the "bottom" of the window of sequence numbers 
+	 * that are valid for this fragment - the "top" of the window is 
+	 * (ipq->seq + sysctl_ip_reassembly_count). ipq->seq is initialized
+	 * to the value in the associated ipc when the fragment queue is 
+	 * created, and incremented each time a fragment is added to the 
+	 * queue */
 };
 
 /* Hash table. */
@@ -105,6 +134,12 @@ static u32 ipfrag_hash_rnd;
 static LIST_HEAD(ipq_lru_list);
 int ip_frag_nqueues = 0;
 
+#define IPC_HASHSZ	IPQ_HASHSZ
+static struct {
+	struct hlist_head head;
+	spinlock_t lock;
+} ipc_hash[IPC_HASHSZ];
+
 static __inline__ void __ipq_unlink(struct ipq *qp)
 {
 	if(qp->next)
@@ -121,6 +156,11 @@ static __inline__ void ipq_unlink(struct
 	write_unlock(&ipfrag_lock);
 }
 
+static unsigned int ipchashfn(u32 saddr, u32 daddr, u8 prot)
+{
+	return jhash_3words(prot, saddr, daddr, 0) & (IPC_HASHSZ - 1);
+}
+
 static unsigned int ipqhashfn(u16 id, u32 saddr, u32 daddr, u8 prot)
 {
 	return jhash_3words((u32)id << 16 | prot, saddr, daddr,
@@ -231,8 +271,16 @@ static __inline__ void ipq_put(struct ip
  */
 static void ipq_kill(struct ipq *ipq)
 {
+	struct ipc *cp = ipq->ipc;
+
 	if (del_timer(&ipq->timer))
 		atomic_dec(&ipq->refcnt);
+	if (cp) {
+		atomic_dec(&cp->refcnt);
+		/* no particular reason to use sysctl_ipfrag_time 
+		 * for this timer */
+		mod_timer(&cp->timer, jiffies + sysctl_ipfrag_time);
+	}
 
 	if (!(ipq->last_in & COMPLETE)) {
 		ipq_unlink(ipq);
@@ -348,10 +396,109 @@ static struct ipq *ip_frag_intern(unsign
 	return qp;
 }
 
+static inline void __ipc_destroy(struct rcu_head *head)
+{
+	kfree(container_of(head, struct ipc, rcu));
+}
+
+static void ipc_destroy(unsigned long arg) 
+{
+	struct ipc *cp = (struct ipc *) arg;
+	unsigned int hash = ipchashfn(cp->saddr, cp->daddr, cp->protocol);
+
+	spin_lock(&ipc_hash[hash].lock);
+	BUG_ON((atomic_read(&cp->refcnt)) < 0);
+	if (atomic_read(&cp->refcnt) == 0) {
+		hlist_del_rcu(&cp->node);
+		call_rcu(&cp->rcu, __ipc_destroy);
+	}
+	spin_unlock(&ipc_hash[hash].lock);
+}
+
+/* 
+ * must hold spinlock for the appropriate hash list head when 
+ * __ipc_create is called 
+ */
+
+static inline struct ipc *__ipc_create(struct iphdr *iph, 
+				       const unsigned int hash) 
+{
+	struct ipc *cp = kmalloc(sizeof(struct ipc), GFP_ATOMIC);
+	/* XXX should we account size to ip_frag_mem ??? */
+	if (cp) {
+		cp->saddr = iph->saddr;
+		cp->daddr = iph->daddr;
+		cp->protocol = iph->protocol;
+		atomic_set(&cp->seq, 0);
+		atomic_set(&cp->refcnt, 1);
+		INIT_HLIST_NODE(&cp->node);
+		hlist_add_head_rcu(&cp->node, &ipc_hash[hash].head);
+		init_timer(&cp->timer);
+		cp->timer.data = (unsigned long) cp;
+		cp->timer.function = ipc_destroy;
+	} else {
+		NETDEBUG(if (net_ratelimit()) 
+			printk(KERN_ERR "__ipc_create: no memory left !\n"));
+	}
+	return cp;
+}
+
+/* 
+ * must be "rcu safe" when __ipc_find is called - either use 
+ * rcu_read_lock (if you intend only to read the returned struct) 
+ * or grab the spinlock for the appropriate hash list head (if 
+ * you might modify the returned struct) 
+ */
+static inline struct ipc *__ipc_find(u32 saddr, u32 daddr, u8 protocol, 
+				     const unsigned int hash)
+{
+	struct hlist_node *p;
+
+	hlist_for_each_rcu(p, &ipc_hash[hash].head) {
+		struct ipc * cp = (struct ipc *)p;
+		if(cp->saddr == saddr &&
+		   cp->daddr == daddr &&
+		   cp->protocol == protocol) {
+			return cp;
+		}
+	}
+	return NULL;
+}
+
+static struct ipc *ipc_find(struct iphdr *iph)
+{
+	struct ipc *cp;
+	unsigned int hash = ipchashfn(iph->saddr, iph->daddr, iph->protocol);
+
+	rcu_read_lock();
+	if((cp = __ipc_find(iph->saddr, iph->daddr, 
+			    iph->protocol, hash)) != NULL) {
+		atomic_inc(&cp->refcnt);
+		rcu_read_unlock();
+		return cp;
+	}
+	rcu_read_unlock();
+	spin_lock(&ipc_hash[hash].lock);
+	if((cp = __ipc_find(iph->saddr, iph->daddr, 
+			    iph->protocol, hash)) != NULL) {
+		atomic_inc(&cp->refcnt);
+		spin_unlock(&ipc_hash[hash].lock);
+		return cp;
+	}
+	cp = __ipc_create(iph, hash);
+	spin_unlock(&ipc_hash[hash].lock);
+	return cp;
+}
+
+
 /* Add an entry to the 'ipq' queue for a newly received IP datagram. */
 static struct ipq *ip_frag_create(unsigned hash, struct iphdr *iph, u32 user)
 {
 	struct ipq *qp;
+	struct ipc *cp = NULL;
+
+	if (sysctl_ip_reassembly_count && (cp = ipc_find(iph)) == NULL)
+		return NULL;
 
 	if ((qp = frag_alloc_queue()) == NULL)
 		goto out_nomem;
@@ -366,6 +513,10 @@ static struct ipq *ip_frag_create(unsign
 	qp->meat = 0;
 	qp->fragments = NULL;
 	qp->iif = 0;
+	qp->ipc = cp;
+	if (sysctl_ip_reassembly_count && cp) {
+		atomic_set(&qp->seq, atomic_read(&cp->seq));
+	}
 
 	/* Initialize a timer for this entry. */
 	init_timer(&qp->timer);
@@ -381,6 +532,51 @@ out_nomem:
 	return NULL;
 }
 
+void ip_count(u32 saddr, u32 daddr, u8 protocol)
+{
+	struct ipc *cp = NULL;
+	unsigned int hash = ipchashfn(saddr, daddr, protocol);
+
+	rcu_read_lock();
+	if((cp = __ipc_find(saddr, daddr, protocol, hash)) != NULL) {
+		atomic_inc(&cp->seq);
+	}
+	rcu_read_unlock();
+}
+
+static inline int in_window(int bottom, int size, int seq) {
+	return (((seq - bottom) >= 0) && ((seq - (bottom + size)) < 0));
+}
+
+static int __ip_reassembly_count_check(const struct iphdr *iph, struct ipq *qp)
+{
+	struct ipc *cp = qp->ipc;
+	int cseq, qseq;
+
+	/* qp->ipc may be NULL if sysctl_ip_reassembly_count was off 
+	 * at the time the fragment queue was created */
+	if (cp == NULL)
+		return 0;
+
+	cseq = atomic_read(&cp->seq);
+	qseq = atomic_inc_return(&qp->seq);
+
+	if (!in_window(qseq, sysctl_ip_reassembly_count, cseq)) {
+		atomic_inc(&qp->refcnt);
+		read_unlock(&ipfrag_lock);
+		spin_lock(&qp->lock);
+		if (!(qp->last_in&COMPLETE))
+			ipq_kill(qp);
+		spin_unlock(&qp->lock);
+		ipq_put(qp, NULL);
+		IP_INC_STATS_BH(IPSTATS_MIB_REASMFAILS);
+		read_lock(&ipfrag_lock);
+		return 1;
+	}
+	return 0;
+}
+
+
 /* Find the correct entry in the "incomplete datagrams" queue for
  * this IP datagram, and create new one, if nothing is found.
  */
@@ -400,6 +596,10 @@ static inline struct ipq *ip_find(struct
 		   qp->daddr == daddr	&&
 		   qp->protocol == protocol &&
 		   qp->user == user) {
+			if (sysctl_ip_reassembly_count &&
+				__ip_reassembly_count_check(iph, qp)) {
+				break;
+			}
 			atomic_inc(&qp->refcnt);
 			read_unlock(&ipfrag_lock);
 			return qp;
@@ -679,9 +879,15 @@ struct sk_buff *ip_defrag(struct sk_buff
 
 void ipfrag_init(void)
 {
+	int i;
 	ipfrag_hash_rnd = (u32) ((num_physpages ^ (num_physpages>>7)) ^
 				 (jiffies ^ (jiffies >> 6)));
 
+	for (i = 0; i < IPC_HASHSZ; i++ ) {
+		INIT_HLIST_HEAD(&ipc_hash[i].head);
+		spin_lock_init(&ipc_hash[i].lock);
+	}
+
 	init_timer(&ipfrag_secret_timer);
 	ipfrag_secret_timer.function = ipfrag_secret_rebuild;
 	ipfrag_secret_timer.expires = jiffies + sysctl_ipfrag_secret_interval;
diff -rup linux.orig/net/ipv4/ip_input.c linux.new/net/ipv4/ip_input.c
--- linux.orig/net/ipv4/ip_input.c	2005-06-13 16:23:41.824620856 -0700
+++ linux.new/net/ipv4/ip_input.c	2005-06-22 14:02:35.705155734 -0700
@@ -146,6 +146,14 @@
 #include <linux/mroute.h>
 #include <linux/netlink.h>
 
+/* 
+ * A non-zero value for sysctl_ip_reassembly_count defines the 
+ * size of the window of ip fragments that are considered valid. 
+ * This is useful for preventing reassembly of fragments from 
+ * different IP datagrams when the 16-bit IP id wraps.
+ * A value of zero means the window is unlimited.
+ */
+int sysctl_ip_reassembly_count = 0;
 /*
  *	SNMP management statistics
  */
@@ -286,13 +294,17 @@ static inline int ip_rcv_finish(struct s
 {
 	struct net_device *dev = skb->dev;
 	struct iphdr *iph = skb->nh.iph;
+	__u32 saddr = iph->saddr;
+	__u32 daddr = iph->daddr;
+	__u8  proto = iph->protocol;
+	int ret;
 
 	/*
 	 *	Initialise the virtual path cache for the packet. It describes
 	 *	how the packet travels inside Linux networking.
 	 */ 
 	if (skb->dst == NULL) {
-		if (ip_route_input(skb, iph->daddr, iph->saddr, iph->tos, dev))
+		if (ip_route_input(skb, daddr, saddr, iph->tos, dev))
 			goto drop; 
 	}
 
@@ -334,7 +346,7 @@ static inline int ip_rcv_finish(struct s
 				if (!IN_DEV_SOURCE_ROUTE(in_dev)) {
 					if (IN_DEV_LOG_MARTIANS(in_dev) && net_ratelimit())
 						printk(KERN_INFO "source route option %u.%u.%u.%u -> %u.%u.%u.%u\n",
-						       NIPQUAD(iph->saddr), NIPQUAD(iph->daddr));
+						       NIPQUAD(saddr), NIPQUAD(iph->daddr));
 					in_dev_put(in_dev);
 					goto drop;
 				}
@@ -345,7 +357,13 @@ static inline int ip_rcv_finish(struct s
 		}
 	}
 
-	return dst_input(skb);
+	ret = dst_input(skb);
+
+	if (sysctl_ip_reassembly_count) {
+		ip_count(saddr, daddr, proto);
+	}
+
+	return ret;
 
 inhdr_error:
 	IP_INC_STATS_BH(IPSTATS_MIB_INHDRERRORS);
diff -rup linux.orig/net/ipv4/sysctl_net_ipv4.c linux.new/net/ipv4/sysctl_net_ipv4.c
--- linux.orig/net/ipv4/sysctl_net_ipv4.c	2005-06-14 11:36:29.923218508 -0700
+++ linux.new/net/ipv4/sysctl_net_ipv4.c	2005-06-22 14:03:50.869948048 -0700
@@ -29,6 +29,7 @@ extern int sysctl_ipfrag_low_thresh;
 extern int sysctl_ipfrag_high_thresh; 
 extern int sysctl_ipfrag_time;
 extern int sysctl_ipfrag_secret_interval;
+extern int sysctl_ip_reassembly_count;
 
 /* From ip_output.c */
 extern int sysctl_ip_dynaddr;
@@ -49,6 +50,7 @@ extern int inet_peer_gc_mintime;
 extern int inet_peer_gc_maxtime;
 
 #ifdef CONFIG_SYSCTL
+static int zero;
 static int tcp_retr1_max = 255; 
 static int ip_local_port_range_min[] = { 1, 1 };
 static int ip_local_port_range_max[] = { 65535, 65535 };
@@ -595,6 +597,15 @@ ctl_table ipv4_table[] = {
 		.strategy	= &sysctl_jiffies
 	},
 	{
+		.ctl_name	= NET_IPV4_REASM_COUNT,
+		.procname	= "ip_reassembly_count",
+		.data		= &sysctl_ip_reassembly_count,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= &proc_dointvec_minmax,
+		.extra1		= &zero
+	},
+	{
 		.ctl_name	= NET_TCP_NO_METRICS_SAVE,
 		.procname	= "tcp_no_metrics_save",
 		.data		= &sysctl_tcp_nometrics_save,


--
Arthur
