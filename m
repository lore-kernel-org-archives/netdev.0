From: Soheil Hassas Yeganeh <soheil@google.com>
Subject: Re: [PATCH v3] packet: fix second argument of sock_tx_timestamp()
Date: Tue, 19 Jul 2016 08:34:20 -0400
Message-ID: <CACSApvYj5X166euM2Qy+ubvLYdfYg65itMYiVeTf5SUuiA+gog@mail.gmail.com>
References: <1468906851-8424-1-git-send-email-yoshihiro.shimoda.uh@renesas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>, daniel@iogearbox.net,
	Willem de Bruijn <willemb@google.com>, ast@plumgrid.com,
	tklauser@distanz.ch, fruggeri@aristanetworks.com,
	netdev <netdev@vger.kernel.org>,
	linux-renesas-soc@vger.kernel.org, stable@vger.kernel.org
To: Yoshihiro Shimoda <yoshihiro.shimoda.uh@renesas.com>
Return-path: <linux-renesas-soc-owner@vger.kernel.org>
In-Reply-To: <1468906851-8424-1-git-send-email-yoshihiro.shimoda.uh@renesas.com>
Sender: linux-renesas-soc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jul 19, 2016 at 1:40 AM, Yoshihiro Shimoda
<yoshihiro.shimoda.uh@renesas.com> wrote:
> This patch fixes an issue that a syscall (e.g. sendto syscall) cannot
> work correctly. Since the sendto syscall doesn't have msg_control buffer,
> the sock_tx_timestamp() in packet_snd() cannot work correctly because
> the socks.tsflags is set to 0.
> So, this patch sets the socks.tsflags to sk->sk_tsflags as default.
>
> Fixes: c14ac9451c34 ("sock: enable timestamping using control messages")
> Cc: <stable@vger.kernel.org>
> Reported-by: Kazuya Mizuguchi <kazuya.mizuguchi.ks@renesas.com>
> Reported-by: Keita Kobayashi <keita.kobayashi.ym@renesas.com>
> Signed-off-by: Yoshihiro Shimoda <yoshihiro.shimoda.uh@renesas.com>
Acked-by: Soheil Hassas Yeganeh <soheil@google.com>
> ---
>  Changes from v2:
>   - Fix build error...
>
>  Changes from v1:
>   - Set socks.tsflags to sk->sk_tsflags as default instead of a condition.
>   - Fix other socks.tsflags values in the af_packet.c.
>   - Revise the commit log.
>
>  About v1 (as RFC):
>   - http://thread.gmane.org/gmane.linux.kernel.renesas-soc/5646
>
>  net/packet/af_packet.c | 6 +++---
>  1 file changed, 3 insertions(+), 3 deletions(-)
>
> diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
> index 9f0983f..53e87ce 100644
> --- a/net/packet/af_packet.c
> +++ b/net/packet/af_packet.c
> @@ -1927,7 +1927,7 @@ retry:
>                 goto out_unlock;
>         }
>
> -       sockc.tsflags = 0;
> +       sockc.tsflags = sk->sk_tsflags;
>         if (msg->msg_controllen) {
>                 err = sock_cmsg_send(sk, msg, &sockc);
>                 if (unlikely(err)) {
> @@ -2678,7 +2678,7 @@ static int tpacket_snd(struct packet_sock *po, struct msghdr *msg)
>                 dev = dev_get_by_index(sock_net(&po->sk), saddr->sll_ifindex);
>         }
>
> -       sockc.tsflags = 0;
> +       sockc.tsflags = po->sk.sk_tsflags;
>         if (msg->msg_controllen) {
>                 err = sock_cmsg_send(&po->sk, msg, &sockc);
>                 if (unlikely(err))
> @@ -2881,7 +2881,7 @@ static int packet_snd(struct socket *sock, struct msghdr *msg, size_t len)
>         if (unlikely(!(dev->flags & IFF_UP)))
>                 goto out_unlock;
>
> -       sockc.tsflags = 0;
> +       sockc.tsflags = sk->sk_tsflags;
>         sockc.mark = sk->sk_mark;
>         if (msg->msg_controllen) {
>                 err = sock_cmsg_send(sk, msg, &sockc);
> --
> 1.9.1
>

Thanks for the fix.
