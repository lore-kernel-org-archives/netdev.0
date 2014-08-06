From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next v4 5/6] net-timestamp: TCP timestamping
Date: Wed, 06 Aug 2014 08:25:07 +0200
Message-ID: <1407306307.14097.2.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1407204710-21778-1-git-send-email-willemb@google.com>
	 <1407204710-21778-6-git-send-email-willemb@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	richardcochran@gmail.com
To: Willem de Bruijn <willemb@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f48.google.com ([74.125.82.48]:36372 "EHLO
	mail-wg0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751323AbaHFGZN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Aug 2014 02:25:13 -0400
Received: by mail-wg0-f48.google.com with SMTP id x13so2094153wgg.31
        for <netdev@vger.kernel.org>; Tue, 05 Aug 2014 23:25:11 -0700 (PDT)
In-Reply-To: <1407204710-21778-6-git-send-email-willemb@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2014-08-04 at 22:11 -0400, Willem de Bruijn wrote:

...

> diff --git a/net/ipv4/tcp_offload.c b/net/ipv4/tcp_offload.c
> index 55046ec..f597119 100644
> --- a/net/ipv4/tcp_offload.c
> +++ b/net/ipv4/tcp_offload.c
> @@ -14,6 +14,21 @@
>  #include <net/tcp.h>
>  #include <net/protocol.h>
>  
> +void tcp_gso_tstamp(struct sk_buff *skb, unsigned int ts_seq, unsigned int seq,
> +		    unsigned int mss)

static void ...

Or else :

make C=2 net/ipv4/tcp_offload.o
  CHECK   net/ipv4/tcp_offload.c
net/ipv4/tcp_offload.c:17:6: warning: symbol 'tcp_gso_tstamp' was not
declared. Should it be static?


> +{
> +	while (skb) {
> +		if (ts_seq < (__u64) seq + mss) {

TCP stack uses after() and/or before() macros when dealing with 32bit
sequence numbers.

> +			skb_shinfo(skb)->tx_flags = SKBTX_SW_TSTAMP;
> +			skb_shinfo(skb)->tskey = ts_seq;
> +			return;
> +		}
> +
> +		skb = skb->next;
> +		seq += mss;
> +	}
> +}
> +
