From: Michal Ostrowski <mostrows@gmail.com>
Subject: Re: kernel panic in latest vanilla stable, while using nameif with
	"alive" pppoe interfaces
Date: Mon, 19 Oct 2009 11:05:51 -0500
Message-ID: <e6d1cecd0910190905x382bfc23w2987c84aa0837609@mail.gmail.com>
References: <200910190002.39937.denys@visp.net.lb>
	 <e6d1cecd0910182034t9d24859mc6f392875b36ad17@mail.gmail.com>
	 <4ADC5D3B.8010006@gmail.com>
	 <e6d1cecd0910190619t3e009e1by49cc8f7307eb7cdb@mail.gmail.com>
	 <20091019155034.GA5233@lenovo>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Denys Fedoryschenko <denys@visp.net.lb>,
	netdev <netdev@vger.kernel.org>, linux-ppp@vger.kernel.org,
	paulus@samba.org, mostrows@earthlink.net
To: Cyrill Gorcunov <gorcunov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f197.google.com ([209.85.222.197]:49544 "EHLO
	mail-pz0-f197.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754640AbZJSQFr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Oct 2009 12:05:47 -0400
In-Reply-To: <20091019155034.GA5233@lenovo>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Here's a bigger patch that just gets rid of flush_lock altogether.

We were seeing oopses due to net namespaces going away while we were using
them, which turns out is simply due to the fact that pppoew wasn't claiming ref
counts properly.

Fixing this requires that adding and removing entries to the per-net hash-table
requires incrementing and decrementing the ref count.  This also allows us to
get rid of the flush_lock since we can now depend on the existence of
"pn->hash_lock".

We also have to be careful when flushing devices that removal of a hash table
entry may bring the net namespace refcount to 0.

---
 drivers/net/pppoe.c |  152 ++++++++++++++++++++++++++++-----------------------
 1 files changed, 83 insertions(+), 69 deletions(-)

diff --git a/drivers/net/pppoe.c b/drivers/net/pppoe.c
index 7cbf6f9..140a196 100644
--- a/drivers/net/pppoe.c
+++ b/drivers/net/pppoe.c
@@ -111,9 +111,6 @@ struct pppoe_net {
       rwlock_t hash_lock;
 };

-/* to eliminate a race btw pppoe_flush_dev and pppoe_release */
-static DEFINE_SPINLOCK(flush_lock);
-
 /*
 * PPPoE could be in the following stages:
 * 1) Discovery stage (to obtain remote MAC and Session ID)
@@ -292,61 +289,77 @@ static inline struct pppox_sock
*delete_item(struct pppoe_net *pn, __be16 sid,
 static void pppoe_flush_dev(struct net_device *dev)
 {
       struct pppoe_net *pn;
+        struct net * net;
       int i;

       BUG_ON(dev == NULL);

+        /* We have to drop and re-acquire locks.  So we'll grab a ref-count on
+         * the net namespace to ensure it is valid throughout this function.
+         */
+
+        net = maybe_get_net(dev_net(dev));
+        if (!net)
+                return;
+
       pn = pppoe_pernet(dev_net(dev));
-       if (!pn) /* already freed */
+       if (!pn) { /* already freed */
+                put_net(net);
               return;
+        }

       write_lock_bh(&pn->hash_lock);
       for (i = 0; i < PPPOE_HASH_SIZE; i++) {
               struct pppox_sock *po = pn->hash_table[i];
-
-               while (po != NULL) {
-                       struct sock *sk;
-                       if (po->pppoe_dev != dev) {
-                               po = po->next;
-                               continue;
-                       }
-                       sk = sk_pppox(po);
-                       spin_lock(&flush_lock);
-                       po->pppoe_dev = NULL;
-                       spin_unlock(&flush_lock);
-                       dev_put(dev);
-
-                       /* We always grab the socket lock, followed by the
-                        * hash_lock, in that order.  Since we should
-                        * hold the sock lock while doing any unbinding,
-                        * we need to release the lock we're holding.
-                        * Hold a reference to the sock so it doesn't disappear
-                        * as we're jumping between locks.
-                        */
-
-                       sock_hold(sk);
-
-                       write_unlock_bh(&pn->hash_lock);
-                       lock_sock(sk);
-
-                       if (sk->sk_state & (PPPOX_CONNECTED | PPPOX_BOUND)) {
-                               pppox_unbind_sock(sk);
-                               sk->sk_state = PPPOX_ZOMBIE;
-                               sk->sk_state_change(sk);
-                       }
-
-                       release_sock(sk);
-                       sock_put(sk);
-
-                       /* Restart scan at the beginning of this hash chain.
-                        * While the lock was dropped the chain contents may
-                        * have changed.
-                        */
-                       write_lock_bh(&pn->hash_lock);
-                       po = pn->hash_table[i];
-               }
+                struct sock *sk;
+
+                while (po && po->pppoe_dev != dev) {
+                        po = po->next;
+                }
+
+                if (po == NULL) {
+                        continue;
+                }
+
+                sk = sk_pppox(po);
+
+                if (po->pppoe_dev) {
+                        dev_put(po->pppoe_dev);
+                        po->pppoe_dev = NULL;
+                }
+
+                /* We always grab the socket lock, followed by the
+                 * hash_lock, in that order.  Since we should
+                 * hold the sock lock while doing any unbinding,
+                 * we need to release the lock we're holding.
+                 * Hold a reference to the sock so it doesn't disappear
+                 * as we're jumping between locks.
+                 */
+
+                sock_hold(sk);
+
+                write_unlock_bh(&pn->hash_lock);
+                lock_sock(sk);
+
+                if (sk->sk_state & (PPPOX_CONNECTED | PPPOX_BOUND)) {
+                        pppox_unbind_sock(sk);
+                        sk->sk_state = PPPOX_ZOMBIE;
+                        sk->sk_state_change(sk);
+                }
+
+                release_sock(sk);
+                sock_put(sk);
+
+                /* Restart the process from the start of the current hash
+                 * chain. We dropped locks so the world may have change from
+                 * underneath us, but we know "pn" is still good because we
+                 * grabbed a ref count on "net".
+                 */
+                write_unlock_bh(&pn->hash_lock);
+                po = pn->hash_table[i];
       }
       write_unlock_bh(&pn->hash_lock);
+        put_net(net);
 }

 static int pppoe_device_event(struct notifier_block *this,
@@ -561,6 +574,7 @@ static int pppoe_release(struct socket *sock)
       struct sock *sk = sock->sk;
       struct pppox_sock *po;
       struct pppoe_net *pn;
+        struct net *net = NULL;

       if (!sk)
               return 0;
@@ -576,19 +590,8 @@ static int pppoe_release(struct socket *sock)
       /* Signal the death of the socket. */
       sk->sk_state = PPPOX_DEAD;

-       /*
-        * pppoe_flush_dev could lead to a race with
-        * this routine so we use flush_lock to eliminate
-        * such a case (we only need per-net specific data)
-        */
-       spin_lock(&flush_lock);
-       po = pppox_sk(sk);
-       if (!po->pppoe_dev) {
-               spin_unlock(&flush_lock);
-               goto out;
-       }
-       pn = pppoe_pernet(dev_net(po->pppoe_dev));
-       spin_unlock(&flush_lock);
+        net = sock_net(sk);
+       pn = pppoe_pernet(net);

       /*
        * protect "po" from concurrent updates
@@ -601,14 +604,14 @@ static int pppoe_release(struct socket *sock)
               __delete_item(pn, po->pppoe_pa.sid, po->pppoe_pa.remote,
                               po->pppoe_ifindex);

-       if (po->pppoe_dev) {
-               dev_put(po->pppoe_dev);
-               po->pppoe_dev = NULL;
-       }
+        if (po->pppoe_dev) {
+                dev_put(po->pppoe_dev);
+                po->pppoe_dev = NULL;
+        }

       write_unlock_bh(&pn->hash_lock);
+        put_net(net);

-out:
       sock_orphan(sk);
       sock->sk = NULL;

@@ -625,8 +628,9 @@ static int pppoe_connect(struct socket *sock,
struct sockaddr *uservaddr,
       struct sock *sk = sock->sk;
       struct sockaddr_pppox *sp = (struct sockaddr_pppox *)uservaddr;
       struct pppox_sock *po = pppox_sk(sk);
-       struct net_device *dev;
       struct pppoe_net *pn;
+       struct net_device *dev = NULL;
+        struct net *net = NULL;
       int error;

       lock_sock(sk);
@@ -653,10 +657,12 @@ static int pppoe_connect(struct socket *sock,
struct sockaddr *uservaddr,
       if (stage_session(po->pppoe_pa.sid)) {
               pppox_unbind_sock(sk);
               if (po->pppoe_dev) {
-                       pn = pppoe_pernet(dev_net(po->pppoe_dev));
+                        struct net *old = dev_net(po->pppoe_dev);
+                       pn = pppoe_pernet(old);
                       delete_item(pn, po->pppoe_pa.sid,
                               po->pppoe_pa.remote, po->pppoe_ifindex);
                       dev_put(po->pppoe_dev);
+                        put_net(old);
               }
               memset(sk_pppox(po) + 1, 0,
                      sizeof(struct pppox_sock) - sizeof(struct sock));
@@ -666,13 +672,17 @@ static int pppoe_connect(struct socket *sock,
struct sockaddr *uservaddr,
       /* Re-bind in session stage only */
       if (stage_session(sp->sa_addr.pppoe.sid)) {
               error = -ENODEV;
-               dev = dev_get_by_name(sock_net(sk), sp->sa_addr.pppoe.dev);
+                net = maybe_get_net(dev_net(dev));
+                if (!net)
+                        goto end;
+
+               dev = dev_get_by_name(net, sp->sa_addr.pppoe.dev);
               if (!dev)
-                       goto end;
+                       goto err_put_net;

               po->pppoe_dev = dev;
               po->pppoe_ifindex = dev->ifindex;
-               pn = pppoe_pernet(dev_net(dev));
+               pn = pppoe_pernet(net);
               write_lock_bh(&pn->hash_lock);
               if (!(dev->flags & IFF_UP)) {
                       write_unlock_bh(&pn->hash_lock);
@@ -707,6 +717,10 @@ static int pppoe_connect(struct socket *sock,
struct sockaddr *uservaddr,
 end:
       release_sock(sk);
       return error;
+err_put_net:
+        if (net) {
+                put_net(net);
+        }
 err_put:
       if (po->pppoe_dev) {
               dev_put(po->pppoe_dev);
--
1.6.3.3
