From: David Miller <davem@davemloft.net>
Subject: Re: sk->sk_socket
Date: Tue, 17 Jun 2008 22:54:27 -0700 (PDT)
Message-ID: <20080617.225427.66863666.davem@davemloft.net>
References: <20080617.032511.240272543.davem@davemloft.net>
	<20080617123254.GB25011@2ka.mipt.ru>
	<20080617141439.GB6970@ghostprotocols.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: johnpol@2ka.mipt.ru, netdev@vger.kernel.org
To: acme@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53127
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754646AbYFRFy0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jun 2008 01:54:26 -0400
In-Reply-To: <20080617141439.GB6970@ghostprotocols.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Arnaldo Carvalho de Melo <acme@redhat.com>
Date: Tue, 17 Jun 2008 11:14:39 -0300

> Em Tue, Jun 17, 2008 at 04:32:55PM +0400, Evgeniy Polyakov escreveu:
> > On Tue, Jun 17, 2008 at 03:25:11AM -0700, David Miller (davem@davemloft.net) wrote:
> > > For the curious, here are the only assignments to sk->sk_socket
> > > remaining in the net-next-2.6 tree right now:
> > > 
> > > include/net/sock.h:	sk->sk_socket = NULL;
> > > include/net/sock.h:	sk->sk_socket = parent;
> 
> Isn't this sock_graft and sock_orphan already? :)
> 
> > > net/core/sock.c:		newsk->sk_socket = NULL;
> > > net/core/sock.c:	sk->sk_socket		=	sock;
> 
> I see, perhaps we can have __sock_orphan() in sk_clone() and
> __sock_graft() in sock_init_data() 8)

Even though Evgeniy was only half-serious I think adding such
a helper makes sense.  I'm going to have to slap an
rcu_assign_pointer() there anyways if I do the RCU socket
freeing changes.

Applied and pushed to net-next-2.6:

net: Add sk_set_socket() helper.

In order to more easily grep for all things that set
sk->sk_socket, add sk_set_socket() helper inline function.

Suggested (although only half-seriously) by Evgeniy Polyakov.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/net/sock.h |    9 +++++++--
 net/core/sock.c    |    4 ++--
 2 files changed, 9 insertions(+), 4 deletions(-)

diff --git a/include/net/sock.h b/include/net/sock.h
index a7c3041..3f4897a 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -990,6 +990,11 @@ static inline void sock_put(struct sock *sk)
 extern int sk_receive_skb(struct sock *sk, struct sk_buff *skb,
 			  const int nested);
 
+static inline void sk_set_socket(struct sock *sk, struct socket *sock)
+{
+	sk->sk_socket = sock;
+}
+
 /* Detach socket from process context.
  * Announce socket dead, detach it from wait queue and inode.
  * Note that parent inode held reference count on this struct sock,
@@ -1001,7 +1006,7 @@ static inline void sock_orphan(struct sock *sk)
 {
 	write_lock_bh(&sk->sk_callback_lock);
 	sock_set_flag(sk, SOCK_DEAD);
-	sk->sk_socket = NULL;
+	sk_set_socket(sk, NULL);
 	sk->sk_sleep  = NULL;
 	write_unlock_bh(&sk->sk_callback_lock);
 }
@@ -1011,7 +1016,7 @@ static inline void sock_graft(struct sock *sk, struct socket *parent)
 	write_lock_bh(&sk->sk_callback_lock);
 	sk->sk_sleep = &parent->wait;
 	parent->sk = sk;
-	sk->sk_socket = parent;
+	sk_set_socket(sk, parent);
 	security_sock_graft(sk, parent);
 	write_unlock_bh(&sk->sk_callback_lock);
 }
diff --git a/net/core/sock.c b/net/core/sock.c
index 3879bf6..2c0ba52 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -1066,7 +1066,7 @@ struct sock *sk_clone(const struct sock *sk, const gfp_t priority)
 		 * to be taken into account in all callers. -acme
 		 */
 		sk_refcnt_debug_inc(newsk);
-		newsk->sk_socket = NULL;
+		sk_set_socket(newsk, NULL);
 		newsk->sk_sleep	 = NULL;
 
 		if (newsk->sk_prot->sockets_allocated)
@@ -1702,7 +1702,7 @@ void sock_init_data(struct socket *sock, struct sock *sk)
 	sk->sk_rcvbuf		=	sysctl_rmem_default;
 	sk->sk_sndbuf		=	sysctl_wmem_default;
 	sk->sk_state		=	TCP_CLOSE;
-	sk->sk_socket		=	sock;
+	sk_set_socket(sk, sock);
 
 	sock_set_flag(sk, SOCK_ZAPPED);
 
-- 
1.5.5.1.308.g1fbb5

