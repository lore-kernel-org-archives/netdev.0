From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] net: dsa: avoid null pointer dereference on p->phy
Date: Sat, 23 Sep 2017 10:13:06 -0700
Message-ID: <1506186786.11186.1.camel@perches.com>
References: <20170923165720.18560-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 8bit
Cc: kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org
To: Colin King <colin.king@canonical.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        Florian Fainelli <f.fainelli@gmail.com>,
        "David S . Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <kernel-janitors-owner@vger.kernel.org>
In-Reply-To: <20170923165720.18560-1-colin.king@canonical.com>
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 2017-09-23 at 17:57 +0100, Colin King wrote:
> From: Colin Ian King <colin.king@canonical.com>
> 
> Currently p->phy is being null checked in several places to avoid
> null pointer dereferences on p->phy, however, the final call
> to phy_attached_info on p->phy when p->phy will perform a null
> pointer dereference. Fix this by simply moving the call into
> the previous code block that is only executed if p->phy is
> not null.
> 
> Detected by CoverityScan, CID#1457034 ("Dereference after null check")
> 
> Fixes: 2220943a21e2 ("phy: Centralise print about attached phy")
> Signed-off-by: Colin Ian King <colin.king@canonical.com>
> ---
>  net/dsa/slave.c | 3 +--
>  1 file changed, 1 insertion(+), 2 deletions(-)
> 
> diff --git a/net/dsa/slave.c b/net/dsa/slave.c
> index 02ace7d462c4..29ab4e98639b 100644
> --- a/net/dsa/slave.c
> +++ b/net/dsa/slave.c
> @@ -1115,10 +1115,9 @@ static int dsa_slave_phy_setup(struct net_device *slave_dev)
>  				of_phy_deregister_fixed_link(port_dn);
>  			return ret;
>  		}
> +		phy_attached_info(p->phy);
>  	}
>  
> -	phy_attached_info(p->phy);
> -
>  	return 0;
>  }

Huh?  Why move this into the test?

The test of the block above this change is

	if (!p->phy) {

Perhaps this should be
'
	if (p->phy)
		phy_attached_info(p->phy);

or simpler

	} else {
		phy_attached_info(p->phy);
	}

or maybe reverse the block

	if (p->phy) {
		phy_attached_info(p->phy);
	} else {
		ret = dsa_slave_phy_connect(slave_dev, p->dp->index);
		if (ret) {
			netdev_err(slave_dev, "failed to connect to port %d: %d\n",
				   p->dp->index, ret);
			if (phy_is_fixed)
				of_phy_deregister_fixed_link(port_dn);
			return ret;
		}
	}

	return 0;
}
