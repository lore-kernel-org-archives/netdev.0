From: Eric Dumazet <dada1@cosmosbay.com>
Subject: [PATCH] netfilter: finer grained nf_conn locking
Date: Sat, 28 Mar 2009 17:55:38 +0100
Message-ID: <49CE568A.9090104@cosmosbay.com>
References: <20090218051906.174295181@vyatta.com> <20090218052747.679540125@vyatta.com> <499BDB5D.2050105@trash.net> <499C1894.7060400@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	David Miller <davem@davemloft.net>,
	Rick Jones <rick.jones2@hp.com>, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:43630 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752145AbZC1Qzz convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 28 Mar 2009 12:55:55 -0400
In-Reply-To: <499C1894.7060400@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet a =E9crit :
> Patrick McHardy a =E9crit :
>> Stephen Hemminger wrote:
>>
>>> @@ -50,6 +50,7 @@ struct ip_ct_tcp_state {
>>> =20
>>>  struct ip_ct_tcp
>>>  {
>>> +    spinlock_t    lock;
>>>      struct ip_ct_tcp_state seen[2];    /* connection parameters pe=
r
>>> direction */
>>>      u_int8_t    state;        /* state of the connection (enum
>>> tcp_conntrack) */
>>>      /* For detecting stale connections */
>> Eric already posted a patch to use an array of locks, which is
>> a better approach IMO since it keeps the size of the conntrack
>> entries down.
>=20
> Yes, we probably can use an array for short lived lock sections.
>=20
> The extra cost to compute the lock address is quite small, if
> the array size is known at compile time.
>=20
> Stephen we might also use this same array to protect the nf_conn_acct=
_find(ct)
> thing as well (I am referring to your RFT 3/4 patch :
> Use mod_timer_noact to remove nf_conntrack_lock)
>=20
> Here is a repost of patch Patrick is referring to :
>=20
>=20
> [PATCH] netfilter: Get rid of central rwlock in tcp conntracking
>=20
> TCP connection tracking suffers of huge contention on a global rwlock=
,
> used to protect tcp conntracking state.
>=20
> As each tcp conntrack state have no relations between each others, we
> can switch to fine grained lock. Using an array of spinlocks avoids
> enlarging size of connection tracking structures, yet giving reasonab=
le
> fanout.
>=20
> tcp_print_conntrack() doesnt need to lock anything to read
> ct->proto.tcp.state, so speedup /proc/net/ip_conntrack as well.
>=20
> nf_conntrack_hash_rnd_initted & nf_conntrack_hash_rnd declared read_m=
ostly
>=20

Hi Patrick

Apparently we could not finish the removal of tcp_lock for 2.6.30 :(

Stephen suggested using a 4 bytes hole in struct nf_conntrack,
but this is ok only if sizeof(spinlock_t) <=3D 4 and 64 bit arches.

We could do an hybrid thing : use nf_conn.ct_general.lock if 64 bit arc=
hes
and sizeof(spinlock_t) <=3D 4.

Other cases would use a carefuly sized array of spinlocks...

Thank you

[PATCH] netfilter: finer grained nf_conn locking

Introduction of fine grained lock infrastructure for nf_conn.
If possible, we use a 32bit hole on 64bit arches.
Else we use a global array of hashed spinlocks, so we dont
change size of "struct nf_conn"

Get rid of central tcp_lock rwlock used in TCP conntracking
using this infrastructure for better performance on SMP.

"tbench 8" results on my 8 core machine (32bit kernel, with
conntracking on) : 2319 MB/s instead of 2284 MB/s


Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>
---
 include/linux/skbuff.h                       |    9 ++-
 include/net/netfilter/nf_conntrack_l4proto.h |    2
 net/netfilter/nf_conntrack_core.c            |   47 +++++++++++++++++
 net/netfilter/nf_conntrack_netlink.c         |    4 -
 net/netfilter/nf_conntrack_proto_tcp.c       |   35 +++++-------
 5 files changed, 74 insertions(+), 23 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index bb1981f..c737f47 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -96,7 +96,14 @@ struct pipe_inode_info;
=20
 #if defined(CONFIG_NF_CONNTRACK) || defined(CONFIG_NF_CONNTRACK_MODULE=
)
 struct nf_conntrack {
-	atomic_t use;
+	atomic_t	use;
+#if BITS_PER_LONG =3D=3D 64
+	/*
+	 * On 64bit arches, we might use this 32bit hole for spinlock
+	 * (if a spinlock_t fits)
+	 */
+	int		pad;
+#endif
 };
 #endif
=20
diff --git a/include/net/netfilter/nf_conntrack_l4proto.h b/include/net=
/netfilter/nf_conntrack_l4proto.h
index ba32ed7..d66bea9 100644
--- a/include/net/netfilter/nf_conntrack_l4proto.h
+++ b/include/net/netfilter/nf_conntrack_l4proto.h
@@ -63,7 +63,7 @@ struct nf_conntrack_l4proto
=20
 	/* convert protoinfo to nfnetink attributes */
 	int (*to_nlattr)(struct sk_buff *skb, struct nlattr *nla,
-			 const struct nf_conn *ct);
+			 struct nf_conn *ct);
 	/* Calculate protoinfo nlattr size */
 	int (*nlattr_size)(void);
=20
diff --git a/net/netfilter/nf_conntrack_core.c b/net/netfilter/nf_connt=
rack_core.c
index 8020db6..408d287 100644
--- a/net/netfilter/nf_conntrack_core.c
+++ b/net/netfilter/nf_conntrack_core.c
@@ -32,6 +32,7 @@
 #include <linux/rculist_nulls.h>
=20
 #include <net/netfilter/nf_conntrack.h>
+#include <net/netfilter/nf_conntrack_lock.h>
 #include <net/netfilter/nf_conntrack_l3proto.h>
 #include <net/netfilter/nf_conntrack_l4proto.h>
 #include <net/netfilter/nf_conntrack_expect.h>
@@ -523,6 +524,7 @@ struct nf_conn *nf_conntrack_alloc(struct net *net,
 		return ERR_PTR(-ENOMEM);
 	}
=20
+	nf_conn_lock_init(ct);
 	atomic_set(&ct->ct_general.use, 1);
 	ct->tuplehash[IP_CT_DIR_ORIGINAL].tuple =3D *orig;
 	ct->tuplehash[IP_CT_DIR_REPLY].tuple =3D *repl;
@@ -1033,11 +1035,50 @@ void nf_conntrack_flush(struct net *net, u32 pi=
d, int report)
 }
 EXPORT_SYMBOL_GPL(nf_conntrack_flush);
=20
+spinlock_t *nf_conn_hlocks __read_mostly;
+unsigned int nf_conn_hlocks_mask __read_mostly;
+
+static int nf_conn_hlocks_init(void)
+{
+	if (nf_conn_lock_type() =3D=3D NF_CONN_LOCK_EXTERNAL) {
+		size_t sz;
+		int i;
+#if defined(CONFIG_PROVE_LOCKING)
+		unsigned int nr_slots =3D 256;
+#else
+		/* 4 nodes per cpu on VSMP, or 256 slots per cpu */
+		unsigned int nr_slots =3D max(256UL, ((4UL << INTERNODE_CACHE_SHIFT)=
 /
+					  sizeof(spinlock_t)));
+		nr_slots =3D roundup_pow_of_two(num_possible_cpus() * nr_slots);
+#endif
+		sz =3D nr_slots * sizeof(spinlock_t);
+		if (sz > PAGE_SIZE)
+			nf_conn_hlocks =3D vmalloc(sz);
+		else
+			nf_conn_hlocks =3D kmalloc(sz, GFP_KERNEL);
+		if (!nf_conn_hlocks)
+			return -ENOMEM;
+		nf_conn_hlocks_mask =3D nr_slots - 1;
+		for (i =3D 0; i < nr_slots; i++)
+			spin_lock_init(nf_conn_hlocks + i);
+	}
+	return 0;
+}
+
+static void nf_conn_hlocks_fini(void)
+{
+	if (is_vmalloc_addr(nf_conn_hlocks))
+		vfree(nf_conn_hlocks);
+	else
+		kfree(nf_conn_hlocks);
+}
+
 static void nf_conntrack_cleanup_init_net(void)
 {
 	nf_conntrack_helper_fini();
 	nf_conntrack_proto_fini();
 	kmem_cache_destroy(nf_conntrack_cachep);
+	nf_conn_hlocks_fini();
 }
=20
 static void nf_conntrack_cleanup_net(struct net *net)
@@ -1170,6 +1211,10 @@ static int nf_conntrack_init_init_net(void)
 	int max_factor =3D 8;
 	int ret;
=20
+	ret =3D nf_conn_hlocks_init();
+	if (ret)
+		goto err_hlocks;
+
 	/* Idea from tcp.c: use 1/16384 of memory.  On i386: 32MB
 	 * machine has 512 buckets. >=3D 1GB machines have 16384 buckets. */
 	if (!nf_conntrack_htable_size) {
@@ -1217,6 +1262,8 @@ err_helper:
 err_proto:
 	kmem_cache_destroy(nf_conntrack_cachep);
 err_cache:
+	nf_conn_hlocks_fini();
+err_hlocks:
 	return ret;
 }
=20
diff --git a/net/netfilter/nf_conntrack_netlink.c b/net/netfilter/nf_co=
nntrack_netlink.c
index c6439c7..89ea035 100644
--- a/net/netfilter/nf_conntrack_netlink.c
+++ b/net/netfilter/nf_conntrack_netlink.c
@@ -144,7 +144,7 @@ nla_put_failure:
 }
=20
 static inline int
-ctnetlink_dump_protoinfo(struct sk_buff *skb, const struct nf_conn *ct=
)
+ctnetlink_dump_protoinfo(struct sk_buff *skb, struct nf_conn *ct)
 {
 	struct nf_conntrack_l4proto *l4proto;
 	struct nlattr *nest_proto;
@@ -351,7 +351,7 @@ nla_put_failure:
 static int
 ctnetlink_fill_info(struct sk_buff *skb, u32 pid, u32 seq,
 		    int event, int nowait,
-		    const struct nf_conn *ct)
+		    struct nf_conn *ct)
 {
 	struct nlmsghdr *nlh;
 	struct nfgenmsg *nfmsg;
diff --git a/net/netfilter/nf_conntrack_proto_tcp.c b/net/netfilter/nf_=
conntrack_proto_tcp.c
index b5ccf2b..bb5fc24 100644
--- a/net/netfilter/nf_conntrack_proto_tcp.c
+++ b/net/netfilter/nf_conntrack_proto_tcp.c
@@ -23,14 +23,13 @@
 #include <linux/netfilter_ipv4.h>
 #include <linux/netfilter_ipv6.h>
 #include <net/netfilter/nf_conntrack.h>
+#include <net/netfilter/nf_conntrack_lock.h>
 #include <net/netfilter/nf_conntrack_l4proto.h>
 #include <net/netfilter/nf_conntrack_ecache.h>
 #include <net/netfilter/nf_log.h>
 #include <net/netfilter/ipv4/nf_conntrack_ipv4.h>
 #include <net/netfilter/ipv6/nf_conntrack_ipv6.h>
=20
-/* Protects ct->proto.tcp */
-static DEFINE_RWLOCK(tcp_lock);
=20
 /* "Be conservative in what you do,
     be liberal in what you accept from others."
@@ -300,9 +299,7 @@ static int tcp_print_conntrack(struct seq_file *s, =
const struct nf_conn *ct)
 {
 	enum tcp_conntrack state;
=20
-	read_lock_bh(&tcp_lock);
 	state =3D ct->proto.tcp.state;
-	read_unlock_bh(&tcp_lock);
=20
 	return seq_printf(s, "%s ", tcp_conntrack_names[state]);
 }
@@ -708,14 +705,14 @@ void nf_conntrack_tcp_update(const struct sk_buff=
 *skb,
=20
 	end =3D segment_seq_plus_len(ntohl(tcph->seq), skb->len, dataoff, tcp=
h);
=20
-	write_lock_bh(&tcp_lock);
+	spin_lock_bh(nf_conn_lock_addr(ct));
 	/*
 	 * We have to worry for the ack in the reply packet only...
 	 */
 	if (after(end, ct->proto.tcp.seen[dir].td_end))
 		ct->proto.tcp.seen[dir].td_end =3D end;
 	ct->proto.tcp.last_end =3D end;
-	write_unlock_bh(&tcp_lock);
+	spin_unlock_bh(nf_conn_lock_addr(ct));
 	pr_debug("tcp_update: sender end=3D%u maxend=3D%u maxwin=3D%u scale=3D=
%i "
 		 "receiver end=3D%u maxend=3D%u maxwin=3D%u scale=3D%i\n",
 		 sender->td_end, sender->td_maxend, sender->td_maxwin,
@@ -824,7 +821,7 @@ static int tcp_packet(struct nf_conn *ct,
 	th =3D skb_header_pointer(skb, dataoff, sizeof(_tcph), &_tcph);
 	BUG_ON(th =3D=3D NULL);
=20
-	write_lock_bh(&tcp_lock);
+	spin_lock_bh(nf_conn_lock_addr(ct));
 	old_state =3D ct->proto.tcp.state;
 	dir =3D CTINFO2DIR(ctinfo);
 	index =3D get_conntrack_index(th);
@@ -854,7 +851,7 @@ static int tcp_packet(struct nf_conn *ct,
 		        && ct->proto.tcp.last_index =3D=3D TCP_RST_SET)) {
 			/* Attempt to reopen a closed/aborted connection.
 			 * Delete this connection and look up again. */
-			write_unlock_bh(&tcp_lock);
+			spin_unlock_bh(nf_conn_lock_addr(ct));
=20
 			/* Only repeat if we can actually remove the timer.
 			 * Destruction may already be in progress in process
@@ -890,7 +887,7 @@ static int tcp_packet(struct nf_conn *ct,
 			 * that the client cannot but retransmit its SYN and
 			 * thus initiate a clean new session.
 			 */
-			write_unlock_bh(&tcp_lock);
+			spin_unlock_bh(nf_conn_lock_addr(ct));
 			if (LOG_INVALID(net, IPPROTO_TCP))
 				nf_log_packet(pf, 0, skb, NULL, NULL, NULL,
 					  "nf_ct_tcp: killing out of sync session ");
@@ -903,7 +900,7 @@ static int tcp_packet(struct nf_conn *ct,
 		ct->proto.tcp.last_end =3D
 		    segment_seq_plus_len(ntohl(th->seq), skb->len, dataoff, th);
=20
-		write_unlock_bh(&tcp_lock);
+		spin_unlock_bh(nf_conn_lock_addr(ct));
 		if (LOG_INVALID(net, IPPROTO_TCP))
 			nf_log_packet(pf, 0, skb, NULL, NULL, NULL,
 				  "nf_ct_tcp: invalid packet ignored ");
@@ -912,7 +909,7 @@ static int tcp_packet(struct nf_conn *ct,
 		/* Invalid packet */
 		pr_debug("nf_ct_tcp: Invalid dir=3D%i index=3D%u ostate=3D%u\n",
 			 dir, get_conntrack_index(th), old_state);
-		write_unlock_bh(&tcp_lock);
+		spin_unlock_bh(nf_conn_lock_addr(ct));
 		if (LOG_INVALID(net, IPPROTO_TCP))
 			nf_log_packet(pf, 0, skb, NULL, NULL, NULL,
 				  "nf_ct_tcp: invalid state ");
@@ -943,7 +940,7 @@ static int tcp_packet(struct nf_conn *ct,
=20
 	if (!tcp_in_window(ct, &ct->proto.tcp, dir, index,
 			   skb, dataoff, th, pf)) {
-		write_unlock_bh(&tcp_lock);
+		spin_unlock_bh(nf_conn_lock_addr(ct));
 		return -NF_ACCEPT;
 	}
      in_window:
@@ -972,7 +969,7 @@ static int tcp_packet(struct nf_conn *ct,
 		timeout =3D nf_ct_tcp_timeout_unacknowledged;
 	else
 		timeout =3D tcp_timeouts[new_state];
-	write_unlock_bh(&tcp_lock);
+	spin_unlock_bh(nf_conn_lock_addr(ct));
=20
 	nf_conntrack_event_cache(IPCT_PROTOINFO_VOLATILE, ct);
 	if (new_state !=3D old_state)
@@ -1090,12 +1087,12 @@ static bool tcp_new(struct nf_conn *ct, const s=
truct sk_buff *skb,
 #include <linux/netfilter/nfnetlink_conntrack.h>
=20
 static int tcp_to_nlattr(struct sk_buff *skb, struct nlattr *nla,
-			 const struct nf_conn *ct)
+			 struct nf_conn *ct)
 {
 	struct nlattr *nest_parms;
 	struct nf_ct_tcp_flags tmp =3D {};
=20
-	read_lock_bh(&tcp_lock);
+	spin_lock_bh(nf_conn_lock_addr(ct));
 	nest_parms =3D nla_nest_start(skb, CTA_PROTOINFO_TCP | NLA_F_NESTED);
 	if (!nest_parms)
 		goto nla_put_failure;
@@ -1115,14 +1112,14 @@ static int tcp_to_nlattr(struct sk_buff *skb, s=
truct nlattr *nla,
 	tmp.flags =3D ct->proto.tcp.seen[1].flags;
 	NLA_PUT(skb, CTA_PROTOINFO_TCP_FLAGS_REPLY,
 		sizeof(struct nf_ct_tcp_flags), &tmp);
-	read_unlock_bh(&tcp_lock);
+	spin_unlock_bh(nf_conn_lock_addr(ct));
=20
 	nla_nest_end(skb, nest_parms);
=20
 	return 0;
=20
 nla_put_failure:
-	read_unlock_bh(&tcp_lock);
+	spin_unlock_bh(nf_conn_lock_addr(ct));
 	return -1;
 }
=20
@@ -1153,7 +1150,7 @@ static int nlattr_to_tcp(struct nlattr *cda[], st=
ruct nf_conn *ct)
 	    nla_get_u8(tb[CTA_PROTOINFO_TCP_STATE]) >=3D TCP_CONNTRACK_MAX)
 		return -EINVAL;
=20
-	write_lock_bh(&tcp_lock);
+	spin_lock_bh(nf_conn_lock_addr(ct));
 	if (tb[CTA_PROTOINFO_TCP_STATE])
 		ct->proto.tcp.state =3D nla_get_u8(tb[CTA_PROTOINFO_TCP_STATE]);
=20
@@ -1180,7 +1177,7 @@ static int nlattr_to_tcp(struct nlattr *cda[], st=
ruct nf_conn *ct)
 		ct->proto.tcp.seen[1].td_scale =3D
 			nla_get_u8(tb[CTA_PROTOINFO_TCP_WSCALE_REPLY]);
 	}
-	write_unlock_bh(&tcp_lock);
+	spin_unlock_bh(nf_conn_lock_addr(ct));
=20
 	return 0;
 }

