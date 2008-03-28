From: Arnaldo Carvalho de Melo <acme@redhat.com>
Subject: Re: [PATCH 3/3] [LLC]: station source mac address
Date: Fri, 28 Mar 2008 10:14:35 -0300
Message-ID: <20080328131435.GR14945@ghostprotocols.net>
References: <1206691188-10938-1-git-send-email-joonwpark81@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Joonwoo Park <joonwpark81@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:45963 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751458AbYC1NOi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 28 Mar 2008 09:14:38 -0400
Content-Disposition: inline
In-Reply-To: <1206691188-10938-1-git-send-email-joonwpark81@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Em Fri, Mar 28, 2008 at 04:59:48PM +0900, Joonwoo Park escreveu:
> kill unnecessary llc_station_mac_sa.
> 
> Signed-off-by: Joonwoo Park <joonwpark81@gmail.com>

Acked-by: Arnaldo Carvalho de Melo <acme@redhat.com>

> ---
>  include/net/llc.h     |    1 -
>  net/llc/llc_core.c    |    8 +-------
>  net/llc/llc_station.c |    6 +++---
>  3 files changed, 4 insertions(+), 11 deletions(-)
> 
> diff --git a/include/net/llc.h b/include/net/llc.h
> index f502458..7940da1 100644
> --- a/include/net/llc.h
> +++ b/include/net/llc.h
> @@ -65,7 +65,6 @@ struct llc_sap {
>  
>  extern struct list_head llc_sap_list;
>  extern rwlock_t llc_sap_list_lock;
> -extern unsigned char llc_station_mac_sa[ETH_ALEN];
>  
>  extern int llc_rcv(struct sk_buff *skb, struct net_device *dev,
>  		   struct packet_type *pt, struct net_device *orig_dev);
> diff --git a/net/llc/llc_core.c b/net/llc/llc_core.c
> index 248b590..00de27c 100644
> --- a/net/llc/llc_core.c
> +++ b/net/llc/llc_core.c
> @@ -25,8 +25,6 @@
>  LIST_HEAD(llc_sap_list);
>  DEFINE_RWLOCK(llc_sap_list_lock);
>  
> -unsigned char llc_station_mac_sa[ETH_ALEN];
> -
>  /**
>   *	llc_sap_alloc - allocates and initializes sap.
>   *
> @@ -37,8 +35,8 @@ static struct llc_sap *llc_sap_alloc(void)
>  	struct llc_sap *sap = kzalloc(sizeof(*sap), GFP_ATOMIC);
>  
>  	if (sap) {
> +		/* sap->laddr.mac - leave as a null, it's filled by bind */
>  		sap->state = LLC_SAP_STATE_ACTIVE;
> -		memcpy(sap->laddr.mac, llc_station_mac_sa, ETH_ALEN);
>  		rwlock_init(&sap->sk_list.lock);
>  		atomic_set(&sap->refcnt, 1);
>  	}
> @@ -167,10 +165,6 @@ static int __init llc_init(void)
>  	if (dev != NULL)
>  		dev = next_net_device(dev);
>  
> -	if (dev != NULL)
> -		memcpy(llc_station_mac_sa, dev->dev_addr, ETH_ALEN);
> -	else
> -		memset(llc_station_mac_sa, 0, ETH_ALEN);
>  	dev_add_pack(&llc_packet_type);
>  	dev_add_pack(&llc_tr_packet_type);
>  	return 0;
> diff --git a/net/llc/llc_station.c b/net/llc/llc_station.c
> index 5c592e4..83da133 100644
> --- a/net/llc/llc_station.c
> +++ b/net/llc/llc_station.c
> @@ -260,7 +260,7 @@ static int llc_station_ac_send_null_dsap_xid_c(struct sk_buff *skb)
>  		goto out;
>  	llc_pdu_header_init(nskb, LLC_PDU_TYPE_U, 0, 0, LLC_PDU_CMD);
>  	llc_pdu_init_as_xid_cmd(nskb, LLC_XID_NULL_CLASS_2, 127);
> -	rc = llc_mac_hdr_init(nskb, llc_station_mac_sa, llc_station_mac_sa);
> +	rc = llc_mac_hdr_init(nskb, skb->dev->dev_addr, skb->dev->dev_addr);
>  	if (unlikely(rc))
>  		goto free;
>  	llc_station_send_pdu(nskb);
> @@ -285,7 +285,7 @@ static int llc_station_ac_send_xid_r(struct sk_buff *skb)
>  	llc_pdu_decode_ssap(skb, &dsap);
>  	llc_pdu_header_init(nskb, LLC_PDU_TYPE_U, 0, dsap, LLC_PDU_RSP);
>  	llc_pdu_init_as_xid_rsp(nskb, LLC_XID_NULL_CLASS_2, 127);
> -	rc = llc_mac_hdr_init(nskb, llc_station_mac_sa, mac_da);
> +	rc = llc_mac_hdr_init(nskb, skb->dev->dev_addr, mac_da);
>  	if (unlikely(rc))
>  		goto free;
>  	llc_station_send_pdu(nskb);
> @@ -314,7 +314,7 @@ static int llc_station_ac_send_test_r(struct sk_buff *skb)
>  	llc_pdu_decode_ssap(skb, &dsap);
>  	llc_pdu_header_init(nskb, LLC_PDU_TYPE_U, 0, dsap, LLC_PDU_RSP);
>  	llc_pdu_init_as_test_rsp(nskb, skb);
> -	rc = llc_mac_hdr_init(nskb, llc_station_mac_sa, mac_da);
> +	rc = llc_mac_hdr_init(nskb, skb->dev->dev_addr, mac_da);
>  	if (unlikely(rc))
>  		goto free;
>  	llc_station_send_pdu(nskb);
> -- 
> 1.5.4.3
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
