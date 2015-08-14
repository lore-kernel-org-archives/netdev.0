From: Jarod Wilson <jarod@redhat.com>
Subject: Re: [PATCH 1/6] net/bonding: enable LRO if one device supports it
Date: Fri, 14 Aug 2015 19:41:03 -0400
Message-ID: <55CE7C8F.8070702@redhat.com>
References: <1439488980-44738-1-git-send-email-jarod@redhat.com>
 <1439488980-44738-2-git-send-email-jarod@redhat.com>
 <20150814065622.GA21759@unicorn.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Jiri Pirko <jiri@resnulli.us>,
	Tom Herbert <therbert@google.com>,
	Scott Feldman <sfeldma@gmail.com>, netdev@vger.kernel.org
To: Michal Kubecek <mkubecek@suse.cz>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150814065622.GA21759@unicorn.suse.cz>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 2015-08-14 2:56 AM, Michal Kubecek wrote:
> On Thu, Aug 13, 2015 at 02:02:55PM -0400, Jarod Wilson wrote:
>> Currently, all bonding devices come up, and claim to have LRO support,
>> which ethtool will let you toggle on and off, even if none of the
>> underlying hardware devices actually support it. While the bonding driver
>> takes precautions for slaves that don't support all features, this is at
>> least a little bit misleading to users.
>>
>> If we add NETIF_F_LRO to the NETIF_F_ONE_FOR_ALL flags in
>> netdev_features.h, then netdev_features_increment() will only enable LRO
>> if 1) its listed in the device's feature mask and 2) if there's actually a
>> slave present that supports the feature.
>>
>> Note that this is going to require some follow-up patches, as not all LRO
>> capable device drivers are currently properly reporting LRO support in
>> their vlan_features, which is where the bonding driver picks up
>> device-specific features.
>>
>> CC: "David S. Miller" <davem@davemloft.net>
>> CC: Jiri Pirko <jiri@resnulli.us>
>> CC: Tom Herbert <therbert@google.com>
>> CC: Scott Feldman <sfeldma@gmail.com>
>> CC: netdev@vger.kernel.org
>> Signed-off-by: Jarod Wilson <jarod@redhat.com>
>> ---
>>   include/linux/netdev_features.h | 3 ++-
>>   1 file changed, 2 insertions(+), 1 deletion(-)
>>
>> diff --git a/include/linux/netdev_features.h b/include/linux/netdev_features.h
>> index 9672781..6440bf1 100644
>> --- a/include/linux/netdev_features.h
>> +++ b/include/linux/netdev_features.h
>> @@ -159,7 +159,8 @@ enum {
>>    */
>>   #define NETIF_F_ONE_FOR_ALL	(NETIF_F_GSO_SOFTWARE | NETIF_F_GSO_ROBUST | \
>>   				 NETIF_F_SG | NETIF_F_HIGHDMA |		\
>> -				 NETIF_F_FRAGLIST | NETIF_F_VLAN_CHALLENGED)
>> +				 NETIF_F_FRAGLIST | NETIF_F_VLAN_CHALLENGED | \
>> +				 NETIF_F_LRO)
>>
>>   /*
>>    * If one device doesn't support one of these features, then disable it
>> --
>
> I don't think this is going to work the way you expect. Assume we have a
> non-LRO eth1 and LRO capable eth2. If we enslave eth1 first, bond will
> lose NETIF_F_LRO so that while enslaving eth2, bond_enslave() does run
>
> 	if (!(bond_dev->features & NETIF_F_LRO))
> 		dev_disable_lro(slave_dev);
>
> and disable LRO on eth2 even before computing the bond features so that
> in the end, all three interfaces end up with disabled LRO. If you add
> the slaves in the opposite order, you end up with eth2 and bond having
> LRO enabled. IMHO features should not depend on the order in which
> slaves are added into the bond.

Crap, you're right. Hadn't tried inverting the order of added devices, 
as it didn't occur to me that it would make a difference.

> You would need to remove the code quoted above to make things work the
> way you want (or move it after the call to bond_compute_features() which
> is effectively the same). But then the result would be even worse:
> adding a LRO-capable slave to a bond having dev_disable_lro() called on
> it would not disable LRO on that slave, possibly (or rather likely)
> causing communication breakage.
>
> I believe NETIF_F_LRO in its original sense should be only considered
> for physical devices; even if it's not explicitely said in the commit
> message, the logic behind fbe168ba91f7 ("net: generic dev_disable_lro()
> stacked device handling") is that for stacked devices like bond or team,
> NETIF_F_LRO means "allow slaves to use LRO if they can and want" while
> its absence means "disable LRO on all slaves". If you wanted NETIF_F_LRO
> for a bond to mean "there is at least one LRO capable slave", you would
> need a new flag for the "LRO should be disabled for all lower devices"
> state. I don't think it's worth the effort.

Yeah, my thinking was that it should mean "there's at least one lro 
capable slave". If we just leave things the way they are though, I think 
its confusing on the user side -- it was one of our QE people who 
reported confusion being able to toggle lro on a bond when none of the 
slaves supported it. And there's also the inconsistency among devices 
that support lro in their vlan_features. So I think *something* should 
still be done here to make things clearer and more consistent, but I'll 
have to ponder that next week, since its beyond quitting time on Friday 
already. :)

Oh, last thought: the comment above #define NETIF_F_ONE_FOR_ALL is 
partly to blame for my not thinking harder and trying inverted ordering 
of slave additions:

/*
  * If one device supports one of these features, then enable them
  * for all in netdev_increment_features.
  */

This clearly seems to fall down in the lro case. :)

-- 
Jarod Wilson
jarod@redhat.com
