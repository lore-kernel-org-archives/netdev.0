From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net-next 07/15] rxrpc: Fix accidental cancellation of
 scheduled resend by ACK parser
Date: Fri, 23 Sep 2016 21:02:36 +0300
Message-ID: <c868ca22-fed0-67f7-7471-165b3e5a9edd@cogentembedded.com>
References: <147464371753.5090.1634919599283321856.stgit@warthog.procyon.org.uk>
 <147464376586.5090.14901936645927156006.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-afs@lists.infradead.org, linux-kernel@vger.kernel.org
To: David Howells <dhowells@redhat.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f54.google.com ([209.85.215.54]:33514 "EHLO
        mail-lf0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1034328AbcIWSCl (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 23 Sep 2016 14:02:41 -0400
Received: by mail-lf0-f54.google.com with SMTP id b71so72622868lfg.0
        for <netdev@vger.kernel.org>; Fri, 23 Sep 2016 11:02:40 -0700 (PDT)
In-Reply-To: <147464376586.5090.14901936645927156006.stgit@warthog.procyon.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 09/23/2016 06:16 PM, David Howells wrote:

> When rxrpc_input_soft_acks() is parsing the soft-ACKs from an ACK packet,
> it updates the Tx packet annotations in the annotation buffer.  If a
> soft-ACK is an ACK, then we overwrite unack'd, nak'd or to-be-retransmitted
> states and that is fine; but if the soft-ACK is an NACK, we overwrite the
> to-be-retransmitted with a nak - which isn't.
>
> Instead, we need to let any scheduled retransmission stand if the packet
> was NAK'd.
>
> Note that we don't reissue a resend if the annotation is in the
> to-be-retransmitted state because someone else must've scheduled the
> resend already.
>
> Signed-off-by: David Howells <dhowells@redhat.com>
> ---
>
>  net/rxrpc/input.c |    2 ++
>  1 file changed, 2 insertions(+)
>
> diff --git a/net/rxrpc/input.c b/net/rxrpc/input.c
> index 06027b6d9c19..d3d69ab1f0a1 100644
> --- a/net/rxrpc/input.c
> +++ b/net/rxrpc/input.c
> @@ -479,6 +479,8 @@ static void rxrpc_input_soft_acks(struct rxrpc_call *call, u8 *acks,
>  		case RXRPC_ACK_TYPE_NACK:
>  			if (anno_type == RXRPC_TX_ANNO_NAK)
>  				continue;
> +			if (anno_type == RXRPC_TX_ANNO_RETRANS)
> +				continue;

    Why not fold the above 2 *if*s together? Or use *else if* at least?

MBR, Sergei
