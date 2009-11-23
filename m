From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 5/7] via-velocity: Re-enable transmit scatter-gather
 support
Date: Mon, 23 Nov 2009 10:52:21 -0800 (PST)
Message-ID: <20091123.105221.101883437.davem@davemloft.net>
References: <20091120160633.77b7aee0@marrow.netinsight.se>
	<20091123152724.2871cf4d@marrow.netinsight.se>
	<20091123153133.2237b04c@marrow.netinsight.se>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davej@redhat.com, shemminger@vyatta.com,
	romieu@fr.zoreil.com
To: simon.kagstrom@netinsight.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58953
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752196AbZKWSwD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Nov 2009 13:52:03 -0500
In-Reply-To: <20091123153133.2237b04c@marrow.netinsight.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Simon Kagstrom <simon.kagstrom@netinsight.net>
Date: Mon, 23 Nov 2009 15:31:33 +0100

> @@ -2543,14 +2546,27 @@ static netdev_tx_t velocity_xmit(struct sk_buff *skb,
>  	struct velocity_td_info *tdinfo;
>  	unsigned long flags;
>  	int pktlen;
> -	__le16 len;
> -	int index;
> +	int index, prev;
> +	int i = 0;
>  
>  	if (skb_padto(skb, ETH_ZLEN))
>  		goto out;
> -	pktlen = max_t(unsigned int, skb->len, ETH_ZLEN);
>  
> -	len = cpu_to_le16(pktlen);
> +	/* The hardware can handle at most 7 memory segments, so merge
> +	 * the skb if there are more */
> +	if (skb_shinfo(skb)->nr_frags > 6 && __skb_linearize(skb)) {
> +		kfree_skb(skb);
> +		return 0;
> +	}

Zero is not a valid return value for this function.  It returns
a "netdev_tx_t" defined as follows in linux/netdevice.h:

enum netdev_tx {
	__NETDEV_TX_MIN	 = INT_MIN,	/* make sure enum is signed */
	NETDEV_TX_OK	 = 0x00,	/* driver took care of packet */
	NETDEV_TX_BUSY	 = 0x10,	/* driver tx path was busy*/
	NETDEV_TX_LOCKED = 0x20,	/* driver tx lock was already taken */
};
typedef enum netdev_tx netdev_tx_t;
