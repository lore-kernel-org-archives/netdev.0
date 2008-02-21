From: David Miller <davem@davemloft.net>
Subject: Re: kernel BUG at net/core/skbuff.c:95!
Date: Wed, 20 Feb 2008 21:57:07 -0800 (PST)
Message-ID: <20080220.215707.194209573.davem@davemloft.net>
References: <20080220002000.GS84358@surrealistic.net>
	<20080221054648.GU84358@surrealistic.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, acme@ghostprotocols.net
To: jwestfall@surrealistic.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60818
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751540AbYBUF43 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Feb 2008 00:56:29 -0500
In-Reply-To: <20080221054648.GU84358@surrealistic.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jim Westfall <jwestfall@surrealistic.net>
Date: Wed, 20 Feb 2008 21:46:48 -0800

> static inline void llc_pdu_init_as_test_rsp(struct sk_buff *skb,
>                                             struct sk_buff *ev_skb)
> {
>         struct llc_pdu_un *pdu = llc_pdu_un_hdr(skb);
>          
>         pdu->ctrl_1  = LLC_PDU_TYPE_U;
>         pdu->ctrl_1 |= LLC_1_PDU_CMD_TEST;
>         pdu->ctrl_1 |= LLC_U_PF_BIT_MASK;
>         if (ev_skb->protocol == htons(ETH_P_802_2)) {
>                 struct llc_pdu_un *ev_pdu = llc_pdu_un_hdr(ev_skb);
>                 int dsize;
> 
>                 dsize = ntohs(eth_hdr(ev_skb)->h_proto) - 3;
>                 memcpy(((u8 *)pdu) + 3, ((u8 *)ev_pdu) + 3, dsize);
>                 skb_put(skb, dsize);
>         }
> ..
> }

Probably what should happen is:

1) First this function validates that there are really
   'dsize' bytes available in the ev_skb source.

2) Second, skb_realloc_headroom() is called on 'skb' with
   a second argument of 'dsize'.

That means also this function now needs to return error
values, and the callers updated to handle that.
