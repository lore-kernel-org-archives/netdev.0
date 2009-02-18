From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [RFT 4/4] netfilter: Get rid of central rwlock in tcp conntracking
Date: Wed, 18 Feb 2009 15:17:56 +0100
Message-ID: <499C1894.7060400@cosmosbay.com>
References: <20090218051906.174295181@vyatta.com> <20090218052747.679540125@vyatta.com> <499BDB5D.2050105@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	David Miller <davem@davemloft.net>,
	Rick Jones <rick.jones2@hp.com>, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:40400 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751420AbZBROSI convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Feb 2009 09:18:08 -0500
In-Reply-To: <499BDB5D.2050105@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Patrick McHardy a =E9crit :
> Stephen Hemminger wrote:
>=20
>> @@ -50,6 +50,7 @@ struct ip_ct_tcp_state {
>> =20
>>  struct ip_ct_tcp
>>  {
>> +    spinlock_t    lock;
>>      struct ip_ct_tcp_state seen[2];    /* connection parameters per
>> direction */
>>      u_int8_t    state;        /* state of the connection (enum
>> tcp_conntrack) */
>>      /* For detecting stale connections */
>=20
> Eric already posted a patch to use an array of locks, which is
> a better approach IMO since it keeps the size of the conntrack
> entries down.

Yes, we probably can use an array for short lived lock sections.

The extra cost to compute the lock address is quite small, if
the array size is known at compile time.

Stephen we might also use this same array to protect the nf_conn_acct_f=
ind(ct)
thing as well (I am referring to your RFT 3/4 patch :
Use mod_timer_noact to remove nf_conntrack_lock)

Here is a repost of patch Patrick is referring to :


[PATCH] netfilter: Get rid of central rwlock in tcp conntracking

TCP connection tracking suffers of huge contention on a global rwlock,
used to protect tcp conntracking state.

As each tcp conntrack state have no relations between each others, we
can switch to fine grained lock. Using an array of spinlocks avoids
enlarging size of connection tracking structures, yet giving reasonable
fanout.

tcp_print_conntrack() doesnt need to lock anything to read
ct->proto.tcp.state, so speedup /proc/net/ip_conntrack as well.

nf_conntrack_hash_rnd_initted & nf_conntrack_hash_rnd declared read_mos=
tly

Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>
Reported-by: Rick Jones <rick.jones2@hp.com>
---
 include/net/netfilter/nf_conntrack.h   |   32 +++++++++++++++++++++
 net/netfilter/nf_conntrack_core.c      |   10 ++++--
 net/netfilter/nf_conntrack_proto_tcp.c |   34 ++++++++++-------------
 3 files changed, 53 insertions(+), 23 deletions(-)

diff --git a/include/net/netfilter/nf_conntrack.h b/include/net/netfilt=
er/nf_conntrack.h
index 2e0c536..288aff5 100644
--- a/include/net/netfilter/nf_conntrack.h
+++ b/include/net/netfilter/nf_conntrack.h
@@ -129,6 +129,38 @@ struct nf_conn
 	struct rcu_head rcu;
 };
=20
+#if defined(CONFIG_SMP) || defined(CONFIG_DEBUG_SPINLOCK) || \
+	defined(CONFIG_PROVE_LOCKING)
+
+/*
+ * We reserve 16 locks per cpu (typical cache line size is 64 bytes)
+ * maxed to 512 locks so that ct_hlock[] uses at most 2048 bytes of me=
mory.
+ * (on lockdep we have a quite big spinlock_t, so keep the size down t=
here)
+ */
+#ifdef CONFIG_LOCKDEP
+#define CT_HASH_LOCK_SZ 64
+#elif NR_CPUS >=3D 32
+#define CT_HASH_LOCK_SZ 512
+#else
+#define CT_HASH_LOCK_SZ (roundup_pow_of_two(NR_CPUS) * 16)
+#endif
+
+extern spinlock_t ct_hlock[CT_HASH_LOCK_SZ];
+
+#else
+#define CT_HASH_LOCK_SZ 0
+#endif
+static inline spinlock_t *ct_lock_addr(const struct nf_conn *ct)
+{
+	if (CT_HASH_LOCK_SZ) {
+		unsigned long hash =3D (unsigned long)ct;
+		hash ^=3D hash >> 16;
+		hash ^=3D hash >> 8;
+		return &ct_hlock[hash % CT_HASH_LOCK_SZ];
+	}
+	return NULL;
+}
+
 static inline struct nf_conn *
 nf_ct_tuplehash_to_ctrack(const struct nf_conntrack_tuple_hash *hash)
 {
diff --git a/net/netfilter/nf_conntrack_core.c b/net/netfilter/nf_connt=
rack_core.c
index 90ce9dd..68822d8 100644
--- a/net/netfilter/nf_conntrack_core.c
+++ b/net/netfilter/nf_conntrack_core.c
@@ -61,9 +61,9 @@ struct nf_conn nf_conntrack_untracked __read_mostly;
 EXPORT_SYMBOL_GPL(nf_conntrack_untracked);
=20
 static struct kmem_cache *nf_conntrack_cachep __read_mostly;
-
-static int nf_conntrack_hash_rnd_initted;
-static unsigned int nf_conntrack_hash_rnd;
+spinlock_t ct_hlock[CT_HASH_LOCK_SZ];
+static int nf_conntrack_hash_rnd_initted __read_mostly;
+static unsigned int nf_conntrack_hash_rnd __read_mostly;
=20
 static u_int32_t __hash_conntrack(const struct nf_conntrack_tuple *tup=
le,
 				  unsigned int size, unsigned int rnd)
@@ -1141,7 +1141,7 @@ module_param_call(hashsize, nf_conntrack_set_hash=
size, param_get_uint,
 static int nf_conntrack_init_init_net(void)
 {
 	int max_factor =3D 8;
-	int ret;
+	int i, ret;
=20
 	/* Idea from tcp.c: use 1/16384 of memory.  On i386: 32MB
 	 * machine has 512 buckets. >=3D 1GB machines have 16384 buckets. */
@@ -1174,6 +1174,8 @@ static int nf_conntrack_init_init_net(void)
 		ret =3D -ENOMEM;
 		goto err_cache;
 	}
+	for (i =3D 0; i < CT_HASH_LOCK_SZ; i++)
+		spin_lock_init(&ct_hlock[i]);
=20
 	ret =3D nf_conntrack_proto_init();
 	if (ret < 0)
diff --git a/net/netfilter/nf_conntrack_proto_tcp.c b/net/netfilter/nf_=
conntrack_proto_tcp.c
index a1edb9c..247e82f 100644
--- a/net/netfilter/nf_conntrack_proto_tcp.c
+++ b/net/netfilter/nf_conntrack_proto_tcp.c
@@ -26,9 +26,6 @@
 #include <net/netfilter/nf_conntrack_ecache.h>
 #include <net/netfilter/nf_log.h>
=20
-/* Protects ct->proto.tcp */
-static DEFINE_RWLOCK(tcp_lock);
-
 /* "Be conservative in what you do,
     be liberal in what you accept from others."
     If it's non-zero, we mark only out of window RST segments as INVAL=
ID. */
@@ -297,9 +294,7 @@ static int tcp_print_conntrack(struct seq_file *s, =
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
@@ -705,14 +700,14 @@ void nf_conntrack_tcp_update(const struct sk_buff=
 *skb,
=20
 	end =3D segment_seq_plus_len(ntohl(tcph->seq), skb->len, dataoff, tcp=
h);
=20
-	write_lock_bh(&tcp_lock);
+	spin_lock_bh(ct_lock_addr(ct));
 	/*
 	 * We have to worry for the ack in the reply packet only...
 	 */
 	if (after(end, ct->proto.tcp.seen[dir].td_end))
 		ct->proto.tcp.seen[dir].td_end =3D end;
 	ct->proto.tcp.last_end =3D end;
-	write_unlock_bh(&tcp_lock);
+	spin_unlock_bh(ct_lock_addr(ct));
 	pr_debug("tcp_update: sender end=3D%u maxend=3D%u maxwin=3D%u scale=3D=
%i "
 		 "receiver end=3D%u maxend=3D%u maxwin=3D%u scale=3D%i\n",
 		 sender->td_end, sender->td_maxend, sender->td_maxwin,
@@ -821,7 +816,7 @@ static int tcp_packet(struct nf_conn *ct,
 	th =3D skb_header_pointer(skb, dataoff, sizeof(_tcph), &_tcph);
 	BUG_ON(th =3D=3D NULL);
=20
-	write_lock_bh(&tcp_lock);
+	spin_lock_bh(ct_lock_addr(ct));
 	old_state =3D ct->proto.tcp.state;
 	dir =3D CTINFO2DIR(ctinfo);
 	index =3D get_conntrack_index(th);
@@ -851,7 +846,7 @@ static int tcp_packet(struct nf_conn *ct,
 		        && ct->proto.tcp.last_index =3D=3D TCP_RST_SET)) {
 			/* Attempt to reopen a closed/aborted connection.
 			 * Delete this connection and look up again. */
-			write_unlock_bh(&tcp_lock);
+			spin_unlock_bh(ct_lock_addr(ct));
=20
 			/* Only repeat if we can actually remove the timer.
 			 * Destruction may already be in progress in process
@@ -887,7 +882,7 @@ static int tcp_packet(struct nf_conn *ct,
 			 * that the client cannot but retransmit its SYN and
 			 * thus initiate a clean new session.
 			 */
-			write_unlock_bh(&tcp_lock);
+			spin_unlock_bh(ct_lock_addr(ct));
 			if (LOG_INVALID(net, IPPROTO_TCP))
 				nf_log_packet(pf, 0, skb, NULL, NULL, NULL,
 					  "nf_ct_tcp: killing out of sync session ");
@@ -900,7 +895,7 @@ static int tcp_packet(struct nf_conn *ct,
 		ct->proto.tcp.last_end =3D
 		    segment_seq_plus_len(ntohl(th->seq), skb->len, dataoff, th);
=20
-		write_unlock_bh(&tcp_lock);
+		spin_unlock_bh(ct_lock_addr(ct));
 		if (LOG_INVALID(net, IPPROTO_TCP))
 			nf_log_packet(pf, 0, skb, NULL, NULL, NULL,
 				  "nf_ct_tcp: invalid packet ignored ");
@@ -909,7 +904,7 @@ static int tcp_packet(struct nf_conn *ct,
 		/* Invalid packet */
 		pr_debug("nf_ct_tcp: Invalid dir=3D%i index=3D%u ostate=3D%u\n",
 			 dir, get_conntrack_index(th), old_state);
-		write_unlock_bh(&tcp_lock);
+		spin_unlock_bh(ct_lock_addr(ct));
 		if (LOG_INVALID(net, IPPROTO_TCP))
 			nf_log_packet(pf, 0, skb, NULL, NULL, NULL,
 				  "nf_ct_tcp: invalid state ");
@@ -940,7 +935,7 @@ static int tcp_packet(struct nf_conn *ct,
=20
 	if (!tcp_in_window(ct, &ct->proto.tcp, dir, index,
 			   skb, dataoff, th, pf)) {
-		write_unlock_bh(&tcp_lock);
+		spin_unlock_bh(ct_lock_addr(ct));
 		return -NF_ACCEPT;
 	}
      in_window:
@@ -969,7 +964,7 @@ static int tcp_packet(struct nf_conn *ct,
 		timeout =3D nf_ct_tcp_timeout_unacknowledged;
 	else
 		timeout =3D tcp_timeouts[new_state];
-	write_unlock_bh(&tcp_lock);
+	spin_unlock_bh(ct_lock_addr(ct));
=20
 	nf_conntrack_event_cache(IPCT_PROTOINFO_VOLATILE, ct);
 	if (new_state !=3D old_state)
@@ -1022,6 +1017,7 @@ static bool tcp_new(struct nf_conn *ct, const str=
uct sk_buff *skb,
 		pr_debug("nf_ct_tcp: invalid new deleting.\n");
 		return false;
 	}
+	spin_lock_init(ct_lock_addr(ct));
=20
 	if (new_state =3D=3D TCP_CONNTRACK_SYN_SENT) {
 		/* SYN packet */
@@ -1092,7 +1088,7 @@ static int tcp_to_nlattr(struct sk_buff *skb, str=
uct nlattr *nla,
 	struct nlattr *nest_parms;
 	struct nf_ct_tcp_flags tmp =3D {};
=20
-	read_lock_bh(&tcp_lock);
+	spin_lock_bh(ct_lock_addr(ct));
 	nest_parms =3D nla_nest_start(skb, CTA_PROTOINFO_TCP | NLA_F_NESTED);
 	if (!nest_parms)
 		goto nla_put_failure;
@@ -1112,14 +1108,14 @@ static int tcp_to_nlattr(struct sk_buff *skb, s=
truct nlattr *nla,
 	tmp.flags =3D ct->proto.tcp.seen[1].flags;
 	NLA_PUT(skb, CTA_PROTOINFO_TCP_FLAGS_REPLY,
 		sizeof(struct nf_ct_tcp_flags), &tmp);
-	read_unlock_bh(&tcp_lock);
+	spin_unlock_bh(ct_lock_addr(ct));
=20
 	nla_nest_end(skb, nest_parms);
=20
 	return 0;
=20
 nla_put_failure:
-	read_unlock_bh(&tcp_lock);
+	spin_unlock_bh(ct_lock_addr(ct));
 	return -1;
 }
=20
@@ -1150,7 +1146,7 @@ static int nlattr_to_tcp(struct nlattr *cda[], st=
ruct nf_conn *ct)
 	    nla_get_u8(tb[CTA_PROTOINFO_TCP_STATE]) >=3D TCP_CONNTRACK_MAX)
 		return -EINVAL;
=20
-	write_lock_bh(&tcp_lock);
+	spin_lock_bh(ct_lock_addr(ct));
 	if (tb[CTA_PROTOINFO_TCP_STATE])
 		ct->proto.tcp.state =3D nla_get_u8(tb[CTA_PROTOINFO_TCP_STATE]);
=20
@@ -1177,7 +1173,7 @@ static int nlattr_to_tcp(struct nlattr *cda[], st=
ruct nf_conn *ct)
 		ct->proto.tcp.seen[1].td_scale =3D
 			nla_get_u8(tb[CTA_PROTOINFO_TCP_WSCALE_REPLY]);
 	}
-	write_unlock_bh(&tcp_lock);
+	spin_unlock_bh(ct_lock_addr(ct));
=20
 	return 0;
 }

