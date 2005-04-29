From: jamal <hadi@cyberus.ca>
Subject: Re: patch2: del/get byid
Date: Fri, 29 Apr 2005 19:20:46 -0400
Message-ID: <1114816846.8929.6.camel@localhost.localdomain>
References: <1114654284.7663.50.camel@localhost.localdomain>
	 <20050428021426.GA23415@gondor.apana.org.au>
	 <1114655014.7663.61.camel@localhost.localdomain>
	 <20050428022549.GA23556@gondor.apana.org.au>
	 <1114655980.7663.76.camel@localhost.localdomain>
	 <20050428024253.GA23695@gondor.apana.org.au>
	 <1114656932.7663.88.camel@localhost.localdomain>
	 <20050428030325.GB23823@gondor.apana.org.au>
	 <1114658657.7663.110.camel@localhost.localdomain>
	 <1114698033.7663.197.camel@localhost.localdomain>
	 <20050428231154.GA14215@gondor.apana.org.au>
	 <1114779104.7800.22.camel@localhost.localdomain>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-MXR6c/QI0Gc5RpbAqqam"
Cc: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>, netdev@oss.sgi.com,
        "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <1114779104.7800.22.camel@localhost.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--=-MXR6c/QI0Gc5RpbAqqam
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

On Fri, 2005-29-04 at 08:51 -0400, jamal wrote:
> On Fri, 2005-29-04 at 09:11 +1000, Herbert Xu wrote:

> > 
> > You also still need to solve the problem that you may need to
> > delete two policies if one matches the index while the other matches
> > the selector (or selector plus priority if you do that).
> > 
> 
> Ok, this bit is tricky...  that is unless we disallowed it from
> happening in the first place maybe
> 
> i.e something along the lines of:
> 
> delp1 = find by index
> delp2 = find by selector
> if delp1 && delp2 and delp1 != delp2
> return -EINVAL
> 
> // so far good. check the add case
> if delp1 || delp2 and excl
> return -EEXIST
>         
> do the insert here based on priority ..
> 
> Thoughts?

Ok, here is the patch - I spent about 30 minutes testing - some of the
logs i remembered capturing attached (in these tests i was trying to
update a rule by selector or index and and see that it gets moved
correctly in terms of priority order).


A rule is unique by both selector(which it was already) and index(new).


cheers,
jamal

--=-MXR6c/QI0Gc5RpbAqqam
Content-Disposition: attachment; filename=polid_p5
Content-Type: text/plain; name=polid_p5; charset=utf-8
Content-Transfer-Encoding: 7bit

--- a/include/net/xfrm.h	2005/04/28 14:05:00	1.1
+++ b/include/net/xfrm.h	2005/04/28 14:05:48
@@ -302,6 +302,7 @@
 	struct dst_entry       *bundles;
 	__u16			family;
 	__u8			action;
+	__u8			dir;
 	__u8			flags;
 	__u8			dead;
 	__u8			xfrm_nr;
--- a/net/xfrm/xfrm_user.c	2005/04/28 13:59:27	1.1
+++ b/net/xfrm/xfrm_user.c	2005/04/28 14:01:58
@@ -653,6 +653,7 @@
 	memcpy(&xp->selector, &p->sel, sizeof(xp->selector));
 	memcpy(&xp->lft, &p->lft, sizeof(xp->lft));
 	xp->action = p->action;
+	xp->dir = p->dir;
 	xp->flags = p->flags;
 	xp->family = p->sel.family;
 	/* XXX xp->share = p->share; */
--- a/net/xfrm/xfrm_policy.c	2005/04/27 11:32:13	1.1
+++ b/net/xfrm/xfrm_policy.c	2005/04/29 23:07:38
@@ -163,7 +163,7 @@
 	if (xp->dead)
 		goto out;
 
-	dir = xp->index & 7;
+	dir = xp->dir;
 
 	if (xp->lft.hard_add_expires_seconds) {
 		long tmo = xp->lft.hard_add_expires_seconds +
@@ -341,17 +341,35 @@
 {
 	struct xfrm_policy *pol, **p;
 	struct xfrm_policy *delpol = NULL;
+	struct xfrm_policy *delpol2 = NULL;
+	struct xfrm_policy *delp = NULL;
 	struct xfrm_policy **newpos = NULL;
+	int ret = -EINVAL;
+
+	if (policy->index)
+		delpol = xfrm_policy_byid(dir, policy->index, 0);
+	delpol2 = xfrm_policy_bysel(dir, &policy->selector, 0);
+
+	/* must be unique in both index and selector */
+	if (delpol && delpol2) 
+		if (delpol != delpol2) 
+			goto pol_err;
 
+	if (delpol) 
+		delp = delpol;
+	else 
+		delp = delpol2;
+			
+	if (delp && excl) { 
+		ret = -EEXIST;
+		goto pol_err;
+	}
+
+	/* insert, sorted by prio*/
 	write_lock_bh(&xfrm_policy_lock);
 	for (p = &xfrm_policy_list[dir]; (pol=*p)!=NULL;) {
-		if (!delpol && memcmp(&policy->selector, &pol->selector, sizeof(pol->selector)) == 0) {
-			if (excl) {
-				write_unlock_bh(&xfrm_policy_lock);
-				return -EEXIST;
-			}
+		if (pol == delp) {
 			*p = pol->next;
-			delpol = pol;
 			if (policy->priority > pol->priority)
 				continue;
 		} else if (policy->priority >= pol->priority) {
@@ -360,27 +378,36 @@
 		}
 		if (!newpos)
 			newpos = p;
-		if (delpol)
-			break;
 		p = &pol->next;
 	}
+
 	if (newpos)
 		p = newpos;
+	
 	xfrm_pol_hold(policy);
 	policy->next = *p;
 	*p = policy;
 	atomic_inc(&flow_cache_genid);
-	policy->index = delpol ? delpol->index : xfrm_gen_index(dir);
+	if (!policy->index)
+		policy->index = delp ? delp->index : xfrm_gen_index(dir);
+
 	policy->curlft.add_time = (unsigned long)xtime.tv_sec;
 	policy->curlft.use_time = 0;
 	if (!mod_timer(&policy->timer, jiffies + HZ))
 		xfrm_pol_hold(policy);
 	write_unlock_bh(&xfrm_policy_lock);
 
-	if (delpol) {
-		xfrm_policy_kill(delpol);
+	if (delp) {
+		xfrm_policy_kill(delp);
 	}
-	return 0;
+	ret = 0;
+
+pol_err:
+	if (delpol)
+		xfrm_pol_put(delpol);
+	if (delpol2)
+		xfrm_pol_put(delpol2);
+	return ret;
 }
 EXPORT_SYMBOL(xfrm_policy_insert);
 
@@ -413,7 +440,7 @@
 	struct xfrm_policy *pol, **p;
 
 	write_lock_bh(&xfrm_policy_lock);
-	for (p = &xfrm_policy_list[id & 7]; (pol=*p)!=NULL; p = &pol->next) {
+	for (p = &xfrm_policy_list[dir]; (pol=*p)!=NULL; p = &pol->next) {
 		if (pol->index == id) {
 			xfrm_pol_hold(pol);
 			if (delete)

--=-MXR6c/QI0Gc5RpbAqqam
Content-Disposition: attachment; filename=ipsec-spd-priotst
Content-Type: text/plain; name=ipsec-spd-priotst; charset=utf-8
Content-Transfer-Encoding: 7bit

IP=./root/iproute-mod/ip/ip 
root@jzny2: $IP x p flush
root@jzny2: $IP -s x p ls
root@jzny2: $IP x policy add dir in index 1 priority 10 src 12.0.0.10/24 dst 12.0.0.2/24
root@jzny2: $IP x policy add dir in index 2 priority 100 src 11.0.0.10/24 dst 12.0.0.2/24
root@jzny2: $IP x policy add dir in index 4 priority 200 src 11.0.0.10/24 dst 11.0.0.2/24
root@jzny2: $IP x policy add dir in index 5 priority 400 src 13.0.0.10/24 dst 11.0.0.2/24
root@jzny2: $IP -s x p ls
src 12.0.0.10/24 dst 12.0.0.2/24 uid 0
	dir in action allow index 1 priority 10 share any flag 0x00000000
	lifetime config:
	  limit: soft (INF)(bytes), hard (INF)(bytes)
	  limit: soft (INF)(packets), hard (INF)(packets)
	  expire add: soft 0(sec), hard 0(sec)
	  expire use: soft 0(sec), hard 0(sec)
	lifetime current:
	  0(bytes), 0(packets)
	  add 2005-04-29 22:16:54 use -
src 11.0.0.10/24 dst 12.0.0.2/24 uid 0
	dir in action allow index 2 priority 100 share any flag 0x00000000
	lifetime config:
	  limit: soft (INF)(bytes), hard (INF)(bytes)
	  limit: soft (INF)(packets), hard (INF)(packets)
	  expire add: soft 0(sec), hard 0(sec)
	  expire use: soft 0(sec), hard 0(sec)
	lifetime current:
	  0(bytes), 0(packets)
	  add 2005-04-29 22:16:54 use -
src 11.0.0.10/24 dst 11.0.0.2/24 uid 0
	dir in action allow index 4 priority 200 share any flag 0x00000000
	lifetime config:
	  limit: soft (INF)(bytes), hard (INF)(bytes)
	  limit: soft (INF)(packets), hard (INF)(packets)
	  expire add: soft 0(sec), hard 0(sec)
	  expire use: soft 0(sec), hard 0(sec)
	lifetime current:
	  0(bytes), 0(packets)
	  add 2005-04-29 22:16:54 use -
src 13.0.0.10/24 dst 11.0.0.2/24 uid 0
	dir in action allow index 5 priority 400 share any flag 0x00000000
	lifetime config:
	  limit: soft (INF)(bytes), hard (INF)(bytes)
	  limit: soft (INF)(packets), hard (INF)(packets)
	  expire add: soft 0(sec), hard 0(sec)
	  expire use: soft 0(sec), hard 0(sec)
	lifetime current:
	  0(bytes), 0(packets)
	  add 2005-04-29 22:16:54 use -

root@jzny2: $IP x policy update dir in priority 120 src 12.0.0.10/24 dst 12.0.0.2/24
root@jzny2: $IP -s x p ls
src 11.0.0.10/24 dst 12.0.0.2/24 uid 0
	dir in action allow index 2 priority 100 share any flag 0x00000000
	lifetime config:
	  limit: soft (INF)(bytes), hard (INF)(bytes)
	  limit: soft (INF)(packets), hard (INF)(packets)
	  expire add: soft 0(sec), hard 0(sec)
	  expire use: soft 0(sec), hard 0(sec)
	lifetime current:
	  0(bytes), 0(packets)
	  add 2005-04-29 22:16:54 use -
src 12.0.0.10/24 dst 12.0.0.2/24 uid 0
	dir in action allow index 1 priority 120 share any flag 0x00000000
	lifetime config:
	  limit: soft (INF)(bytes), hard (INF)(bytes)
	  limit: soft (INF)(packets), hard (INF)(packets)
	  expire add: soft 0(sec), hard 0(sec)
	  expire use: soft 0(sec), hard 0(sec)
	lifetime current:
	  0(bytes), 0(packets)
	  add 2005-04-29 22:16:54 use -
src 11.0.0.10/24 dst 11.0.0.2/24 uid 0
	dir in action allow index 4 priority 200 share any flag 0x00000000
	lifetime config:
	  limit: soft (INF)(bytes), hard (INF)(bytes)
	  limit: soft (INF)(packets), hard (INF)(packets)
	  expire add: soft 0(sec), hard 0(sec)
	  expire use: soft 0(sec), hard 0(sec)
	lifetime current:
	  0(bytes), 0(packets)
	  add 2005-04-29 22:16:54 use -
src 13.0.0.10/24 dst 11.0.0.2/24 uid 0
	dir in action allow index 5 priority 400 share any flag 0x00000000
	lifetime config:
	  limit: soft (INF)(bytes), hard (INF)(bytes)
	  limit: soft (INF)(packets), hard (INF)(packets)
	  expire add: soft 0(sec), hard 0(sec)
	  expire use: soft 0(sec), hard 0(sec)
	lifetime current:
	  0(bytes), 0(packets)
	  add 2005-04-29 22:16:54 use -

root@jzny2: $IP x policy update dir in priority 220 src 12.0.0.10/24 dst 12.0.0.2/24
root@jzny2: $IP -s x p ls
src 11.0.0.10/24 dst 12.0.0.2/24 uid 0
	dir in action allow index 2 priority 100 share any flag 0x00000000
	lifetime config:
	  limit: soft (INF)(bytes), hard (INF)(bytes)
	  limit: soft (INF)(packets), hard (INF)(packets)
	  expire add: soft 0(sec), hard 0(sec)
	  expire use: soft 0(sec), hard 0(sec)
	lifetime current:
	  0(bytes), 0(packets)
	  add 2005-04-29 22:16:54 use -
src 11.0.0.10/24 dst 11.0.0.2/24 uid 0
	dir in action allow index 4 priority 200 share any flag 0x00000000
	lifetime config:
	  limit: soft (INF)(bytes), hard (INF)(bytes)
	  limit: soft (INF)(packets), hard (INF)(packets)
	  expire add: soft 0(sec), hard 0(sec)
	  expire use: soft 0(sec), hard 0(sec)
	lifetime current:
	  0(bytes), 0(packets)
	  add 2005-04-29 22:16:54 use -
src 12.0.0.10/24 dst 12.0.0.2/24 uid 0
	dir in action allow index 1 priority 220 share any flag 0x00000000
	lifetime config:
	  limit: soft (INF)(bytes), hard (INF)(bytes)
	  limit: soft (INF)(packets), hard (INF)(packets)
	  expire add: soft 0(sec), hard 0(sec)
	  expire use: soft 0(sec), hard 0(sec)
	lifetime current:
	  0(bytes), 0(packets)
	  add 2005-04-29 22:16:55 use -
src 13.0.0.10/24 dst 11.0.0.2/24 uid 0
	dir in action allow index 5 priority 400 share any flag 0x00000000
	lifetime config:
	  limit: soft (INF)(bytes), hard (INF)(bytes)
	  limit: soft (INF)(packets), hard (INF)(packets)
	  expire add: soft 0(sec), hard 0(sec)
	  expire use: soft 0(sec), hard 0(sec)
	lifetime current:
	  0(bytes), 0(packets)
	  add 2005-04-29 22:16:54 use -

root@jzny2: $IP x policy update dir in priority 420 src 12.0.0.10/24 dst 12.0.0.2/24
root@jzny2: $IP -s x p ls
src 11.0.0.10/24 dst 12.0.0.2/24 uid 0
	dir in action allow index 2 priority 100 share any flag 0x00000000
	lifetime config:
	  limit: soft (INF)(bytes), hard (INF)(bytes)
	  limit: soft (INF)(packets), hard (INF)(packets)
	  expire add: soft 0(sec), hard 0(sec)
	  expire use: soft 0(sec), hard 0(sec)
	lifetime current:
	  0(bytes), 0(packets)
	  add 2005-04-29 22:16:54 use -
src 11.0.0.10/24 dst 11.0.0.2/24 uid 0
	dir in action allow index 4 priority 200 share any flag 0x00000000
	lifetime config:
	  limit: soft (INF)(bytes), hard (INF)(bytes)
	  limit: soft (INF)(packets), hard (INF)(packets)
	  expire add: soft 0(sec), hard 0(sec)
	  expire use: soft 0(sec), hard 0(sec)
	lifetime current:
	  0(bytes), 0(packets)
	  add 2005-04-29 22:16:54 use -
src 13.0.0.10/24 dst 11.0.0.2/24 uid 0
	dir in action allow index 5 priority 400 share any flag 0x00000000
	lifetime config:
	  limit: soft (INF)(bytes), hard (INF)(bytes)
	  limit: soft (INF)(packets), hard (INF)(packets)
	  expire add: soft 0(sec), hard 0(sec)
	  expire use: soft 0(sec), hard 0(sec)
	lifetime current:
	  0(bytes), 0(packets)
	  add 2005-04-29 22:16:54 use -
src 12.0.0.10/24 dst 12.0.0.2/24 uid 0
	dir in action allow index 1 priority 420 share any flag 0x00000000
	lifetime config:
	  limit: soft (INF)(bytes), hard (INF)(bytes)
	  limit: soft (INF)(packets), hard (INF)(packets)
	  expire add: soft 0(sec), hard 0(sec)
	  expire use: soft 0(sec), hard 0(sec)
	lifetime current:
	  0(bytes), 0(packets)
	  add 2005-04-29 22:16:55 use -

root@jzny2: $IP x policy update dir in priority 20 src 12.0.0.10/24 dst 12.0.0.2/24
root@jzny2: $IP -s x p ls
src 12.0.0.10/24 dst 12.0.0.2/24 uid 0
	dir in action allow index 1 priority 20 share any flag 0x00000000
	lifetime config:
	  limit: soft (INF)(bytes), hard (INF)(bytes)
	  limit: soft (INF)(packets), hard (INF)(packets)
	  expire add: soft 0(sec), hard 0(sec)
	  expire use: soft 0(sec), hard 0(sec)
	lifetime current:
	  0(bytes), 0(packets)
	  add 2005-04-29 22:16:55 use -
src 11.0.0.10/24 dst 12.0.0.2/24 uid 0
	dir in action allow index 2 priority 100 share any flag 0x00000000
	lifetime config:
	  limit: soft (INF)(bytes), hard (INF)(bytes)
	  limit: soft (INF)(packets), hard (INF)(packets)
	  expire add: soft 0(sec), hard 0(sec)
	  expire use: soft 0(sec), hard 0(sec)
	lifetime current:
	  0(bytes), 0(packets)
	  add 2005-04-29 22:16:54 use -
src 11.0.0.10/24 dst 11.0.0.2/24 uid 0
	dir in action allow index 4 priority 200 share any flag 0x00000000
	lifetime config:
	  limit: soft (INF)(bytes), hard (INF)(bytes)
	  limit: soft (INF)(packets), hard (INF)(packets)
	  expire add: soft 0(sec), hard 0(sec)
	  expire use: soft 0(sec), hard 0(sec)
	lifetime current:
	  0(bytes), 0(packets)
	  add 2005-04-29 22:16:54 use -
src 13.0.0.10/24 dst 11.0.0.2/24 uid 0
	dir in action allow index 5 priority 400 share any flag 0x00000000
	lifetime config:
	  limit: soft (INF)(bytes), hard (INF)(bytes)
	  limit: soft (INF)(packets), hard (INF)(packets)
	  expire add: soft 0(sec), hard 0(sec)
	  expire use: soft 0(sec), hard 0(sec)
	lifetime current:
	  0(bytes), 0(packets)
	  add 2005-04-29 22:16:54 use -

root@jzny2: $IP x policy add dir in priority 30 src 13.0.0.10/24 dst 11.0.0.2/24
RTNETLINK answers: File exists

root@jzny2: $IP -s x p ls
src 12.0.0.10/24 dst 12.0.0.2/24 uid 0
	dir in action allow index 1 priority 20 share any flag 0x00000000
	lifetime config:
	  limit: soft (INF)(bytes), hard (INF)(bytes)
	  limit: soft (INF)(packets), hard (INF)(packets)
	  expire add: soft 0(sec), hard 0(sec)
	  expire use: soft 0(sec), hard 0(sec)
	lifetime current:
	  0(bytes), 0(packets)
	  add 2005-04-29 22:16:55 use -
src 11.0.0.10/24 dst 12.0.0.2/24 uid 0
	dir in action allow index 2 priority 100 share any flag 0x00000000
	lifetime config:
	  limit: soft (INF)(bytes), hard (INF)(bytes)
	  limit: soft (INF)(packets), hard (INF)(packets)
	  expire add: soft 0(sec), hard 0(sec)
	  expire use: soft 0(sec), hard 0(sec)
	lifetime current:
	  0(bytes), 0(packets)
	  add 2005-04-29 22:16:54 use -
src 11.0.0.10/24 dst 11.0.0.2/24 uid 0
	dir in action allow index 4 priority 200 share any flag 0x00000000
	lifetime config:
	  limit: soft (INF)(bytes), hard (INF)(bytes)
	  limit: soft (INF)(packets), hard (INF)(packets)
	  expire add: soft 0(sec), hard 0(sec)
	  expire use: soft 0(sec), hard 0(sec)
	lifetime current:
	  0(bytes), 0(packets)
	  add 2005-04-29 22:16:54 use -
src 13.0.0.10/24 dst 11.0.0.2/24 uid 0
	dir in action allow index 5 priority 400 share any flag 0x00000000
	lifetime config:
	  limit: soft (INF)(bytes), hard (INF)(bytes)
	  limit: soft (INF)(packets), hard (INF)(packets)
	  expire add: soft 0(sec), hard 0(sec)
	  expire use: soft 0(sec), hard 0(sec)
	lifetime current:
	  0(bytes), 0(packets)
	  add 2005-04-29 22:16:54 use -

root@jzny2: $IP x policy update dir in priority 700 src 12.0.0.10/24 dst 12.0.0.2/24
root@jzny2: $IP -s x p ls
src 11.0.0.10/24 dst 12.0.0.2/24 uid 0
	dir in action allow index 2 priority 100 share any flag 0x00000000
	lifetime config:
	  limit: soft (INF)(bytes), hard (INF)(bytes)
	  limit: soft (INF)(packets), hard (INF)(packets)
	  expire add: soft 0(sec), hard 0(sec)
	  expire use: soft 0(sec), hard 0(sec)
	lifetime current:
	  0(bytes), 0(packets)
	  add 2005-04-29 22:16:54 use -
src 11.0.0.10/24 dst 11.0.0.2/24 uid 0
	dir in action allow index 4 priority 200 share any flag 0x00000000
	lifetime config:
	  limit: soft (INF)(bytes), hard (INF)(bytes)
	  limit: soft (INF)(packets), hard (INF)(packets)
	  expire add: soft 0(sec), hard 0(sec)
	  expire use: soft 0(sec), hard 0(sec)
	lifetime current:
	  0(bytes), 0(packets)
	  add 2005-04-29 22:16:54 use -
src 13.0.0.10/24 dst 11.0.0.2/24 uid 0
	dir in action allow index 5 priority 400 share any flag 0x00000000
	lifetime config:
	  limit: soft (INF)(bytes), hard (INF)(bytes)
	  limit: soft (INF)(packets), hard (INF)(packets)
	  expire add: soft 0(sec), hard 0(sec)
	  expire use: soft 0(sec), hard 0(sec)
	lifetime current:
	  0(bytes), 0(packets)
	  add 2005-04-29 22:16:54 use -
src 12.0.0.10/24 dst 12.0.0.2/24 uid 0
	dir in action allow index 1 priority 700 share any flag 0x00000000
	lifetime config:
	  limit: soft (INF)(bytes), hard (INF)(bytes)
	  limit: soft (INF)(packets), hard (INF)(packets)
	  expire add: soft 0(sec), hard 0(sec)
	  expire use: soft 0(sec), hard 0(sec)
	lifetime current:
	  0(bytes), 0(packets)
	  add 2005-04-29 22:16:56 use -

root@jzny2: $IP x p flush
root@jzny2: $IP -s x p ls
root@jzny2: $IP x policy add dir in index 1 priority 10 src 12.0.0.10/24 dst 12.0.0.2/24
root@jzny2: $IP x policy add dir in index 2 priority 100 src 11.0.0.10/24 dst 12.0.0.2/24
root@jzny2: $IP x policy add dir in index 3 priority 200 src 11.0.0.10/24 dst 11.0.0.2/24
root@jzny2: $IP x policy add dir in index 4 priority 400 src 13.0.0.10/24 dst 11.0.0.2/24
root@jzny2: $IP -s x p ls
src 12.0.0.10/24 dst 12.0.0.2/24 uid 0
	dir in action allow index 1 priority 10 share any flag 0x00000000
	lifetime config:
	  limit: soft (INF)(bytes), hard (INF)(bytes)
	  limit: soft (INF)(packets), hard (INF)(packets)
	  expire add: soft 0(sec), hard 0(sec)
	  expire use: soft 0(sec), hard 0(sec)
	lifetime current:
	  0(bytes), 0(packets)
	  add 2005-04-29 22:16:59 use -
src 11.0.0.10/24 dst 12.0.0.2/24 uid 0
	dir in action allow index 2 priority 100 share any flag 0x00000000
	lifetime config:
	  limit: soft (INF)(bytes), hard (INF)(bytes)
	  limit: soft (INF)(packets), hard (INF)(packets)
	  expire add: soft 0(sec), hard 0(sec)
	  expire use: soft 0(sec), hard 0(sec)
	lifetime current:
	  0(bytes), 0(packets)
	  add 2005-04-29 22:16:59 use -
src 11.0.0.10/24 dst 11.0.0.2/24 uid 0
	dir in action allow index 3 priority 200 share any flag 0x00000000
	lifetime config:
	  limit: soft (INF)(bytes), hard (INF)(bytes)
	  limit: soft (INF)(packets), hard (INF)(packets)
	  expire add: soft 0(sec), hard 0(sec)
	  expire use: soft 0(sec), hard 0(sec)
	lifetime current:
	  0(bytes), 0(packets)
	  add 2005-04-29 22:16:59 use -
src 13.0.0.10/24 dst 11.0.0.2/24 uid 0
	dir in action allow index 4 priority 400 share any flag 0x00000000
	lifetime config:
	  limit: soft (INF)(bytes), hard (INF)(bytes)
	  limit: soft (INF)(packets), hard (INF)(packets)
	  expire add: soft 0(sec), hard 0(sec)
	  expire use: soft 0(sec), hard 0(sec)
	lifetime current:
	  0(bytes), 0(packets)
	  add 2005-04-29 22:16:59 use -

root@jzny2: $IP x policy update dir in priority 120 index 1
root@jzny2: $IP -s x p ls
src 11.0.0.10/24 dst 12.0.0.2/24 uid 0
	dir in action allow index 2 priority 100 share any flag 0x00000000
	lifetime config:
	  limit: soft (INF)(bytes), hard (INF)(bytes)
	  limit: soft (INF)(packets), hard (INF)(packets)
	  expire add: soft 0(sec), hard 0(sec)
	  expire use: soft 0(sec), hard 0(sec)
	lifetime current:
	  0(bytes), 0(packets)
	  add 2005-04-29 22:16:59 use -
src 0.0.0.0/0 dst 0.0.0.0/0 uid 0
	dir in action allow index 1 priority 120 share any flag 0x00000000
	lifetime config:
	  limit: soft (INF)(bytes), hard (INF)(bytes)
	  limit: soft (INF)(packets), hard (INF)(packets)
	  expire add: soft 0(sec), hard 0(sec)
	  expire use: soft 0(sec), hard 0(sec)
	lifetime current:
	  0(bytes), 0(packets)
	  add 2005-04-29 22:16:59 use 2005-04-29 22:16:59
src 11.0.0.10/24 dst 11.0.0.2/24 uid 0
	dir in action allow index 3 priority 200 share any flag 0x00000000
	lifetime config:
	  limit: soft (INF)(bytes), hard (INF)(bytes)
	  limit: soft (INF)(packets), hard (INF)(packets)
	  expire add: soft 0(sec), hard 0(sec)
	  expire use: soft 0(sec), hard 0(sec)
	lifetime current:
	  0(bytes), 0(packets)
	  add 2005-04-29 22:16:59 use -
src 13.0.0.10/24 dst 11.0.0.2/24 uid 0
	dir in action allow index 4 priority 400 share any flag 0x00000000
	lifetime config:
	  limit: soft (INF)(bytes), hard (INF)(bytes)
	  limit: soft (INF)(packets), hard (INF)(packets)
	  expire add: soft 0(sec), hard 0(sec)
	  expire use: soft 0(sec), hard 0(sec)
	lifetime current:
	  0(bytes), 0(packets)
	  add 2005-04-29 22:16:59 use -

root@jzny2: $IP x policy update dir in priority 220 index 1
root@jzny2: $IP -s x p ls
src 11.0.0.10/24 dst 12.0.0.2/24 uid 0
	dir in action allow index 2 priority 100 share any flag 0x00000000
	lifetime config:
	  limit: soft (INF)(bytes), hard (INF)(bytes)
	  limit: soft (INF)(packets), hard (INF)(packets)
	  expire add: soft 0(sec), hard 0(sec)
	  expire use: soft 0(sec), hard 0(sec)
	lifetime current:
	  0(bytes), 0(packets)
	  add 2005-04-29 22:16:59 use -
src 11.0.0.10/24 dst 11.0.0.2/24 uid 0
	dir in action allow index 3 priority 200 share any flag 0x00000000
	lifetime config:
	  limit: soft (INF)(bytes), hard (INF)(bytes)
	  limit: soft (INF)(packets), hard (INF)(packets)
	  expire add: soft 0(sec), hard 0(sec)
	  expire use: soft 0(sec), hard 0(sec)
	lifetime current:
	  0(bytes), 0(packets)
	  add 2005-04-29 22:16:59 use -
src 0.0.0.0/0 dst 0.0.0.0/0 uid 0
	dir in action allow index 1 priority 220 share any flag 0x00000000
	lifetime config:
	  limit: soft (INF)(bytes), hard (INF)(bytes)
	  limit: soft (INF)(packets), hard (INF)(packets)
	  expire add: soft 0(sec), hard 0(sec)
	  expire use: soft 0(sec), hard 0(sec)
	lifetime current:
	  0(bytes), 0(packets)
	  add 2005-04-29 22:17:00 use 2005-04-29 22:17:00
src 13.0.0.10/24 dst 11.0.0.2/24 uid 0
	dir in action allow index 4 priority 400 share any flag 0x00000000
	lifetime config:
	  limit: soft (INF)(bytes), hard (INF)(bytes)
	  limit: soft (INF)(packets), hard (INF)(packets)
	  expire add: soft 0(sec), hard 0(sec)
	  expire use: soft 0(sec), hard 0(sec)
	lifetime current:
	  0(bytes), 0(packets)
	  add 2005-04-29 22:16:59 use -

root@jzny2: $IP x policy update dir in priority 420 index 1
root@jzny2: $IP -s x p ls
src 11.0.0.10/24 dst 12.0.0.2/24 uid 0
	dir in action allow index 2 priority 100 share any flag 0x00000000
	lifetime config:
	  limit: soft (INF)(bytes), hard (INF)(bytes)
	  limit: soft (INF)(packets), hard (INF)(packets)
	  expire add: soft 0(sec), hard 0(sec)
	  expire use: soft 0(sec), hard 0(sec)
	lifetime current:
	  0(bytes), 0(packets)
	  add 2005-04-29 22:16:59 use -
src 11.0.0.10/24 dst 11.0.0.2/24 uid 0
	dir in action allow index 3 priority 200 share any flag 0x00000000
	lifetime config:
	  limit: soft (INF)(bytes), hard (INF)(bytes)
	  limit: soft (INF)(packets), hard (INF)(packets)
	  expire add: soft 0(sec), hard 0(sec)
	  expire use: soft 0(sec), hard 0(sec)
	lifetime current:
	  0(bytes), 0(packets)
	  add 2005-04-29 22:16:59 use -
src 13.0.0.10/24 dst 11.0.0.2/24 uid 0
	dir in action allow index 4 priority 400 share any flag 0x00000000
	lifetime config:
	  limit: soft (INF)(bytes), hard (INF)(bytes)
	  limit: soft (INF)(packets), hard (INF)(packets)
	  expire add: soft 0(sec), hard 0(sec)
	  expire use: soft 0(sec), hard 0(sec)
	lifetime current:
	  0(bytes), 0(packets)
	  add 2005-04-29 22:16:59 use -
src 0.0.0.0/0 dst 0.0.0.0/0 uid 0
	dir in action allow index 1 priority 420 share any flag 0x00000000
	lifetime config:
	  limit: soft (INF)(bytes), hard (INF)(bytes)
	  limit: soft (INF)(packets), hard (INF)(packets)
	  expire add: soft 0(sec), hard 0(sec)
	  expire use: soft 0(sec), hard 0(sec)
	lifetime current:
	  0(bytes), 0(packets)
	  add 2005-04-29 22:17:00 use 2005-04-29 22:17:00

root@jzny2: $IP x policy update dir in priority 20 index 1
root@jzny2: $IP -s x p ls
src 0.0.0.0/0 dst 0.0.0.0/0 uid 0
	dir in action allow index 1 priority 20 share any flag 0x00000000
	lifetime config:
	  limit: soft (INF)(bytes), hard (INF)(bytes)
	  limit: soft (INF)(packets), hard (INF)(packets)
	  expire add: soft 0(sec), hard 0(sec)
	  expire use: soft 0(sec), hard 0(sec)
	lifetime current:
	  0(bytes), 0(packets)
	  add 2005-04-29 22:17:01 use 2005-04-29 22:17:01
src 11.0.0.10/24 dst 12.0.0.2/24 uid 0
	dir in action allow index 2 priority 100 share any flag 0x00000000
	lifetime config:
	  limit: soft (INF)(bytes), hard (INF)(bytes)
	  limit: soft (INF)(packets), hard (INF)(packets)
	  expire add: soft 0(sec), hard 0(sec)
	  expire use: soft 0(sec), hard 0(sec)
	lifetime current:
	  0(bytes), 0(packets)
	  add 2005-04-29 22:16:59 use -
src 11.0.0.10/24 dst 11.0.0.2/24 uid 0
	dir in action allow index 3 priority 200 share any flag 0x00000000
	lifetime config:
	  limit: soft (INF)(bytes), hard (INF)(bytes)
	  limit: soft (INF)(packets), hard (INF)(packets)
	  expire add: soft 0(sec), hard 0(sec)
	  expire use: soft 0(sec), hard 0(sec)
	lifetime current:
	  0(bytes), 0(packets)
	  add 2005-04-29 22:16:59 use -
src 13.0.0.10/24 dst 11.0.0.2/24 uid 0
	dir in action allow index 4 priority 400 share any flag 0x00000000
	lifetime config:
	  limit: soft (INF)(bytes), hard (INF)(bytes)
	  limit: soft (INF)(packets), hard (INF)(packets)
	  expire add: soft 0(sec), hard 0(sec)
	  expire use: soft 0(sec), hard 0(sec)
	lifetime current:
	  0(bytes), 0(packets)
	  add 2005-04-29 22:16:59 use -

root@jzny2: $IP x policy add dir in priority 30 index 4
RTNETLINK answers: Invalid argument
root@jzny2: $IP -s x p ls
src 0.0.0.0/0 dst 0.0.0.0/0 uid 0
	dir in action allow index 1 priority 20 share any flag 0x00000000
	lifetime config:
	  limit: soft (INF)(bytes), hard (INF)(bytes)
	  limit: soft (INF)(packets), hard (INF)(packets)
	  expire add: soft 0(sec), hard 0(sec)
	  expire use: soft 0(sec), hard 0(sec)
	lifetime current:
	  0(bytes), 0(packets)
	  add 2005-04-29 22:17:01 use 2005-04-29 22:17:01
src 11.0.0.10/24 dst 12.0.0.2/24 uid 0
	dir in action allow index 2 priority 100 share any flag 0x00000000
	lifetime config:
	  limit: soft (INF)(bytes), hard (INF)(bytes)
	  limit: soft (INF)(packets), hard (INF)(packets)
	  expire add: soft 0(sec), hard 0(sec)
	  expire use: soft 0(sec), hard 0(sec)
	lifetime current:
	  0(bytes), 0(packets)
	  add 2005-04-29 22:16:59 use -
src 11.0.0.10/24 dst 11.0.0.2/24 uid 0
	dir in action allow index 3 priority 200 share any flag 0x00000000
	lifetime config:
	  limit: soft (INF)(bytes), hard (INF)(bytes)
	  limit: soft (INF)(packets), hard (INF)(packets)
	  expire add: soft 0(sec), hard 0(sec)
	  expire use: soft 0(sec), hard 0(sec)
	lifetime current:
	  0(bytes), 0(packets)
	  add 2005-04-29 22:16:59 use -
src 13.0.0.10/24 dst 11.0.0.2/24 uid 0
	dir in action allow index 4 priority 400 share any flag 0x00000000
	lifetime config:
	  limit: soft (INF)(bytes), hard (INF)(bytes)
	  limit: soft (INF)(packets), hard (INF)(packets)
	  expire add: soft 0(sec), hard 0(sec)
	  expire use: soft 0(sec), hard 0(sec)
	lifetime current:
	  0(bytes), 0(packets)
	  add 2005-04-29 22:16:59 use -

root@jzny2: $IP x policy update dir in priority 700 index 1
root@jzny2: $IP -s x p ls
src 11.0.0.10/24 dst 12.0.0.2/24 uid 0
	dir in action allow index 2 priority 100 share any flag 0x00000000
	lifetime config:
	  limit: soft (INF)(bytes), hard (INF)(bytes)
	  limit: soft (INF)(packets), hard (INF)(packets)
	  expire add: soft 0(sec), hard 0(sec)
	  expire use: soft 0(sec), hard 0(sec)
	lifetime current:
	  0(bytes), 0(packets)
	  add 2005-04-29 22:16:59 use -
src 11.0.0.10/24 dst 11.0.0.2/24 uid 0
	dir in action allow index 3 priority 200 share any flag 0x00000000
	lifetime config:
	  limit: soft (INF)(bytes), hard (INF)(bytes)
	  limit: soft (INF)(packets), hard (INF)(packets)
	  expire add: soft 0(sec), hard 0(sec)
	  expire use: soft 0(sec), hard 0(sec)
	lifetime current:
	  0(bytes), 0(packets)
	  add 2005-04-29 22:16:59 use -
src 13.0.0.10/24 dst 11.0.0.2/24 uid 0
	dir in action allow index 4 priority 400 share any flag 0x00000000
	lifetime config:
	  limit: soft (INF)(bytes), hard (INF)(bytes)
	  limit: soft (INF)(packets), hard (INF)(packets)
	  expire add: soft 0(sec), hard 0(sec)
	  expire use: soft 0(sec), hard 0(sec)
	lifetime current:
	  0(bytes), 0(packets)
	  add 2005-04-29 22:16:59 use -
src 0.0.0.0/0 dst 0.0.0.0/0 uid 0
	dir in action allow index 1 priority 700 share any flag 0x00000000
	lifetime config:
	  limit: soft (INF)(bytes), hard (INF)(bytes)
	  limit: soft (INF)(packets), hard (INF)(packets)
	  expire add: soft 0(sec), hard 0(sec)
	  expire use: soft 0(sec), hard 0(sec)
	lifetime current:
	  0(bytes), 0(packets)
	  add 2005-04-29 22:17:02 use 2005-04-29 22:17:02

--=-MXR6c/QI0Gc5RpbAqqam--
