From: Fabio Estevam <festevam@gmail.com>
Subject: fec_main: context imbalance in 'fec_set_features'
Date: Wed, 1 Oct 2014 21:15:53 -0300
Message-ID: <CAOMZO5CJKp7+d8EPRZdr-3Bd9UxVU8fxLybFZ4uLn+cUQjPH8w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	linux-sparse@vger.kernel.org
To: Frank Li <Frank.Li@freescale.com>,
	Duan Fugang-B38611 <B38611@freescale.com>
Return-path: <linux-sparse-owner@vger.kernel.org>
Sender: linux-sparse-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

sparse complains the following:

drivers/net/ethernet/freescale/fec_main.c:2835:12: warning: context
imbalance in 'fec_set_features' - different lock contexts for basic
block

The code looks like this:

static int fec_set_features(struct net_device *netdev,
    netdev_features_t features)
{
    struct fec_enet_private *fep = netdev_priv(netdev);
    netdev_features_t changed = features ^ netdev->features;

    /* Quiesce the device if necessary */
    if (netif_running(netdev) && changed & FEATURES_NEED_QUIESCE) {
        napi_disable(&fep->napi);
        netif_tx_lock_bh(netdev);
        fec_stop(netdev);
    }

    netdev->features = features;

    /* Receive checksum has been changed */
    if (changed & NETIF_F_RXCSUM) {
        if (features & NETIF_F_RXCSUM)
            fep->csum_flags |= FLAG_RX_CSUM_ENABLED;
        else
            fep->csum_flags &= ~FLAG_RX_CSUM_ENABLED;
    }

    /* Resume the device after updates */
    if (netif_running(netdev) && changed & FEATURES_NEED_QUIESCE) {
        fec_restart(netdev);
        netif_tx_wake_all_queues(netdev);
        netif_tx_unlock_bh(netdev);
        napi_enable(&fep->napi);
    }

    return 0;
}

What would be the proper way to fix this warning?

Thanks,

Fabio Estevam
