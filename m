From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH] net: orphan queued skbs if device tx can stall
Date: Thu, 12 Apr 2012 00:52:12 +0300
Message-ID: <20120411215212.GA27550@redhat.com>
References: <20120408171323.GA16012@redhat.com>
 <1334044558.3126.5.camel@edumazet-glaptop>
 <20120410084151.GA27193@redhat.com>
 <1334048100.3126.21.camel@edumazet-glaptop>
 <20120410093140.GA27651@redhat.com>
 <1334052259.3126.68.camel@edumazet-glaptop>
 <20120410112459.GA28825@redhat.com>
 <1334058300.3126.99.camel@edumazet-glaptop>
 <20120410124151.GA29808@redhat.com>
 <1334065929.5300.40.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Jamal Hadi Salim <hadi@cyberus.ca>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Jason Wang <jasowang@redhat.com>,
	Neil Horman <nhorman@tuxdriver.com>,
	Jiri Pirko <jpirko@redhat.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	=?utf-8?B?TWljaGHFgiBNaXJvc8WCYXc=?= <mirq-linux@rere.qmqm.pl>,
	Ben Hutchings <bhutchings@solarflare.com>,
	Herbert Xu <herbert@gondor.hengli.com.au>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1334065929.5300.40.camel@edumazet-glaptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Apr 10, 2012 at 03:52:09PM +0200, Eric Dumazet wrote:
> On Tue, 2012-04-10 at 15:41 +0300, Michael S. Tsirkin wrote:
> 
> > I think it's a bad interface too but it's in a userspace ABI
> > now so I suspect we are stuck with it for now. We can try deprecating
> > but we can't just drop it.
> > 
> 
> By the way, skb orphaning should already be done in skb_orphan_try(),
> not sure why its done again in tun_net_xmit(). Note we perform orphaning
> right before giving skb to device on premise it'll be sent (and freed)
> in a reasonable amount of time.
> 
> 
> With following patch, no more qdisc on top of tun device, yet user can
> change the limit (I would be curious to know if anybody changes tun
> txqueuelen and why)

Following would makes the default visible with SIOCGIFTXQLEN
same as it was + avoid branch on data path.
Didn't have time to test yet - it should achieve
same purpose, shouldn't it?
Or do I misunderstand how it's designed to work?

diff --git a/drivers/net/tun.c b/drivers/net/tun.c
index bb8c72c..418abd1 100644
--- a/drivers/net/tun.c
+++ b/drivers/net/tun.c
@@ -521,7 +521,6 @@ static void tun_net_init(struct net_device *dev)
 		/* Zero header length */
 		dev->type = ARPHRD_NONE;
 		dev->flags = IFF_POINTOPOINT | IFF_NOARP | IFF_MULTICAST;
-		dev->tx_queue_len = TUN_READQ_SIZE;  /* We prefer our own queue length */
 		break;
 
 	case TUN_TAP_DEV:
@@ -531,10 +530,9 @@ static void tun_net_init(struct net_device *dev)
 		dev->priv_flags &= ~IFF_TX_SKB_SHARING;
 
 		eth_hw_addr_random(dev);
-
-		dev->tx_queue_len = TUN_READQ_SIZE;  /* We prefer our own queue length */
 		break;
 	}
+	dev->tx_queue_len = 0;  /* Disable qdisc queueing */
 }
 
 /* Character device part */
@@ -1143,6 +1141,12 @@ static int tun_set_iff(struct net *net, struct file *file, struct ifreq *ifr)
 		if (err < 0)
 			goto err_free_sk;
 
+		/*
+		 * We (ab)use queue length to limit our amount of buffering.
+		 * Set our own default queue length.
+		 */
+		dev->tx_queue_len = TUN_READQ_SIZE;
+
 		if (device_create_file(&tun->dev->dev, &dev_attr_tun_flags) ||
 		    device_create_file(&tun->dev->dev, &dev_attr_owner) ||
 		    device_create_file(&tun->dev->dev, &dev_attr_group))
