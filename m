From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net v2] vti: fix spd lookup: match plaintext pkt, not
 ipsec pkt
Date: Tue, 05 Nov 2013 09:01:43 -0800
Message-ID: <1383670903.4291.142.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1383646612-30103-1-git-send-email-christophe.gouault@6wind.com>
	 <1383667121-23798-1-git-send-email-christophe.gouault@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Steffen Klassert <steffen.klassert@secunet.com>,
	"David S. Miller" <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	netdev@vger.kernel.org, Saurabh Mohan <saurabh.mohan@vyatta.com>,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
To: Christophe Gouault <christophe.gouault@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:52103 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754279Ab3KERBq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Nov 2013 12:01:46 -0500
Received: by mail-pa0-f52.google.com with SMTP id bj1so9050689pad.39
        for <netdev@vger.kernel.org>; Tue, 05 Nov 2013 09:01:44 -0800 (PST)
In-Reply-To: <1383667121-23798-1-git-send-email-christophe.gouault@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-11-05 at 16:58 +0100, Christophe Gouault wrote:

> diff --git a/net/ipv4/ip_vti.c b/net/ipv4/ip_vti.c
> index 6e87f85..bcd85be 100644
> --- a/net/ipv4/ip_vti.c
> +++ b/net/ipv4/ip_vti.c
> @@ -126,6 +126,7 @@ static int vti_rcv(struct sk_buff *skb)
>  	if (tunnel != NULL) {
>  		struct pcpu_tstats *tstats;
>  		u32 oldmark = skb->mark;
> +		u16 netoff = skb_network_header(skb) - skb->data;

		unsigned int nhoff = skb_network_offset(skb);

There is no need to assume u16 here, even if the implementation
currently has this assumption.

You also could just use faster operation (no need to access
skb->data/head)

	unsigned int old_nh = skb->network_header;

...
at restore, use :
	skb->network_header = old_nh;

instead of the more expensive skb_set_network_header()
