From: Stefan Hajnoczi <stefanha@gmail.com>
Subject: Re: [RFC PATCH 0/1] vhost: Reduce TX used buffer signal for performance
Date: Thu, 28 Oct 2010 09:57:38 +0100
Message-ID: <AANLkTinqG_G2pevoYJyiHiBda1ZZS-53Uqz9WEspbMOy@mail.gmail.com>
References: <1288213257.17571.25.camel@localhost.localdomain>
	<1288213557.17571.28.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "mst@redhat.com" <mst@redhat.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	kvm@vger.kernel.org, linux-kernel@vger.kernel.org
To: Shirley Ma <mashirle@us.ibm.com>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <1288213557.17571.28.camel@localhost.localdomain>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Oct 27, 2010 at 10:05 PM, Shirley Ma <mashirle@us.ibm.com> wrot=
e:
> This patch changes vhost TX used buffer signal to guest from one by
> one to up to 3/4 of vring size. This change improves vhost TX message
> size from 256 to 8K performance for both bandwidth and CPU utilizatio=
n
> without inducing any regression.

Any concerns about introducing latency or does the guest not care when
TX completions come in?

> Signed-off-by: Shirley Ma <xma@us.ibm.com>
> ---
>
> =A0drivers/vhost/net.c =A0 | =A0 19 ++++++++++++++++++-
> =A0drivers/vhost/vhost.c | =A0 31 +++++++++++++++++++++++++++++++
> =A0drivers/vhost/vhost.h | =A0 =A03 +++
> =A03 files changed, 52 insertions(+), 1 deletions(-)
>
> diff --git a/drivers/vhost/net.c b/drivers/vhost/net.c
> index 4b4da5b..bd1ba71 100644
> --- a/drivers/vhost/net.c
> +++ b/drivers/vhost/net.c
> @@ -198,7 +198,24 @@ static void handle_tx(struct vhost_net *net)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (err !=3D len)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0pr_debug("Truncated TX=
 packet: "
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 " len=
 %d !=3D %zd\n", err, len);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 vhost_add_used_and_signal(&net->dev, vq=
, head, 0);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 /*
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* if no pending buffer size allocate=
, signal used buffer
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* one by one, otherwise, signal used=
 buffer when reaching
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* 3/4 ring size to reduce CPU utiliz=
ation.
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*/
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (unlikely(vq->pend))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 vhost_add_used_and_sign=
al(&net->dev, vq, head, 0);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 else {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 vq->pend[vq->num_pend].=
id =3D head;

I don't understand the logic here: if !vq->pend then we assign to
vq->pend[vq->num_pend].

> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 vq->pend[vq->num_pend].=
len =3D 0;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ++vq->num_pend;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (vq->num_pend =3D=3D=
 (vq->num - (vq->num >> 2))) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 vhost_a=
dd_used_and_signal_n(&net->dev, vq,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 vq->pend,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 vq->num_pend);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 vq->num=
_pend =3D 0;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0total_len +=3D len;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (unlikely(total_len >=3D VHOST_NET_=
WEIGHT)) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0vhost_poll_queue(&vq->=
poll);
> diff --git a/drivers/vhost/vhost.c b/drivers/vhost/vhost.c
> index 94701ff..47696d2 100644
> --- a/drivers/vhost/vhost.c
> +++ b/drivers/vhost/vhost.c
> @@ -170,6 +170,16 @@ static void vhost_vq_reset(struct vhost_dev *dev=
,
> =A0 =A0 =A0 =A0vq->call_ctx =3D NULL;
> =A0 =A0 =A0 =A0vq->call =3D NULL;
> =A0 =A0 =A0 =A0vq->log_ctx =3D NULL;
> + =A0 =A0 =A0 /* signal pending used buffers */
> + =A0 =A0 =A0 if (vq->pend) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (vq->num_pend !=3D 0) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 vhost_add_used_and_sign=
al_n(dev, vq, vq->pend,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 vq->num_pend);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 vq->num_pend =3D 0;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 kfree(vq->pend);
> + =A0 =A0 =A0 }
> + =A0 =A0 =A0 vq->pend =3D NULL;
> =A0}
>
> =A0static int vhost_worker(void *data)
> @@ -273,7 +283,13 @@ long vhost_dev_init(struct vhost_dev *dev,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0dev->vqs[i].heads =3D NULL;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0dev->vqs[i].dev =3D dev;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0mutex_init(&dev->vqs[i].mutex);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 dev->vqs[i].num_pend =3D 0;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 dev->vqs[i].pend =3D NULL;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0vhost_vq_reset(dev, dev->vqs + i);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* signal 3/4 of ring size used buffers=
 */
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 dev->vqs[i].pend =3D kmalloc((dev->vqs[=
i].num -
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0(dev->vqs[i].num >> 2)) *
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0sizeof *vq->peed, GFP_KERNEL);

Has this patch been compile tested?  vq->peed?

Stefan
