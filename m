From: Stanislaw Gruszka <sgruszka@redhat.com>
Subject: Re: [v3 Patch 2/2] mlx4: add dynamic LRO disable support
Date: Mon, 21 Jun 2010 11:02:15 +0200
Message-ID: <20100621090214.GB3240@dhcp-lab-161.englab.brq.redhat.com>
References: <20100618105935.6496.4725.sendpatchset@localhost.localdomain> <20100618105945.6496.67648.sendpatchset@localhost.localdomain> <20100618110910.GA4347@dhcp-lab-161.englab.brq.redhat.com> <4C1ECD04.20609@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, nhorman@redhat.com, herbert.xu@redhat.com,
	bhutchings@solarflare.com, Ramkrishna.Vepa@exar.com,
	davem@davemloft.net
To: Cong Wang <amwang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:2732 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756308Ab0FUJDi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 21 Jun 2010 05:03:38 -0400
Content-Disposition: inline
In-Reply-To: <4C1ECD04.20609@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jun 21, 2010 at 10:23:00AM +0800, Cong Wang wrote:
> On 06/18/10 19:09, Stanislaw Gruszka wrote:
>> On Fri, Jun 18, 2010 at 06:55:38AM -0400, Amerigo Wang wrote:
>>> +static int mlx4_ethtool_op_set_flags(struct net_device *dev, u32 data)
>>> +{
>>> +	struct mlx4_en_priv *priv = netdev_priv(dev);
>>> +	struct mlx4_en_dev *mdev = priv->mdev;
>>> +	int rc = 0;
>>> +	int changed = 0;
>>> +
>>> +	if (data&  (ETH_FLAG_NTUPLE | ETH_FLAG_RXHASH))
>>> +		return -EOPNOTSUPP;

As we are here, better would be
	if (data & ~ETH_FLAG_LRO)
		return -EOPNOTSUPP;
code will persist correct when someone add new flags.

>>> +
>>> +	if (data&  ETH_FLAG_LRO) {
>>> +		if (!(dev->features&  NETIF_F_LRO))
>>> +			changed = 1;
>>> +	} else if (dev->features&  NETIF_F_LRO) {
>>> +		changed = 1;
>>> +		mdev->profile.num_lro = 0;
>>
>> Everything fine except that, what for you zero num_lro value?
>>
>> If we set it to zero it will stay zero and we will not create
>> proper number of lro descriptors in mlx4_en_create_rx_ring()
>> (called from mlx4_en_set_ringparam() ->   mlx4_en_alloc_resources())
>> when someone enable LRO again on.
>>
>
> Huh? Isn't ->num_lro which controls LRO of mlx4 driver?

It is, but only in mlx4_en_add() just before register_netdev(),
when we setup default dev->features. Otherwise dev->features
tells if LRO is enabled or disabled.

This realize me, that we should not dev->features |= NETIF_F_LRO
if mdev->profile.num_lro == 0 .

Stanislaw
