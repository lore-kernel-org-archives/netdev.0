From: Marcel Holtmann <marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org>
Subject: Re: [PATCH] Bluetooth: Silence static checker warning.
Date: Wed, 29 Feb 2012 09:39:07 -0800
Message-ID: <1330537147.3392.99.camel@aeonflux>
References: <1330535217-26785-1-git-send-email-santoshprasadnayak@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: padovan-Y3ZbgMPKUGA34EUeqzHoZw@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org,
	linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, kernel-janitors-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: santosh nayak <santoshprasadnayak-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1330535217-26785-1-git-send-email-santoshprasadnayak-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Santosh,

> Silencing Static checker warning.
> 1. Endian warning
> 2. variable dereferenced before check 'sk' .
> 
> Signed-off-by: Santosh Nayak <santoshprasadnayak-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> ---
>  net/bluetooth/l2cap_sock.c |    9 ++++++---
>  1 files changed, 6 insertions(+), 3 deletions(-)
> 
> diff --git a/net/bluetooth/l2cap_sock.c b/net/bluetooth/l2cap_sock.c
> index 401d942..d206321 100644
> --- a/net/bluetooth/l2cap_sock.c
> +++ b/net/bluetooth/l2cap_sock.c
> @@ -82,7 +82,7 @@ static int l2cap_sock_bind(struct socket *sock, struct sockaddr *addr, int alen)
>  	}
>  
>  	if (la.l2_cid)
> -		err = l2cap_add_scid(chan, la.l2_cid);
> +		err = l2cap_add_scid(chan, __le16_to_cpu(la.l2_cid));
>  	else
>  		err = l2cap_add_psm(chan, &la.l2_bdaddr, la.l2_psm);
>  
> @@ -123,7 +123,8 @@ static int l2cap_sock_connect(struct socket *sock, struct sockaddr *addr, int al
>  	if (la.l2_cid && la.l2_psm)
>  		return -EINVAL;
>  
> -	err = l2cap_chan_connect(chan, la.l2_psm, la.l2_cid, &la.l2_bdaddr);
> +	err = l2cap_chan_connect(chan, la.l2_psm, __le16_to_cpu(la.l2_cid),
> +				&la.l2_bdaddr);
>  	if (err)
>  		goto done;

I am not sure about this one. Need to go back and read through the
source code. The value provided from userspace is already in the right
host endian. Could be that we mess up our internal classification. And
instead of adding __le16_to_cpu we should fix its classification.
 
> @@ -795,7 +796,7 @@ static void l2cap_sock_kill(struct sock *sk)
>  static int l2cap_sock_shutdown(struct socket *sock, int how)
>  {
>  	struct sock *sk = sock->sk;
> -	struct l2cap_chan *chan = l2cap_pi(sk)->chan;
> +	struct l2cap_chan *chan;
>  	int err = 0;
>  
>  	BT_DBG("sock %p, sk %p", sock, sk);
> @@ -803,6 +804,8 @@ static int l2cap_sock_shutdown(struct socket *sock, int how)
>  	if (!sk)
>  		return 0;
>  
> +	chan = l2cap_pi(sk)->chan;
> +
>  	lock_sock(sk);
>  	if (!sk->sk_shutdown) {
>  		if (chan->mode == L2CAP_MODE_ERTM)

This one is fine.

Regards

Marcel
