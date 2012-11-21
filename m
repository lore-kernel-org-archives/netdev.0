From: "Bandi,Sarveshwar" <Sarveshwar.Bandi@Emulex.Com>
Subject: RE: [PATCH net-2.6] bonding: Bonding driver does not consider the
 gso_max_size setting of slaves.
Date: Wed, 21 Nov 2012 12:03:29 +0000
Message-ID: <9D1F9FE58F08ED47AA451ABB038550E90A8AF3EC@CMEXMB1.ad.emulex.com>
References: <8814d83f-7213-4a32-91ec-39088a1a60a6@CMEXHTCAS1.ad.emulex.com>
 <20121121115601.GA5579@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge2.ext.emulex.com ([138.239.224.100]:4002 "EHLO
	CMEXEDGE2.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754587Ab2KUMDa convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Nov 2012 07:03:30 -0500
In-Reply-To: <20121121115601.GA5579@hmsreliant.think-freely.org>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Understood. Will respin the patch.

-----Original Message-----
From: Neil Horman [mailto:nhorman@tuxdriver.com] 
Sent: Wednesday, November 21, 2012 5:26 PM
To: Bandi,Sarveshwar
Cc: davem@davemloft.net; netdev@vger.kernel.org
Subject: Re: [PATCH net-2.6] bonding: Bonding driver does not consider the gso_max_size setting of slaves.

On Wed, Nov 21, 2012 at 04:48:56PM +0530, sarveshwar.bandi@emulex.com wrote:
> From: Sarveshwar Bandi <sarveshwar.bandi@emulex.com>
> 
> Patch sets the lowest non-zero gso_max_size value of the slaves during 
> enslave and detach.
> 
> Signed-off-by: Sarveshwar Bandi <sarveshwar.bandi@emulex.com>
> ---
>  drivers/net/bonding/bond_main.c |   27 +++++++++++++++++++++++++++
>  1 file changed, 27 insertions(+)
> 
> diff --git a/drivers/net/bonding/bond_main.c 
> b/drivers/net/bonding/bond_main.c index b2530b0..5f19d16 100644
> --- a/drivers/net/bonding/bond_main.c
> +++ b/drivers/net/bonding/bond_main.c
> @@ -1198,6 +1198,31 @@ static void bond_attach_slave(struct bonding *bond, struct slave *new_slave)
>  	bond->slave_cnt++;
>  }
>  
> +static void bond_set_gso_max_size(struct bonding *bond) {
> +	struct slave *slave;
> +	struct net_device *bond_dev = bond->dev;
> +	unsigned int gso_max_size = 0;
> +	bool reset_gso_size = true;
> +	int i;
> +
> +	bond_for_each_slave(bond, slave, i) {
> +		if (!slave->dev->gso_max_size)
> +			continue;
> +
> +		reset_gso_size = false;
> +
> +		if (!gso_max_size ||
> +		    slave->dev->gso_max_size < gso_max_size)
> +			gso_max_size = slave->dev->gso_max_size;
> +	}
> +
> +	if (gso_max_size && gso_max_size < bond_dev->gso_max_size)
> +		netif_set_gso_max_size(bond_dev, gso_max_size);
> +	else if (reset_gso_size)
> +		netif_set_gso_max_size(bond_dev, 0); }
> +
This seems a bit overly complex.  It doesn't seem like you need the reset_go_size bool in here at all.  Just initalize gso_max_size to GSO_MAX_SIZE and reduce it every time you find a smaller gso value on a slave.  Then you can unilaterally set the bond devices gso_max_size without having to check any bools or do any comparisons.

Regards
Neil
