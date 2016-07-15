From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: Re: [PATCH/RFC] packet: fix sock_tx_timestamp() in packet_snd() via
 sendto syscall
Date: Fri, 15 Jul 2016 11:31:08 -0400
Message-ID: <CAF=yD-K5aqcjPw4T1_+YXFg-gPBzGwxC5hAFwT6Otda7nhNxag@mail.gmail.com>
References: <1468550944-4584-1-git-send-email-yoshihiro.shimoda.uh@renesas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>, fruggeri@aristanetworks.com,
	Network Development <netdev@vger.kernel.org>,
	Soheil Hassas Yeganeh <soheil.kdev@gmail.com>
To: Yoshihiro Shimoda <yoshihiro.shimoda.uh@renesas.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vk0-f65.google.com ([209.85.213.65]:34797 "EHLO
	mail-vk0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751667AbcGOPbt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Jul 2016 11:31:49 -0400
Received: by mail-vk0-f65.google.com with SMTP id w127so4427175vkh.1
        for <netdev@vger.kernel.org>; Fri, 15 Jul 2016 08:31:48 -0700 (PDT)
In-Reply-To: <1468550944-4584-1-git-send-email-yoshihiro.shimoda.uh@renesas.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jul 14, 2016 at 10:49 PM, Yoshihiro Shimoda
<yoshihiro.shimoda.uh@renesas.com> wrote:
> Since the sendto syscall doesn't have msg_control buffer,
> the sock_tx_timestamp() in packet_snd() cannot work correctly because
> the socks.fsflags is set to 0.

You're right. __sock_tx_timestamp used to take sk->sk_tsflags as
input, now it relies solely on this parameter tsflags. All callsites
must either pass sk->sk_tsflags directly or initialize sockc.tsflags
to this value.

> diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
> index 9f0983f..d76fd41 100644
> --- a/net/packet/af_packet.c
> +++ b/net/packet/af_packet.c
> @@ -2887,6 +2887,11 @@ static int packet_snd(struct socket *sock, struct msghdr *msg, size_t len)
>                 err = sock_cmsg_send(sk, msg, &sockc);
>                 if (unlikely(err))
>                         goto out_unlock;
> +       } else {
> +               /* Set tsflags from sk because a syscall (e.g. sendto) doesn't
> +                * have msg_control buffer.
> +                */
> +               sockc.tsflags = sk->sk_tsflags;
>         }

Better to follow the example of other protocols. In all three packet
variants, make the following initialization change:

-       sockc.tsflags = 0;
+       sockc.tsflags = sk->sk_tsflags;

(I had to remove some recipients, because my reply was marked as spam
and dropped otherwise..)
