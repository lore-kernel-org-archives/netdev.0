From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: 32 core net-next stack/netfilter "scaling"
Date: Tue, 27 Jan 2009 10:10:28 +0100
Message-ID: <497ECF84.1030308@cosmosbay.com>
References: <497E361B.30909@hp.com> <497E42F4.7080201@cosmosbay.com> <497E44F6.2010703@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linux Network Development list <netdev@vger.kernel.org>,
	Netfilter Developers <netfilter-devel@vger.kernel.org>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Patrick McHardy <kaber@trash.net>
To: Rick Jones <rick.jones2@hp.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <497E44F6.2010703@hp.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Rick Jones a =E9crit :
>>
>> Hi Rick, nice hardware you have :)
>=20
> Every once in a while the cobbler's children get some shoes to wear :=
)
>=20
>>
>> Stephen had a patch to nuke read_lock() from iptables, using RCU and
>> seqlocks.
>> I hit this contention point even with low cost hardware, and quite
>> standard application.
>>
>> I pinged him few days ago to try to finish the job with him, but it
>> seems Stephen
>> is busy at the moment.
>>
>> Then conntrack (tcp sessions) is awfull, since it uses a single
>> rwlock_t tcp_lock
>>  that must be write_locked() for basically every handled tcp frame..=
=2E
>>
>> How long is "not indefinitely" ?=20
>=20
> The system I am using is being borrowed under an open ended loan.=20
> However, my use of it can be thought of as being the "null process" i=
n
> VMS - once anyone else wants it I have to get off of it.
>=20
> That said, I would guess that the chances of someone else trying to g=
et
> that system are pretty small for the next four+ weeks.  I had a simil=
ar
> system (PCIe I/O rather than PCI-X) for quite a few weeks before it g=
ot
> pulled-out from under.
>=20

As Stephen will probably send the iptable part, I can do the tcp conntr=
ack
improvment.

Let me know how it helps your last test (connection tracking enabled)

Thanks

[PATCH] netfilter: Get rid of central rwlock in tcp conntracking

TCP connection tracking suffers of huge contention on a global rwlock,
used to protect tcp conntracking state.
As each tcp conntrack state have no relations between each others, we
can switch to fine grained lock, using a spinlock per "struct ip_ct_tcp=
"

tcp_print_conntrack() dont need to lock anything to read ct->proto.tcp.=
state,
so speedup /proc/net/ip_conntrack as well.

Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>
Reported-by: Rick Jones <rick.jones2@hp.com>
---
diff --git a/include/linux/netfilter/nf_conntrack_tcp.h b/include/linux=
/netfilter/nf_conntrack_tcp.h
index a049df4..3dc72c6 100644
--- a/include/linux/netfilter/nf_conntrack_tcp.h
+++ b/include/linux/netfilter/nf_conntrack_tcp.h
@@ -50,6 +50,7 @@ struct ip_ct_tcp_state {
=20
 struct ip_ct_tcp
 {
+	spinlock_t	lock;
 	struct ip_ct_tcp_state seen[2];	/* connection parameters per directio=
n */
 	u_int8_t	state;		/* state of the connection (enum tcp_conntrack) */
 	/* For detecting stale connections */
diff --git a/net/netfilter/nf_conntrack_proto_tcp.c b/net/netfilter/nf_=
conntrack_proto_tcp.c
index a1edb9c..1bc8fc1 100644
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
+	spin_lock_bh(&ct->proto.lock);
 	/*
 	 * We have to worry for the ack in the reply packet only...
 	 */
 	if (after(end, ct->proto.tcp.seen[dir].td_end))
 		ct->proto.tcp.seen[dir].td_end =3D end;
 	ct->proto.tcp.last_end =3D end;
-	write_unlock_bh(&tcp_lock);
+	spin_unlock_bh(&ct->proto.lock);
 	pr_debug("tcp_update: sender end=3D%u maxend=3D%u maxwin=3D%u scale=3D=
%i "
 		 "receiver end=3D%u maxend=3D%u maxwin=3D%u scale=3D%i\n",
 		 sender->td_end, sender->td_maxend, sender->td_maxwin,
@@ -821,7 +816,7 @@ static int tcp_packet(struct nf_conn *ct,
 	th =3D skb_header_pointer(skb, dataoff, sizeof(_tcph), &_tcph);
 	BUG_ON(th =3D=3D NULL);
=20
-	write_lock_bh(&tcp_lock);
+	spin_lock_bh(&ct->proto.tcp.lock);
 	old_state =3D ct->proto.tcp.state;
 	dir =3D CTINFO2DIR(ctinfo);
 	index =3D get_conntrack_index(th);
@@ -851,7 +846,7 @@ static int tcp_packet(struct nf_conn *ct,
 		        && ct->proto.tcp.last_index =3D=3D TCP_RST_SET)) {
 			/* Attempt to reopen a closed/aborted connection.
 			 * Delete this connection and look up again. */
-			write_unlock_bh(&tcp_lock);
+			spin_unlock_bh(&ct->proto.tcp.lock);
=20
 			/* Only repeat if we can actually remove the timer.
 			 * Destruction may already be in progress in process
@@ -887,7 +882,7 @@ static int tcp_packet(struct nf_conn *ct,
 			 * that the client cannot but retransmit its SYN and
 			 * thus initiate a clean new session.
 			 */
-			write_unlock_bh(&tcp_lock);
+			spin_unlock_bh(&ct->proto.tcp.lock);
 			if (LOG_INVALID(net, IPPROTO_TCP))
 				nf_log_packet(pf, 0, skb, NULL, NULL, NULL,
 					  "nf_ct_tcp: killing out of sync session ");
@@ -900,7 +895,7 @@ static int tcp_packet(struct nf_conn *ct,
 		ct->proto.tcp.last_end =3D
 		    segment_seq_plus_len(ntohl(th->seq), skb->len, dataoff, th);
=20
-		write_unlock_bh(&tcp_lock);
+		spin_unlock_bh(&ct->proto.tcp.lock);
 		if (LOG_INVALID(net, IPPROTO_TCP))
 			nf_log_packet(pf, 0, skb, NULL, NULL, NULL,
 				  "nf_ct_tcp: invalid packet ignored ");
@@ -909,7 +904,7 @@ static int tcp_packet(struct nf_conn *ct,
 		/* Invalid packet */
 		pr_debug("nf_ct_tcp: Invalid dir=3D%i index=3D%u ostate=3D%u\n",
 			 dir, get_conntrack_index(th), old_state);
-		write_unlock_bh(&tcp_lock);
+		spin_unlock_bh(&ct->proto.tcp.lock);
 		if (LOG_INVALID(net, IPPROTO_TCP))
 			nf_log_packet(pf, 0, skb, NULL, NULL, NULL,
 				  "nf_ct_tcp: invalid state ");
@@ -940,7 +935,7 @@ static int tcp_packet(struct nf_conn *ct,
=20
 	if (!tcp_in_window(ct, &ct->proto.tcp, dir, index,
 			   skb, dataoff, th, pf)) {
-		write_unlock_bh(&tcp_lock);
+		spin_unlock_bh(&ct->proto.tcp.lock);
 		return -NF_ACCEPT;
 	}
      in_window:
@@ -969,7 +964,7 @@ static int tcp_packet(struct nf_conn *ct,
 		timeout =3D nf_ct_tcp_timeout_unacknowledged;
 	else
 		timeout =3D tcp_timeouts[new_state];
-	write_unlock_bh(&tcp_lock);
+	spin_unlock_bh(&ct->proto.tcp.lock);
=20
 	nf_conntrack_event_cache(IPCT_PROTOINFO_VOLATILE, ct);
 	if (new_state !=3D old_state)
@@ -1022,6 +1017,7 @@ static bool tcp_new(struct nf_conn *ct, const str=
uct sk_buff *skb,
 		pr_debug("nf_ct_tcp: invalid new deleting.\n");
 		return false;
 	}
+	spin_lock_init(&ct->proto.tcp.lock);
=20
 	if (new_state =3D=3D TCP_CONNTRACK_SYN_SENT) {
 		/* SYN packet */
@@ -1092,7 +1088,7 @@ static int tcp_to_nlattr(struct sk_buff *skb, str=
uct nlattr *nla,
 	struct nlattr *nest_parms;
 	struct nf_ct_tcp_flags tmp =3D {};
=20
-	read_lock_bh(&tcp_lock);
+	spin_lock_bh(&ct->proto.tcp.lock);
 	nest_parms =3D nla_nest_start(skb, CTA_PROTOINFO_TCP | NLA_F_NESTED);
 	if (!nest_parms)
 		goto nla_put_failure;
@@ -1112,14 +1108,14 @@ static int tcp_to_nlattr(struct sk_buff *skb, s=
truct nlattr *nla,
 	tmp.flags =3D ct->proto.tcp.seen[1].flags;
 	NLA_PUT(skb, CTA_PROTOINFO_TCP_FLAGS_REPLY,
 		sizeof(struct nf_ct_tcp_flags), &tmp);
-	read_unlock_bh(&tcp_lock);
+	spin_unlock_bh(&ct->proto.tcp.lock);
=20
 	nla_nest_end(skb, nest_parms);
=20
 	return 0;
=20
 nla_put_failure:
-	read_unlock_bh(&tcp_lock);
+	spin_unlock_bh(&ct->proto.tcp.lock);
 	return -1;
 }
=20
@@ -1150,7 +1146,7 @@ static int nlattr_to_tcp(struct nlattr *cda[], st=
ruct nf_conn *ct)
 	    nla_get_u8(tb[CTA_PROTOINFO_TCP_STATE]) >=3D TCP_CONNTRACK_MAX)
 		return -EINVAL;
=20
-	write_lock_bh(&tcp_lock);
+	spin_lock_bh(&ct->proto.tcp.lock);
 	if (tb[CTA_PROTOINFO_TCP_STATE])
 		ct->proto.tcp.state =3D nla_get_u8(tb[CTA_PROTOINFO_TCP_STATE]);
=20
@@ -1177,7 +1173,7 @@ static int nlattr_to_tcp(struct nlattr *cda[], st=
ruct nf_conn *ct)
 		ct->proto.tcp.seen[1].td_scale =3D
 			nla_get_u8(tb[CTA_PROTOINFO_TCP_WSCALE_REPLY]);
 	}
-	write_unlock_bh(&tcp_lock);
+	spin_unlock_bh(&ct->proto.tcp.lock);
=20
 	return 0;
 }

--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
