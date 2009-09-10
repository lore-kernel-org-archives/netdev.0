From: Moni Shoua <monis@Voltaire.COM>
Subject: Re: [PATCH RESEND] bonding: remap muticast addresses without using
 dev_close() and dev_open()
Date: Thu, 10 Sep 2009 11:47:05 +0300
Message-ID: <4AA8BD09.2010607@Voltaire.COM>
References: <4AA39E42.9070702@Voltaire.COM> <4AA8B19F.2080704@voltaire.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Jay Vosburgh <fubar@us.ibm.com>,
	David Miller <davem@davemloft.net>,
	Jason Gunthorpe <jgunthorpe@obsidianresearch.com>,
	netdev <netdev@vger.kernel.org>,
	bonding-devel@lists.sourceforge.net
To: Or Gerlitz <ogerlitz@voltaire.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fwil.voltaire.com ([193.47.165.2]:20092 "EHLO exil.voltaire.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751258AbZIJIrS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 Sep 2009 04:47:18 -0400
In-Reply-To: <4AA8B19F.2080704@voltaire.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Or Gerlitz wrote:
> Moni Shoua wrote:
>> This patch fixes commit e36b9d16c6a6d0f59803b3ef04ff3c22c3844c10. The
>> approach there is to call dev_close()/dev_open() whenever the device
>> type is changed in order to remap the device IP multicast addresses to
>> HW multicast addresses. This approach suffers from 2 drawbacks [...]
>> The fix here is to directly remap the IP multicast addresses to HW
>> multicast addresses for a bonding device that changes its type, and
>> nothing else.
> 
> Moni,
> 
> The approach and patch look good. First, I think it may be more easier
> to review and maintain if you separate this to two patches, the first
> simply reverting e36b9d16c6a6d0f59803b3ef04ff3c22c3844c10 and the second
> the approach suggested by this patch. Second, I think you may be able to
> do well with only one event, see next
> 
I don't need to revert the entire patch. Only the dev_open() and dev_close() functions need to be removed and it is quite easy to review it in one patch.
>> @@ -1460,14 +1460,17 @@ int bond_enslave(struct net_device *bond_dev,
>> struct net_device *slave_dev)
>>       */
>>      if (bond->slave_cnt == 0) {
>>          if (bond_dev->type != slave_dev->type) {
>> -            dev_close(bond_dev);
>>              pr_debug("%s: change device type from %d to %d\n",
>>                  bond_dev->name, bond_dev->type, slave_dev->type);
>> +
>> +            netdev_bonding_change(bond_dev, NETDEV_BONDING_OLDTYPE);
>> +
>>              if (slave_dev->type != ARPHRD_ETHER)
>>                  bond_setup_by_slave(bond_dev, slave_dev);
>>              else
>>                  ether_setup(bond_dev);
>> -            dev_open(bond_dev);
>> +
>> +            netdev_bonding_change(bond_dev, NETDEV_BONDING_NEWTYPE);
>>          }
> can't you achieve the same impact if just calling
> netdev_bonding_change(bond_dev, NETDEV_BONDING_NEWTYPE) after doing the
> setup_by_slave, and have the stack call ip_mc_unmap(...) and then
> ip_mc_map(...) ???
> 
I thought about it but the function arp_mc_map() which is called before and after the change in dev->type, relies on the value of dev->type. I could write the patch with one event after the type has changed and passing the old device type somehow (field prev_type in struct net_device?) but the resulted code will look clumsy (at least to me).

> Or.
> 
> 
> -- 
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 

