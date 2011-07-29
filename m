From: Mike Waychison <mikew@google.com>
Subject: Re: [PATCH RFC net-next] virtio_net: refill buffer right after being used
Date: Fri, 29 Jul 2011 16:58:04 -0700
Message-ID: <CAGTjWtCsgcf664HJ_prmcRyUzLcSSKhjfbaM0KnsxhDJo6k7Fg@mail.gmail.com>
References: <1311979448.24300.28.camel@localhost.localdomain> <1311980131.24300.30.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Rusty Russell <rusty@rustcorp.com.au>, mst@redhat.com,
	kvm@vger.kernel.org, virtualization@lists.osdl.org,
	netdev@vger.kernel.org
To: Shirley Ma <mashirle@us.ibm.com>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <1311980131.24300.30.camel@localhost.localdomain>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jul 29, 2011 at 3:55 PM, Shirley Ma <mashirle@us.ibm.com> wrote=
:
> Resubmit it with a typo fix.
>
> Signed-off-by: Shirley Ma <xma@us.ibm.com>
> ---
>
> diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
> index 0c7321c..c8201d4 100644
> --- a/drivers/net/virtio_net.c
> +++ b/drivers/net/virtio_net.c
> @@ -429,6 +429,22 @@ static int add_recvbuf_mergeable(struct virtnet_=
info *vi, gfp_t gfp)
> =A0 =A0 =A0 =A0return err;
> =A0}
>
> +static int fill_one(struct virtnet_info *vi, gfp_t gfp)
> +{
> + =A0 =A0 =A0 int err;
> +
> + =A0 =A0 =A0 if (vi->mergeable_rx_bufs)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 err =3D add_recvbuf_mergeable(vi, gfp);
> + =A0 =A0 =A0 else if (vi->big_packets)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 err =3D add_recvbuf_big(vi, gfp);
> + =A0 =A0 =A0 else
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 err =3D add_recvbuf_small(vi, gfp);
> +
> + =A0 =A0 =A0 if (err >=3D 0)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 ++vi->num;
> + =A0 =A0 =A0 return err;
> +}
> +
> =A0/* Returns false if we couldn't fill entirely (OOM). */
> =A0static bool try_fill_recv(struct virtnet_info *vi, gfp_t gfp)
> =A0{
> @@ -436,17 +452,10 @@ static bool try_fill_recv(struct virtnet_info *=
vi, gfp_t gfp)
> =A0 =A0 =A0 =A0bool oom;
>
> =A0 =A0 =A0 =A0do {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (vi->mergeable_rx_bufs)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 err =3D add_recvbuf_mer=
geable(vi, gfp);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 else if (vi->big_packets)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 err =3D add_recvbuf_big=
(vi, gfp);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 else
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 err =3D add_recvbuf_sma=
ll(vi, gfp);
> -
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 err =3D fill_one(vi, gfp);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0oom =3D err =3D=3D -ENOMEM;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (err < 0)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0break;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 ++vi->num;
> =A0 =A0 =A0 =A0} while (err > 0);
> =A0 =A0 =A0 =A0if (unlikely(vi->num > vi->max))
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0vi->max =3D vi->num;
> @@ -506,13 +515,13 @@ again:
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0receive_buf(vi->dev, buf, len);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0--vi->num;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0received++;
> - =A0 =A0 =A0 }
> -
> - =A0 =A0 =A0 if (vi->num < vi->max / 2) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!try_fill_recv(vi, GFP_ATOMIC))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (fill_one(vi, GFP_ATOMIC) < 0)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0schedule_delayed_work(=
&vi->refill, 0);
> =A0 =A0 =A0 =A0}
>
> + =A0 =A0 =A0 /* notify buffers are refilled */
> + =A0 =A0 =A0 virtqueue_kick(vi->rvq);
> +

How does this reduce latency?   We are doing the same amount of work
in both cases, and in both cases the newly available buffers are not
visible to the device until the virtqueue_kick..


> =A0 =A0 =A0 =A0/* Out of packets? */
> =A0 =A0 =A0 =A0if (received < budget) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0napi_complete(napi);
>
>
> --
> To unsubscribe from this list: send the line "unsubscribe kvm" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
>
