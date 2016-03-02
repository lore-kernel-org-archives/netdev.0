From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next 6/8] net/mlx5e: Introduce tc offload support
Date: Wed, 2 Mar 2016 16:58:45 +0100
Message-ID: <20160302155845.GD2122@nanopsycho.orion>
References: <1456842290-7844-1-git-send-email-amir@vadai.me>
 <1456842290-7844-7-git-send-email-amir@vadai.me>
 <20160301145208.GB2098@nanopsycho.orion>
 <56d5c9bd.c13fc20a.046a.ffffe0ce@mx.google.com>
 <56D5CDB5.4090906@gmail.com>
 <56d70b87.49f9c20a.c7eb3.ffff9f05@mx.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: John Fastabend <john.fastabend@gmail.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Or Gerlitz <ogerlitz@mellanox.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	Saeed Mahameed <saeedm@mellanox.com>,
	Hadar Har-Zion <hadarh@mellanox.com>,
	Jiri Pirko <jiri@mellanox.com>
To: Amir Vadai <amir@vadai.me>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:35724 "EHLO
	mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754832AbcCBP6s (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Mar 2016 10:58:48 -0500
Received: by mail-wm0-f67.google.com with SMTP id 1so10377216wmg.2
        for <netdev@vger.kernel.org>; Wed, 02 Mar 2016 07:58:47 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <56d70b87.49f9c20a.c7eb3.ffff9f05@mx.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wed, Mar 02, 2016 at 04:53:37PM CET, amir@vadai.me wrote:
>On Tue, Mar 01, 2016 at 09:13:25AM -0800, John Fastabend wrote:
>> On 16-03-01 09:00 AM, Amir Vadai wrote:
>> > On Tue, Mar 01, 2016 at 03:52:08PM +0100, Jiri Pirko wrote:
>> >> Tue, Mar 01, 2016 at 03:24:48PM CET, amir@vadai.me wrote:
>> >>> Extend ndo_setup_tc() to support ingress tc offloading. Will be used by
>> >>> later patches to offload tc flower filter.
>> >>>
>> >>> Feature is off by default and could be enabled by issuing:
>> >>> # ethtool  -K eth0 hw-tc-offload on
>> >>>
>> >>> Offloads flow table is dynamically created when first filter is
>> >>> added.
>> >>> Rules are saved in a hash table that is maintained by the consumer (for
>> >>> example - the flower offload in the next patch).
>> >>> When last filter is removed and no filters exist in the hash table, the
>> >>> offload flow table is destroyed.
>> >>
>> >> <snip>	
>> >> 	
>> >>> @@ -1880,6 +1883,17 @@ static int mlx5e_setup_tc(struct net_device *netdev, u8 tc)
>> >>> static int mlx5e_ndo_setup_tc(struct net_device *dev, u32 handle,
>> >>> 			      __be16 proto, struct tc_to_netdev *tc)
>> >>> {
>> >>> +	struct mlx5e_priv *priv = netdev_priv(dev);
>> >>> +
>> >>> +	if (TC_H_MAJ(handle) != TC_H_MAJ(TC_H_INGRESS))
>> >>> +		goto mqprio;
>> >>> +
>> >>> +	switch (tc->type) {
>> >>> +	default:
>> >>> +		return -EINVAL;
>> >>
>> >> -EOPNOTSUPP would be better here perhaps?
>> >>
>> >>
>> >>> +	}
>> >>> +
>> >>> +mqprio:
>> >>> 	if (handle != TC_H_ROOT || tc->type != TC_SETUP_MQPRIO)
>> >>> 		return -EINVAL;
>> >>>
>> >>> @@ -1963,6 +1977,13 @@ static int mlx5e_set_features(struct net_device *netdev,
>> >>> 			mlx5e_disable_vlan_filter(priv);
>> >>> 	}
>> >>>
>> >>> +	if ((changes & NETIF_F_HW_TC) && !(features & NETIF_F_HW_TC) &&
>> >>> +	    mlx5e_tc_num_filters(priv)) {
>> >>> +		netdev_err(netdev,
>> >>> +			   "Active offloaded tc filters, can't turn hw_tc_offload off\n");
>> >>> +		return -EINVAL;
>> >>
>> >> This should not fail I believe. Just disable it in hw. I would even toss
>> >> away the rules if necessary.
>> > It depends on the answer regarding your comment on the previous patch.
>> > If we have the rule in both SW and HW, and remove it from the HW it is
>> > ok (although, currently I don't understand why would anyone want in both
>> > places).
>> > If the rule is processed by HW only - turning off this flag, will
>> > disable the offloaded rules - it might be misleading, so I prefered not
>> > to allow it and print a message.
>> 
>> When we get the HW only mode we will need to also flush the hardware
>> representation in software as well as the hardware state.
>
>Yep, I do think that just failing the operation is the best appraoch.
>Will make the design simpler, and from the user point of view, less
>surprises.
>
>Jiri?

I don't feel it is ok, but at the same time, it is probably the best
solution for now. Other solutions would be too complicated.
