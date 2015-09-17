From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: Possible netlink autobind regression
Date: Thu, 17 Sep 2015 11:41:34 +0800
Message-ID: <20150917034134.GA19327@gondor.apana.org.au>
References: <20150917022909.GA22754@htj.duckdns.org>
 <20150917030845.GA19162@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, tom@herbertland.com, kafai@fb.com,
	kernel-team@fb.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Jiri Pirko <jiri@resnulli.us>,
	Cong Wang <cwang@twopensource.com>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	Thomas Graf <tgraf@suug.ch>, Scott Feldman <sfeldma@gmail.com>
To: Tejun Heo <tj@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20150917030845.GA19162@gondor.apana.org.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Sep 17, 2015 at 11:08:45AM +0800, Herbert Xu wrote:
> 
> Good catch! I think your explanation makes perfect sense.  Linus
> ran into this previously too after suspend-and-resume.

Unfortunately you can't just postpone the setting of portid because
once you pass it onto rhashtable the portid must never change while
it's in custody.

So what I've done is essentially revert my previous fix and instead
add a new boolean "bound" to indicate whether the socket has been
bound.

---8<---
netlink: Fix autobind race condition that leads to zero port ID

The commit c0bb07df7d981e4091432754e30c9c720e2c0c78 ("netlink:
Reset portid after netlink_insert failure") introduced a race
condition where if two threads tried to autobind the same socket
one of them may end up with a zero port ID.

This patch reverts that commit and instead fixes it by introducing
a separte "bound" variable to indicate whether a socket has been
bound.

Fixes: c0bb07df7d98 ("netlink: Reset portid after netlink_insert failure")
Reported-by: Tejun Heo <tj@kernel.org>
Reported-by: Linus Torvalds <torvalds@linux-foundation.org>
Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index 7f86d3b..abcbca5 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -1095,7 +1095,7 @@ static int netlink_insert(struct sock *sk, u32 portid)
 	lock_sock(sk);
 
 	err = -EBUSY;
-	if (nlk_sk(sk)->portid)
+	if (nlk_sk(sk)->bound)
 		goto err;
 
 	err = -ENOMEM;
@@ -1115,10 +1115,12 @@ static int netlink_insert(struct sock *sk, u32 portid)
 			err = -EOVERFLOW;
 		if (err == -EEXIST)
 			err = -EADDRINUSE;
-		nlk_sk(sk)->portid = 0;
 		sock_put(sk);
+		goto err;
 	}
 
+	nlk_sk(sk)->bound = true;
+
 err:
 	release_sock(sk);
 	return err;
@@ -1285,7 +1287,7 @@ static int netlink_release(struct socket *sock)
 
 	skb_queue_purge(&sk->sk_write_queue);
 
-	if (nlk->portid) {
+	if (nlk->bound) {
 		struct netlink_notify n = {
 						.net = sock_net(sk),
 						.protocol = sk->sk_protocol,
@@ -1519,7 +1521,7 @@ static int netlink_bind(struct socket *sock, struct sockaddr *addr,
 			return err;
 	}
 
-	if (nlk->portid)
+	if (nlk->bound)
 		if (nladdr->nl_pid != nlk->portid)
 			return -EINVAL;
 
@@ -1537,7 +1539,7 @@ static int netlink_bind(struct socket *sock, struct sockaddr *addr,
 		}
 	}
 
-	if (!nlk->portid) {
+	if (!nlk->bound) {
 		err = nladdr->nl_pid ?
 			netlink_insert(sk, nladdr->nl_pid) :
 			netlink_autobind(sock);
@@ -1585,7 +1587,7 @@ static int netlink_connect(struct socket *sock, struct sockaddr *addr,
 	    !netlink_allowed(sock, NL_CFG_F_NONROOT_SEND))
 		return -EPERM;
 
-	if (!nlk->portid)
+	if (!nlk->bound)
 		err = netlink_autobind(sock);
 
 	if (err == 0) {
@@ -2426,7 +2428,7 @@ static int netlink_sendmsg(struct socket *sock, struct msghdr *msg, size_t len)
 		dst_group = nlk->dst_group;
 	}
 
-	if (!nlk->portid) {
+	if (!nlk->bound) {
 		err = netlink_autobind(sock);
 		if (err)
 			goto out;
diff --git a/net/netlink/af_netlink.h b/net/netlink/af_netlink.h
index 8900840..e6aae40 100644
--- a/net/netlink/af_netlink.h
+++ b/net/netlink/af_netlink.h
@@ -35,6 +35,7 @@ struct netlink_sock {
 	unsigned long		state;
 	size_t			max_recvmsg_len;
 	wait_queue_head_t	wait;
+	bool			bound;
 	bool			cb_running;
 	struct netlink_callback	cb;
 	struct mutex		*cb_mutex;
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
