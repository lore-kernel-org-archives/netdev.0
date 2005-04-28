From: jamal <hadi@cyberus.ca>
Subject: Re: patch: policy update by id
Date: Wed, 27 Apr 2005 21:44:40 -0400
Message-ID: <1114652680.7663.31.camel@localhost.localdomain>
References: <1114602874.7670.4.camel@localhost.localdomain>
	 <1114604657.7670.22.camel@localhost.localdomain>
	 <1114604826.7670.24.camel@localhost.localdomain>
	 <20050427233924.GA22238@gondor.apana.org.au>
	 <1114650816.7663.13.camel@localhost.localdomain>
	 <20050428012135.GA22950@gondor.apana.org.au>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-vLEVTr45h8CK2KiIrX87"
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20050428012135.GA22950@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--=-vLEVTr45h8CK2KiIrX87
Content-Type: text/plain
Content-Transfer-Encoding: 7bit


I found a bug in the kernel that i initially thought was in "ip x p". 
If you specify an index when creating a new rule,  the kernel overrides
it regardless.
So i can now update by index with attached patch.

On Thu, 2005-28-04 at 11:21 +1000, Herbert Xu wrote:

> I see.  In that case you want to change your expression above
> so that the memcmp is never done if excl is off and the index
> is non-zero.

Hrm. Thinking... So you want to exclude the selector check if someone
updating ever specified the index? That may change things a little, no?
Give me a clever expression.

>   Otherwise this will result in non-deterministic
> behaviour as the result will change depending on whether the
> first hit is an index match or a selector match.
> 

I was trying to emulate the get/del. There if p->index is specified
it trumps the selector as a search key. 
 
> Actually, would it be so bad to check the policy->index for the
> add case? It does have a well-defined meaning there.

That may not be totally unreasonable depending on what you mean by 
"well defined meaning" ;->
If we want to ensure that theres a uniqueness of indices, then it makes
sense. i.e  noone should be able to add either a selector or index which
match what already is in the SPD (per direction and probably ifindex).
Is that what you mean?

cheers,
jamal

--=-vLEVTr45h8CK2KiIrX87
Content-Disposition: attachment; filename=polid_p2
Content-Type: text/plain; name=polid_p2; charset=utf-8
Content-Transfer-Encoding: 7bit

--- a/net/xfrm/xfrm_policy.c	2005/04/27 11:32:13	1.1
+++ b/net/xfrm/xfrm_policy.c	2005/04/28 01:22:42
@@ -345,7 +345,10 @@
 
 	write_lock_bh(&xfrm_policy_lock);
 	for (p = &xfrm_policy_list[dir]; (pol=*p)!=NULL;) {
-		if (!delpol && memcmp(&policy->selector, &pol->selector, sizeof(pol->selector)) == 0) {
+		if (!delpol && 
+		    ((!excl && policy->index && 
+		      (policy->index == pol->index)) || 
+		    (memcmp(&policy->selector, &pol->selector, sizeof(pol->selector)) == 0))) {
 			if (excl) {
 				write_unlock_bh(&xfrm_policy_lock);
 				return -EEXIST;
@@ -370,7 +373,9 @@
 	policy->next = *p;
 	*p = policy;
 	atomic_inc(&flow_cache_genid);
-	policy->index = delpol ? delpol->index : xfrm_gen_index(dir);
+	if (!policy->index)
+		policy->index = delpol ? delpol->index : xfrm_gen_index(dir);
+
 	policy->curlft.add_time = (unsigned long)xtime.tv_sec;
 	policy->curlft.use_time = 0;
 	if (!mod_timer(&policy->timer, jiffies + HZ))

--=-vLEVTr45h8CK2KiIrX87--
