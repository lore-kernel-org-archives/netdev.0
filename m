From: "Arnaldo Carvalho de Melo" <acme@ghostprotocols.net>
Subject: Re: Transforming code to using ICMP packet accessors
Date: Thu, 26 Apr 2007 09:18:16 -0300
Message-ID: <39e6f6c70704260518q68ff180eu7722a9917681136@mail.gmail.com>
References: <11959.1177586619@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "David Howells" <dhowells@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wr-out-0506.google.com ([64.233.184.238]:52212 "EHLO
	wr-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1031200AbXDZMSW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Apr 2007 08:18:22 -0400
Received: by wr-out-0506.google.com with SMTP id 76so589795wra
        for <netdev@vger.kernel.org>; Thu, 26 Apr 2007 05:18:22 -0700 (PDT)
In-Reply-To: <11959.1177586619@redhat.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 4/26/07, David Howells <dhowells@redhat.com> wrote:
>
> How do I convert:
>
>         addr = *(__be32 *)(skb->nh.raw + serr->addr_offset);
>
> to use the ICMP accessor macros now that skb->nh is no longer available?  I
> was using this to pluck an address out of the ICMP packet payload, but
>
>         void rxrpc_UDP_error_report(struct sock *sk)
>         {
>                 struct sock_exterr_skb *serr;
>         ...
>                 struct sk_buff *skb;
>                 __be32 addr;
>                 __be16 port;
>         ...
>
>                 skb = skb_dequeue(&sk->sk_error_queue);
>                 if (!skb) {
>                         _leave("UDP socket errqueue empty");
>                         return;
>                 }
>         ...
>
>                 serr = SKB_EXT_ERR(skb);
>                 addr = *(__be32 *)(skb->nh.raw + serr->addr_offset);
>                 port = serr->port;
>
>                 _net("Rx UDP Error from "NIPQUAD_FMT":%hu",
>                      NIPQUAD(addr), ntohs(port));
>         ...
>         }
>
> Should I do this?:
>
>         addr = *(__be32 *)(skb_network_header(skb) + serr->addr_offset);

Yes, as this is the only use in this function.

When there is more than one use, create a pointer from
skb_network_header(skb). That way the skb->head + skb->network_header
math is done just once.

- Arnaldo
