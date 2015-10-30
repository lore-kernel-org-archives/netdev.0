From: Jarod Wilson <jarod@redhat.com>
Subject: Re: [RFC PATCH net-next] net/core: initial support for stacked dev
 feature toggles
Date: Fri, 30 Oct 2015 12:35:55 -0400
Message-ID: <56339C6B.3000108@redhat.com>
References: <1445658019-58621-1-git-send-email-jarod@redhat.com> <562B1C4D.8050407@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Jay Vosburgh <j.vosburgh@gmail.com>,
	Veaceslav Falico <vfalico@gmail.com>,
	Andy Gospodarek <gospo@cumulusnetworks.com>,
	Jiri Pirko <jiri@resnulli.us>,
	Nikolay Aleksandrov <razor@blackwall.org>,
	Michal Kubecek <mkubecek@suse.cz>, netdev@vger.kernel.org
To: Alexander Duyck <alexander.duyck@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <562B1C4D.8050407@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Alexander Duyck wrote:
> On 10/23/2015 08:40 PM, Jarod Wilson wrote:
>> There are some netdev features that make little sense to toggle on and
>> off in a stacked device setup on only one device in the stack. The prime
>> example is a bonded connection, where it really doesn't make sense to
>> disable LRO on the master, but not on any of the slaves, nor does it
>> really make sense to be able to shut LRO off on a slave when its still
>> enabled on the master.
>>
>> The strategy here is to add a section near the end of
>> netdev_fix_features() that looks for upper and lower netdevs, then make
>> sure certain feature flags match both up and down the stack. At present,
>> only the LRO flag is included.
...
>> +static void netdev_sync_lower_features(struct net_device *upper,
>> + struct net_device *lower, netdev_features_t features)
>> +{
>> + netdev_features_t want = features & lower->hw_features;
>> +
>> + if (!(features & NETIF_F_LRO) && (lower->features & NETIF_F_LRO)) {
>> + netdev_info(upper, "Disabling LRO on lower dev %s.\n",
>> + lower->name);
>> + upper->wanted_features &= ~NETIF_F_LRO;
>> + lower->wanted_features &= ~NETIF_F_LRO;
>> + netdev_update_features(lower);
>> + if (unlikely(lower->features & NETIF_F_LRO))
>> + netdev_WARN(upper, "failed to disable LRO on %s!\n",
>> + lower->name);
>> + } else if ((want & NETIF_F_LRO) && !(lower->features & NETIF_F_LRO)) {
>> + netdev_info(upper, "Enabling LRO on lower dev %s.\n",
>> + lower->name);
>> + upper->wanted_features |= NETIF_F_LRO;
>> + lower->wanted_features |= NETIF_F_LRO;
>> + netdev_update_features(lower);
>> + if (unlikely(!(lower->features & NETIF_F_LRO)))
>> + netdev_WARN(upper, "failed to enable LRO on %s!\n",
>> + lower->name);
>> + }
>> +}
>> +
>
> Same thing here. If a lower dev has it disabled then leave it disabled.
> I believe your goal is to make it so that dev_disable_lro() can shut
> down LRO when it is making packets in the data-path unusable. There is
> no need to make this an all or nothing scenario. We can let the stack
> slam things down with dev_disable_lro() and then if a user so desires
> they can come back through and enable LRO more selectively if they for
> instance have an interface that can do a smarter job of putting together
> frames that could be routed.
>
> You could probably look at doing something like this for RXCSUM as well.
> The general idea is that if an upper device has it off then the value
> has to be off. For example if RXCSUM is off in a upper device and LRO is
> enabled on the lower device there is a good chance that the upper device
> will report checksum errors since most LRO implementations don't
> recalculate the checksum. If RXCSUM is forced down to the lower device
> hopefully its fix_features will know this and disable LRO on that device
> when the RXCSUM is disabled on it.

Yeah, I was thinking there might be more flags to treat the same way, 
just wanted to hammer out the plausibility of doing it at all first. I 
can add RXCSUM to v2, or just wait until there's something that people 
might consider merge-worthy before worrying about additional flags. From 
what I've seen, most device's fix_features are reasonably intelligent 
about allowing/disallowing certain flag combos, so this does look pretty 
safe at a glance, and if a specific device tips over, it probably needs 
to be fixed in the device's driver anyway.

-- 
Jarod Wilson
jarod@redhat.com
