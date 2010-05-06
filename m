From: Scott Feldman <scofeldm@cisco.com>
Subject: Re: [net-next-2.6 V5 PATCH 2/3] Add ndo_{set|get}_vf_port_profile op
 support for enic dynamic vnics
Date: Thu, 06 May 2010 09:25:49 -0700
Message-ID: <C8083B9D.2EC18%scofeldm@cisco.com>
References: <201005061547.22400.arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<chrisw@redhat.com>
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ams-iport-2.cisco.com ([144.254.224.141]:49725 "EHLO
	ams-iport-2.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754824Ab0EFQfm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 May 2010 12:35:42 -0400
In-Reply-To: <201005061547.22400.arnd@arndb.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 5/6/10 6:47 AM, "Arnd Bergmann" <arnd@arndb.de> wrote:

> On Thursday 06 May 2010, Scott Feldman wrote:
>> @@ -810,14 +819,24 @@ static void enic_reset_mcaddrs(struct enic *enic)
>>  
>>  static int enic_set_mac_addr(struct net_device *netdev, char *addr)
>>  {
>> -       if (!is_valid_ether_addr(addr))
>> -               return -EADDRNOTAVAIL;
>> +       struct enic *enic = netdev_priv(netdev);
>>  
>> -       memcpy(netdev->dev_addr, addr, netdev->addr_len);
>> +       if (enic_is_dynamic(enic)) {
>> +               random_ether_addr(netdev->dev_addr);
>> +       } else {
>> +               if (!is_valid_ether_addr(addr))
>> +                       return -EADDRNOTAVAIL;
>> +               memcpy(netdev->dev_addr, addr, netdev->addr_len);
>> +       }
>>  
>>         return 0;
>>  }
>>  
>> +static int enic_set_mac_address(struct net_device *netdev, void *p)
>> +{
>> +       return -EOPNOTSUPP;
>> +}
>> +
>>  /* netif_tx_lock held, BHs disabled */
>>  static void enic_set_multicast_list(struct net_device *netdev)
>>  {
> 
> Thsi looks funny. So you just ignore the address that gets passed to
> enic_set_mac_addr for dynamic interfaces and instead set a random
> address?

Dynamic enics have all-zero mac address on init, so we assign a random mac
addr to the interface.  This would seem less funny:

    if (enic_is_dynamic(enic) && is_zero_ether_addr(addr))
        random_ether_addr(netdev->dev_addr);
    else
        ...

I'll make that change and resubmit with your VDP additions if you like.

-scott

