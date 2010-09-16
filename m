From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH NEXT 1/5] qlcnic: support vlan rx accleration
Date: Thu, 16 Sep 2010 15:36:49 +0200
Message-ID: <1284644209.3352.35.camel@edumazet-laptop>
References: <1284642872-27832-1-git-send-email-amit.salecha@qlogic.com>
	 <1284642872-27832-2-git-send-email-amit.salecha@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	ameen.rahman@qlogic.com, anirban.chakraborty@qlogic.com
To: Amit Kumar Salecha <amit.salecha@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:43808 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753084Ab0IPNgy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Sep 2010 09:36:54 -0400
Received: by bwz11 with SMTP id 11so1575189bwz.19
        for <netdev@vger.kernel.org>; Thu, 16 Sep 2010 06:36:53 -0700 (PDT)
In-Reply-To: <1284642872-27832-2-git-send-email-amit.salecha@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 16 septembre 2010 =C3=A0 06:14 -0700, Amit Kumar Salecha a =C3=
=A9crit :

> -	if (unlikely(adapter->pvid)) {
> -		if (qlcnic_check_rx_tagging(adapter, skb)) {
> -			adapter->stats.rxdropped++;
> -			dev_kfree_skb_any(skb);
> -			return buffer;
> -		}
> +	if (unlikely(qlcnic_check_rx_tagging(adapter, skb, &vid))) {
> +		adapter->stats.rxdropped++;
> +		dev_kfree_skb_any(skb);

Its a bit strange you use dev_kfree_skb_any(skb) here.

We run in NAPI mode, so you can use dev_kfree_skb().

> +		return buffer;
>  	}
> =20
>  	skb->protocol =3D eth_type_trans(skb, netdev);
> =20
> -	napi_gro_receive(&sds_ring->napi, skb);
> +	if ((vid !=3D 0xffff) && adapter->vlgrp)
> +		vlan_hwaccel_receive_skb(skb, adapter->vlgrp, vid);
> +	else
> +		napi_gro_receive(&sds_ring->napi, skb);


