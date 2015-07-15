From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: Re: [PATCH net] bonding: fix bond dev flags after convert to arphrd_ether
Date: Wed, 15 Jul 2015 22:34:19 +0200
Message-ID: <55A6C3CB.9070605@cumulusnetworks.com>
References: <1436990983-1406-1-git-send-email-razor@blackwall.org> <1817.1436992353@famine>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, monis@voltaire.com,
	gospo@cumulusnetworks.com, vfalico@gmail.com, davem@davemloft.net
To: Jay Vosburgh <jay.vosburgh@canonical.com>,
	Nikolay Aleksandrov <razor@blackwall.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f46.google.com ([74.125.82.46]:34094 "EHLO
	mail-wg0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753239AbbGOUeW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Jul 2015 16:34:22 -0400
Received: by wgkl9 with SMTP id l9so42535018wgk.1
        for <netdev@vger.kernel.org>; Wed, 15 Jul 2015 13:34:21 -0700 (PDT)
In-Reply-To: <1817.1436992353@famine>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/15/2015 10:32 PM, Jay Vosburgh wrote:
> Nikolay Aleksandrov <razor@blackwall.org> wrote:
> 
>> From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
>>
>> If a bonding device enslaves devices != arphrd_ether it'll change types
>> and if later these devices are released, it can enslave an arphrd_ether
>> device and switch back calling ether_setup() which resets dev->flags to
>> IFF_BROADCAST|IFF_MULTICAST and clears IFF_MASTER which then could lead
>> to many different bugs. This bug seems to have been there since the
>> introduction of ether_setup() in bond_enslave().
> 
> 	I thought the hack-around for the non-ethernet device problem
> was that, for non-ARPHRD_ETHER devices, the bonding master device is
> automatically destroyed when the last slave is released.
> 
> 	This (well, this sort of thing) originally came up with IPoIB
> devices needing different ops that would disappear if the ipoib module
> was unloaded, so the bond master was deliberately unregistered when the
> last slave was released.
> 
> 	Looking at the code, at first glance this appears to still be
> the case: bond_slave_netdev_event calls bond_release_and_destroy for !=
> ARPHRD_ETHER, which in turn should unregister the bond itself if there
> are no slaves left.  Is this no longer working as intended?
> 
> 	-J
> 
> 
>> Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
>> Fixes: e36b9d16c6a6 ("bonding: clean muticast addresses when device changes type")
>> ---
>> drivers/net/bonding/bond_main.c | 1 +
>> 1 file changed, 1 insertion(+)
>>
>> diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
>> index 317a49480475..8ba119896e55 100644
>> --- a/drivers/net/bonding/bond_main.c
>> +++ b/drivers/net/bonding/bond_main.c
>> @@ -1368,6 +1368,7 @@ int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev)
>> 				bond_setup_by_slave(bond_dev, slave_dev);
>> 			else {
>> 				ether_setup(bond_dev);
>> +				bond_dev->flags |= IFF_MASTER;
>> 				bond_dev->priv_flags &= ~IFF_TX_SKB_SHARING;
>> 			}
>>
>> -- 
>> 1.9.3
>>
> 
> ---
> 	-Jay Vosburgh, jay.vosburgh@canonical.com
> 

Ah yes, the bug is actually that the bond doesn't switch back its type
on failure after the bond_setup_by_slave().
I actually had prepared that fix next. :-)
But you're right, this doesn't need to be fixed if the enslave failure
path is updated to switch back the type on fail.
