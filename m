From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH 01/01] ipv6: RFC4214 Support (v2.2)
Date: Thu, 15 Nov 2007 20:22:08 +0900 (JST)
Message-ID: <20071115.202208.126883108.yoshfuji@linux-ipv6.org>
References: <4739D7F7.90300@hp.com>
	<39C363776A4E8C4A94691D2BD9D1C9A1029EDC29@XCH-NW-7V2.nw.nos.boeing.com>
	<39C363776A4E8C4A94691D2BD9D1C9A1029EDC2B@XCH-NW-7V2.nw.nos.boeing.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, vladislav.yasevich@hp.com,
	yoshfuji@linux-ipv6.org
To: Fred.L.Templin@boeing.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:33173 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752033AbXKOLWL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Nov 2007 06:22:11 -0500
In-Reply-To: <39C363776A4E8C4A94691D2BD9D1C9A1029EDC2B@XCH-NW-7V2.nw.nos.boeing.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In article <39C363776A4E8C4A94691D2BD9D1C9A1029EDC2B@XCH-NW-7V2.nw.nos.boeing.com> (at Wed, 14 Nov 2007 22:44:17 -0800), "Templin, Fred L" <Fred.L.Templin@boeing.com> says:

> --- linux-2.6.24-rc2/net/ipv6/addrconf.c.orig	2007-11-08 11:59:35.000000000 -0800
> +++ linux-2.6.24-rc2/net/ipv6/addrconf.c	2007-11-14 22:17:28.000000000 -0800
> @@ -1424,6 +1424,21 @@ static int addrconf_ifid_infiniband(u8 *
>  	return 0;
>  }
>  
> +static int addrconf_ifid_isatap(u8 *eui, __be32 addr)
> +{
> +
> +	eui[0] = 0x02; eui[1] = 0; eui[2] = 0x5E; eui[3] = 0xFE;
> +	memcpy (eui+4, &addr, 4);
> +
> +	if (ZERONET(addr) || PRIVATE_10(addr) || LOOPBACK(addr) ||
> +	    LINKLOCAL_169(addr) || PRIVATE_172(addr) || TEST_192(addr) ||
> +	    ANYCAST_6TO4(addr) || PRIVATE_192(addr) || TEST_198(addr) ||
> +	    MULTICAST(addr) || BADCLASS(addr))
> +		eui[0] &= ~0x02;
> +
> +	return 0;
> +}
> +
>  static int ipv6_generate_eui64(u8 *eui, struct net_device *dev)
>  {
>  	switch (dev->type) {

{
  eui[0] = (ZERONET(addr) || PRIVATE_10(addr) || LOOPBACK(addr) ||
            LINKLOCAL_169(addr) || PRIVATE_172(addr) || TEST_192(addr) ||
            ANYCAST_6TO4(addr) || PRIVATE_192(addr) || TEST_198(addr) ||
            MULTICAST(addr) || BADCLASS(addr)) ? 0 : 2;
  eui[1] = 0;
  eui[2] = 0x5E;
  eui[3] = 0xFE;
  memcpy (eui+4, &addr, 4);
}


> @@ -2167,7 +2185,8 @@ static void addrconf_dev_config(struct n
>  	    (dev->type != ARPHRD_FDDI) &&
>  	    (dev->type != ARPHRD_IEEE802_TR) &&
>  	    (dev->type != ARPHRD_ARCNET) &&
> -	    (dev->type != ARPHRD_INFINIBAND)) {
> +	    (dev->type != ARPHRD_INFINIBAND) &&
> +	    !(dev->priv_flags & IFF_ISATAP)) {
>  		/* Alas, we support only Ethernet autoconfiguration. */
>  		return;
>  	}

Because priv_flags are local to device type, you need to check dev->type:
	(dev->type == ARPHRD_SIT && !(dev->priv_flags & IFF_ISATAP))
or something like this.


> +	struct ip_tunnel *t  = netdev_priv(ifp->idev->dev);
> +	if (t->parms.i_key != INADDR_NONE) {
> +		spin_lock(&ifp->lock);

I guess INADDR_ANY.

--yoshfuji
