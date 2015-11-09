From: Gavin Shan <gwshan@linux.vnet.ibm.com>
Subject: Re: [PATCH RFC 5/6] net/faraday: Enable NCSI interface
Date: Mon, 9 Nov 2015 18:30:32 +1100
Message-ID: <20151109073032.GA10235@gwshan>
References: <1447027806-4744-1-git-send-email-gwshan@linux.vnet.ibm.com>
 <1447027806-4744-6-git-send-email-gwshan@linux.vnet.ibm.com>
 <1447029127.8727.29.camel@kernel.crashing.org>
Reply-To: Gavin Shan <gwshan@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Gavin Shan <gwshan@linux.vnet.ibm.com>, netdev@vger.kernel.org,
	davem@davemloft.net, sergei.shtylyov@cogentembedded.com
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e28smtp07.in.ibm.com ([122.248.162.7]:36827 "EHLO
	e28smtp07.in.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751275AbbKIHky convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Nov 2015 02:40:54 -0500
Received: from /spool/local
	by e28smtp07.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <gwshan@linux.vnet.ibm.com>;
	Mon, 9 Nov 2015 13:10:51 +0530
Received: from d28relay05.in.ibm.com (d28relay05.in.ibm.com [9.184.220.62])
	by d28dlp01.in.ibm.com (Postfix) with ESMTP id 6FB41E0058
	for <netdev@vger.kernel.org>; Mon,  9 Nov 2015 13:11:10 +0530 (IST)
Received: from d28av04.in.ibm.com (d28av04.in.ibm.com [9.184.220.66])
	by d28relay05.in.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id tA97aiws65339448
	for <netdev@vger.kernel.org>; Mon, 9 Nov 2015 13:10:49 +0530
Received: from d28av04.in.ibm.com (localhost [127.0.0.1])
	by d28av04.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id tA97Uit8018007
	for <netdev@vger.kernel.org>; Mon, 9 Nov 2015 13:00:45 +0530
Content-Disposition: inline
In-Reply-To: <1447029127.8727.29.camel@kernel.crashing.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Nov 09, 2015 at 11:32:07AM +1100, Benjamin Herrenschmidt wrote:
>On Mon, 2015-11-09 at 11:10 +1100, Gavin Shan wrote:
>>=A0
>> -	if (likely(netif_running(netdev))) {
>> +	/* When running in NCSI mode, the interface should be
>> +	=A0* ready to receive or transmit NCSI packet before it's
>> +	=A0* opened.
>> +	=A0*/
>
>No, that's not right. open/close is when a driver allocates it's data
>structures, DMA ring descriptors, packet buffers etc... and request
>it's interrupts.
>
>You cannot expect packets to flow on a closed interface and you
>shouldn't be getting any interrupts on a closed interface either.
>

Yeah, It's something that I hilighed in the cover letter. I was
thinking we might need a better way to enable Tx/Rx before the
interrupt is up, but couldn't figure out one way. So I need some
advice here.

Thanks,
Gavin

>> +	if (likely(priv->use_ncsi || netif_running(netdev))) {
>> =A0		/* Disable interrupts for polling */
>> =A0		iowrite32(0, priv->base + FTGMAC100_OFFSET_IER);
>> =A0		napi_schedule(&priv->napi);
>> @@ -1162,8 +1168,18 @@ static int ftgmac100_open(struct net_device
>> *netdev)
>> =A0
>> =A0	/* enable all interrupts */
>> =A0	iowrite32(INT_MASK_ALL_ENABLED, priv->base +
>> FTGMAC100_OFFSET_IER);
>> +	/* Start the NCSI device */
>> +	if (priv->use_ncsi){
>> +		err =3D ncsi_start_dev(priv->ndev);
>> +		if (err)
>> +			goto err_ncsi;
>> +	}
>> =A0	return 0;
>> =A0
>> +err_ncsi:
>> +	napi_disable(&priv->napi);
>> +	netif_stop_queue(netdev);
>> +	iowrite32(0, priv->base + FTGMAC100_OFFSET_IER);
>> =A0err_hw:
>> =A0	free_irq(priv->irq, netdev);
>> =A0err_irq:
>> @@ -1172,7 +1188,7 @@ err_alloc:
>> =A0	return err;
>> =A0}
>> =A0
>> -static int ftgmac100_stop(struct net_device *netdev)
>> +static int ftgmac100_stop_dev(struct net_device *netdev)
>> =A0{
>> =A0	struct ftgmac100 *priv =3D netdev_priv(netdev);
>> =A0
>> @@ -1191,6 +1207,18 @@ static int ftgmac100_stop(struct net_device
>> *netdev)
>> =A0	return 0;
>> =A0}
>> =A0
>> +static int ftgmac100_stop(struct net_device *netdev)
>> +{
>> +	struct ftgmac100 *priv =3D netdev_priv(netdev);
>> +
>> +	/* Stop NCSI device */
>> +	if (priv->use_ncsi) {
>> +		ncsi_stop_dev(priv->ndev);
>> +		return 0;
>> +	}
>> +
>> +	return ftgmac100_stop_dev(netdev);
>> +}
>> =A0static int ftgmac100_hard_start_xmit(struct sk_buff *skb,
>> =A0				=A0=A0=A0=A0=A0struct net_device *netdev)
>> =A0{
>> @@ -1291,6 +1319,21 @@ static const struct net_device_ops
>> ftgmac100_netdev_ops =3D {
>> =A0	.ndo_do_ioctl		=3D ftgmac100_do_ioctl,
>> =A0};
>> =A0
>> +static void ftgmac100_ncsi_handler(struct ncsi_dev *nd)
>> +{
>> +	struct net_device *netdev =3D nd->nd_dev;
>> +
>> +	if (nd->nd_state !=3D ncsi_dev_state_functional)
>> +		return;
>> +
>> +	if (nd->nd_link_up) {
>> +		pr_info("NCSI dev is up\n");
>> +		netif_start_queue(netdev);
>> +	} else {
>> +		pr_info("NCSI dev is down\n");
>> +		ftgmac100_stop_dev(netdev);
>> +	}
>> +}
>> =A0/****************************************************************=
***
>> ***********
>> =A0 * struct platform_driver functions
>> =A0
>> ********************************************************************=
*
>> ********/
>> @@ -1300,7 +1343,7 @@ static int ftgmac100_probe(struct
>> platform_device *pdev)
>> =A0	int irq;
>> =A0	struct net_device *netdev;
>> =A0	struct ftgmac100 *priv;
>> -	int err;
>> +	int err =3D 0;
>> =A0
>> =A0	if (!pdev)
>> =A0		return -ENODEV;
>> @@ -1320,7 +1363,17 @@ static int ftgmac100_probe(struct
>> platform_device *pdev)
>> =A0		goto err_alloc_etherdev;
>> =A0	}
>> =A0
>> +	/* Check for NCSI mode */
>> +	priv =3D netdev_priv(netdev);
>> =A0	SET_NETDEV_DEV(netdev, &pdev->dev);
>> +	if (pdev->dev.of_node &&
>> +	=A0=A0=A0=A0of_get_property(pdev->dev.of_node, "use-nc-si", NULL))=
 {
>> +		dev_info(&pdev->dev, "Using NCSI interface\n");
>> +		priv->phydev =3D NULL;
>> +		priv->use_ncsi =3D true;
>> +	} else {
>> +		priv->use_ncsi =3D false;
>> +	}
>> =A0
>> =A0	netdev->ethtool_ops =3D &ftgmac100_ethtool_ops;
>> =A0	netdev->netdev_ops =3D &ftgmac100_netdev_ops;
>> @@ -1329,7 +1382,6 @@ static int ftgmac100_probe(struct
>> platform_device *pdev)
>> =A0	platform_set_drvdata(pdev, netdev);
>> =A0
>> =A0	/* setup private data */
>> -	priv =3D netdev_priv(netdev);
>> =A0	priv->netdev =3D netdev;
>> =A0	priv->dev =3D &pdev->dev;
>> =A0
>> @@ -1356,24 +1408,14 @@ static int ftgmac100_probe(struct
>> platform_device *pdev)
>> =A0
>> =A0	priv->irq =3D irq;
>> =A0
>> -	/* Check for NC-SI mode */
>> -	if (pdev->dev.of_node &&
>> -	=A0=A0=A0=A0of_get_property(pdev->dev.of_node, "use-nc-si", NULL))
>> -		priv->use_ncsi =3D true;
>> -	else
>> -		priv->use_ncsi =3D false;
>> +	/* Read MAC address or setup a new one */
>> +	ftgmac100_setup_mac(priv);
>> =A0
>> -	/* If we use NC-SI, we need to set that up, which isn't
>> implemented yet
>> -	=A0* so we pray things were setup by the bootloader and just
>> mark our link
>> -	=A0* as up (otherwise we can't get packets through).
>> -	=A0*
>> -	=A0* Eventually, we'll have a proper NC-SI stack as a helper
>> we can
>> -	=A0* instanciate
>> -	=A0*/
>> +	/* Register NCSI device */
>> =A0	if (priv->use_ncsi) {
>> -		/* XXX */
>> -		priv->phydev =3D NULL;
>> -		dev_info(&pdev->dev, "Using NC-SI interface\n");
>> +		priv->ndev =3D ncsi_register_dev(netdev,
>> ftgmac100_ncsi_handler);
>> +		if (!priv->ndev)
>> +			goto err_ncsi_dev;
>> =A0	} else {
>> =A0		err =3D ftgmac100_setup_mdio(priv);
>> =A0
>> @@ -1384,9 +1426,6 @@ static int ftgmac100_probe(struct
>> platform_device *pdev)
>> =A0			dev_warn(&pdev->dev, "Error %d setting up
>> MDIO\n", err);
>> =A0	}
>> =A0
>> -	/* Read MAC address or setup a new one */
>> -	ftgmac100_setup_mac(priv);
>> -
>> =A0	/* Register network device */
>> =A0	err =3D register_netdev(netdev);
>> =A0	if (err) {
>> @@ -1399,7 +1438,11 @@ static int ftgmac100_probe(struct
>> platform_device *pdev)
>> =A0	return 0;
>> =A0
>> =A0err_register_netdev:
>> -	ftgmac100_destroy_mdio(priv);
>> +	if (!priv->use_ncsi)
>> +		ftgmac100_destroy_mdio(priv);
>> +	else
>> +		ncsi_unregister_dev(priv->ndev);
>> +err_ncsi_dev:
>> =A0	iounmap(priv->base);
>> =A0err_ioremap:
>> =A0	release_resource(priv->res);
>
