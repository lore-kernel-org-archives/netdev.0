From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: netlink: Add barrier to netlink_connect for theoretical case
Date: Fri, 25 Sep 2015 11:39:57 +0800
Message-ID: <20150925033957.GA4675@gondor.apana.org.au>
References: <20150921133415.GA1740@gondor.apana.org.au>
 <20150921182022.GB13263@mtj.duckdns.org>
 <20150922033856.GA7851@gondor.apana.org.au>
 <20150924.121142.870602292135442487.davem@davemloft.net>
 <20150924200510.GE25415@mtj.duckdns.org>
 <20150925014327.GA3725@gondor.apana.org.au>
 <CA+55aFxSqK1dcuKapCkn+VaN0E1XwxGrz_5WzrJB5Ej52zsn9w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Tejun Heo <tj@kernel.org>, David Miller <davem@davemloft.net>,
	Cong Wang <cwang@twopensource.com>,
	Tom Herbert <tom@herbertland.com>, kafai@fb.com,
	kernel-team@fb.com,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	=?utf-8?B?SmnFmcOtIFDDrXJrbw==?= <jiri@resnulli.us>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	Thomas Graf <tgraf@suug.ch>, Scott Feldman <sfeldma@gmail.com>
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CA+55aFxSqK1dcuKapCkn+VaN0E1XwxGrz_5WzrJB5Ej52zsn9w@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Sep 24, 2015 at 08:24:56PM -0700, Linus Torvalds wrote:
> 
> The above looks very suspicious.

You're right Linus.  I've added the READ_ONCE there.  The reason I
kept the conditional is because the helper is always called in a
context where the result is used as part of an if statement.  The
assembly actually looks sane, e.g., for netlink_bind:

    3a06:       41 0f b6 94 24 e8 02    movzbl 0x2e8(%r12),%edx
    3a0d:       00 00 
    3a0f:       84 d2                   test   %dl,%dl
    3a11:       0f 85 97 00 00 00       jne    3aae <netlink_bind+0x12e>
    3a17:       49 83 bc 24 98 03 00    cmpq   $0x0,0x398(%r12)
    3a1e:       00 00 

...

    3aae:       41 8b 84 24 a0 02 00    mov    0x2a0(%r12),%eax
    3ab5:       00 
    3ab6:       41 39 46 04             cmp    %eax,0x4(%r14)
    3aba:       0f 84 57 ff ff ff       je     3a17 <netlink_bind+0x97>
    3ac0:       b8 ea ff ff ff          mov    $0xffffffea,%eax
    3ac5:       eb d1                   jmp    3a98 <netlink_bind+0x118>

So there is no unnecessary jumping around.  I checked the other
two call sites and they look the same.  I'm on a fairly old compiler
though (4.7.2) so it is possible that newer gcc's may do silly things.

Thanks,

---8<---
If a netlink_connect call is followed by a netlink_getname call
the portid returned may not be up-to-date.  This patch adds a
barrier for that case.

As all nlk->bound dereferences now have barriers this patch also
adds a netlink_bound helper to encapsulate the barrier, as was
suggested by Tejun.  Also as suggested by Linus, the lockless
read of nlk->bound is now protected with READ_ONCE to ensure that
the compiler doesn't do double reads that may screw up our use
of the barrier.

Fixes: da314c9923fe ("netlink: Replace rhash_portid with bound")
Reported-by: Tejun Heo <tj@kernel.org>
Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index 2c15fae..dd0a294 100644
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
@@ -1598,10 +1602,7 @@ static int netlink_connect(struct socket *sock, struct sockaddr *addr,
 	    !netlink_allowed(sock, NL_CFG_F_NONROOT_SEND))
 		return -EPERM;
 
-	/* No need for barriers here as we return to user-space without
-	 * using any of the bound attributes.
-	 */
-	if (!nlk->bound)
+	if (!netlink_bound(nlk))
 		err = netlink_autobind(sock);
 
 	if (err == 0) {
@@ -2442,13 +2443,10 @@ static int netlink_sendmsg(struct socket *sock, struct msghdr *msg, size_t len)
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
