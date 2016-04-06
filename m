From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: Re: [PATCH] packet: uses kfree_skb() for drop.
Date: Wed, 6 Apr 2016 13:27:11 -0400
Message-ID: <CAF=yD-JrVXKsJTUcWSmuVmPbdZV=_h8hsVPQVQTPF64R1k684w@mail.gmail.com>
References: <1459961686-14281-1-git-send-email-weongyo.linux@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Network Development <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Willem de Bruijn <willemb@google.com>
To: Weongyo Jeong <weongyo.linux@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f196.google.com ([209.85.217.196]:33852 "EHLO
	mail-lb0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751290AbcDFR1w (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Apr 2016 13:27:52 -0400
Received: by mail-lb0-f196.google.com with SMTP id vk4so4428019lbb.1
        for <netdev@vger.kernel.org>; Wed, 06 Apr 2016 10:27:51 -0700 (PDT)
In-Reply-To: <1459961686-14281-1-git-send-email-weongyo.linux@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 6, 2016 at 12:54 PM, Weongyo Jeong <weongyo.linux@gmail.com> wrote:
> consume_skb() isn't for drop or error cases.  kfree_skb() is more proper
> one.
> Signed-off-by: Weongyo Jeong <weongyo.linux@gmail.com>
> ---
>  net/packet/af_packet.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
> index 1ecfa71..a75d5bf 100644
> --- a/net/packet/af_packet.c
> +++ b/net/packet/af_packet.c
> @@ -2141,7 +2141,7 @@ drop_n_restore:
>                 skb->len = skb_len;
>         }
>  drop:
> -       consume_skb(skb);
> +       kfree_skb(skb);

This does show an inconsistency between packet_rcv and tpacket_rcv,
which calls kfree_skb.

A comment at consume_skb mentions that kfree_skb is intended for drops
that signal a failure condition, and indeed, that makes it a useful
way to track errors (e.g., with perf record -a -g -e skb:kfree_skb).

This drop path is not always an error path, though. These network taps
will legitimately drop references to any packets not destined to them.
To be precise, only the drop_n_acct label cases are delivery errors
(drops after the filter accepted the packet). Changing unconditionally
to kfree_skb does pollute that useful counter with false positives. A
pedantic solution is to change both functions to only call kfree_skb
on drop_n_acct and consume_skb otherwise.

This shorthand change does at least makes packet_rcv and tpacket_rcv more alike.
