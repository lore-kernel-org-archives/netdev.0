From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH 3/3] vhost-net: use lock_sock_fast() in peek_head_len()
Date: Sun, 13 Mar 2011 18:19:15 +0200
Message-ID: <20110313161915.GB30642@redhat.com>
References: <20110117081058.18900.67456.stgit@dhcp-91-7.nay.redhat.com.englab.nay.redhat.com>
 <20110117081117.18900.48672.stgit@dhcp-91-7.nay.redhat.com.englab.nay.redhat.com>
 <20110313150646.GA30494@redhat.com>
 <1300031570.2761.22.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jason Wang <jasowang@redhat.com>, virtualization@lists.osdl.org,
	netdev@vger.kernel.org, kvm@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1300031570.2761.22.camel@edumazet-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Mar 13, 2011 at 04:52:50PM +0100, Eric Dumazet wrote:
> Le dimanche 13 mars 2011 =E0 17:06 +0200, Michael S. Tsirkin a =E9cri=
t :
> > On Mon, Jan 17, 2011 at 04:11:17PM +0800, Jason Wang wrote:
> > > We can use lock_sock_fast() instead of lock_sock() in order to ge=
t
> > > speedup in peek_head_len().
> > >=20
> > > Signed-off-by: Jason Wang <jasowang@redhat.com>
> > > ---
> > >  drivers/vhost/net.c |    4 ++--
> > >  1 files changed, 2 insertions(+), 2 deletions(-)
> > >=20
> > > diff --git a/drivers/vhost/net.c b/drivers/vhost/net.c
> > > index c32a2e4..50b622a 100644
> > > --- a/drivers/vhost/net.c
> > > +++ b/drivers/vhost/net.c
> > > @@ -211,12 +211,12 @@ static int peek_head_len(struct sock *sk)
> > >  {
> > >  	struct sk_buff *head;
> > >  	int len =3D 0;
> > > +	bool slow =3D lock_sock_fast(sk);
> > > =20
> > > -	lock_sock(sk);
> > >  	head =3D skb_peek(&sk->sk_receive_queue);
> > >  	if (head)
> > >  		len =3D head->len;
> > > -	release_sock(sk);
> > > +	unlock_sock_fast(sk, slow);
> > >  	return len;
> > >  }
> > > =20
> >=20
> > Wanted to apply this, but looking at the code I think the lock_sock=
 here
> > is wrong. What we really need is to handle the case where the skb i=
s
> > pulled from the receive queue after skb_peek.  However this is not =
the
> > right lock to use for that, sk_receive_queue.lock is.
> > So I expect the following is the right way to handle this.
> > Comments?
> >=20
> > Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
> >=20
> > diff --git a/drivers/vhost/net.c b/drivers/vhost/net.c
> > index 0329c41..5720301 100644
> > --- a/drivers/vhost/net.c
> > +++ b/drivers/vhost/net.c
> > @@ -213,12 +213,13 @@ static int peek_head_len(struct sock *sk)
> >  {
> >  	struct sk_buff *head;
> >  	int len =3D 0;
> > +	unsigned long flags;
> > =20
> > -	lock_sock(sk);
> > +	spin_lock_irqsave(&sk->sk_receive_queue.lock, flags);
> >  	head =3D skb_peek(&sk->sk_receive_queue);
> > -	if (head)
> > +	if (likely(head))
> >  		len =3D head->len;
> > -	release_sock(sk);
> > +	spin_unlock_irqrestore(&sk->sk_receive_queue.lock, flags);
> >  	return len;
> >  }
> > =20
>=20
> You may be right, only way to be sure is to check the other side.
>=20
> If it uses skb_queue_tail(), then yes, your patch is fine.
>=20
> If other side did not lock socket, then your patch is a bug fix.
>=20
>=20

Other side is in drivers/net/tun.c and net/packet/af_packet.c
At least wrt tun it seems clear socket is not locked.
Besides queue, dequeue seems to be done without socket locked.

--=20
MST
