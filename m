From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: netlink: Add barrier to netlink_connect for theoretical case
Date: Fri, 25 Sep 2015 09:43:27 +0800
Message-ID: <20150925014327.GA3725@gondor.apana.org.au>
References: <20150921133415.GA1740@gondor.apana.org.au>
 <20150921182022.GB13263@mtj.duckdns.org>
 <20150922033856.GA7851@gondor.apana.org.au>
 <20150924.121142.870602292135442487.davem@davemloft.net>
 <20150924200510.GE25415@mtj.duckdns.org>
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
In-Reply-To: <20150924200510.GE25415@mtj.duckdns.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Sep 24, 2015 at 04:05:10PM -0400, Tejun Heo wrote:
>
> > I've decided to apply this and queue it up for -stable.

Thanks Dave!

> This is mostly correct; however, if there are or can be in-kernel
> users which create the client side of netlink socket, it isn't.  Let's
> say such in-kernel user does kernel_connect() and then query the
> assigned port number by kernel_getsockname().  That can just return
> zero.  Maybe such scenario is not possible for some combination of
> reasons but why leak this level of synchronization detail to the users
> in the first place?  This should be terminated from the site where
> such synchronization scheme is implemented.  This expands the scope of
> correctness verification to all possible users of these functions.

Well had you said this in the first place I would've fixed it a
long time ago.  There aren't any in-kernel users right now and
even if there were they'd have to do a connect/bind/sendmsg on
the same socket in two threads at the same time.  But let's close
this theoretical hole:

---8<---
If a netlink_connect call is followed by a netlink_getname call
the portid returned may not be up-to-date.  This patch adds a
barrier for that case.

As all nlk->bound dereferences now have barriers this patch also
adds a netlink_bound helper to encapsulate the barrier, as was
suggested by Tejun.

Fixes: da314c9923fe ("netlink: Replace rhash_portid with bound")
Reported-by: Tejun Heo <tj@kernel.org>
Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index 2c15fae..02121e1 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -125,6 +125,15 @@ static inline u32 netlink_group_mask(u32 group)
 	return group ? 1 << (group - 1) : 0;
 }
 
+static inline bool netlink_bound(struct netlink_sock *nlk)
+{
+	/* Ensure nlk is hashed and visible. */
+	if (nlk->bound)
+		smp_rmb();
+
+	return nlk->bound;
+}
+
 int netlink_add_tap(struct netlink_tap *nt)
 {
 	if (unlikely(nt->dev->type != ARPHRD_NETLINK))
@@ -1524,14 +1533,10 @@ static int netlink_bind(struct socket *sock, struct sockaddr *addr,
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
@@ -1547,9 +1552,6 @@ static int netlink_bind(struct socket *sock, struct sockaddr *addr,
 		}
 	}
 
-	/* No need for barriers here as we return to user-space without
-	 * using any of the bound attributes.
-	 */
 	if (!bound) {
 		err = nladdr->nl_pid ?
 			netlink_insert(sk, nladdr->nl_pid) :
@@ -1598,10 +1600,7 @@ static int netlink_connect(struct socket *sock, struct sockaddr *addr,
 	    !netlink_allowed(sock, NL_CFG_F_NONROOT_SEND))
 		return -EPERM;
 
-	/* No need for barriers here as we return to user-space without
-	 * using any of the bound attributes.
-	 */
-	if (!nlk->bound)
+	if (!netlink_bound(nlk))
 		err = netlink_autobind(sock);
 
 	if (err == 0) {
@@ -2442,13 +2441,10 @@ static int netlink_sendmsg(struct socket *sock, struct msghdr *msg, size_t len)
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
