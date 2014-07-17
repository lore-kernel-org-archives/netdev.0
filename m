From: Marcel Holtmann <marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org>
Subject: Re: [PATCH] bluetooth: never linger on process exit
Date: Thu, 17 Jul 2014 12:05:26 +0200
Message-ID: <2ECFA3A4-C890-4512-86CD-B17EFDB57663@holtmann.org>
References: <1405412728-4706-1-git-send-email-vdavydov@parallels.com>
Mime-Version: 1.0 (Mac OS X Mail 7.3 \(1878.6\))
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"Gustavo F. Padovan" <gustavo-THi1TnShQwVAfugRpC6u6w@public.gmane.org>,
	Johan Hedberg <johan.hedberg-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Linux Bluetooth mailing list
	<linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Vladimir Davydov <vdavydov-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Return-path: <linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1405412728-4706-1-git-send-email-vdavydov-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Sender: linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Vladimir,

please always include linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org since otherwise it might be missed in the massive amount of emails that is LKML.

> If the current process is exiting, lingering on socket close will make
> it unkillable, so we should avoid it.
> 
> Reproducer:
> 
>  #include <sys/types.h>
>  #include <sys/socket.h>
> 
>  #define BTPROTO_L2CAP   0
>  #define BTPROTO_SCO     2
>  #define BTPROTO_RFCOMM  3
> 
>  int main()
>  {
>          int fd;
>          struct linger ling;
> 
>          fd = socket(PF_BLUETOOTH, SOCK_STREAM, BTPROTO_RFCOMM);
>          //or: fd = socket(PF_BLUETOOTH, SOCK_DGRAM, BTPROTO_L2CAP);
>          //or: fd = socket(PF_BLUETOOTH, SOCK_SEQPACKET, BTPROTO_SCO);
> 
>          ling.l_onoff = 1;
>          ling.l_linger = 1000000000;
>          setsockopt(fd, SOL_SOCKET, SO_LINGER, &ling, sizeof(ling));
> 
>          return 0;
>  }
> 
> Signed-off-by: Vladimir Davydov <vdavydov-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
> Cc: Marcel Holtmann <marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org>
> Cc: Gustavo Padovan <gustavo-THi1TnShQwVAfugRpC6u6w@public.gmane.org>
> Cc: Johan Hedberg <johan.hedberg-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> ---
> net/bluetooth/l2cap_sock.c  |    3 ++-
> net/bluetooth/rfcomm/sock.c |    3 ++-
> net/bluetooth/sco.c         |    6 ++++--
> 3 files changed, 8 insertions(+), 4 deletions(-)
> 
> diff --git a/net/bluetooth/l2cap_sock.c b/net/bluetooth/l2cap_sock.c
> index e1378693cc90..d0fd8b04f2e6 100644
> --- a/net/bluetooth/l2cap_sock.c
> +++ b/net/bluetooth/l2cap_sock.c
> @@ -1111,7 +1111,8 @@ static int l2cap_sock_shutdown(struct socket *sock, int how)
> 		l2cap_chan_close(chan, 0);
> 		lock_sock(sk);
> 
> -		if (sock_flag(sk, SOCK_LINGER) && sk->sk_lingertime)
> +		if (sock_flag(sk, SOCK_LINGER) && sk->sk_lingertime &&
> +		    !(current->flags & PF_EXITING))
> 			err = bt_sock_wait_state(sk, BT_CLOSED,
> 						 sk->sk_lingertime);
> 	}

The only other example of using PF_EXITING I found is net/ipv4/af_inet.c and if this is the preferred way of handling this, the patch looks fine to me.

Regards

Marcel
