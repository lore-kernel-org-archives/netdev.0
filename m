From: Ding Tianhong <dingtianhong@huawei.com>
Subject: Re: [PATCH net-next v2] macvlan: fix the problem when mac address
 changes for passthru mode
Date: Fri, 30 May 2014 10:36:22 +0800
Message-ID: <5387EEA6.1080609@huawei.com>
References: <5386E137.1040304@huawei.com> <53873A32.5000107@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: Vlad Yasevich <vyasevich@gmail.com>,
	Patrick McHardy <kaber@trash.net>,
	"David S. Miller" <davem@davemloft.net>,
	Vlad Yasevich <vyasevic@redhat.com>,
	Netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga01-in.huawei.com ([119.145.14.64]:6999 "EHLO
	szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751360AbaE3Ch2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 May 2014 22:37:28 -0400
In-Reply-To: <53873A32.5000107@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2014/5/29 21:46, Vlad Yasevich wrote:
> On 05/29/2014 03:26 AM, Ding Tianhong wrote:
>> The macvlan dev should always have the same mac address like lowerdev
>> when in the passthru mode, change the mac address alone will break the
>> work mechanism, so when the lowerdev or macvlan mac address changes,
>> we should propagate the changes to another dev.
>>
>> v1->v2: Allow macvlan dev to change mac address for passthru mode and propagate to
>> 	lowerdev.
>>
>> Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
>> ---
>>  drivers/net/macvlan.c | 42 +++++++++++++++++++++++++++++++++---------
>>  1 file changed, 33 insertions(+), 9 deletions(-)
>>
>> diff --git a/drivers/net/macvlan.c b/drivers/net/macvlan.c
>> index a665e90..3e24770 100644
>> --- a/drivers/net/macvlan.c
>> +++ b/drivers/net/macvlan.c
>> @@ -494,35 +494,47 @@ hash_del:
>>  	return 0;
>>  }
>>  
>> -static int macvlan_set_mac_address(struct net_device *dev, void *p)
>> +static int macvlan_sync_address(struct net_device *dev, unsigned char *addr)
>>  {
>>  	struct macvlan_dev *vlan = netdev_priv(dev);
>>  	struct net_device *lowerdev = vlan->lowerdev;
>> -	struct sockaddr *addr = p;
>>  	int err;
>>  
>> -	if (!is_valid_ether_addr(addr->sa_data))
>> -		return -EADDRNOTAVAIL;
>> -
>>  	if (!(dev->flags & IFF_UP)) {
>>  		/* Just copy in the new address */
>> -		memcpy(dev->dev_addr, addr->sa_data, ETH_ALEN);
>> +		ether_addr_copy(dev->dev_addr, addr);
>>  	} else {
>>  		/* Rehash and update the device filters */
>> -		if (macvlan_addr_busy(vlan->port, addr->sa_data))
>> +		if (macvlan_addr_busy(vlan->port, addr))
>>  			return -EBUSY;
>>  
>> -		err = dev_uc_add(lowerdev, addr->sa_data);
>> +		err = dev_uc_add(lowerdev, addr);
>>  		if (err)
>>  			return err;
>>  
>>  		dev_uc_del(lowerdev, dev->dev_addr);
>>  
>> -		macvlan_hash_change_addr(vlan, addr->sa_data);
>> +		macvlan_hash_change_addr(vlan, addr);
>>  	}
>>  	return 0;
>>  }
>>  
>> +static int macvlan_set_mac_address(struct net_device *dev, void *p)
>> +{
>> +	struct macvlan_dev *vlan = netdev_priv(dev);
>> +	struct sockaddr *addr = p;
>> +
>> +	if (!is_valid_ether_addr(addr->sa_data))
>> +		return -EADDRNOTAVAIL;
>> +
>> +	if (vlan->mode == MACVLAN_MODE_PASSTHRU) {
>> +		dev_set_mac_address(vlan->lowerdev, addr);
>> +		return 0;
>> +	}
>> +
>> +	return macvlan_sync_address(dev, addr->sa_data);
>> +}
>> +
>>  static void macvlan_change_rx_flags(struct net_device *dev, int change)
>>  {
>>  	struct macvlan_dev *vlan = netdev_priv(dev);
>> @@ -1106,6 +1118,18 @@ static int macvlan_device_event(struct notifier_block *unused,
>>  			dev_set_mtu(vlan->dev, dev->mtu);
>>  		}
>>  		break;
>> +	case NETDEV_CHANGEADDR:
>> +		if (!port->passthru)
>> +			return NOTIFY_DONE;
>> +
>> +		vlan = list_first_entry_or_null(&port->vlans,
>> +						struct macvlan_dev,
>> +						list);
>> +
>> +		if (macvlan_sync_address(vlan->dev, dev->dev_addr))
>> +			return NOTIFY_BAD;
>> +
> 
> Ok, this is not quite right.  The lower device changes it's mac address
> and notifies upper macvlan about it.  Macvlan, if it is up, will write
> the same mac address down to the lower device's unicast address list
> as part of the sync.  The lower device ends up with two copies of its
> own address.
> 
> -vlad

Good catch, I will fix it, thanks.

Ding

>> +		break;
>>  	case NETDEV_UNREGISTER:
>>  		/* twiddle thumbs on netns device moves */
>>  		if (dev->reg_state != NETREG_UNREGISTERING)
>>
> 
> 
> .
> 
