From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: netlink: Add netlink_bound helper and use it in netlink_getname
Date: Sat, 26 Sep 2015 21:16:21 +0800
Message-ID: <20150926131621.GA16724@gondor.apana.org.au>
References: <20150921133415.GA1740@gondor.apana.org.au>
 <20150921182022.GB13263@mtj.duckdns.org>
 <20150922033856.GA7851@gondor.apana.org.au>
 <20150924.121142.870602292135442487.davem@davemloft.net>
 <20150924200510.GE25415@mtj.duckdns.org>
 <20150925014327.GA3725@gondor.apana.org.au>
 <20150925150113.GD4449@mtj.duckdns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, cwang@twopensource.com,
	tom@herbertland.com, kafai@fb.com, kernel-team@fb.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	torvalds@linux-foundation.org, jiri@resnulli.us,
	nicolas.dichtel@6wind.com, tgraf@suug.ch, sfeldma@gmail.com
To: Tejun Heo <tj@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20150925150113.GD4449@mtj.duckdns.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Sep 25, 2015 at 11:01:13AM -0400, Tejun Heo wrote:
> 
> I'm not even sure we guarantee memory barrier on kernel/user
> crossings.  In practice, we probably have enough barriers (e.g. some
> syscall traps imply barrier) but I can't think of a reason why we'd
> guarantee the existence of barrier there.  As an extreme example,
> imagine UML on an architecture with relaxed memory model.

You misunderstood what I wrote.  I was not basing this on whether
user-space transitions contained a barrier, but on the fact that
the next syscall must recheck nlk->bound before using nlk->portid.

In fact thanks to your email I now realise that my fix to the
getsockname problem is wrong.  Instead of adding a barrier to
netlink_connect I should be adding a nlk->bound check to getname.

---8<---
netlink_getname must check nlk->bound before using nlk->portid
as otherwise nlk->portid may contain garbage.

This patch also adds a netlink_bound helper that encapsulate the
barrier, as was suggested by Tejun.  Also as suggested by Linus,
the lockless read of nlk->bound in netlink_bound is protected with
READ_ONCE to ensure that the compiler doesn't do double reads that
may screw up our use of the barrier.

Fixes: da314c9923fe ("netlink: Replace rhash_portid with bound")
Reported-by: Tejun Heo <tj@kernel.org>
Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index 2c15fae..c860464 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -125,6 +125,17 @@ static inline u32 netlink_group_mask(u32 group)
 	return group ? 1 << (group - 1) : 0;
 }
 
+static inline bool netlink_bound(struct netlink_sock *nlk)
+{
+	bool bound = READ_ONCE(nlk->bound);
+
+	/* Ensure nlk is hashed and visible. */
+	if (bound)
+		smp_rmb();
+
+	return bound;
+}
+
 int netlink_add_tap(struct netlink_tap *nt)
 {
 	if (unlikely(nt->dev->type != ARPHRD_NETLINK))
@@ -1524,14 +1535,10 @@ static int netlink_bind(struct socket *sock, struct sockaddr *addr,
 			return err;
 	}
 
-	bound = nlk->bound;
-	if (bound) {
-		/* Ensure nlk->portid is up-to-date. */
-		smp_rmb();
-
+	bound = netlink_bound(nlk);
+	if (bound)
 		if (nladdr->nl_pid != nlk->portid)
 			return -EINVAL;
-	}
 
 	if (nlk->netlink_bind && groups) {
 		int group;
@@ -1547,9 +1554,6 @@ static int netlink_bind(struct socket *sock, struct sockaddr *addr,
 		}
 	}
 
-	/* No need for barriers here as we return to user-space without
-	 * using any of the bound attributes.
-	 */
 	if (!bound) {
 		err = nladdr->nl_pid ?
 			netlink_insert(sk, nladdr->nl_pid) :
@@ -1628,7 +1632,7 @@ static int netlink_getname(struct socket *sock, struct sockaddr *addr,
 		nladdr->nl_pid = nlk->dst_portid;
 		nladdr->nl_groups = netlink_group_mask(nlk->dst_group);
 	} else {
-		nladdr->nl_pid = nlk->portid;
+		nladdr->nl_pid = netlink_bound(nlk) ? nlk->portid : 0;
 		nladdr->nl_groups = nlk->groups ? nlk->groups[0] : 0;
 	}
 	return 0;
@@ -2442,13 +2446,10 @@ static int netlink_sendmsg(struct socket *sock, struct msghdr *msg, size_t len)
 		dst_group = nlk->dst_group;
 	}
 
-	if (!nlk->bound) {
+	if (!netlink_bound(nlk)) {
 		err = netlink_autobind(sock);
 		if (err)
 			goto out;
-	} else {
-		/* Ensure nlk is hashed and visible. */
-		smp_rmb();
 	}
 
 	/* It's a really convoluted way for userland to ask for mmaped
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
