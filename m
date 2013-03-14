From: Glen Turner <gdt@gdt.id.au>
Subject: Re: [PATCH net-next] bond: add support to read speed and duplex via ethtool
Date: Thu, 14 Mar 2013 17:27:18 +1030
Message-ID: <7F6F6B08-6546-4B46-91C0-C5C6AFCAEE40@gdt.id.au>
References: <1362595173-11442-1-git-send-email-andy@greyhouse.net> <22416.1362597912@death.nxdomain> <20130306200140.GB19544@gospo.rdu.redhat.com> <27035.1362606373@death.nxdomain> <58A138EA-ADB5-4DFC-AA35-2D0E578483FD@gdt.id.au> <20130308153505.GB7606@gospo.rdu.redhat.com>
Mime-Version: 1.0 (Mac OS X Mail 6.2 \(1499\))
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: netdev@vger.kernel.org
To: Andy Gospodarek <andy@greyhouse.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eth6445.sa.adsl.internode.on.net ([150.101.30.44]:57342 "EHLO
	aix.gdt.id.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753699Ab3CNG5a convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Mar 2013 02:57:30 -0400
In-Reply-To: <20130308153505.GB7606@gospo.rdu.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On 09/03/2013, at 2:05 AM, Andy Gospodarek <andy@greyhouse.net> wrote:

> 
> That is a great point.  Are you saying that quagga or other
> outside-the-kernel routing daemons actually query ethtool settings to
> determine link speed and weight?

Wasn't sure. I was hinting if it did happen it would be serious, as bonding is commonly used in network designs to reduce L3 flapping.

I downloaded Quagga for a look.

Quagga uses the NetLink protocol to talk with the kernel, and it doesn't seem to be possible to retrieve an interface's bandwidth using that. That's possibly because bandwidth is a hairy concept (eg, you can argue that it's more a attribute of links than interfaces). Netlink does return a metric for links, but not a bandwidth.

So Quagga can retrieve each link's metric, that metric is then interpreted by the various routing daemons. But in Linux metrics are usually 1, not based on link speeds like they are with routers.

So Quagga in practice relies on manual setting of bandwidth in zebra.conf:

  interface eth0
    ! 1000Base-T
    bandwidth 1000000

If the interface bandwidth is nonzero then Quagga uses that (adjusted by "auto-cost reference-bandwidth") to set the link metric used by the routing protocol. Otherwise it seems to adjust the Linux metric (I didn't check how or why) and use that.

So, at least in the Quagga instance, ethtool's reported bandwidth isn't used for routing.


The more I think about the look of the graphs the more I think that they are not going to work as you hope. The graphed value shouldn't suddenly halve just because a link has come back online.

I really think you'll be happier reporting the addition of the maximum bandwidth of all the interfaces in the bond, whatever their carrier state or negotiated value. Maybe you could change the bonding driver so that if this results is poor scaling then you can set a bond's speed with "ethtool -s bond0 400" and "ethtool bond0" will report that. After all it's not like setting a bond's speed could have any physical meaning.

Best wishes, glen

-- 
 Glen Turner <http://www.gdt.id.au/~gdt/>
