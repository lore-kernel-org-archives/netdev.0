From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [PATCH net-next 6/8] net/mlx5e: Introduce tc offload support
Date: Tue, 01 Mar 2016 09:13:25 -0800
Message-ID: <56D5CDB5.4090906@gmail.com>
References: <1456842290-7844-1-git-send-email-amir@vadai.me> <1456842290-7844-7-git-send-email-amir@vadai.me> <20160301145208.GB2098@nanopsycho.orion> <56d5c9bd.c13fc20a.046a.ffffe0ce@mx.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Or Gerlitz <ogerlitz@mellanox.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	Saeed Mahameed <saeedm@mellanox.com>,
	Hadar Har-Zion <hadarh@mellanox.com>,
	Jiri Pirko <jiri@mellanox.com>
To: Amir Vadai <amir@vadai.me>, Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:36778 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751495AbcCARNl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Mar 2016 12:13:41 -0500
Received: by mail-pa0-f53.google.com with SMTP id yy13so115297440pab.3
        for <netdev@vger.kernel.org>; Tue, 01 Mar 2016 09:13:41 -0800 (PST)
In-Reply-To: <56d5c9bd.c13fc20a.046a.ffffe0ce@mx.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-03-01 09:00 AM, Amir Vadai wrote:
> On Tue, Mar 01, 2016 at 03:52:08PM +0100, Jiri Pirko wrote:
>> Tue, Mar 01, 2016 at 03:24:48PM CET, amir@vadai.me wrote:
>>> Extend ndo_setup_tc() to support ingress tc offloading. Will be used by
>>> later patches to offload tc flower filter.
>>>
>>> Feature is off by default and could be enabled by issuing:
>>> # ethtool  -K eth0 hw-tc-offload on
>>>
>>> Offloads flow table is dynamically created when first filter is
>>> added.
>>> Rules are saved in a hash table that is maintained by the consumer (for
>>> example - the flower offload in the next patch).
>>> When last filter is removed and no filters exist in the hash table, the
>>> offload flow table is destroyed.
>>
>> <snip>	
>> 	
>>> @@ -1880,6 +1883,17 @@ static int mlx5e_setup_tc(struct net_device *netdev, u8 tc)
>>> static int mlx5e_ndo_setup_tc(struct net_device *dev, u32 handle,
>>> 			      __be16 proto, struct tc_to_netdev *tc)
>>> {
>>> +	struct mlx5e_priv *priv = netdev_priv(dev);
>>> +
>>> +	if (TC_H_MAJ(handle) != TC_H_MAJ(TC_H_INGRESS))
>>> +		goto mqprio;
>>> +
>>> +	switch (tc->type) {
>>> +	default:
>>> +		return -EINVAL;
>>
>> -EOPNOTSUPP would be better here perhaps?
>>
>>
>>> +	}
>>> +
>>> +mqprio:
>>> 	if (handle != TC_H_ROOT || tc->type != TC_SETUP_MQPRIO)
>>> 		return -EINVAL;
>>>
>>> @@ -1963,6 +1977,13 @@ static int mlx5e_set_features(struct net_device *netdev,
>>> 			mlx5e_disable_vlan_filter(priv);
>>> 	}
>>>
>>> +	if ((changes & NETIF_F_HW_TC) && !(features & NETIF_F_HW_TC) &&
>>> +	    mlx5e_tc_num_filters(priv)) {
>>> +		netdev_err(netdev,
>>> +			   "Active offloaded tc filters, can't turn hw_tc_offload off\n");
>>> +		return -EINVAL;
>>
>> This should not fail I believe. Just disable it in hw. I would even toss
>> away the rules if necessary.
> It depends on the answer regarding your comment on the previous patch.
> If we have the rule in both SW and HW, and remove it from the HW it is
> ok (although, currently I don't understand why would anyone want in both
> places).
> If the rule is processed by HW only - turning off this flag, will
> disable the offloaded rules - it might be misleading, so I prefered not
> to allow it and print a message.

When we get the HW only mode we will need to also flush the hardware
representation in software as well as the hardware state.
