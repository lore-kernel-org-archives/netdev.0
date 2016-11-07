From: Madalin-Cristian Bucur <madalin.bucur@nxp.com>
Subject: RE: [PATCH net-next v6 02/10] dpaa_eth: add support for DPAA Ethernet
Date: Mon, 7 Nov 2016 15:43:26 +0000
Message-ID: <AM4PR04MB16049FF6E433DA445828A855ECA70@AM4PR04MB1604.eurprd04.prod.outlook.com>
References: <1478117854-8952-1-git-send-email-madalin.bucur@nxp.com>
 <1478117854-8952-3-git-send-email-madalin.bucur@nxp.com>
 <20161103.155816.642712588084106823.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: "pebolle@tiscali.nl" <pebolle@tiscali.nl>,
 "joakim.tjernlund@transmode.se" <joakim.tjernlund@transmode.se>,
 "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
 "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
 "ppc@mindchasers.com" <ppc@mindchasers.com>,
 "oss@buserror.net" <oss@buserror.net>, "joe@perches.com" <joe@perches.com>,
 "linuxppc-dev@lists.ozlabs.org" <linuxppc-dev@lists.ozlabs.org>
To: David Miller <davem@davemloft.net>
Return-path: <linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org>
In-Reply-To: <20161103.155816.642712588084106823.davem@davemloft.net>
Content-Language: en-US
List-Unsubscribe: <https://lists.ozlabs.org/options/linuxppc-dev>,
 <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=unsubscribe>
List-Archive: <http://lists.ozlabs.org/pipermail/linuxppc-dev/>
List-Post: <mailto:linuxppc-dev@lists.ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=help>
List-Subscribe: <https://lists.ozlabs.org/listinfo/linuxppc-dev>,
 <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=subscribe>
Errors-To: linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org
Sender: "Linuxppc-dev"
 <linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org>
List-Id: netdev.vger.kernel.org

> From: David Miller [mailto:davem@davemloft.net]
> Sent: Thursday, November 03, 2016 9:58 PM
>=20
> From: Madalin Bucur <madalin.bucur@nxp.com>
> Date: Wed, 2 Nov 2016 22:17:26 +0200
>=20
> > This introduces the Freescale Data Path Acceleration Architecture
> > +static inline size_t bpool_buffer_raw_size(u8 index, u8 cnt)
> > +{
> > +	u8 i;
> > +	size_t res =3D DPAA_BP_RAW_SIZE / 2;
>=20
> Always order local variable declarations from longest to shortest line,
> also know as Reverse Christmas Tree Format.
>=20
> Please audit your entire submission for this problem, it occurs
> everywhere.

Thank you, I'll resolve this.

> > +	/* we do not want shared skbs on TX */
> > +	net_dev->priv_flags &=3D ~IFF_TX_SKB_SHARING;
>=20
> Why?  By clearing this, you disallow an important fundamental way to do
> performane testing, via pktgen.

The Tx path in DPAA requires one to insert a back-pointer to the skb into
the Tx buffer. On the Tx confirmation path the back-pointer in the buffer
is used to release the skb. If Tx buffer is shared we'd alter the back-poin=
ter
and leak/double free skbs. See also=20

	static int dpaa_start_xmit(struct sk_buff *skb, struct net_device *net_dev=
)
	{
	...
      	  if (!nonlinear) {
	                /* We're going to store the skb backpointer at the beginni=
ng
            	     * of the data buffer, so we need a privately owned skb
      	           *
	                 * We've made sure skb is not shared in dev->priv_flags,
            	     * we need to verify the skb head is not cloned
      	           */
	                if (skb_cow_head(skb, priv->tx_headroom))
            	            goto enomem;

      	          WARN_ON(skb_is_nonlinear(skb));
	        }
	...

> > +	int numstats =3D sizeof(struct rtnl_link_stats64) / sizeof(u64);
>  ...
> > +		cpustats =3D (u64 *)&percpu_priv->stats;
> > +
> > +		for (j =3D 0; j < numstats; j++)
> > +			netstats[j] +=3D cpustats[j];
>=20
> This is a memcpy() on well-typed datastructures which requires no
> casting or special handling whatsoever, so use memcpy instead of
> needlessly open coding the operation.

Will fix.

> > +static int dpaa_change_mtu(struct net_device *net_dev, int new_mtu)
> > +{
> > +	const int max_mtu =3D dpaa_get_max_mtu();
> > +
> > +	/* Make sure we don't exceed the Ethernet controller's MAXFRM */
> > +	if (new_mtu < 68 || new_mtu > max_mtu) {
> > +		netdev_err(net_dev, "Invalid L3 mtu %d (must be between %d and
> %d).\n",
> > +			   new_mtu, 68, max_mtu);
> > +		return -EINVAL;
> > +	}
> > +	net_dev->mtu =3D new_mtu;
> > +
> > +	return 0;
> > +}
>=20
> MTU restrictions are handled in the net-next tree via net_dev->min_mtu an=
d
> net_dev->max_mtu.  Use that and do not define this NDO operation as you d=
o
> not need it.

OK
=20
> > +static int dpaa_set_features(struct net_device *dev, netdev_features_t
> features)
> > +{
> > +	/* Not much to do here for now */
> > +	dev->features =3D features;
> > +	return 0;
> > +}
>=20
> Do not define unnecessary NDO operations, let the defaults do their job.
>=20
> > +static netdev_features_t dpaa_fix_features(struct net_device *dev,
> > +					   netdev_features_t features)
> > +{
> > +	netdev_features_t unsupported_features =3D 0;
> > +
> > +	/* In theory we should never be requested to enable features that
> > +	 * we didn't set in netdev->features and netdev->hw_features at
> probe
> > +	 * time, but double check just to be on the safe side.
> > +	 */
> > +	unsupported_features |=3D NETIF_F_RXCSUM;
> > +
> > +	features &=3D ~unsupported_features;
> > +
> > +	return features;
> > +}
>=20
> Unless you can show that your need this, do not "guess" by implement this
> NDO operation.  You don't need it.

Will remove it.
=20
> > +#ifdef CONFIG_FSL_DPAA_ETH_FRIENDLY_IF_NAME
> > +static int dpaa_mac_hw_index_get(struct platform_device *pdev)
> > +{
> > +	struct device *dpaa_dev;
> > +	struct dpaa_eth_data *eth_data;
> > +
> > +	dpaa_dev =3D &pdev->dev;
> > +	eth_data =3D dpaa_dev->platform_data;
> > +
> > +	return eth_data->mac_hw_id;
> > +}
> > +
> > +static int dpaa_mac_fman_index_get(struct platform_device *pdev)
> > +{
> > +	struct device *dpaa_dev;
> > +	struct dpaa_eth_data *eth_data;
> > +
> > +	dpaa_dev =3D &pdev->dev;
> > +	eth_data =3D dpaa_dev->platform_data;
> > +
> > +	return eth_data->fman_hw_id;
> > +}
> > +#endif
>=20
> Do not play network device naming games like this, use the standard name
> assignment done by the kernel and have userspace entities do geographic o=
r
> device type specific naming.
>=20
> I want to see this code completely removed.

I'll remove the option, udev rules like these can achieve the same effect:

SUBSYSTEM=3D=3D"net", DRIVERS=3D=3D"fsl_dpa*", ATTR{device_addr}=3D=3D"ffe4=
e0000", NAME=3D"fm1-mac1"
SUBSYSTEM=3D=3D"net", DRIVERS=3D=3D"fsl_dpa*", ATTR{device_addr}=3D=3D"ffe4=
e2000", NAME=3D"fm1-mac2"
=20
> > +static int dpaa_set_mac_address(struct net_device *net_dev, void *addr=
)
> > +{
> > +	const struct dpaa_priv	*priv;
> > +	int err;
> > +	struct mac_device *mac_dev;
> > +
> > +	priv =3D netdev_priv(net_dev);
> > +
> > +	err =3D eth_mac_addr(net_dev, addr);
> > +	if (err < 0) {
> > +		netif_err(priv, drv, net_dev, "eth_mac_addr() =3D %d\n", err);
> > +		return err;
> > +	}
> > +
> > +	mac_dev =3D priv->mac_dev;
> > +
> > +	err =3D mac_dev->change_addr(mac_dev->fman_mac,
> > +				   (enet_addr_t *)net_dev->dev_addr);
> > +	if (err < 0) {
> > +		netif_err(priv, drv, net_dev, "mac_dev->change_addr() =3D %d\n",
> > +			  err);
> > +		return err;
> > +	}
>=20
> You MUST NOT return an error at this point without rewinding the state
> change
> performed by eth_mac_addr().  Otherwise device will be left in an
> inconsistent
> state compared to what the software MAC address has recorded.

Will address this.

> This driver is enormous, I don't have the time nor the patience to
> review it further for what seems to be many fundamental errors like
> the ones I have pointed out so far.
>=20
> Sorry.

Thank you for your time. I know the dpaa_eth is large, about 4K LOC,
also depends on the in-tree FMan and QMan drivers that are a bit
larger. We're coming down to this from a set of drivers that amounted
to more than 100K LOC and stuff like the ndos that here do nothing are
artifacts of that deep pruning. I'll go through all the code to check
for such redundancies before the next submission but junk is always
easier to see for a fresh pair of eyes.

Thank you,
Madalin
