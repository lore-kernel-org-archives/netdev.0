From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [IPV4] ROUTE: ip_rt_dump() is unecessary slow
Date: Tue, 08 Jan 2008 07:11:30 +0100
Message-ID: <47831412.40606@cosmosbay.com>
References: <20080107193002.df137d57.dada1@cosmosbay.com> <20080107.215253.250616600.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------070906050107050908070108"
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([86.65.150.130]:57093 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755843AbYAHGLj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Jan 2008 01:11:39 -0500
In-Reply-To: <20080107.215253.250616600.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------070906050107050908070108
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 8bit

David Miller a écrit :
> From: Eric Dumazet <dada1@cosmosbay.com>
> Date: Mon, 7 Jan 2008 19:30:02 +0100
> 
>> I noticed "ip route list cache x.y.z.t" can be *very* slow.
>>
>> While strace-ing -T it I also noticed that first part of route cache is
>> fetched quite fast :
>  ...
>> The following patch corrects this performance/latency problem, removing quadratic behavior.
>>
>> Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>
> 
> I think removing quadratic behavior is a bug fix, thus applied
> to net-2.6, thanks Eric :-)

You are the boss :)

I had another patch to submit, so I based it no net-2.6, please just say me if 
you prefer a net-2/6.25 one, as it's not a critical bug fix...

Thank you

[IPV4] ROUTE: fix rcu_dereference() uses in /proc/net/rt_cache

Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>


--------------070906050107050908070108
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

--------------070906050107050908070108--
