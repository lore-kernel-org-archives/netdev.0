From: David Miller <davem@davemloft.net>
Subject: Re: net-next/unix: BUG: using smp_processor_id() in preemptible
Date: Sun, 23 Nov 2008 17:34:26 -0800 (PST)
Message-ID: <20081123.173426.255648175.davem@davemloft.net>
References: <Pine.LNX.4.64.0811221634370.10534@wrl-59.cs.helsinki.fi>
	<4928CECE.602@cosmosbay.com>
	<20081123.172014.78676422.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ilpo.jarvinen@helsinki.fi, netdev@vger.kernel.org
To: dada1@cosmosbay.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53993
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751075AbYKXBe1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 23 Nov 2008 20:34:27 -0500
In-Reply-To: <20081123.172014.78676422.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Miller <davem@davemloft.net>
Date: Sun, 23 Nov 2008 17:20:14 -0800 (PST)

> From: Eric Dumazet <dada1@cosmosbay.com>
> Date: Sun, 23 Nov 2008 04:32:30 +0100
> 
> > [PATCH] net: make sock_prot_inuse_add() preempt safe
 ...
> Eric, you added this bug by starting to use this interface in
> situations where BH's were not disabled.
> 
> Ever existing use adhered to that rule.
> 
> If you therefore want to call this interface in new locations,
> you have to make sure those locations follow the rule too.

Here is what I commited to fix this bug.

net: Make sure BHs are disabled in sock_prot_inuse_add()

The rule of calling sock_prot_inuse_add() is that BHs must
be disabled.  Some new calls were added where this was not
true and this tiggers warnings as reported by Ilpo.

Fix this by adding explicit BH disabling around those call sites.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/netlink/af_netlink.c |    3 +++
 net/sctp/socket.c        |    4 ++++
 net/unix/af_unix.c       |    2 ++
 3 files changed, 9 insertions(+), 0 deletions(-)

diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index a2071dc..c7d7657 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -452,7 +452,10 @@ static int netlink_create(struct net *net, struct socket *sock, int protocol)
 	if (err < 0)
 		goto out_module;
 
+	local_bh_disable();
 	sock_prot_inuse_add(net, &netlink_proto, 1);
+	local_bh_enable();
+
 	nlk = nlk_sk(sock->sk);
 	nlk->module = module;
 out:
diff --git a/net/sctp/socket.c b/net/sctp/socket.c
index 0c70eff..f03af84 100644
--- a/net/sctp/socket.c
+++ b/net/sctp/socket.c
@@ -3614,7 +3614,11 @@ SCTP_STATIC int sctp_init_sock(struct sock *sk)
 
 	SCTP_DBG_OBJCNT_INC(sock);
 	atomic_inc(&sctp_sockets_allocated);
+
+	local_bh_disable();
 	sock_prot_inuse_add(sock_net(sk), sk->sk_prot, 1);
+	local_bh_enable();
+
 	return 0;
 }
 
diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
index e1ca8f7..a45a9f7 100644
--- a/net/unix/af_unix.c
+++ b/net/unix/af_unix.c
@@ -361,7 +361,9 @@ static void unix_sock_destructor(struct sock *sk)
 		unix_release_addr(u->addr);
 
 	atomic_dec(&unix_nr_socks);
+	local_bh_disable();
 	sock_prot_inuse_add(sock_net(sk), sk->sk_prot, -1);
+	local_bh_enable();
 #ifdef UNIX_REFCNT_DEBUG
 	printk(KERN_DEBUG "UNIX %p is destroyed, %d are still alive.\n", sk,
 		atomic_read(&unix_nr_socks));
-- 
1.5.6.5

