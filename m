From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH RFC 1/2] tun: don't require serialization lock on tx
Date: Wed, 13 Apr 2016 15:57:37 +0300
Message-ID: <20160413155654-mutt-send-email-mst@redhat.com>
References: <cover.1460393493.git.pabeni@redhat.com>
 <425e8f69ffd8fe315ef9d3cc678519c7060fb2e0.1460393493.git.pabeni@redhat.com>
 <20160413123828-mutt-send-email-mst@redhat.com>
 <570E15D9.4000308@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Paolo Abeni <pabeni@redhat.com>, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Greg Kurz <gkurz@linux.vnet.ibm.com>,
	Jason Wang <jasowang@redhat.com>,
	Christian Borntraeger <borntraeger@de.ibm.com>,
	Herbert Xu <herbert@gondor.apana.org.au>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:50672 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757586AbcDMM5m (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Apr 2016 08:57:42 -0400
Content-Disposition: inline
In-Reply-To: <570E15D9.4000308@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 13, 2016 at 11:48:09AM +0200, Hannes Frederic Sowa wrote:
> On 13.04.2016 11:41, Michael S. Tsirkin wrote:
> >On Wed, Apr 13, 2016 at 11:04:46AM +0200, Paolo Abeni wrote:
> >>The current tun_net_xmit() implementation don't need any external
> >>lock since it relay on rcu protection for the tun data structure
> >>and on socket queue lock for skb queuing.
> >>
> >>This patch set the NETIF_F_LLTX feature bit in the tun device, so
> >>that on xmit, in absence of qdisc, no serialization lock is acquired
> >>by the caller.
> >>
> >>Signed-off-by: Paolo Abeni <pabeni@redhat.com>
> >>---
> >>  drivers/net/tun.c | 2 +-
> >>  1 file changed, 1 insertion(+), 1 deletion(-)
> >>
> >>diff --git a/drivers/net/tun.c b/drivers/net/tun.c
> >>index faf9297..42992dc 100644
> >>--- a/drivers/net/tun.c
> >>+++ b/drivers/net/tun.c
> >>@@ -1796,7 +1796,7 @@ static int tun_set_iff(struct net *net, struct file *file, struct ifreq *ifr)
> >>  		dev->hw_features = NETIF_F_SG | NETIF_F_FRAGLIST |
> >>  				   TUN_USER_FEATURES | NETIF_F_HW_VLAN_CTAG_TX |
> >>  				   NETIF_F_HW_VLAN_STAG_TX;
> >>-		dev->features = dev->hw_features;
> >>+		dev->features = dev->hw_features | NETIF_F_LLTX;
> >
> >the documentation says:
> >         NETIF_F_LLTX_BIT,               /* LockLess TX - deprecated.  Please */
> >                                         /* do not use LLTX in new drivers */
> 
> In networking/netdev-features.txt
> 
>  * LLTX driver (deprecated for hardware drivers)
> 
> NETIF_F_LLTX should be set in drivers that implement their own locking in
> transmit path or don't need locking at all (e.g. software tunnels).
> In ndo_start_xmit, it is recommended to use a try_lock and return
> NETDEV_TX_LOCKED when the spin lock fails.  The locking should also properly
> protect against other callbacks (the rules you need to find out).
> 
> Don't use it for new drivers.
> 
> I think this is documentation is correct and it is only deprecated for
> hardware drivers.
> 
> Bye,
> Hannes

Fine, but what's the AF_PACKET duplication that Herbert Xu
reported with NETIF_F_LLTX? Does anyone remember?

-- 
MST
