From: "Amir Vadai\"" <amir@vadai.me>
Subject: Re: [net-next PATCH 7/7] net: ixgbe: add support for tc_u32 offload
Date: Thu, 4 Feb 2016 14:12:09 +0200
Message-ID: <20160204121209.GA32335@office.Home>
References: <20160203092708.1356.13733.stgit@john-Precision-Tower-5810>
 <20160203092959.1356.91778.stgit@john-Precision-Tower-5810>
 <20160204073050.GA31753@office.Home>
 <56B30A66.80206@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: ogerlitz@mellanox.com, jiri@resnulli.us, jhs@mojatatu.com,
	jeffrey.t.kirsher@intel.com, netdev@vger.kernel.org,
	davem@davemloft.net
To: "Fastabend, John R" <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:35282 "EHLO
	mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750885AbcBDMJK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Feb 2016 07:09:10 -0500
Received: by mail-wm0-f65.google.com with SMTP id g62so139089wme.2
        for <netdev@vger.kernel.org>; Thu, 04 Feb 2016 04:09:09 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <56B30A66.80206@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Feb 04, 2016 at 12:23:02AM -0800, Fastabend, John R wrote:
> On 2/3/2016 11:30 PM, Amir Vadai" wrote:
> > On Wed, Feb 03, 2016 at 01:29:59AM -0800, John Fastabend wrote:
> >> This adds initial support for offloading the u32 tc classifier. This
> >> initial implementation only implements a few base matches and actions
> >> to illustrate the use of the infrastructure patches.
> >>
> >> However it is an interesting subset because it handles the u32 next
> >> hdr logic to correctly map tcp packets from ip headers using the ihl
> >> and protocol fields. After this is accepted we can extend the match
> >> and action fields easily by updating the model header file.
> >>
> >> Also only the drop action is supported initially.
> >>
> >> Here is a short test script,
> >>
> >>  #tc qdisc add dev eth4 ingress
> >>  #tc filter add dev eth4 parent ffff: protocol ip \
> >> 	u32 ht 800: order 1 \
> >> 	match ip dst 15.0.0.1/32 match ip src 15.0.0.2/32 action drop
> >>
> >> <-- hardware has dst/src ip match rule installed -->
> >>
> >>  #tc filter del dev eth4 parent ffff: prio 49152
> >>  #tc filter add dev eth4 parent ffff: protocol ip prio 99 \
> >> 	handle 1: u32 divisor 1
> >>  #tc filter add dev eth4 protocol ip parent ffff: prio 99 \
> >> 	u32 ht 800: order 1 link 1: \
> >> 	offset at 0 mask 0f00 shift 6 plus 0 eat match ip protocol 6 ff
> >>  #tc filter add dev eth4 parent ffff: protocol ip \
> >> 	u32 ht 1: order 3 match tcp src 23 ffff action drop
> >>
> >> <-- hardware has tcp src port rule installed -->
> >>
> >>  #tc qdisc del dev eth4 parent ffff:
> >>
> >> <-- hardware cleaned up -->
> >>
> >> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
> >> ---
> >>  drivers/net/ethernet/intel/ixgbe/ixgbe.h         |    3 
> >>  drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c |    6 -
> >>  drivers/net/ethernet/intel/ixgbe/ixgbe_main.c    |  196 ++++++++++++++++++++++
> >>  3 files changed, 198 insertions(+), 7 deletions(-)
> >>
> >> diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe.h b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
> >> index 4b9156c..09c2d9b 100644
> >> --- a/drivers/net/ethernet/intel/ixgbe/ixgbe.h
> >> +++ b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
> > 
> > [...]
> > 
> >> @@ -8277,6 +8465,7 @@ static int ixgbe_set_features(struct net_device *netdev,
> >>  	 */
> >>  	switch (features & NETIF_F_NTUPLE) {
> >>  	case NETIF_F_NTUPLE:
> >> +	case NETIF_F_HW_TC:
> >>  		/* turn off ATR, enable perfect filters and reset */
> >>  		if (!(adapter->flags & IXGBE_FLAG_FDIR_PERFECT_CAPABLE))
> >>  			need_reset = true;
> > 
> > I think you have a bug here. I don't see how the NETIF_F_HW_TC case will
> > happen after masking 'features' out.
> > 
> 
> Ah I should have annotated this in the commit msg. I turn the feature
> off by default to enable it the user needs to run
> 
> 	# ethtool -K ethx hw-tc-offload on
> 
> this is just a habit of mine to leave new features off by default for
> a bit until I work out some of the kinks. For example I found a case
> today where if you build loops into your u32 graph the hardware tables
> can get out of sync with the software tables. This is sort of extreme
> corner case not sure if anyone would really use u32 but it is valid
> and the hardware should abort correctly.
Yeh - that is nice :) But I was just pointing out on a small typo which I
think you have.
The new case will never happen. You compare: (features & NETIF_F_NTUPLE) == NETIF_F_HW_TC
Also the comment before the switch should be modified.

> 
> Thanks,
> John
> 
