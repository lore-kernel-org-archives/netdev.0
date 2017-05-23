From: Leon Romanovsky <leon@kernel.org>
Subject: Re: [PATCH net] net/mlx4: Fix the check in attaching steering rules
Date: Tue, 23 May 2017 17:10:24 +0300
Message-ID: <20170523141024.GO17751@mtr-leonro.local>
References: <1495543807-14956-1-git-send-email-tariqt@mellanox.com>
 <20170523131513.GN17751@mtr-leonro.local>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
        protocol="application/pgp-signature"; boundary="vdqwC0msT4ilQ2it"
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        Eran Ben Elisha <eranbe@mellanox.com>,
        Or Gerlitz <ogerlitz@mellanox.com>,
        Talat Batheesh <talatb@mellanox.com>
To: Tariq Toukan <tariqt@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.99]:40374 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S936261AbdEWOKc (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 23 May 2017 10:10:32 -0400
Content-Disposition: inline
In-Reply-To: <20170523131513.GN17751@mtr-leonro.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--vdqwC0msT4ilQ2it
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Tue, May 23, 2017 at 04:15:13PM +0300, Leon Romanovsky wrote:
> On Tue, May 23, 2017 at 03:50:07PM +0300, Tariq Toukan wrote:
> > From: Talat Batheesh <talatb@mellanox.com>
> >
> > Our previous patch (cited below) introduced a regression
> > for RAW Eth QPs.
> >
> > Fix it by checking if the QP number provided by user-space
> > exists, hence allowing steering rules to be added for valid
> > QPs only.
> >
> > Fixes: 89c557687a32 ("net/mlx4_en: Avoid adding steering rules with ...")
> > Reported-by: Or Gerlitz <gerlitz.or@gmail.com>
> > Signed-off-by: Talat Batheesh <talatb@mellanox.com>
> > Signed-off-by: Tariq Toukan <tariqt@mellanox.com>
> > ---
> >  drivers/net/ethernet/mellanox/mlx4/en_ethtool.c |  3 +--
> >  drivers/net/ethernet/mellanox/mlx4/qp.c         | 14 ++++++++++++++
> >  include/linux/mlx4/qp.h                         |  1 +
> >  3 files changed, 16 insertions(+), 2 deletions(-)
> >
> > diff --git a/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c b/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c
> > index ae5fdc2df654..00a7cd3dcc2e 100644
> > --- a/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c
> > +++ b/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c
> > @@ -1562,8 +1562,7 @@ static int mlx4_en_flow_replace(struct net_device *dev,
> >  		qpn = priv->drop_qp.qpn;
> >  	else if (cmd->fs.ring_cookie & EN_ETHTOOL_QP_ATTACH) {
> >  		qpn = cmd->fs.ring_cookie & (EN_ETHTOOL_QP_ATTACH - 1);
> > -		if (qpn < priv->rss_map.base_qpn ||
> > -		    qpn >= priv->rss_map.base_qpn + priv->rx_ring_num) {
> > +		if (!mlx4_qp_lookup(priv->mdev->dev, qpn)) {
> >  			en_warn(priv, "rxnfc: QP (0x%x) doesn't exist\n", qpn);
> >  			return -EINVAL;
> >  		}
> > diff --git a/drivers/net/ethernet/mellanox/mlx4/qp.c b/drivers/net/ethernet/mellanox/mlx4/qp.c
> > index 2d6abd4662b1..1eff2fe32a8b 100644
> > --- a/drivers/net/ethernet/mellanox/mlx4/qp.c
> > +++ b/drivers/net/ethernet/mellanox/mlx4/qp.c
> > @@ -384,6 +384,20 @@ static void mlx4_qp_free_icm(struct mlx4_dev *dev, int qpn)
> >  		__mlx4_qp_free_icm(dev, qpn);
> >  }
> >
> > +struct mlx4_qp *mlx4_qp_lookup(struct mlx4_dev *dev, u32 qpn)
> > +{
> > +	struct mlx4_qp_table *qp_table = &mlx4_priv(dev)->qp_table;
> > +	struct mlx4_qp *qp;
> > +
> > +	spin_lock(&qp_table->lock);
> > +
> > +	qp = __mlx4_qp_lookup(dev, qpn);
> > +
> > +	spin_unlock(&qp_table->lock);
> > +	return qp;
> > +}
> > +EXPORT_SYMBOL_GPL(mlx4_qp_lookup);
>
> Tariq,
>
> Why do you need this export and header fils? You are using this function in one place only.
>

Let's keep it as you proposed for better separation of en vs. core modules.

Reviewed-by: Leon Romanovsky <leonro@mellanox.com>

Thanks

--vdqwC0msT4ilQ2it
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEkhr/r4Op1/04yqaB5GN7iDZyWKcFAlkkQtAACgkQ5GN7iDZy
WKeyZRAA0rSu/fH4p6xpptgUF219j1W5IFE7zP2aaNFR0o2wpJ7f6Qsq/QhmKs8j
bmNa8b0VkoF5Wgy7VEToWv7WclrtX7XBgIQPzEXdUM6dk5PdsSVe2X5iF+hHS7Ff
Lcyh0pHErNRb3EPP3CZXQ++krIbvpLIbE882FY1gj5Ingc9ufpTdncIL4pPrP5NI
s3lGPUG11g5kq8MrfnWDz7K3lWWqSULIHe1UfdPBRxAj7Zt3w2s8GOAwvPkKF/uX
bHdyR2cHLaSo8tMBz7DkbDKtmNEAIjnoThdysW4Q0La/ILDD+3A+8WmavMDbiqOD
Ce1hmVJ8azW8X9g9qiKKRb5JxNAVSPxn+ET4E6zqKgKECpKjXOFeT1pgzuWk+oHu
uJUa0VvNhzxrjug9ATvM8YEbDh2NuTOJtM/7ZqW5HCVSo7inprGbRykPivSnd998
P15PGu66ZalZpY/DHZ4rTgu7mjC+BUkVIyhRrANrokd705pCWHSlR7QVAf0ny/KI
hsFceCiVrd20Gm6gfPRcjYdMpiIcW+cjlHRSQ5QNn/qh5/HWBrGEHHWXc+q2eIEZ
FxxP0LETAlSVhWAryJRDn9nkCRnCmhmXPhFGhNK/HQCPrghtyVhfJ06xoOtgzZfU
4bx4xfUBwzaS+fRnMFs2VyoDkRzEPl8tPFX5rrGFt4Utc0+z4+0=
=MsJx
-----END PGP SIGNATURE-----

--vdqwC0msT4ilQ2it--
