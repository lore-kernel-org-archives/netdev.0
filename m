From: Willem de Bruijn <willemb@google.com>
Subject: Re: [PATCH] net-timestamp: Fix a documentation typo
Date: Mon, 24 Nov 2014 17:11:28 -0500
Message-ID: <CA+FuTSenSVXP-=hH+erpoE7yz1HbF8n9PeD_Xof-W=3GaQ6OFA@mail.gmail.com>
References: <ca6ac789334c26905d86f2a596878d2dc18e69e9.1416859110.git.luto@amacapital.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Network Development <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>
To: Andy Lutomirski <luto@amacapital.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f48.google.com ([209.85.192.48]:50997 "EHLO
	mail-qg0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750821AbaKXWMD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Nov 2014 17:12:03 -0500
Received: by mail-qg0-f48.google.com with SMTP id q107so7387897qgd.7
        for <netdev@vger.kernel.org>; Mon, 24 Nov 2014 14:12:02 -0800 (PST)
In-Reply-To: <ca6ac789334c26905d86f2a596878d2dc18e69e9.1416859110.git.luto@amacapital.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Nov 24, 2014 at 3:02 PM, Andy Lutomirski <luto@amacapital.net> wrote:
> SOF_TIMESTAMPING_OPT_ID puts the id in ee_data, not ee_info.
>
> Cc: Willem de Bruijn <willemb@google.com>
> Signed-off-by: Andy Lutomirski <luto@amacapital.net>

Acked-by: Willem de Bruijn <willemb@google.com>

> ---

Thanks for sending a fix.

> While I'm here, the docs say:
>
>     In practice, it [ee_data] is a monotonically increasing u32 (that wraps).
>
> Is user code supposed to rely on this and, further, on the fact that the
> counter starts at zero?  If not, how else is user code supposed to match
> outgoing data to timestamps?

That is correct. The per-socket counter is reset when
SOF_TIMESTAMPING_OPT_ID is set. On datagram sockets, it returns the
packet number since the reset. On stream sockets, it returns the byte
offset since the reset.

> Also, is it intentional that the payload data associated with the tx
> timestamp is (I think) the full outgoing packet including lower-layer
> headers?

Absolutely not. I'll look into that right away. It doesn't on ACK, and
should certainly not expose this info in the other cases, either.

> And, finally, would it be possible to attach IP_PKTINFO to the looped
> timestamp?  That way I could finally update my fancy ping program to
> track which outgoing interface was used for a request.

If socket option IP_PKTINFO is set, you want to receive in_pktinfo for
any packet that happens to be queued onto the error queue? Both
SKB_EXT_ERR(skb) and PKTINFO_SKB_CB(skb) use the control block to
store data that is later encoded in a cmsg, so there may not be enough
room to hold both. I'll take a look.
