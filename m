From: Mark Lord <kernel@teksavvy.com>
Subject: Re: [PATCH] drivers/net/usb/asix:  resync from vendor's copy
Date: Wed, 09 Nov 2011 11:57:14 -0500
Message-ID: <4EBAB0EA.1050102@teksavvy.com>
References: <4EA89972.5060101@teksavvy.com>   <20111026.194045.2019668159403582571.davem@davemloft.net>   <4EA8B283.3010105@teksavvy.com>   <20111026.221719.2216112919297458522.davem@davemloft.net>   <4EB19BBE.5050602@teksavvy.com> <1320266549.2782.21.camel@bwh-desktop>  <4EBAA967.10403@teksavvy.com> <1320856444.18929.78.camel@deadeye> <4EBAAEA5.1060408@teksavvy.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4EBAAEA5.1060408@teksavvy.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 11-11-09 11:47 AM, Mark Lord wrote:
..
> Note:  I'm looking at smsc95xx.c and smsc75xx.c for examples,
> and they both have the same problem I'll have here:
> 
> How to update the csum settings atomically.
> A spinlock is no good, because config register access is over USB.

Nevermind.. a slight change in the logic and all is well again.

static int ax88772b_set_features(struct net_device *netdev, u32 features)
{
        struct usbnet *dev = netdev_priv(netdev);
        struct ax88772b_data *priv = (struct ax88772b_data *)dev->driver_priv;
        unsigned long flags;
        u16 tx_csum = 0, rx_csum = 0;

        spin_lock_irqsave(&priv->features_lock, flags);
        if (features & NETIF_F_HW_CSUM) {
                priv->checksum |= AX_TX_CHECKSUM;
                tx_csum = AX_TXCOE_DEF_CSUM;
        } else
                priv->checksum &= ~AX_TX_CHECKSUM;
        if (features & NETIF_F_RXCSUM) {
                priv->checksum |= AX_RX_CHECKSUM;
                rx_csum = AX_RXCOE_DEF_CSUM;
        } else
                priv->checksum &= ~AX_RX_CHECKSUM;
        spin_unlock_irqrestore(&priv->features_lock, flags);

        ax8817x_write_cmd(dev, AX_CMD_WRITE_RXCOE_CTL,
                                 rx_csum, 0, 0, NULL);
        ax8817x_write_cmd(dev, AX_CMD_WRITE_TXCOE_CTL,
                                 tx_csum, 0, 0, NULL);
        return 0;
}
