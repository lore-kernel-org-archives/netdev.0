From: Arnaldo Carvalho de Melo <acme@redhat.com>
Subject: Re: [PATCH 1/3] [LLC]: skb allocation size for responses
Date: Mon, 24 Mar 2008 14:16:31 -0300
Message-ID: <20080324171631.GE32612@ghostprotocols.net>
References: <47e76779.0f98600a.36ef.ffff9c13@mx.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	jwestfall@surrealistic.net
To: joonwpark81@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:40589 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754883AbYCXRQx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 24 Mar 2008 13:16:53 -0400
Content-Disposition: inline
In-Reply-To: <47e76779.0f98600a.36ef.ffff9c13@mx.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Em Mon, Mar 24, 2008 at 05:33:57PM +0900, joonwpark81@gmail.com escreveu:
> From: Joonwoo Park <joonwpark81@gmail.com>
> 
> allocate the skb for llc responses with the received packet size by
> using the size adjustable llc_frame_alloc.
> 
> Reported by Jim Westfall:
> kernel: skb_over_panic: text:c0541fc7 len:1000 put:997 head:c166ac00 data:c166ac2f tail:0xc166b017 end:0xc166ac80 dev:eth0
> kernel: ------------[ cut here ]------------
> kernel: kernel BUG at net/core/skbuff.c:95!
> 
> Signed-off-by: Joonwoo Park <joonwpark81@gmail.com>
> ---
> diff --git a/include/net/llc_sap.h b/include/net/llc_sap.h
> index 2c56dbe..a5c9f5b 100644
> --- a/include/net/llc_sap.h
> +++ b/include/net/llc_sap.h
> @@ -1,5 +1,8 @@
>  #ifndef LLC_SAP_H
>  #define LLC_SAP_H
> +
> +#include <asm/types.h>
> +
>  /*
>   * Copyright (c) 1997 by Procom Technology,Inc.
>   * 		 2001-2003 by Arnaldo Carvalho de Melo <acme@conectiva.com.br>
> @@ -20,7 +23,7 @@ extern void llc_sap_rtn_pdu(struct llc_sap *sap, struct sk_buff *skb);
>  extern void llc_save_primitive(struct sock *sk, struct sk_buff* skb,
>  			       unsigned char prim);
>  extern struct sk_buff *llc_alloc_frame(struct sock *sk,
> -				       struct net_device *dev);
> +				       struct net_device *dev, u32 size);
>  
>  extern void llc_build_and_send_test_pkt(struct llc_sap *sap,
>  				        struct sk_buff *skb,
> diff --git a/net/llc/llc_c_ac.c b/net/llc/llc_c_ac.c
> index 860140c..a9db49d 100644
> --- a/net/llc/llc_c_ac.c
> +++ b/net/llc/llc_c_ac.c
> @@ -198,7 +198,7 @@ int llc_conn_ac_send_disc_cmd_p_set_x(struct sock *sk, struct sk_buff *skb)
>  {
>  	int rc = -ENOBUFS;
>  	struct llc_sock *llc = llc_sk(sk);
> -	struct sk_buff *nskb = llc_alloc_frame(sk, llc->dev);
> +	struct sk_buff *nskb = llc_alloc_frame(sk, llc->dev, 78);

I know that this ancient code has magic numbers, but I guess we
shouldn't introduce new ones :-\ Why 78? (rethoric)
  
>  	if (nskb) {
>  		struct llc_sap *sap = llc->sap;
> @@ -223,7 +223,7 @@ int llc_conn_ac_send_dm_rsp_f_set_p(struct sock *sk, struct sk_buff *skb)
>  {
>  	int rc = -ENOBUFS;
>  	struct llc_sock *llc = llc_sk(sk);
> -	struct sk_buff *nskb = llc_alloc_frame(sk, llc->dev);
> +	struct sk_buff *nskb = llc_alloc_frame(sk, llc->dev, 78);

ditto

>  	if (nskb) {
>  		struct llc_sap *sap = llc->sap;
> @@ -249,7 +249,7 @@ int llc_conn_ac_send_dm_rsp_f_set_1(struct sock *sk, struct sk_buff *skb)
>  {
>  	int rc = -ENOBUFS;
>  	struct llc_sock *llc = llc_sk(sk);
> -	struct sk_buff *nskb = llc_alloc_frame(sk, llc->dev);
> +	struct sk_buff *nskb = llc_alloc_frame(sk, llc->dev, 78);

ditto

>  	if (nskb) {
>  		struct llc_sap *sap = llc->sap;
> @@ -282,7 +282,7 @@ int llc_conn_ac_send_frmr_rsp_f_set_x(struct sock *sk, struct sk_buff *skb)
>  		llc_pdu_decode_pf_bit(skb, &f_bit);
>  	else
>  		f_bit = 0;
> -	nskb = llc_alloc_frame(sk, llc->dev);
> +	nskb = llc_alloc_frame(sk, llc->dev, 78);

ditto

>  	if (nskb) {
>  		struct llc_sap *sap = llc->sap;
>  
> @@ -306,7 +306,7 @@ int llc_conn_ac_resend_frmr_rsp_f_set_0(struct sock *sk, struct sk_buff *skb)
>  {
>  	int rc = -ENOBUFS;
>  	struct llc_sock *llc = llc_sk(sk);
> -	struct sk_buff *nskb = llc_alloc_frame(sk, llc->dev);
> +	struct sk_buff *nskb = llc_alloc_frame(sk, llc->dev, 78);

ditto


<SNIP>

> @@ -144,11 +144,18 @@ int llc_sap_action_send_test_r(struct llc_sap *sap, struct sk_buff *skb)
>  	u8 mac_da[ETH_ALEN], mac_sa[ETH_ALEN], dsap;
>  	struct sk_buff *nskb;
>  	int rc = 1;
> +	u32 size;
>  
>  	llc_pdu_decode_sa(skb, mac_da);
>  	llc_pdu_decode_da(skb, mac_sa);
>  	llc_pdu_decode_ssap(skb, &dsap);
> -	nskb = llc_alloc_frame(NULL, skb->dev);
> +
> +#ifdef NET_SKBUFF_DATA_USES_OFFSET
> +	size = skb->end + skb->data_len;
> +#else
> +	size = skb->end - skb->head;
> +#endif


huh? Try not to use NET_SKBUFF_DATA_USES_OFFSET, it should die at some
point, perhaps today :-)

Please use one of the existing helpers.


> +	nskb = llc_alloc_frame(NULL, skb->dev, size);
>  	if (!nskb)
>  		goto out;
>  	llc_pdu_header_init(nskb, LLC_PDU_TYPE_U, sap->laddr.lsap, dsap,
> diff --git a/net/llc/llc_sap.c b/net/llc/llc_sap.c
> index 2525165..e295549 100644
> --- a/net/llc/llc_sap.c
> +++ b/net/llc/llc_sap.c
> @@ -27,13 +27,15 @@
>  /**
>   *	llc_alloc_frame - allocates sk_buff for frame
>   *	@dev: network device this skb will be sent over
> + *	@size: size to allocate
>   *
>   *	Allocates an sk_buff for frame and initializes sk_buff fields.
>   *	Returns allocated skb or %NULL when out of memory.
>   */
> -struct sk_buff *llc_alloc_frame(struct sock *sk, struct net_device *dev)
> +struct sk_buff *llc_alloc_frame(struct sock *sk, struct net_device *dev,
> +				u32 size)
>  {
> -	struct sk_buff *skb = alloc_skb(128, GFP_ATOMIC);
> +	struct sk_buff *skb = alloc_skb(size + 50, GFP_ATOMIC);

take the opportunity to document what is fifty in this context.

<SNIP>

- Arnaldo
