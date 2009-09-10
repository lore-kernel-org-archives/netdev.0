From: Or Gerlitz <ogerlitz@voltaire.com>
Subject: Re: [PATCH RESEND] bonding: remap muticast addresses without using
 dev_close() and dev_open()
Date: Thu, 10 Sep 2009 10:58:23 +0300
Message-ID: <4AA8B19F.2080704@voltaire.com>
References: <4AA39E42.9070702@Voltaire.COM>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jay Vosburgh <fubar@us.ibm.com>,
	David Miller <davem@davemloft.net>,
	Jason Gunthorpe <jgunthorpe@obsidianresearch.com>,
	netdev <netdev@vger.kernel.org>,
	bonding-devel@lists.sourceforge.net
To: Moni Shoua <monis@Voltaire.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fwil.voltaire.com ([193.47.165.2]:30897 "EHLO exil.voltaire.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752762AbZIJH63 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 Sep 2009 03:58:29 -0400
In-Reply-To: <4AA39E42.9070702@Voltaire.COM>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Moni Shoua wrote:
> This patch fixes commit e36b9d16c6a6d0f59803b3ef04ff3c22c3844c10. The approach there is to call dev_close()/dev_open() whenever the device type is changed in order to remap the device IP multicast addresses to HW multicast addresses. This approach suffers from 2 drawbacks [...] The fix here is to directly remap the IP multicast addresses to HW multicast addresses for a bonding device that changes its type, and nothing else.

Moni,

The approach and patch look good. First, I think it may be more easier 
to review and maintain if you separate this to two patches, the first 
simply reverting e36b9d16c6a6d0f59803b3ef04ff3c22c3844c10 and the second 
the approach suggested by this patch. Second, I think you may be able to 
do well with only one event, see next

> @@ -1460,14 +1460,17 @@ int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev)
>  	 */
>  	if (bond->slave_cnt == 0) {
>  		if (bond_dev->type != slave_dev->type) {
> -			dev_close(bond_dev);
>  			pr_debug("%s: change device type from %d to %d\n",
>  				bond_dev->name, bond_dev->type, slave_dev->type);
> +
> +			netdev_bonding_change(bond_dev, NETDEV_BONDING_OLDTYPE);
> +
>  			if (slave_dev->type != ARPHRD_ETHER)
>  				bond_setup_by_slave(bond_dev, slave_dev);
>  			else
>  				ether_setup(bond_dev);
> -			dev_open(bond_dev);
> +
> +			netdev_bonding_change(bond_dev, NETDEV_BONDING_NEWTYPE);
>  		}
can't you achieve the same impact if just calling 
netdev_bonding_change(bond_dev, NETDEV_BONDING_NEWTYPE) after doing the 
setup_by_slave, and have the stack call ip_mc_unmap(...) and then 
ip_mc_map(...) ???

Or.


