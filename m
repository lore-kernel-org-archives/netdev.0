From: jamal <hadi@cyberus.ca>
Subject: Re: patch2: del/get byid
Date: Thu, 28 Apr 2005 10:20:33 -0400
Message-ID: <1114698033.7663.197.camel@localhost.localdomain>
References: <1114654284.7663.50.camel@localhost.localdomain>
	 <20050428021426.GA23415@gondor.apana.org.au>
	 <1114655014.7663.61.camel@localhost.localdomain>
	 <20050428022549.GA23556@gondor.apana.org.au>
	 <1114655980.7663.76.camel@localhost.localdomain>
	 <20050428024253.GA23695@gondor.apana.org.au>
	 <1114656932.7663.88.camel@localhost.localdomain>
	 <20050428030325.GB23823@gondor.apana.org.au>
	 <1114658657.7663.110.camel@localhost.localdomain>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-DDdKt4BejgU2c4VMw0+4"
Cc: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>, netdev@oss.sgi.com,
        "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <1114658657.7663.110.camel@localhost.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--=-DDdKt4BejgU2c4VMw0+4
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

On Wed, 2005-27-04 at 23:24 -0400, jamal wrote:
> On Thu, 2005-28-04 at 13:03 +1000, Herbert Xu wrote:
> 
> > Or we can simply put it in a field called dir and start using it
> > instead of passing it around :)
> > 
> 
> that would be the best option. 

Well, heres some minimalist patch i havent tested. i.e doesnt change any
of the functions; but at least it doesnt break the timers.
This includes both patches i posted earlier and introduces dir in 
xfrm_policy. 

cheers,
jamal

--=-DDdKt4BejgU2c4VMw0+4
Content-Disposition: attachment; filename=polid_p4
Content-Type: text/plain; name=polid_p4; charset=utf-8
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
+++ b/net/xfrm/xfrm_policy.c	2005/04/28 14:02:18
@@ -163,7 +163,7 @@
 	if (xp->dead)
 		goto out;
 
-	dir = xp->index & 7;
+	dir = xp->dir;
 
 	if (xp->lft.hard_add_expires_seconds) {
 		long tmo = xp->lft.hard_add_expires_seconds +
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
@@ -413,7 +418,7 @@
 	struct xfrm_policy *pol, **p;
 
 	write_lock_bh(&xfrm_policy_lock);
-	for (p = &xfrm_policy_list[id & 7]; (pol=*p)!=NULL; p = &pol->next) {
+	for (p = &xfrm_policy_list[dir]; (pol=*p)!=NULL; p = &pol->next) {
 		if (pol->index == id) {
 			xfrm_pol_hold(pol);
 			if (delete)

--=-DDdKt4BejgU2c4VMw0+4--
