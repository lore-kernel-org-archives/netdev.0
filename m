From: Jarod Wilson <jarod@redhat.com>
Subject: Re: [RFC PATCH net-next] net/core: initial support for stacked dev
 feature toggles
Date: Fri, 30 Oct 2015 12:25:44 -0400
Message-ID: <56339A08.8000205@redhat.com>
References: <1445658019-58621-1-git-send-email-jarod@redhat.com> <562B1C4D.8050407@gmail.com> <20151026094213.GA1715@unicorn.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Alexander Duyck <alexander.duyck@gmail.com>,
	linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Jay Vosburgh <j.vosburgh@gmail.com>,
	Veaceslav Falico <vfalico@gmail.com>,
	Andy Gospodarek <gospo@cumulusnetworks.com>,
	Jiri Pirko <jiri@resnulli.us>,
	Nikolay Aleksandrov <razor@blackwall.org>,
	netdev@vger.kernel.org
To: Michal Kubecek <mkubecek@suse.cz>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20151026094213.GA1715@unicorn.suse.cz>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Michal Kubecek wrote:
> On Fri, Oct 23, 2015 at 10:51:09PM -0700, Alexander Duyck wrote:
>> On 10/23/2015 08:40 PM, Jarod Wilson wrote:
>>> +static netdev_features_t netdev_sync_upper_features(struct net_device *lower,
>>> +	struct net_device *upper, netdev_features_t features)
>>> +{
>>> +	netdev_features_t want = upper->wanted_features&  lower->hw_features;
>>> +
>>> +	if (!(upper->wanted_features&  NETIF_F_LRO)
>>> +	&&  (features&  NETIF_F_LRO)) {
>>> +		netdev_info(lower, "Dropping LRO, upper dev %s has it off.\n",
>>> +			   upper->name);
>>> +		features&= ~NETIF_F_LRO;
>>> +	} else if ((want&  NETIF_F_LRO)&&  !(features&  NETIF_F_LRO)) {
>>> +		netdev_info(lower, "Keeping LRO, upper dev %s has it on.\n",
>>> +			   upper->name);
>>> +		features |= NETIF_F_LRO;
>>> +	}
>>> +
>>> +	return features;
>>> +}
>>> +
>> I'd say to drop the second half of this statement.  LRO is a feature
>> that should be enabled explicitly per interface.  If someone enables
>> LRO on the master they may only want it on one interface.  The fact
>> is there are some implementations of LRO that work better than
>> others so you want to give the end user the option to mix and match.
>
> Agreed. IMHO it makes sense to allow setups with LRO disabled on some
> slaves and enabled on other.
>
> Also, the logic seems to only consider the 1 upper : N lower scheme
> (bond, team) but we also have N upper : 1 lower setups (vlan, macvlan).
> For these, there is no way to propagate both 0 and 1 down as this would
> result in a conflict.

Okay, so we're thinking do prevent lower devices turning LRO on if the 
upper device has it off. Or rather, if *an* upper device has it off. 
Probably need to rework the bit that calls this function to use 
netdev_for_each_upper_dev{_rcu}() to walk all of adj_list.upper here.

Rather than outright dropping the second bit though, I was thinking 
maybe just drop a note in dmesg along the lines of "hey, you shut off 
LRO, it is still enabled on upper dev foo", to placate end-users.


>>> +static void netdev_sync_lower_features(struct net_device *upper,
>>> +	struct net_device *lower, netdev_features_t features)
>>> +{
>>> +	netdev_features_t want = features&  lower->hw_features;
>>> +
>>> +	if (!(features&  NETIF_F_LRO)&&  (lower->features&  NETIF_F_LRO)) {
>>> +		netdev_info(upper, "Disabling LRO on lower dev %s.\n",
>>> +			   lower->name);
>>> +		upper->wanted_features&= ~NETIF_F_LRO;
>>> +		lower->wanted_features&= ~NETIF_F_LRO;
>>> +		netdev_update_features(lower);
>>> +		if (unlikely(lower->features&  NETIF_F_LRO))
>>> +			netdev_WARN(upper, "failed to disable LRO on %s!\n",
>>> +				    lower->name);
>>> +	} else if ((want&  NETIF_F_LRO)&&  !(lower->features&  NETIF_F_LRO)) {
>>> +		netdev_info(upper, "Enabling LRO on lower dev %s.\n",
>>> +			   lower->name);
>>> +		upper->wanted_features |= NETIF_F_LRO;
>>> +		lower->wanted_features |= NETIF_F_LRO;
>>> +		netdev_update_features(lower);
>>> +		if (unlikely(!(lower->features&  NETIF_F_LRO)))
>>> +			netdev_WARN(upper, "failed to enable LRO on %s!\n",
>>> +				    lower->name);
>>> +	}
>>> +}
>>> +
>> Same thing here.  If a lower dev has it disabled then leave it
>> disabled.  I believe your goal is to make it so that
>> dev_disable_lro() can shut down LRO when it is making packets in the
>> data-path unusable.
>
> This is already the case since commit fbe168ba91f7 ("net: generic
> dev_disable_lro() stacked device handling"). That commit makes sure
> dev_disable_lro() is propagated down the stack and also makes sure new
> slaves added to a bond/team with LRO disabled have it disabled too.
>
> What it does not do is propagating LRO disabling down if it is disabled
> in ways that do not call dev_disable_lro() (e.g. via ethtool). I'm not
> sure if this should be done or not, both options have their pros and
> cons.

Making it work with ethtool was one of my primary goals with this 
change, as it was users prodding things with ethtool that prompted the 
"hey, this doesn't make sense" bug reports.

> However, I believe enabling LRO shouldn't be propagated down.

Hm. Devices that should never have LRO enabled still won't get it 
enabled, so I'm not clear what harm it would cause. I tend to think you 
do want this sync'ing down the stack if set on an upper dev (i.e., 
ethtool -K bond0 lro on), for consistency's sake. You can always come 
back through afterwards and disable things on lower devs individually if 
they're really not wanted, since we're in agreement that we shouldn't 
prevent disabling features on lower devices.

-- 
Jarod Wilson
jarod@redhat.com
