From: Michal Ostrowski <mostrows@gmail.com>
Subject: Re: kernel panic in latest vanilla stable, while using nameif with
	"alive" pppoe interfaces
Date: Mon, 19 Oct 2009 16:22:39 -0500
Message-ID: <e6d1cecd0910191422t2905d9bbl3355fc50cf36ff90@mail.gmail.com>
References: <200910190002.39937.denys@visp.net.lb>
	 <e6d1cecd0910182034t9d24859mc6f392875b36ad17@mail.gmail.com>
	 <4ADC5D3B.8010006@gmail.com>
	 <e6d1cecd0910190619t3e009e1by49cc8f7307eb7cdb@mail.gmail.com>
	 <20091019155034.GA5233@lenovo>
	 <e6d1cecd0910190905x382bfc23w2987c84aa0837609@mail.gmail.com>
	 <4ADC9DE2.5010308@gmail.com>
	 <e6d1cecd0910191107h899a4ffs588f2413093dfb4b@mail.gmail.com>
	 <4ADCB3A4.8060408@gmail.com> <20091019205740.GD5233@lenovo>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Denys Fedoryschenko <denys@visp.net.lb>,
	netdev <netdev@vger.kernel.org>, linux-ppp@vger.kernel.org,
	paulus@samba.org, mostrows@earthlink.net
To: Cyrill Gorcunov <gorcunov@gmail.com>
Return-path: <linux-ppp-owner@vger.kernel.org>
In-Reply-To: <20091019205740.GD5233@lenovo>
Sender: linux-ppp-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I'm assuming that there was a race in us sending patches at nearly the =
same time
I'm convinced now that the flush_lock can die, and the patch I sent
out kills it.
If we were to have to have a global lock, you might as well just use
the flush_lock for everything.

Note that there's a bunch of checks for sk->sk_state vs
PPPOX_CONNECTED.  PPPOX_CONNECTED being set implies that po->pppoe_dev
is valid.   So, by ensuring that checks of sk->sk_state and
po->pppoe_dev are done under the protection of
lock_sock()/release_sock() it is not even necessary to check
po->pppoe_dev=3D=3DNULL.

In fact, the NULL checks you're adding are equivalent to testing
sk->sk_state vs PPPOX_CONNECTED, and thus you're replacing the
synchronization provided by the socket lock with flush_lock.

--
Michal Ostrowski
mostrows@gmail.com



On Mon, Oct 19, 2009 at 3:57 PM, Cyrill Gorcunov <gorcunov@gmail.com> w=
rote:
> [Eric Dumazet - Mon, Oct 19, 2009 at 08:44:52PM +0200]
> ...
> |
> | There is still a race here, since you do a dev_put(po->ppoe_dev); w=
ithout any lock held
> |
> | So pppoe_flush_dev() can run concurently and dev_put(po->ppoe_dev) =
at same time.
> |
> | In fact pppoe_flush_dev() can change po->ppoe_dev anytime, so you s=
hould check
> | all occurences of po->ppoe_dev use in the code and check if appropr=
iate locking is done.
> |
> | pppoe_rcv_core() is not safe
> | pppoe_ioctl() is not safe
> | pppoe_sendmsg() is not safe
> | __pppoe_xmit() is not safe
> |
>
> Eric, Michal, please take a look (compile-test only).
> There is still unclear moment for NETDEV_CHANGEMTU
> since one could be doing this in say endless loop from
> userspace calling device to flush all the time which
> implies dev_put as a result :(
>
> Comments are welcome (and complains as well). I'll be able to
> continue handling (or reply to mail) tomorrow evening only.
> Anyway -- this patch is ugly enough but may happen to work.
>
> =A0 =A0 =A0 =A0-- Cyrill
> ---
> =A0drivers/net/pppoe.c | =A0 79 +++++++++++++++++++++++++++++++++++++=
+++------------
> =A01 file changed, 62 insertions(+), 17 deletions(-)
>
> Index: linux-2.6.git/drivers/net/pppoe.c
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> --- linux-2.6.git.orig/drivers/net/pppoe.c
> +++ linux-2.6.git/drivers/net/pppoe.c
> @@ -386,14 +386,19 @@ static struct notifier_block pppoe_notif
> =A0static int pppoe_rcv_core(struct sock *sk, struct sk_buff *skb)
> =A0{
> =A0 =A0 =A0 =A0struct pppox_sock *po =3D pppox_sk(sk);
> - =A0 =A0 =A0 struct pppox_sock *relay_po;
> + =A0 =A0 =A0 struct pppox_sock *relay_po =3D NULL;
> + =A0 =A0 =A0 struct net *net =3D NULL;
>
> =A0 =A0 =A0 =A0if (sk->sk_state & PPPOX_BOUND) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0ppp_input(&po->chan, skb);
> =A0 =A0 =A0 =A0} else if (sk->sk_state & PPPOX_RELAY) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 relay_po =3D get_item_by_addr(dev_net(p=
o->pppoe_dev),
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 &po->pppoe_relay);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (relay_po =3D=3D NULL)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 spin_lock(&flush_lock);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (po->pppoe_dev)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 net =3D dev_net(po->ppp=
oe_dev);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 spin_unlock(&flush_lock);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (net)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 relay_po =3D get_item_b=
y_addr(net, &po->pppoe_relay);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!net || !relay_po)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto abort_kfree;
>
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if ((sk_pppox(relay_po)->sk_state & PP=
POX_CONNECTED) =3D=3D 0)
> @@ -652,12 +657,15 @@ static int pppoe_connect(struct socket *
> =A0 =A0 =A0 =A0/* Delete the old binding */
> =A0 =A0 =A0 =A0if (stage_session(po->pppoe_pa.sid)) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0pppox_unbind_sock(sk);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 spin_lock(&flush_lock);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (po->pppoe_dev) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0pn =3D pppoe_pernet(de=
v_net(po->pppoe_dev));
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0delete_item(pn, po->pp=
poe_pa.sid,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0po->pp=
poe_pa.remote, po->pppoe_ifindex);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0dev_put(po->pppoe_dev)=
;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 po->pppoe_dev =3D NULL;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 spin_unlock(&flush_lock);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0memset(sk_pppox(po) + 1, 0,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 sizeof(struct pppox_sock)=
 - sizeof(struct sock));
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0sk->sk_state =3D PPPOX_NONE;
> @@ -670,7 +678,9 @@ static int pppoe_connect(struct socket *
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (!dev)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto end;
>
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 spin_lock(&flush_lock);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0po->pppoe_dev =3D dev;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 spin_unlock(&flush_lock);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0po->pppoe_ifindex =3D dev->ifindex;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0pn =3D pppoe_pernet(dev_net(dev));
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0write_lock_bh(&pn->hash_lock);
> @@ -708,10 +718,12 @@ end:
> =A0 =A0 =A0 =A0release_sock(sk);
> =A0 =A0 =A0 =A0return error;
> =A0err_put:
> + =A0 =A0 =A0 spin_lock(&flush_lock);
> =A0 =A0 =A0 =A0if (po->pppoe_dev) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0dev_put(po->pppoe_dev);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0po->pppoe_dev =3D NULL;
> =A0 =A0 =A0 =A0}
> + =A0 =A0 =A0 spin_unlock(&flush_lock);
> =A0 =A0 =A0 =A0goto end;
> =A0}
>
> @@ -738,6 +750,7 @@ static int pppoe_ioctl(struct socket *so
> =A0{
> =A0 =A0 =A0 =A0struct sock *sk =3D sock->sk;
> =A0 =A0 =A0 =A0struct pppox_sock *po =3D pppox_sk(sk);
> + =A0 =A0 =A0 unsigned int mtu =3D 0;
> =A0 =A0 =A0 =A0int val;
> =A0 =A0 =A0 =A0int err;
>
> @@ -746,11 +759,19 @@ static int pppoe_ioctl(struct socket *so
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0err =3D -ENXIO;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (!(sk->sk_state & PPPOX_CONNECTED))
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0break;
> -
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 err =3D -EBUSY;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!spin_trylock(&flush_lock))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 err =3D -ENODEV;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (po->pppoe_dev) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 mtu =3D po->pppoe_dev->=
mtu;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 err =3D 0;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 spin_unlock(&flush_lock);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (err)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0err =3D -EFAULT;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (put_user(po->pppoe_dev->mtu -
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0sizeof(struc=
t pppoe_hdr) -
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0PPP_HDRLEN,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (put_user(mtu - sizeof(struct pppoe_=
hdr) - PPP_HDRLEN,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 (int __user *=
)arg))
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0break;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0err =3D 0;
> @@ -760,14 +781,22 @@ static int pppoe_ioctl(struct socket *so
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0err =3D -ENXIO;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (!(sk->sk_state & PPPOX_CONNECTED))
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0break;
> -
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 err =3D -EBUSY;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!spin_trylock(&flush_lock))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 err =3D -ENODEV;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (po->pppoe_dev) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 mtu =3D po->pppoe_dev->=
mtu;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 err =3D 0;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 spin_unlock(&flush_lock);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (err)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0err =3D -EFAULT;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (get_user(val, (int __user *)arg))
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0break;
>
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (val < (po->pppoe_dev->mtu
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0- sizeof(struct =
pppoe_hdr)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0- PPP_HDRLEN))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (val < (mtu - sizeof(struct pppoe_hd=
r) - PPP_HDRLEN))
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0err =3D 0;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0else
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0err =3D -EINVAL;
> @@ -842,7 +871,7 @@ static int pppoe_sendmsg(struct kiocb *i
> =A0 =A0 =A0 =A0int error;
> =A0 =A0 =A0 =A0struct pppoe_hdr hdr;
> =A0 =A0 =A0 =A0struct pppoe_hdr *ph;
> - =A0 =A0 =A0 struct net_device *dev;
> + =A0 =A0 =A0 struct net_device *dev =3D NULL;
> =A0 =A0 =A0 =A0char *start;
>
> =A0 =A0 =A0 =A0lock_sock(sk);
> @@ -856,7 +885,15 @@ static int pppoe_sendmsg(struct kiocb *i
> =A0 =A0 =A0 =A0hdr.code =3D 0;
> =A0 =A0 =A0 =A0hdr.sid =3D po->num;
>
> + =A0 =A0 =A0 spin_lock(&flush_lock);
> =A0 =A0 =A0 =A0dev =3D po->pppoe_dev;
> + =A0 =A0 =A0 if (!dev) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 spin_unlock(&flush_lock);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 error =3D -ENODEV;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto end;
> + =A0 =A0 =A0 }
> + =A0 =A0 =A0 dev_hold(dev);
> + =A0 =A0 =A0 spin_unlock(&flush_lock);
>
> =A0 =A0 =A0 =A0error =3D -EMSGSIZE;
> =A0 =A0 =A0 =A0if (total_len > (dev->mtu + dev->hard_header_len))
> @@ -899,6 +936,8 @@ static int pppoe_sendmsg(struct kiocb *i
> =A0 =A0 =A0 =A0dev_queue_xmit(skb);
>
> =A0end:
> + =A0 =A0 =A0 if (dev)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 dev_put(dev);
> =A0 =A0 =A0 =A0release_sock(sk);
> =A0 =A0 =A0 =A0return error;
> =A0}
> @@ -911,15 +950,19 @@ end:
> =A0static int __pppoe_xmit(struct sock *sk, struct sk_buff *skb)
> =A0{
> =A0 =A0 =A0 =A0struct pppox_sock *po =3D pppox_sk(sk);
> - =A0 =A0 =A0 struct net_device *dev =3D po->pppoe_dev;
> + =A0 =A0 =A0 struct net_device *dev;
> =A0 =A0 =A0 =A0struct pppoe_hdr *ph;
> =A0 =A0 =A0 =A0int data_len =3D skb->len;
>
> =A0 =A0 =A0 =A0if (sock_flag(sk, SOCK_DEAD) || !(sk->sk_state & PPPOX=
_CONNECTED))
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto abort;
>
> - =A0 =A0 =A0 if (!dev)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto abort;
> + =A0 =A0 =A0 spin_lock(&flush_lock);
> + =A0 =A0 =A0 if (!po->pppoe_dev)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto abort_unlock;
> + =A0 =A0 =A0 dev =3D po->pppoe_dev;
> + =A0 =A0 =A0 dev_hold(dev);
> + =A0 =A0 =A0 spin_unlock(&flush_lock);
>
> =A0 =A0 =A0 =A0/* Copy the data if there is no space for the header o=
r if it's
> =A0 =A0 =A0 =A0 * read-only.
> @@ -942,11 +985,13 @@ static int __pppoe_xmit(struct sock *sk,
>
> =A0 =A0 =A0 =A0dev_hard_header(skb, dev, ETH_P_PPP_SES,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0po->pppoe_pa.remote, N=
ULL, data_len);
> -
> =A0 =A0 =A0 =A0dev_queue_xmit(skb);
> + =A0 =A0 =A0 dev_put(dev);
>
> =A0 =A0 =A0 =A0return 1;
>
> +abort_unlock:
> + =A0 =A0 =A0 spin_unlock(&flush_lock);
> =A0abort:
> =A0 =A0 =A0 =A0kfree_skb(skb);
> =A0 =A0 =A0 =A0return 1;
>
