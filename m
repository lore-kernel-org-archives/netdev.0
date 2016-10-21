From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net] net: remove MTU limits on a few ether_setup callers
Date: Thu, 20 Oct 2016 20:42:46 -0700
Message-ID: <ebcdfc7f-5d91-c64f-19f4-99f58614caae@gmail.com>
References: <20161021032527.12954-1-jarod@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org,
        Asbjoern Sloth Toennesen <asbjorn@asbjorn.st>,
        R Parameswaran <parameswaran.r7@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: Jarod Wilson <jarod@redhat.com>, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161021032527.12954-1-jarod@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le 20/10/2016 à 20:25, Jarod Wilson a écrit :
> These few drivers call ether_setup(), but have no ndo_change_mtu, and thus
> were overlooked for changes to MTU range checking behavior. They
> previously had no range checks, so for feature-parity, set their min_mtu
> to 0 and max_mtu to ETH_MAX_MTU (65535), instead of the 68 and 1500
> inherited from the ether_setup() changes. Fine-tuning can come after we get
> back to full feature-parity here.
> 
> CC: netdev@vger.kernel.org
> Reported-by: Asbjoern Sloth Toennesen <asbjorn@asbjorn.st>
> CC: Asbjoern Sloth Toennesen <asbjorn@asbjorn.st>
> CC: R Parameswaran <parameswaran.r7@gmail.com>
> Signed-off-by: Jarod Wilson <jarod@redhat.com>
> ---

> diff --git a/net/dsa/slave.c b/net/dsa/slave.c
> index 68714a5..d0c7bce 100644
> --- a/net/dsa/slave.c
> +++ b/net/dsa/slave.c
> @@ -1247,6 +1247,8 @@ int dsa_slave_create(struct dsa_switch *ds, struct device *parent,
>  	slave_dev->priv_flags |= IFF_NO_QUEUE;
>  	slave_dev->netdev_ops = &dsa_slave_netdev_ops;
>  	slave_dev->switchdev_ops = &dsa_slave_switchdev_ops;
> +	slave_dev->min_mtu = 0;
> +	slave_dev->max_mtu = ETH_MAX_MTU;
>  	SET_NETDEV_DEVTYPE(slave_dev, &dsa_type);

Actually for DSA, a reasonable minimum is probably 68 for the following
reasons: ETH_ZLEN of 60 bytes + FCS (4 bytes) + 2/4/8 bytes of Ethernet
switch tag (which is dependent on the tagging protocol used). Such an
Ethernet interface would submit packets through the conduit interface
which is connected to an Ethernet switches, and those typically discard
packets smaller than 64 bytes +/- their custom tag length.

One driver for sure pads the packets to the appropriate length:
bcmsysport, but I don't know about e1000e or e.g: mv643xx_eth which are
also commonly used for the same purposes.
-- 
Florian
