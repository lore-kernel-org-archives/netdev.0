From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH V3 5/8] sctp: use limited socket backlog
Date: Fri, 05 Mar 2010 07:28:03 +0100
Message-ID: <1267770483.2867.6.camel@edumazet-laptop>
References: <1267761707-15605-1-git-send-email-yi.zhu@intel.com>
	 <1267761707-15605-2-git-send-email-yi.zhu@intel.com>
	 <1267761707-15605-3-git-send-email-yi.zhu@intel.com>
	 <1267761707-15605-4-git-send-email-yi.zhu@intel.com>
	 <1267761707-15605-5-git-send-email-yi.zhu@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	Vlad Yasevich <vladislav.yasevich@hp.com>,
	Sridhar Samudrala <sri@us.ibm.com>
To: Zhu Yi <yi.zhu@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f219.google.com ([209.85.220.219]:45268 "EHLO
	mail-fx0-f219.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752710Ab0CEG2J (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Mar 2010 01:28:09 -0500
Received: by fxm19 with SMTP id 19so3726774fxm.21
        for <netdev@vger.kernel.org>; Thu, 04 Mar 2010 22:28:08 -0800 (PST)
In-Reply-To: <1267761707-15605-5-git-send-email-yi.zhu@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 05 mars 2010 =C3=A0 12:01 +0800, Zhu Yi a =C3=A9crit :
> Make sctp adapt to the limited socket backlog change.
>=20
> Cc: Vlad Yasevich <vladislav.yasevich@hp.com>
> Cc: Sridhar Samudrala <sri@us.ibm.com>
> Signed-off-by: Zhu Yi <yi.zhu@intel.com>

This patch looks wrong.


> -static void sctp_add_backlog(struct sock *sk, struct sk_buff *skb)
> +static int sctp_add_backlog(struct sock *sk, struct sk_buff *skb)
>  {
>  	struct sctp_chunk *chunk =3D SCTP_INPUT_CB(skb)->chunk;
>  	struct sctp_ep_common *rcvr =3D chunk->rcvr;
> +	int ret;
> =20
> -	/* Hold the assoc/ep while hanging on the backlog queue.
> -	 * This way, we know structures we need will not disappear from us
> -	 */
> -	if (SCTP_EP_TYPE_ASSOCIATION =3D=3D rcvr->type)
> -		sctp_association_hold(sctp_assoc(rcvr));
> -	else if (SCTP_EP_TYPE_SOCKET =3D=3D rcvr->type)
> -		sctp_endpoint_hold(sctp_ep(rcvr));
> -	else
> -		BUG();
> +	ret =3D sk_add_backlog_limited(sk, skb);
> +	if (!ret) {
> +		/* Hold the assoc/ep while hanging on the backlog queue.
> +		 * This way, we know structures we need will not disappear
> +		 * from us
> +		 */
> +		if (SCTP_EP_TYPE_ASSOCIATION =3D=3D rcvr->type)
> +			sctp_association_hold(sctp_assoc(rcvr));
> +		else if (SCTP_EP_TYPE_SOCKET =3D=3D rcvr->type)
> +			sctp_endpoint_hold(sctp_ep(rcvr));
> +		else
> +			BUG();
> +	}
> +	return ret;
> =20
> -	sk_add_backlog(sk, skb);
>  }
> =20

As advertized by comment, we should hold the association *before*
accessing backlog queue.

If order is not important, comment should be relaxed somehow ?


