From: Daniel Baluta <dbaluta@ixiacom.com>
Subject: Re: [PATCH] llc_cmsg_rcv was getting called after sk_eat_skb.
Date: Fri, 16 Dec 2011 17:29:24 +0200
Message-ID: <CAEnQRZAWpjZ2gm9wgoqdyHmKQ=geoXNC0kdVL4fT0Vrk54E1Ew@mail.gmail.com>
References: <1324026085-11812-1-git-send-email-ajuncu@ixiacom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: acme@ghostprotocols.net, davem@davemloft.net,
	netdev@vger.kernel.org, alex.juncu@rosedu.org,
	Kunjan Naik <knaik@ixiacom.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: Alexandru Juncu <ajuncu@ixiacom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f174.google.com ([209.85.216.174]:56394 "EHLO
	mail-qy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759955Ab1LPP3Z convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Dec 2011 10:29:25 -0500
Received: by qcqz2 with SMTP id z2so1896536qcq.19
        for <netdev@vger.kernel.org>; Fri, 16 Dec 2011 07:29:24 -0800 (PST)
In-Reply-To: <1324026085-11812-1-git-send-email-ajuncu@ixiacom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Alex,

Please add a llc: prefix to the Subject. Also the title
should suggest what is the patch supposed to do.

e.g:

llc: Don't call llc_cmsg_rcv after sk_eat_skb

On Fri, Dec 16, 2011 at 11:01 AM, Alexandru Juncu <ajuncu@ixiacom.com> =
wrote:
> Received non stream protocol packets were calling llc_cmsg_rcv that u=
sed a
> skb after that skb was released by sk_eat_skb. This caused received S=
TP
> packets to generate kernel panics.
>
> Signed-off-by: Alexandru Juncu <ajuncu@ixiacom.com>
> Signed-off-by: Kunjan Naik <knaik@ixiacom.com>
> ---
> =A0net/llc/af_llc.c | =A0 14 ++++++++++----
> =A01 files changed, 10 insertions(+), 4 deletions(-)
>
> diff --git a/net/llc/af_llc.c b/net/llc/af_llc.c
> index dfd3a64..a18e6c3 100644
> --- a/net/llc/af_llc.c
> +++ b/net/llc/af_llc.c
> @@ -833,15 +833,15 @@ static int llc_ui_recvmsg(struct kiocb *iocb, s=
truct socket *sock,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0copied +=3D used;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0len -=3D used;
>
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* For non stream protcols we get one p=
acket per recvmsg call */
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (sk->sk_type !=3D SOCK_STREAM)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto copy_uaddr;
> +
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (!(flags & MSG_PEEK)) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0sk_eat_skb(sk, skb, 0)=
;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*seq =3D 0;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
>
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* For non stream protcols we get one p=
acket per recvmsg call */
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (sk->sk_type !=3D SOCK_STREAM)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto copy_uaddr;
> -
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0/* Partial read */
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (used + offset < skb->len)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0continue;
> @@ -857,6 +857,12 @@ copy_uaddr:
> =A0 =A0 =A0 =A0}
> =A0 =A0 =A0 =A0if (llc_sk(sk)->cmsg_flags)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0llc_cmsg_rcv(msg, skb);
> +
> + =A0 =A0 =A0 if (!(flags & MSG_PEEK)) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 sk_eat_skb(sk, skb, 0);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 *seq =3D 0;
> + =A0 =A0 =A0 }
> +
> =A0 =A0 =A0 =A0goto out;
> =A0}
>
> --
> 1.7.4.1

David, Eric could you please review this?

thanks,
Daniel.
