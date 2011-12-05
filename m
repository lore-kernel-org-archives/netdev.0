From: Mark Lord <kernel@teksavvy.com>
Subject: Re: [PATCH] drivers/net/usb/asix:  resync from vendor's copy
Date: Mon, 05 Dec 2011 09:41:44 -0500
Message-ID: <4EDCD828.2090904@teksavvy.com>
References: <4EA89972.5060101@teksavvy.com>  <20111026.194045.2019668159403582571.davem@davemloft.net>  <4EA8B283.3010105@teksavvy.com>  <20111026.221719.2216112919297458522.davem@davemloft.net>  <4EB19BBE.5050602@teksavvy.com> <1320266549.2782.21.camel@bwh-desktop>  <4EBAA967.10403@teksavvy.com> <1320856444.18929.78.camel@deadeye>  <4EBAAEA5.1060408@teksavvy.com> <4EBAB0EA.1050102@teksavvy.com>  <4EBAB643.8020603@teksavvy.com> <1320859911.2781.1.camel@bwh-desktop>  <4EBABAFD.6050604@teksavvy.com> <1320860895.2781.6.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Ben Hutchings <bhutchings@solarflare.com>,
	David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1320860895.2781.6.camel@bwh-desktop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David / Ben / anyone..

I'm trying to puzzle out the rx/tx checksum feature flags,
and there does seem to be a lot of variance among drivers
as to how these are used.

The ASIX chips have hardware support for IP and TCP checksumming
for both IPv4 and IPv6.  So I'm thinking this code (below) is the
most appropriate method for use in asix.c:

------------------------------- asix.h -----------------------------------
...
#define AX_RXCOE_IPCE                   0x0001
#define AX_RXCOE_IPVE                   0x0002
#define AX_RXCOE_V6VE                   0x0004
#define AX_RXCOE_TCPE                   0x0008
#define AX_RXCOE_UDPE                   0x0010
#define AX_RXCOE_ICMP                   0x0020
#define AX_RXCOE_IGMP                   0x0040
#define AX_RXCOE_ICV6                   0x0080
#define AX_RXCOE_TCPV6                  0x0100
#define AX_RXCOE_UDPV6                  0x0200
#define AX_RXCOE_ICMV6                  0x0400
#define AX_RXCOE_IGMV6                  0x0800
#define AX_RXCOE_ICV6V6                 0x1000
#define AX_RXCOE_FOPC                   0x8000
#define AX_RXCOE_DEF_CSUM               (AX_RXCOE_IPCE  | AX_RXCOE_IPVE  | \
                                         AX_RXCOE_V6VE  | AX_RXCOE_TCPE  | \
                                         AX_RXCOE_UDPE  | AX_RXCOE_ICV6  | \
                                         AX_RXCOE_TCPV6 | AX_RXCOE_UDPV6)

#define AX_RXCOE_64TE                   0x0100
#define AX_RXCOE_PPPOE                  0x0200
#define AX_RXCOE_RPCE                   0x8000

#define AX_TXCOE_IP                     0x0001
#define AX_TXCOE_TCP                    0x0002
#define AX_TXCOE_UDP                    0x0004
#define AX_TXCOE_ICMP                   0x0008
#define AX_TXCOE_IGMP                   0x0010
#define AX_TXCOE_ICV6                   0x0020
#define AX_TXCOE_TCPV6                  0x0100
#define AX_TXCOE_UDPV6                  0x0200
#define AX_TXCOE_ICMV6                  0x0400
#define AX_TXCOE_IGMV6                  0x0800
#define AX_TXCOE_ICV6V6                 0x1000
#define AX_TXCOE_DEF_CSUM               (AX_TXCOE_TCP   | AX_TXCOE_UDP | \
                                         AX_TXCOE_TCPV6 | AX_TXCOE_UDPV6)
...
------------------------------- asix.c -----------------------------------

static int ax88772b_set_features(struct net_device *netdev, u32 features)
{
        struct usbnet *dev = netdev_priv(netdev);
        u16 tx_csum = (features & NETIF_F_HW_CSUM) ? AX_TXCOE_DEF_CSUM : 0;
        u16 rx_csum = (features & NETIF_F_RXCSUM ) ? AX_RXCOE_DEF_CSUM : 0;

        ax8817x_write_cmd(dev, AX_CMD_WRITE_TXCOE_CTL, tx_csum, 0, 0, NULL);
        ax8817x_write_cmd(dev, AX_CMD_WRITE_RXCOE_CTL, rx_csum, 0, 0, NULL);
        return 0;
}
...

static int ax88772b_bind(struct usbnet *dev, struct usb_interface *intf)
{
...
        /* register support for hardware checksums */
        dev->net->hw_features |= NETIF_F_HW_CSUM | NETIF_F_RXCSUM;

        /* enable hardware checksums */
        dev->net->features |= NETIF_F_HW_CSUM | NETIF_F_RXCSUM;
        ax88772b_set_features(dev->net, dev->net->features);
...
}
-------------------------------snip-----------------------------------

Does this look correct -- any improvements/fixes to suggest?
I am still trying to find out about all of the other possible hardware bits,
but the AX_TXCOE_DEF_CSUM and AX_RXCOE_DEF_CSUM patterns are the ones
that Asix themselves were using in the vendor driver.

Thanks.
