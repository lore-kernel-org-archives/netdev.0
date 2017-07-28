From: Neal Cardwell <ncardwell@google.com>
Subject: Re: [RFC PATCH v1 5/5] wave: Added basic version of TCP Wave
Date: Fri, 28 Jul 2017 19:15:07 -0400
Message-ID: <CADVnQynbZcHSUffbiW8WU1-s6js0zkh3jz-z949xQm2ePmGg6w@mail.gmail.com>
References: <20170728195919.10099-1-natale.patriciello@gmail.com> <20170728195919.10099-6-natale.patriciello@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: "David S . Miller" <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        James Morris <jmorris@namei.org>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        Patrick McHardy <kaber@trash.net>,
        netdev <netdev@vger.kernel.org>,
        Ahmed Said <ahmed.said@uniroma2.it>,
        Francesco Zampognaro <zampognaro@ing.uniroma2.it>,
        Cesare Roseti <roseti@ing.uniroma2.it>
To: Natale Patriciello <natale.patriciello@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f49.google.com ([209.85.218.49]:33153 "EHLO
        mail-oi0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753038AbdG1XPi (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 28 Jul 2017 19:15:38 -0400
Received: by mail-oi0-f49.google.com with SMTP id a9so145124461oih.0
        for <netdev@vger.kernel.org>; Fri, 28 Jul 2017 16:15:38 -0700 (PDT)
In-Reply-To: <20170728195919.10099-6-natale.patriciello@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jul 28, 2017 at 3:59 PM, Natale Patriciello
<natale.patriciello@gmail.com> wrote:
> TCP Wave (TCPW) replaces the window-based transmission paradigm of the
> standard TCP with a burst-based transmission, the ACK-clock scheduling
> with a self-managed timer and the RTT-based congestion control loop
> with an Ack-based Capacity and Congestion Estimation (ACCE) module. In
> non-technical words, it sends data down the stack when its internal
> timer expires, and the timing of the received ACKs contribute to
> updating this timer regularly.
>
> It is the first TCP congestion control that uses the timing constraint
> developed in the Linux kernel.
>
> Signed-off-by: Natale Patriciello <natale.patriciello@gmail.com>
> Tested-by: Ahmed Said <ahmed.said@uniroma2.it>
> ---
>  MAINTAINERS           |   6 +
>  net/ipv4/Kconfig      |  16 +
>  net/ipv4/Makefile     |   1 +
>  net/ipv4/tcp_output.c |   4 +-
>  net/ipv4/tcp_wave.c   | 914 ++++++++++++++++++++++++++++++++++++++++++++++++++
>  5 files changed, 940 insertions(+), 1 deletion(-)
>  create mode 100644 net/ipv4/tcp_wave.c
>
> diff --git a/MAINTAINERS b/MAINTAINERS
> index 767e9d202adf..39c57bdc417d 100644
> --- a/MAINTAINERS
> +++ b/MAINTAINERS
> @@ -12427,6 +12427,12 @@ W:     http://tcp-lp-mod.sourceforge.net/
>  S:     Maintained
>  F:     net/ipv4/tcp_lp.c
>
> +TCP WAVE MODULE
> +M:     "Natale Patriciello" <natale.patriciello@gmail.com>
> +W:     http://tcp-lp-mod.sourceforge.net/

This URL does not work for me... I get "Unable to connect to database server".

> @@ -2522,7 +2522,9 @@ void tcp_push_one(struct sock *sk, unsigned int mss_now)
>  {
>         struct sk_buff *skb = tcp_send_head(sk);
>
> -       BUG_ON(!skb || skb->len < mss_now);
> +       /* Don't be forced to send not meaningful data */
> +       if (!skb || skb->len < mss_now)
> +               return;
>
>         tcp_write_xmit(sk, mss_now, TCP_NAGLE_PUSH, 1, sk->sk_allocation);
>  }

This seems unrelated to the rest of the patch, and should probably be
its own patch? Also, IMHO it would be better to leave at least a
WARN_ON or WARN_ON_ONCE here, rather than completely turning this into
a silent failure.

thanks,
neal
