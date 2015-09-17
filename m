From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: Possible netlink autobind regression
Date: Thu, 17 Sep 2015 13:15:03 +0800
Message-ID: <20150917051503.GA19978@gondor.apana.org.au>
References: <20150917022909.GA22754@htj.duckdns.org>
 <20150917030845.GA19162@gondor.apana.org.au>
 <20150917034134.GA19327@gondor.apana.org.au>
 <CAHA+R7OdJyZiidHarKhp-U6R5fkHj=5KjugK=XoWj=q4D8krxw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Tejun Heo <tj@kernel.org>, David Miller <davem@davemloft.net>,
	Tom Herbert <tom@herbertland.com>, kafai@fb.com,
	kernel-team <kernel-team@fb.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Jiri Pirko <jiri@resnulli.us>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	Thomas Graf <tgraf@suug.ch>, Scott Feldman <sfeldma@gmail.com>
To: Cong Wang <cwang@twopensource.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CAHA+R7OdJyZiidHarKhp-U6R5fkHj=5KjugK=XoWj=q4D8krxw@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Sep 16, 2015 at 10:02:00PM -0700, Cong Wang wrote:
>
> This part doesn't look correct, seems it is checking if this is a kernel
> netlink socket rather than if it is bound. But I am not sure...

Good point.  I've changed it so that bound is only set for non-kernel
sockets.

---8<---
netlink: Fix autobind race condition that leads to zero port ID

The commit c0bb07df7d981e4091432754e30c9c720e2c0c78 ("netlink:
Reset portid after netlink_insert failure") introduced a race
condition where if two threads tried to autobind the same socket
one of them may end up with a zero port ID.

This patch reverts that commit and instead fixes it by introducing
a separte "bound" variable to indicate whether a user-space socket
has been bound.

Fixes: c0bb07df7d98 ("netlink: Reset portid after netlink_insert failure")
Reported-by: Tejun Heo <tj@kernel.org>
Reported-by: Linus Torvalds <torvalds@linux-foundation.org>
Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
Reviewed-by: Cong Wang <cwang@twopensource.com>


diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index dea9253..42013c5 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -1068,7 +1068,7 @@ static int netlink_insert(struct sock *sk, u32 portid)
 	lock_sock(sk);
 
 	err = -EBUSY;
-	if (nlk_sk(sk)->portid)
+	if (nlk_sk(sk)->bound)
 		goto err;
 
 	err = -ENOMEM;
@@ -1083,10 +1083,12 @@ static int netlink_insert(struct sock *sk, u32 portid)
 	if (err) {
 		if (err == -EEXIST)
 			err = -EADDRINUSE;
-		nlk_sk(sk)->portid = 0;
 		sock_put(sk);
+		goto err;
 	}
 
+	nlk_sk(sk)->bound = !!portid;
+
 err:
 	release_sock(sk);
 	return err;
@@ -1253,7 +1255,7 @@ static int netlink_release(struct socket *sock)
 
 	skb_queue_purge(&sk->sk_write_queue);
 
-	if (nlk->portid) {
+	if (nlk->bound) {
 		struct netlink_notify n = {
 						.net = sock_net(sk),
 						.protocol = sk->sk_protocol,
@@ -1487,7 +1489,7 @@ static int netlink_bind(struct socket *sock, struct sockaddr *addr,
 			return err;
 	}
 
-	if (nlk->portid)
+	if (nlk->bound)
 		if (nladdr->nl_pid != nlk->portid)
 			return -EINVAL;
 
@@ -1505,7 +1507,7 @@ static int netlink_bind(struct socket *sock, struct sockaddr *addr,
 		}
 	}
 
-	if (!nlk->portid) {
+	if (!nlk->bound) {
 		err = nladdr->nl_pid ?
 			netlink_insert(sk, nladdr->nl_pid) :
 			netlink_autobind(sock);
@@ -1553,7 +1555,7 @@ static int netlink_connect(struct socket *sock, struct sockaddr *addr,
 	    !netlink_allowed(sock, NL_CFG_F_NONROOT_SEND))
 		return -EPERM;
 
-	if (!nlk->portid)
+	if (!nlk->bound)
 		err = netlink_autobind(sock);
 
 	if (err == 0) {
@@ -2371,7 +2373,7 @@ static int netlink_sendmsg(struct socket *sock, struct msghdr *msg, size_t len)
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
