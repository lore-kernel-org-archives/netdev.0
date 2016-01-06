From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH v2] net: Add eth_platform_get_mac_address() helper.
Date: Wed, 06 Jan 2016 15:12:46 -0800
Message-ID: <1452121966.24575.52.camel@perches.com>
References: <20160106.163309.111867454969344145.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: sowmini.varadhan@oracle.com
To: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0224.hostedemail.com ([216.40.44.224]:60717 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752562AbcAFXMt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Jan 2016 18:12:49 -0500
In-Reply-To: <20160106.163309.111867454969344145.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2016-01-06 at 16:33 -0500, David Miller wrote:
> A repeating pattern in drivers has become to use OF node information
> and, if not found, platform specific host information to extract the
> ethernet address for a given device.
[]
> diff --git a/include/linux/etherdevice.h b/include/linux/etherdevice.=
h
[]
> @@ -485,3 +487,32 @@ static int __init eth_offload_init(void)
> =A0}
> =A0
> =A0fs_initcall(eth_offload_init);
> +
> +unsigned char * __weak arch_get_platform_mac_address(void)
> +{
> +=A0=A0=A0=A0=A0=A0=A0return NULL;

WARN_ON_ONCE ?

> +}
> +
> +int eth_platform_get_mac_address(struct device *dev, u8 *mac_addr)
> +{
> +=A0=A0=A0=A0=A0=A0=A0const unsigned char *addr;
> +=A0=A0=A0=A0=A0=A0=A0struct device_node *dp;
> +
> +=A0=A0=A0=A0=A0=A0=A0if (dev_is_pci(dev))
> +=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0dp =3D pci_device_to_OF=
_node(to_pci_dev(dev));
> +=A0=A0=A0=A0=A0=A0=A0else
> +=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0dp =3D dev->of_node;
> +
> +=A0=A0=A0=A0=A0=A0=A0addr =3D NULL;
> +=A0=A0=A0=A0=A0=A0=A0if (dp)
> +=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0addr =3D of_get_mac_add=
ress(dp);
> +=A0=A0=A0=A0=A0=A0=A0if (!addr)
> +=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0addr =3D arch_get_platf=
orm_mac_address();
> +
> +=A0=A0=A0=A0=A0=A0=A0if (!addr)
> +=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0return -ENODEV;
> +
> +=A0=A0=A0=A0=A0=A0=A0ether_addr_copy(mac_addr, addr);

Couldn't some oddball arch have an unaligned addr?
