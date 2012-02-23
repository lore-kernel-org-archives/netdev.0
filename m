From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] llc: fix skb_over_panic due to bogus RX packet
Date: Thu, 23 Feb 2012 17:33:05 -0500 (EST)
Message-ID: <20120223.173305.576493449692097140.davem@davemloft.net>
References: <1329819196-25176-1-git-send-email-ajuncu@ixiacom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: acme@ghostprotocols.net, netdev@vger.kernel.org,
	dbaluta@ixiacom.com, alexj@rosedu.org
To: ajuncu@ixiacom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:57019 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756292Ab2BWWdO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Feb 2012 17:33:14 -0500
In-Reply-To: <1329819196-25176-1-git-send-email-ajuncu@ixiacom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexandru Juncu <ajuncu@ixiacom.com>
Date: Tue, 21 Feb 2012 12:13:16 +0200

> @@ -336,7 +337,7 @@ static inline void llc_pdu_init_as_test_cmd(struct sk_buff *skb)
>   *
>   *	Builds a pdu frame as a TEST response.
>   */
> -static inline void llc_pdu_init_as_test_rsp(struct sk_buff *skb,
> +static inline int llc_pdu_init_as_test_rsp(struct sk_buff *skb,
>  					    struct sk_buff *ev_skb)
>  {
>  	struct llc_pdu_un *pdu = llc_pdu_un_hdr(skb);
> @@ -348,10 +349,15 @@ static inline void llc_pdu_init_as_test_rsp(struct sk_buff *skb,
>  		struct llc_pdu_un *ev_pdu = llc_pdu_un_hdr(ev_skb);
>  		int dsize;
>  
> -		dsize = ntohs(eth_hdr(ev_skb)->h_proto) - 3;
> +		dsize = ntohs(eth_hdr(ev_skb)->h_proto);
> +		if((dsize < 3) || (dsize > skb_tailroom(skb))) {
> +			return -EINVAL;
> +		}
> +		dsize -= 3;
>  		memcpy(((u8 *)pdu) + 3, ((u8 *)ev_pdu) + 3, dsize);
>  		skb_put(skb, dsize);
>  	}
> +	return 0;
>  }

All callers of llc_pdu_init_as_test_rsp() allocate "skb" such that it
has size enough to accomodate what is present in ->h_proto.

The two call sites are:

	data_size = ntohs(eth_hdr(skb)->h_proto) - 3;
	nskb = llc_alloc_frame(NULL, skb->dev, LLC_PDU_TYPE_U, data_size);
	if (!nskb)
		goto out;
	llc_pdu_header_init(nskb, LLC_PDU_TYPE_U, sap->laddr.lsap, dsap,
			    LLC_PDU_RSP);
	llc_pdu_init_as_test_rsp(nskb, skb);

and

	data_size = ntohs(eth_hdr(skb)->h_proto) - 3;
	nskb = llc_alloc_frame(NULL, skb->dev, LLC_PDU_TYPE_U, data_size);

	if (!nskb)
		goto out;
	rc = 0;
	llc_pdu_decode_sa(skb, mac_da);
	llc_pdu_decode_ssap(skb, &dsap);
	llc_pdu_header_init(nskb, LLC_PDU_TYPE_U, 0, dsap, LLC_PDU_RSP);
	llc_pdu_init_as_test_rsp(nskb, skb);

Therefore I cannot see a case where the SKB's space is insufficient for
the pdu header copy performed by llc_pdu_init_as_test_rsp().

And if anything this indicates that the call sites should validate the
dsize first before doing all of the expensive memory allocations and
PDU header initialization.  These little header munging routines like
llc_pdu_init_as_test_rsp() shouldn't have to validate their arguments,
they should be simple and have a sane validated state given to them.

Also, even if this change was actually needed, your coding style needs
to be fixed:

+		if((dsize < 3) || (dsize > skb_tailroom(skb))) {
+			return -EINVAL;
+		}

Should be:

		if (dsize < 3 || dsize > skb_tailroom(skb))
			return -EINVAL;

And your commit message was too terse, you need to describe exactly
how the over panic can happen, otherwise I have to analyze it myself
and if I can't figure it out then I have to ask you all of the
questions which should be answered from the start in your change
description.
