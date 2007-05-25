From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [Bugme-new] [Bug 8536] New: Kernel drops UDP packets silently when reading from certain proc file entries
Date: Fri, 25 May 2007 16:23:56 +1000
Message-ID: <E1HrTDQ-0006qu-00@gondolin.me.apana.org.au>
References: <20070524125926.f91d64a2.akpm@linux-foundation.org>
Cc: netdev@vger.kernel.org, bugme-daemon@bugzilla.kernel.org,
	andsve@gmail.com
To: akpm@linux-foundation.org (Andrew Morton), davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:2491 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752084AbXEYGYH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 May 2007 02:24:07 -0400
In-Reply-To: <20070524125926.f91d64a2.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Andrew Morton <akpm@linux-foundation.org> wrote:
>
>> It is possible to introduce UDP packet losses by reading
>> the proc file entry /proc/net/tcp. The really strange thing is that
>> the error counters for packet drops are not increased. 

Please try this patch and let us know if it helps.

[TCPv4]: Improve BH latency in /proc/net/tcp

Currently the code for /proc/net/tcp disable BH while iterating
over the entire established hash table.  Even though we call
cond_resched_softirq for each entry, we still won't process
softirq's as regularly as we would otherwise do which results
in poor performance when the system is loaded near capacity.

This anomaly comes from the 2.4 code where this was all in a
single function and the local_bh_disable might have made sense
as a small optimisation.

The cost of each local_bh_disable is so small when compared
against the increased latency in keeping it disabled over a
large but mostly empty TCP established hash table that we
should just move it to the individual read_lock/read_unlock
calls as we do in inet_diag.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
--
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 5a3e7f8..9dab06d 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -2039,10 +2039,7 @@ static void *established_get_first(struct seq_file *seq)
 		struct hlist_node *node;
 		struct inet_timewait_sock *tw;
 
-		/* We can reschedule _before_ having picked the target: */
-		cond_resched_softirq();
-
-		read_lock(&tcp_hashinfo.ehash[st->bucket].lock);
+		read_lock_bh(&tcp_hashinfo.ehash[st->bucket].lock);
 		sk_for_each(sk, node, &tcp_hashinfo.ehash[st->bucket].chain) {
 			if (sk->sk_family != st->family) {
 				continue;
@@ -2059,7 +2056,7 @@ static void *established_get_first(struct seq_file *seq)
 			rc = tw;
 			goto out;
 		}
-		read_unlock(&tcp_hashinfo.ehash[st->bucket].lock);
+		read_unlock_bh(&tcp_hashinfo.ehash[st->bucket].lock);
 		st->state = TCP_SEQ_STATE_ESTABLISHED;
 	}
 out:
@@ -2086,14 +2083,11 @@ get_tw:
 			cur = tw;
 			goto out;
 		}
-		read_unlock(&tcp_hashinfo.ehash[st->bucket].lock);
+		read_unlock_bh(&tcp_hashinfo.ehash[st->bucket].lock);
 		st->state = TCP_SEQ_STATE_ESTABLISHED;
 
-		/* We can reschedule between buckets: */
-		cond_resched_softirq();
-
 		if (++st->bucket < tcp_hashinfo.ehash_size) {
-			read_lock(&tcp_hashinfo.ehash[st->bucket].lock);
+			read_lock_bh(&tcp_hashinfo.ehash[st->bucket].lock);
 			sk = sk_head(&tcp_hashinfo.ehash[st->bucket].chain);
 		} else {
 			cur = NULL;
@@ -2138,7 +2132,6 @@ static void *tcp_get_idx(struct seq_file *seq, loff_t pos)
 
 	if (!rc) {
 		inet_listen_unlock(&tcp_hashinfo);
-		local_bh_disable();
 		st->state = TCP_SEQ_STATE_ESTABLISHED;
 		rc	  = established_get_idx(seq, pos);
 	}
@@ -2171,7 +2164,6 @@ static void *tcp_seq_next(struct seq_file *seq, void *v, loff_t *pos)
 		rc = listening_get_next(seq, v);
 		if (!rc) {
 			inet_listen_unlock(&tcp_hashinfo);
-			local_bh_disable();
 			st->state = TCP_SEQ_STATE_ESTABLISHED;
 			rc	  = established_get_first(seq);
 		}
@@ -2203,8 +2195,7 @@ static void tcp_seq_stop(struct seq_file *seq, void *v)
 	case TCP_SEQ_STATE_TIME_WAIT:
 	case TCP_SEQ_STATE_ESTABLISHED:
 		if (v)
-			read_unlock(&tcp_hashinfo.ehash[st->bucket].lock);
-		local_bh_enable();
+			read_unlock_bh(&tcp_hashinfo.ehash[st->bucket].lock);
 		break;
 	}
 }
