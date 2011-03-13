From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH 3/3] vhost-net: use lock_sock_fast() in peek_head_len()
Date: Sun, 13 Mar 2011 23:11:29 +0200
Message-ID: <20110313211129.GA10235@redhat.com>
References: <20110117081058.18900.67456.stgit@dhcp-91-7.nay.redhat.com.englab.nay.redhat.com>
 <20110117081117.18900.48672.stgit@dhcp-91-7.nay.redhat.com.englab.nay.redhat.com>
 <20110313150646.GA30494@redhat.com>
 <1300031570.2761.22.camel@edumazet-laptop>
 <20110313161915.GB30642@redhat.com>
 <1300033927.2761.26.camel@edumazet-laptop>
 <20110313164359.GA32562@redhat.com>
 <1300038092.2761.41.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jason Wang <jasowang@redhat.com>, virtualization@lists.osdl.org,
	netdev@vger.kernel.org, kvm@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1300038092.2761.41.camel@edumazet-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Mar 13, 2011 at 06:41:32PM +0100, Eric Dumazet wrote:
> Le dimanche 13 mars 2011 =E0 18:43 +0200, Michael S. Tsirkin a =E9cri=
t :
> > On Sun, Mar 13, 2011 at 05:32:07PM +0100, Eric Dumazet wrote:
> > > Le dimanche 13 mars 2011 =E0 18:19 +0200, Michael S. Tsirkin a =E9=
crit :
> > >=20
> > > > Other side is in drivers/net/tun.c and net/packet/af_packet.c
> > > > At least wrt tun it seems clear socket is not locked.
> > >=20
> > > Yes (assuming you refer to tun_net_xmit())
> > >=20
> > > > Besides queue, dequeue seems to be done without socket locked.
> > > >=20
> > >=20
> > > It seems this code (assuming you speak of drivers/vhost/net.c ?) =
has
> > > some races indeed.
> > >=20
> >=20
> > Hmm. Any more besides the one fixed here?
> >=20
>=20
> If writers and readers dont share a common lock, how can they reliabl=
y
> synchronize states ?

They are all supposed to use sk_receive_queue.lock I think.

> For example, the check at line 420 seems unsafe or useless.
>=20
> skb_queue_empty(&sock->sk->sk_receive_queue)
>=20

It's mostly useless: code that is called after this
 does skb_peek and checks the result under the spinlock.
This was supposed to be an optimization: quickly check
that queue is not empty before we bother disabling notifications
etc, but I dont' remember at this point whether it actually gives any g=
ain.
Thanks for pointing this out, I'll take it out I think (below).
Note: there are two places of this call in upstream: handle_rx_bug and
handle_rx_mergeable, but they are merged into a single
handle_rx by a patch by Jason Wang.
The below patch is on top.
If you like to look at the latest code,
it's here master.kernel.org:/home/mst/pub/vhost.git
branch vhost-net-next has it all.

Eric, thanks very much for pointing out these.
Is there anything else that you see in this driver?


Thanks!


    vhost-net: remove unlocked use of receive_queue
   =20
    Use of skb_queue_empty(&sock->sk->sk_receive_queue)
    without taking the sk_receive_queue.lock is unsafe
    or useless. Take it out.
   =20
    Reported-by:  Eric Dumazet <eric.dumazet@gmail.com>
    Signed-off-by: Michael S. Tsirkin <mst@redhat.com>

diff --git a/drivers/vhost/net.c b/drivers/vhost/net.c
index 5720301..2f7c76a 100644
--- a/drivers/vhost/net.c
+++ b/drivers/vhost/net.c
@@ -311,7 +311,7 @@ static void handle_rx(struct vhost_net *net)
 	/* TODO: check that we are running from vhost_worker? */
 	struct socket *sock =3D rcu_dereference_check(vq->private_data, 1);
=20
-	if (!sock || skb_queue_empty(&sock->sk->sk_receive_queue))
+	if (!sock)
 		return;
=20
 	mutex_lock(&vq->mutex);
