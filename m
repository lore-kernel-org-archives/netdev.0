From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH net-next v2 3/3] macsec: introduce IEEE 802.1AE driver
Date: Tue, 15 Mar 2016 15:03:31 +0100
Message-ID: <1458050611.2871.11.camel@sipsolutions.net>
References: <cover.1457714618.git.sd@queasysnail.net>
	 <3d7ef45fa74b3bde47dabee3f23c8b8d04b546aa.1457714618.git.sd@queasysnail.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Florian Westphal <fw@strlen.de>,
	Paolo Abeni <pabeni@redhat.com>, stephen@networkplumber.org
To: Sabrina Dubroca <sd@queasysnail.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:48389 "EHLO sipsolutions.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750833AbcCOODl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Mar 2016 10:03:41 -0400
In-Reply-To: <3d7ef45fa74b3bde47dabee3f23c8b8d04b546aa.1457714618.git.sd@queasysnail.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

> +struct macsec_rx_sa_stats {
> +	__u32 InPktsOK;
> +	__u32 InPktsInvalid;
> +	__u32 InPktsNotValid;
> +	__u32 InPktsNotUsingSA;
> +	__u32 InPktsUnusedSA;
> +};
> +
> +struct macsec_tx_sa_stats {
> +	__u32 OutPktsProtected;
> +	__u32 OutPktsEncrypted;
> +};

Just noticed this: is there a particular reason for using only __u32
here? The others all seem to use __u64.

> +static int macsec_dump_txsc(struct sk_buff *skb, struct
> netlink_callback *cb)
> +{
> +	struct net *net =3D sock_net(skb->sk);
> +	struct net_device *dev;
> +	int dev_idx, d;
> +
> +	dev_idx =3D cb->args[0];
> +
> +	d =3D 0;
> +	for_each_netdev(net, dev) {
> +		struct macsec_secy *secy;
> +
> +		if (d < dev_idx)
> +			goto next;
> +
> +		if (!netif_is_macsec(dev))
> +			goto next;
> +
> +		secy =3D &macsec_priv(dev)->secy;
> +		if (dump_secy(secy, dev, skb, cb) < 0)
> +			goto done;
> +next:
> +		d++;
> +	}
> +
> +done:
> +	cb->args[0] =3D d;
> +	return skb->len;
> +}

Maybe you should consider adding=C2=A0genl_dump_check_consistent() supp=
ort
here, so userspace can figure out if the dump was really consistent, if
necessary.

To do this, you have to keep a global generation counter that changes
whenever this list changes (adding/removing macsec interfaces, I think)
and then set

	cb->seq =3D macsec_generation_counter;

at the beginning of this function, and call
genl_dump_check_consistent() for each message in the loop.

Btw, aren't you missing locking here for=C2=A0for_each_netdev()?

johannes
