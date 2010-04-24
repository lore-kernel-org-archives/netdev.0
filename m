From: Scott Feldman <scofeldm@cisco.com>
Subject: Re: [net-next-2.6 PATCH 2/2] add enic ndo_vf_set_port_profile op
 support for dynamic vnics
Date: Sat, 24 Apr 2010 07:30:18 -0700
Message-ID: <C7F84E8A.2B52B%scofeldm@cisco.com>
References: <20100424022121.GE3843@x200.localdomain>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>, <arnd@arndb.de>
To: Chris Wright <chrisw@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-5.cisco.com ([171.68.10.87]:10018 "EHLO
	sj-iport-5.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752174Ab0DXOah (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 24 Apr 2010 10:30:37 -0400
In-Reply-To: <20100424022121.GE3843@x200.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 4/23/10 7:21 PM, "Chris Wright" <chrisw@redhat.com> wrote:

> * Scott Feldman (scofeldm@cisco.com) wrote:
>> -#define DRV_VERSION  "1.3.1.1"
>> +#define DRV_VERSION  "1.3.1.1-iov"
> 
> not a version bump?

Anything ver diff will work to tell this patch from what's upstream already.
 
>> @@ -810,14 +819,24 @@ static void enic_reset_mcaddrs(struct enic *enic)
>>  
>>  static int enic_set_mac_addr(struct net_device *netdev, char *addr)
>>  {
>> - if (!is_valid_ether_addr(addr))
>> -  return -EADDRNOTAVAIL;
>> + struct enic *enic = netdev_priv(netdev);
>>  
>> - memcpy(netdev->dev_addr, addr, netdev->addr_len);
>> + if (enic_is_dynamic(enic)) {
>> +  random_ether_addr(netdev->dev_addr);
> 
> Would it make more sense to just ignore this?  Then the default (not
> port profile configured yet) mac is still a useful identifier.

Dynamic enics start out with all zero mac addr, so this assigns a random one
to the interface when created.  After I sent out this patch, I realized if
mac addr arg wasn't included in port-profile by user (it's optional), then I
should use this random netdev->dev_addr for the port-profile mac addr.  Next
patch.

>> +static int enic_set_mac_address(struct net_device *netdev, void *p)
>> +{
>> + return -EOPNOTSUPP;
>> +}
>> +
> 
> Ever?  Even on non-dynamic enic?  Oh, I see, this was just a lie before ;-)

Static enics get mac addr from mgmt tool; and dynamic enics get mac addr
during port-profile assignment.  In either case, there is no need for the
user to change the interface mac addr, so I'm adding this explicit block.

It's weird, without setting any value to ndo_set_mac_address, you can change
the mac addr on the interface when the interface is DOWN but not when it's
UP.  Not sure why that is.  In any case, adding this ndo_set_mac_address
callback blocks all attempts to change mac addr on interface.
 
>> +static int enic_set_vf_port_profile(struct net_device *netdev, int vf,
>> + u8 *port_profile, u8 *mac, u8 *host_uuid, u8 *client_uuid,
>> + u8 *client_name)
>> +{
>> + struct enic *enic = netdev_priv(netdev);
>> + struct vic_provinfo *vp;
>> + u8 oui[3] = VIC_PROVINFO_CISCO_OUI;
>> + int err;
>> +
>> + if (!enic_is_dynamic(enic))
>> +  return -EOPNOTSUPP;
> 
> Do you want to validate vf (like require it to be 0) or something?

Yes, I should add a check for vf == 0.

> How should userspace know to talk directly to the VF (dynamic enic) in
> this device, but a PF + VF_index for another device?

Can we use IFLA_NUM_VF?  In this enic case since PF==VF (for now), we'll
need to return IFLA_NUM_VF=1.  Let me see what we can do here.

>> + err = enic_vnic_dev_deinit(enic);
>> + if (err)
>> +  goto err_out;
>> +
>> + err = enic_dev_init_prov(enic, vp);
>> +
>> +err_out:
>> + vic_provinfo_free(vp);
>> +
>> + enic_set_multicast_list(netdev);
> 
> Should that happen in error case (and is the locking correct)?

Locking is correct.  I change this to do this only on the non-err patch.

-scott

