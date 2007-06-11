From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 3/4] [IPV4]: Add default config support after inetdev_init
Date: Mon, 11 Jun 2007 14:26:58 +0200
Message-ID: <466D3F92.7050803@trash.net>
References: <20070605062929.GA12024@gondor.apana.org.au> <E1HvSZL-0003AB-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:41305 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751336AbXFKM3Z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Jun 2007 08:29:25 -0400
In-Reply-To: <E1HvSZL-0003AB-00@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Herbert Xu wrote:
> [IPV4]: Add default config support after inetdev_init
> 
> Previously once inetdev_init has been called on a device any changes made
> to ipv4_devconf_dflt would have no effect on that device's configuration.


I noticed a few more side-effects from the original change that
seem to be undesired. Some code assumes that dev->ip_ptr != NULL
implies existance of IP addresses on the device. For example
fib_check_nh used to allow to add routes to devices only when a
in_device is present. We can now add routes without having any
IP addresses configured, which makes routing choose 0.0.0.0 as
source and invalidates the assumption of some other code that
the outgoing device of a packet always has an in_device present
(like MASQUERADE). fib_sync_up used to skip a nexthop when no
IP addresses was present on the device, now it will keep it.
There's probably more, I guess we need to audit all in_dev_get
calls.

