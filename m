From: Moni Shoua <monisonlists@gmail.com>
Subject: Re: [ofa-general] Re: [PATCH V4 8/10] net/bonding: Handlle wrong
 assumptions that slave is always an Ethernet device
Date: Wed, 29 Aug 2007 16:37:34 +0300
Message-ID: <46D5769E.6000405@gmail.com>
References: <46C9B474.5020202@voltaire.com> <46C9B8D9.5060508@voltaire.com> <416.1188343604@death>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Moni Shoua <monis@voltaire.com>, netdev@vger.kernel.org,
	rdreier@cisco.com, davem@davemloft.net,
	general@lists.openfabrics.org
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fwil.voltaire.com ([193.47.165.2]:55502 "EHLO exil.voltaire.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1757297AbXH2Nhl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 29 Aug 2007 09:37:41 -0400
In-Reply-To: <416.1188343604@death>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jay Vosburgh wrote:
> Moni Shoua <monis@voltaire.com> wrote:
> 
>> bonding sometimes uses Ethernet constants (such as MTU and address length) which
>> are not good when it enslaves non Ethernet devices (such as InfiniBand).
>>
>> Signed-off-by: Moni Shoua <monis@voltaire.com>
>> ---
>> drivers/net/bonding/bond_main.c  |    3 ++-
>> drivers/net/bonding/bond_sysfs.c |   19 +++++++++++++------
>> drivers/net/bonding/bonding.h    |    1 +
>> 3 files changed, 16 insertions(+), 7 deletions(-)
>>
>> Index: net-2.6/drivers/net/bonding/bond_main.c
>> ===================================================================
>> --- net-2.6.orig/drivers/net/bonding/bond_main.c	2007-08-15 10:55:48.000000000 +0300
>> +++ net-2.6/drivers/net/bonding/bond_main.c	2007-08-20 14:29:11.911298577 +0300
>> @@ -1224,7 +1224,8 @@ static int bond_compute_features(struct 
>> 	struct slave *slave;
>> 	struct net_device *bond_dev = bond->dev;
>> 	unsigned long features = bond_dev->features;
>> -	unsigned short max_hard_header_len = ETH_HLEN;
>> +	unsigned short max_hard_header_len = max((u16)ETH_HLEN,
>> +						bond_dev->hard_header_len);
> 
> 	Since non-IB bonding masters are run through ether_setup, which
> sets hard_header_len to ETH_HLEN, the max() is probably unnecessary, and
> I think this could just be bond_dev->hard_header_len.
> 
This is true except for the case where there are no slaves left.
In that case max_hard_header_len has equals to the initialization value.


       bond_for_each_slave(bond, slave, i) {
                features = netdev_compute_features(features,
                                                   slave->dev->features);
                if (slave->dev->hard_header_len > max_hard_header_len)
                        max_hard_header_len = slave->dev->hard_header_len;
        }

        features |= (bond_dev->features & BOND_VLAN_FEATURES);
        bond_dev->features = features;
        bond_dev->hard_header_len = max_hard_header_len;


