From: "N, Mugunthan V" <mugunthanvnm@ti.com>
Subject: RE: [PATCH 2/2] netdev: driver: ethernet: Add TI CPSW driver
Date: Fri, 17 Feb 2012 07:17:43 +0000
Message-ID: <EB1619762EAF8B4E97A227FB77B7E0293178BBA9@DBDE01.ent.ti.com>
References: <1329113061-13026-1-git-send-email-mugunthanvnm@ti.com>
	 <1329113061-13026-3-git-send-email-mugunthanvnm@ti.com>
 <1329156914.2494.33.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bear.ext.ti.com ([192.94.94.41]:52337 "EHLO bear.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751027Ab2BQHRu convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Feb 2012 02:17:50 -0500
In-Reply-To: <1329156914.2494.33.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet

> -----Original Message-----
> From: Eric Dumazet [mailto:eric.dumazet@gmail.com]
> Sent: Monday, February 13, 2012 11:45 PM
> To: N, Mugunthan V
> Cc: netdev@vger.kernel.org; davem@davemloft.net
> Subject: Re: [PATCH 2/2] netdev: driver: ethernet: Add TI CPSW driver
>=20
> Le lundi 13 f=E9vrier 2012 =E0 11:34 +0530, Mugunthan V N a =E9crit :
> > This patch adds support for TI's CPSW driver.
> >
> > The three port switch gigabit ethernet subsystem provides ethernet
> packet
> > communication and can be configured as an ethernet switch. Supports
> > 10/100/1000 Mbps.
> >
> > Signed-off-by: Cyril Chemparathy <cyril@ti.com>
> > Signed-off-by: Sriramakrishnan A G <srk@ti.com>
> > Signed-off-by: Mugunthan V N <mugunthanvnm@ti.com>
>=20
> ...
>=20
> > +
> > +static netdev_tx_t cpsw_ndo_start_xmit(struct sk_buff *skb,
> > +				       struct net_device *ndev)
> > +{
> > +	struct cpsw_priv *priv =3D netdev_priv(ndev);
> > +	int ret;
> > +
> > +	ndev->trans_start =3D jiffies;
>=20
> 	Are you sure trans_start needs to  be updated ?
It holds time of last tx, so I am sure it has to be updated on every tx=
=2E

>=20
> > +
> > +	ret =3D skb_padto(skb, CPSW_MIN_PACKET_SIZE);
> > +	if (unlikely(ret < 0)) {
> > +		msg(err, tx_err, "packet pad failed");
> > +		goto fail;
>=20
> Ouch... if skb_padto() fails, we stop queue forever, and skb is freed
> twice...
>=20
> correct sequence is :
>=20
> 	if (skb_padto(skb, CPSW_MIN_PACKET_SIZE)) {
> 		priv->stats.tx_dropped++;
> 		return NETDEV_TX_OK;
> 	}
>=20
> By the way, skb_padto() doesnt change skb->len, be warned !
Yes, will update the patch in next version

>=20
>=20
> > +	}
> > +
> > +	ret =3D cpdma_chan_submit(priv->txch, skb, skb->data,
> > +				skb->len, GFP_KERNEL);
>=20
> This GFP_KERNEL cannot be right, even if cpdma_chan_submit() ignores =
its
> last argument.
Yes, Good catch. I just reviewed davinci_cpdma code, the argument is no=
t used. I will send a separate patch set to remove this argument as thi=
s is already used in another driver "davinci_emcac.c"

>=20
> > +	if (unlikely(ret !=3D 0)) {
> > +		msg(err, tx_err, "desc submit failed");
> > +		goto fail;
> > +	}
> > +
> > +	return NETDEV_TX_OK;
> > +fail:
> > +	priv->stats.tx_dropped++;
> > +	netif_stop_queue(ndev);
> > +	return NETDEV_TX_BUSY;
> > +}
> > +
>=20
>=20
