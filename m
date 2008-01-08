From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [IPV4] ROUTE: ip_rt_dump() is unecessary slow
Date: Tue, 08 Jan 2008 07:37:43 +0100
Message-ID: <47831A37.5000607@cosmosbay.com>
References: <20080107193002.df137d57.dada1@cosmosbay.com>	<20080107.215253.250616600.davem@davemloft.net>	<47831412.40606@cosmosbay.com> <20080107.221537.178212902.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------070103030305090908030100"
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>,
	Dipankar Sarma <dipankar@in.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([86.65.150.130]:53569 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755856AbYAHGiD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Jan 2008 01:38:03 -0500
In-Reply-To: <20080107.221537.178212902.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------070103030305090908030100
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 8bit

David Miller a écrit :
> From: Eric Dumazet <dada1@cosmosbay.com>
> Date: Tue, 08 Jan 2008 07:11:30 +0100
> 
>> @@ -288,15 +288,15 @@ static struct rtable *rt_cache_get_first(struct seq_file *seq)
>>  
>>  static struct rtable *rt_cache_get_next(struct seq_file *seq, struct rtable *r)
>>  {
>> -	struct rt_cache_iter_state *st = rcu_dereference(seq->private);
>> +	struct rt_cache_iter_state *st = seq->private;
>>  
> 
> Can you explain to me why this rcu_dereference() can be removed?

Very good question, but honestly I really dont see why it was there at the 
first place :

"struct seq_file" is private to this thread, so seq.private is
also private and cannot change while this thread runs rt_cache_get_next().

Reading it once (as guaranted bu rcu_dereference()) or several time if 
compiler really is dumb enough wont change the result...

> 
> The rest of your patch is OK and once I understand the above
> I'll add it to net-2.6, thanks!
> 

Maybe we can first have an Ack from Dipankar Sarma, I can repost the patch
with a more precise ChangeLog and wait his answer ?

[NET] ROUTE: fix rcu_dereference() uses in /proc/net/rt_cache

In rt_cache_get_next(), no need to guard seq->private by a rcu_dereference()
since seq is private to the thread running this function. Reading seq.private
once (as guaranted bu rcu_dereference()) or several time if compiler really is 
dumb enough wont change the result.

But we miss real spots where rcu_dereference() are needed, both in 
rt_cache_get_first() and rt_cache_get_next()

Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>


--------------070103030305090908030100
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

--------------070103030305090908030100--
