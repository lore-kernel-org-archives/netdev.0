From: Daniel Baluta <daniel.baluta-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH net-next] can-raw: add msg_flags to distinguish local
	traffic
Date: Fri, 15 Oct 2010 12:09:37 +0300
Message-ID: <AANLkTi=3Zh+EQ+CcwypMMJWu80BC_UNsPe7yQUN5ciDL@mail.gmail.com>
References: <20101015073709.GA387@e-circ.dyndns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org, netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Oliver Hartkopp <socketcan-fJ+pQTUTwRTk1uMJSBkQmQ@public.gmane.org>
To: Kurt Van Dijck <kurt.van.dijck-/BeEPy95v10@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <20101015073709.GA387-MxZ6Iy/zr/UdbCeoMzGj59i2O/JbrIOy@public.gmane.org>
List-Unsubscribe: <https://lists.berlios.de/mailman/options/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=unsubscribe>
List-Archive: <https://lists.berlios.de/pipermail/socketcan-core>
List-Post: <mailto:socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
List-Help: <mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=help>
List-Subscribe: <https://lists.berlios.de/mailman/listinfo/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=subscribe>
Sender: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Errors-To: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, Oct 15, 2010 at 10:37 AM, Kurt Van Dijck <kurt.van.dijck-/BeEPy95v10@public.gmane.org> wr=
ote:
> CAN has no addressing scheme. It is currently impossible
> for userspace to tell is a received CAN frame comes from
> another process on the local host, or from a remote CAN
> device.
> This patch add support for userspace applications to distinguish
> between 'own', 'local' and 'remote' CAN traffic.
> Distinction is made by returning some flags in msg->msg_flags
> in the call to recvmsg.
> MSG_CONFIRM flag means 'own', as in 'transmission confirmation'
> MSG_DONTROUTE flag means 'local', not routed.
> Obviously, msgs with MSG_CONFIRM will have MSG_DONTROUTE set too.
>
> Please note that on SocketCAN mailing list, different opinions
> exist on the exact meaning of MSG_DONTROUTE. Better (=3Dmore
> intuitive) alternatives are appreciated.
>
> Signed-off-by: Kurt Van Dijck <kurt.van.dijck-AgBVmzD5pcezQB+pC5nmwQ@public.gmane.org>
> ---
> =A0net/can/raw.c | =A0 33 ++++++++++++++++++++++++++++++---
> =A01 files changed, 30 insertions(+), 3 deletions(-)
>
> diff --git a/net/can/raw.c b/net/can/raw.c
> index 7d77e67..f98709e 100644
> --- a/net/can/raw.c
> +++ b/net/can/raw.c
> @@ -90,23 +90,39 @@ struct raw_sock {
> =A0 =A0 =A0 =A0can_err_mask_t err_mask;
> =A0};
>
> +/*
> + * return some space to store extra msg flags in.
> + * We use 1 int beyond the 'struct sockaddr_can' in skb->cb
> + * to store those.
> + * These flags will be use in raw_recvmsg()
> + */
> +static inline int *raw_flags(struct sk_buff *skb)
> +{
> + =A0 =A0 =A0 BUILD_BUG_ON(sizeof(skb->cb)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 <=3D (sizeof(struct sockadd=
r_can) + sizeof(int)));
> + =A0 =A0 =A0 /* return pointer after struct sockaddr_can */
> + =A0 =A0 =A0 return (int *)(&((struct sockaddr_can *)skb->cb)[1]);

Since msg_flags is unsigned, it would be nice if this function returns unsi=
gned.

> +}
> +
> =A0static inline struct raw_sock *raw_sk(const struct sock *sk)
> =A0{
> =A0 =A0 =A0 =A0return (struct raw_sock *)sk;
> =A0}
>
> -static void raw_rcv(struct sk_buff *skb, void *data)
> +static void raw_rcv(struct sk_buff *oskb, void *data)
> =A0{
> =A0 =A0 =A0 =A0struct sock *sk =3D (struct sock *)data;
> =A0 =A0 =A0 =A0struct raw_sock *ro =3D raw_sk(sk);
> =A0 =A0 =A0 =A0struct sockaddr_can *addr;
> + =A0 =A0 =A0 struct sk_buff *skb;
> + =A0 =A0 =A0 int *pflags;
>
> =A0 =A0 =A0 =A0/* check the received tx sock reference */
> - =A0 =A0 =A0 if (!ro->recv_own_msgs && skb->sk =3D=3D sk)
> + =A0 =A0 =A0 if (!ro->recv_own_msgs && oskb->sk =3D=3D sk)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return;
>
> =A0 =A0 =A0 =A0/* clone the given skb to be able to enqueue it into the r=
cv queue */
> - =A0 =A0 =A0 skb =3D skb_clone(skb, GFP_ATOMIC);
> + =A0 =A0 =A0 skb =3D skb_clone(oskb, GFP_ATOMIC);
> =A0 =A0 =A0 =A0if (!skb)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return;
>
> @@ -123,6 +139,14 @@ static void raw_rcv(struct sk_buff *skb, void *data)
> =A0 =A0 =A0 =A0addr->can_family =A0=3D AF_CAN;
> =A0 =A0 =A0 =A0addr->can_ifindex =3D skb->dev->ifindex;
>
> + =A0 =A0 =A0 /* prepare the flags for raw_recvmsg() */
> + =A0 =A0 =A0 pflags =3D raw_flags(skb);
> + =A0 =A0 =A0 *pflags =3D 0;
> + =A0 =A0 =A0 if (oskb->sk)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 *pflags |=3D MSG_DONTROUTE;
> + =A0 =A0 =A0 if (oskb->sk =3D=3D sk)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 *pflags |=3D MSG_CONFIRM;
> +
> =A0 =A0 =A0 =A0if (sock_queue_rcv_skb(sk, skb) < 0)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0kfree_skb(skb);
> =A0}
> @@ -707,6 +731,9 @@ static int raw_recvmsg(struct kiocb *iocb, struct soc=
ket *sock,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0memcpy(msg->msg_name, skb->cb, msg->msg_na=
melen);
> =A0 =A0 =A0 =A0}
>
> + =A0 =A0 =A0 /* assign the flags that have been recorded in in raw_rcv()=
 */
small typo: double in
> + =A0 =A0 =A0 msg->msg_flags |=3D *(raw_flags(skb));
> +
> =A0 =A0 =A0 =A0skb_free_datagram(sk, skb);
>
> =A0 =A0 =A0 =A0return size;

thanks,
Daniel.
