From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net-next 11/11] rxrpc: Add config to inject packet loss
Date: Sun, 18 Sep 2016 14:47:30 +0300
Message-ID: <176ee541-5f28-c7f1-657f-d015554b99e1@cogentembedded.com>
References: <147415448967.18436.14900942726390485534.stgit@warthog.procyon.org.uk>
 <147415456698.18436.9557149460694248243.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-afs@lists.infradead.org, linux-kernel@vger.kernel.org
To: David Howells <dhowells@redhat.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f50.google.com ([209.85.215.50]:33097 "EHLO
        mail-lf0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756172AbcIRLre (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 18 Sep 2016 07:47:34 -0400
Received: by mail-lf0-f50.google.com with SMTP id h127so93139051lfh.0
        for <netdev@vger.kernel.org>; Sun, 18 Sep 2016 04:47:33 -0700 (PDT)
In-Reply-To: <147415456698.18436.9557149460694248243.stgit@warthog.procyon.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 9/18/2016 2:22 AM, David Howells wrote:

> Add a configuration option to inject packet loss by discarding
> approximately every 8th packet received and approximately every 8th DATA
> packet transmitted.
>
> Note that no locking is used, but it shouldn't really matter.
>
> Signed-off-by: David Howells <dhowells@redhat.com>

[...]

> diff --git a/net/rxrpc/input.c b/net/rxrpc/input.c
> index 84bb16d47b85..7ac1edf3aac7 100644
> --- a/net/rxrpc/input.c
> +++ b/net/rxrpc/input.c
> @@ -712,6 +712,14 @@ void rxrpc_data_ready(struct sock *udp_sk)
>  	skb_orphan(skb);
>  	sp = rxrpc_skb(skb);
>
> +	if (IS_ENABLED(CONFIG_AF_RXRPC_INJECT_LOSS)) {
> +		static int lose;

    IIRC, scripts/checkpatch.pl complains now if there's no empty line after 
declaration...

> +		if ((lose++ & 7) == 7) {
> +			rxrpc_lose_skb(skb, rxrpc_skb_rx_lost);
> +			return;
> +		}
> +	}
> +
>  	_net("Rx UDP packet from %08x:%04hu",
>  	     ntohl(ip_hdr(skb)->saddr), ntohs(udp_hdr(skb)->source));
>
> diff --git a/net/rxrpc/output.c b/net/rxrpc/output.c
> index a2cad5ce7416..16e18a94ffa6 100644
> --- a/net/rxrpc/output.c
> +++ b/net/rxrpc/output.c
> @@ -225,6 +225,15 @@ int rxrpc_send_data_packet(struct rxrpc_connection *conn, struct sk_buff *skb)
>  	msg.msg_controllen = 0;
>  	msg.msg_flags = 0;
>
> +	if (IS_ENABLED(CONFIG_AF_RXRPC_INJECT_LOSS)) {
> +		static int lose;

    Same here.

> +		if ((lose++ & 7) == 7) {
> +			rxrpc_lose_skb(skb, rxrpc_skb_tx_lost);
> +			_leave(" = 0 [lose]");
> +			return 0;
> +		}
> +	}
> +
>  	/* send the packet with the don't fragment bit set if we currently
>  	 * think it's small enough */
>  	if (skb->len - sizeof(struct rxrpc_wire_header) < conn->params.peer->maxdata) {

MBR, Sergei
