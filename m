From: Eric Dumazet <dada1@cosmosbay.com>
Subject: [NET] ROUTE: fix rcu_dereference() uses in /proc/net/rt_cache
Date: Wed, 09 Jan 2008 08:38:56 +0100
Message-ID: <47847A10.1020508@cosmosbay.com>
References: <E1JCU1E-00076z-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------090903080006020109060807"
Cc: davem@davemloft.net, dipankar@in.ibm.com, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([86.65.150.130]:55138 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750962AbYAIHkN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Jan 2008 02:40:13 -0500
In-Reply-To: <E1JCU1E-00076z-00@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------090903080006020109060807
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 8bit

Herbert Xu a écrit :
> Eric Dumazet <dada1@cosmosbay.com> wrote:
>> Very good question, but honestly I really dont see why it was there at the 
>> first place :
> 
> It was there because someone went through this file and robotically
> replaced all conditional read barriers with rcu_dereference, even when
> it made zero sense.
> 
> Basically you can add a conditional barrier either at the point where
> the pointer gets read, or where it gets derferenced.  Previously we
> did the latter (except that the show function didn't have a barrier
> at all which is technically a bug though harmless in pratice).  This
> patch moves it to the spot where it gets read which is also OK.
> 
>> static struct rtable *rt_cache_get_next(struct seq_file *seq, struct rtable *r)
>> {
>> -       struct rt_cache_iter_state *st = rcu_dereference(seq->private);
>> +       struct rt_cache_iter_state *st = seq->private;
>>
>> -       r = r->u.dst.rt_next;
>> +       r = rcu_dereference(r->u.dst.rt_next);
>>        while (!r) {
>>                rcu_read_unlock_bh();
>>                if (--st->bucket < 0)
>>                        break;
>>                rcu_read_lock_bh();
>> -               r = rt_hash_table[st->bucket].chain;
>> +               r = rcu_dereference(rt_hash_table[st->bucket].chain);
>>        }
>>        return r;
> 
> Slight optimisation: please move both barriers onto the return statement,
> i.e.,
> 
> 	return rcu_dereference(r);

I am not sure this is valid, since it will do this :

r = rt_hash_table[st->bucket].chain;
if (r)
     return rcu_dereference(r);

So compiler might be dumb enough do dereference 
&rt_hash_table[st->bucket].chain two times.


It seems Dipankar is busy at this moment, so I will post again the patch and 
ask a comment from Paul :)

Thank you

[NET] ROUTE: fix rcu_dereference() uses in /proc/net/rt_cache

In rt_cache_get_next(), no need to guard seq->private by a rcu_dereference()
since seq is private to the thread running this function. Reading seq.private
once (as guaranted bu rcu_dereference()) or several time if compiler really is 
dumb enough wont change the result.

But we miss real spots where rcu_dereference() are needed, both in 
rt_cache_get_first() and rt_cache_get_next()

Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>


--------------090903080006020109060807
Content-Type: text/plain;
 name="route_rcu.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="route_rcu.patch"

diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index d337706..3b7562f 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -278,7 +278,7 @@ static struct rtable *rt_cache_get_first(struct seq_file *seq)
 
 	for (st->bucket = rt_hash_mask; st->bucket >= 0; --st->bucket) {
 		rcu_read_lock_bh();
-		r = rt_hash_table[st->bucket].chain;
+		r = rcu_dereference(rt_hash_table[st->bucket].chain);
 		if (r)
 			break;
 		rcu_read_unlock_bh();
@@ -288,15 +288,15 @@ static struct rtable *rt_cache_get_first(struct seq_file *seq)
 
 static struct rtable *rt_cache_get_next(struct seq_file *seq, struct rtable *r)
 {
-	struct rt_cache_iter_state *st = rcu_dereference(seq->private);
+	struct rt_cache_iter_state *st = seq->private;
 
-	r = r->u.dst.rt_next;
+	r = rcu_dereference(r->u.dst.rt_next);
 	while (!r) {
 		rcu_read_unlock_bh();
 		if (--st->bucket < 0)
 			break;
 		rcu_read_lock_bh();
-		r = rt_hash_table[st->bucket].chain;
+		r = rcu_dereference(rt_hash_table[st->bucket].chain);
 	}
 	return r;
 }

--------------090903080006020109060807--
