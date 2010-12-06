From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [RFC] mark devices with broken LRO implementation
Date: Mon, 6 Dec 2010 09:58:02 -0800
Message-ID: <20101206095802.2905aea5@nehalam>
References: <4CFD15F6.7040609@linux.vnet.ibm.com>
	<20101206091010.036cd78b@nehalam>
	<20101206171816.GA25568@lixom.net>
	<20101206.092855.193714367.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: olof@lixom.net, leitao@linux.vnet.ibm.com, eli@dev.mellanox.co.il,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>,
	Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:35158 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752806Ab0LFR6G (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 6 Dec 2010 12:58:06 -0500
In-Reply-To: <20101206.092855.193714367.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 06 Dec 2010 09:28:55 -0800 (PST)
David Miller <davem@davemloft.net> wrote:

> From: Olof Johansson <olof@lixom.net>
> Date: Mon, 6 Dec 2010 11:18:16 -0600
> 
> > On Mon, Dec 06, 2010 at 09:10:10AM -0800, Stephen Hemminger wrote:
> >> The kernel uses dev_disable_lro to disable Large Receive Offload
> >> for cases where it is inappropriate. But several drivers do not implement
> >> the required hook.  This is a "penalty box" patch to encourage those
> >> drivers to add support for the necessary ethtool set_flags.
> >> 
> >> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
> > 
> > pasemi_mac:
> > 
> > Acked-by: Olof Johansson <olof@lixom.net>
> > 
> >> I only found three drivers that are broken. Normally, I would just fix
> >> them; but since changing state in the device is hardware specific, and
> >> I don't have the hardware or specs to do anything useful to fix it.
> > 
> > Thanks. All my hardware is currently in storage due to my relocation, but
> > I'll take a look at it when I have something to run on back. :-)
> 
> I don't think we can do what this patch does.
> 
> It serves no purpose, as it just means the user is going to have an
> extra headache to turn their driver on.
> 
> And %99 of them won't see it, the distribution folks will.
> 
> So this is all for nothing.
> 
> Better to just work on fixing the problem in the few drivers for
> which the issue exists.
> 
> And I'm always happy to receive patches that just plain rip LRO
> support out of such drivers.  That's a real legitimate patch unlike
> this one because it keeps the user able to get their driver enabled
> with no fuss and it removes only the improperly functioning feature.

I am less worried about the drivers for embedded devices, the one that
surprises me the mellanox driver.  But it looks like that driver doesn't
really do LRO (only GRO).

Subject: mlx4: remove reference to LRO

This device does not do LRO, the current version does GRO.
This patch removes unused inline and changes the configuration
and comments to reflect that.  Compile tested only.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

---
 drivers/net/Kconfig        |    1 -
 drivers/net/mlx4/en_rx.c   |    6 +++---
 drivers/net/mlx4/mlx4_en.h |   17 -----------------
 3 files changed, 3 insertions(+), 21 deletions(-)

--- a/drivers/net/Kconfig	2010-12-06 09:49:11.210488154 -0800
+++ b/drivers/net/Kconfig	2010-12-06 09:49:45.461406671 -0800
@@ -2859,7 +2859,6 @@ config MLX4_EN
 	tristate "Mellanox Technologies 10Gbit Ethernet support"
 	depends on PCI && INET
 	select MLX4_CORE
-	select INET_LRO
 	help
 	  This driver supports Mellanox Technologies ConnectX Ethernet
 	  devices.
--- a/drivers/net/mlx4/en_rx.c	2010-12-06 09:51:38.316270948 -0800
+++ b/drivers/net/mlx4/en_rx.c	2010-12-06 09:51:55.758024934 -0800
@@ -584,7 +584,7 @@ int mlx4_en_process_rx_cq(struct net_dev
 			if ((cqe->status & cpu_to_be16(MLX4_CQE_STATUS_IPOK)) &&
 			    (cqe->checksum == cpu_to_be16(0xffff))) {
 				priv->port_stats.rx_chksum_good++;
-				/* This packet is eligible for LRO if it is:
+				/* This packet is eligible for GRO if it is:
 				 * - DIX Ethernet (type interpretation)
 				 * - TCP/IP (v4)
 				 * - without IP options
@@ -616,7 +616,7 @@ int mlx4_en_process_rx_cq(struct net_dev
 					goto next;
 				}
 
-				/* LRO not possible, complete processing here */
+				/* GRO not possible, complete processing here */
 				ip_summed = CHECKSUM_UNNECESSARY;
 			} else {
 				ip_summed = CHECKSUM_NONE;
@@ -657,7 +657,7 @@ next:
 		cqe = &cq->buf[index];
 		if (++polled == budget) {
 			/* We are here because we reached the NAPI budget -
-			 * flush only pending LRO sessions */
+			 * flush only pending GRO sessions */
 			goto out;
 		}
 	}
--- a/drivers/net/mlx4/mlx4_en.h	2010-12-06 09:50:40.142348439 -0800
+++ b/drivers/net/mlx4/mlx4_en.h	2010-12-06 09:51:59.470397030 -0800
@@ -83,8 +83,6 @@
 #define MLX4_EN_ALLOC_ORDER	2
 #define MLX4_EN_ALLOC_SIZE	(PAGE_SIZE << MLX4_EN_ALLOC_ORDER)
 
-#define MLX4_EN_MAX_LRO_DESCRIPTORS	32
-
 /* Receive fragment sizes; we use at most 4 fragments (for 9600 byte MTU
  * and 4K allocations) */
 enum {
@@ -268,21 +266,6 @@ struct mlx4_en_rx_ring {
 	unsigned long packets;
 };
 
-
-static inline int mlx4_en_can_lro(__be16 status)
-{
-	return (status & cpu_to_be16(MLX4_CQE_STATUS_IPV4	|
-				     MLX4_CQE_STATUS_IPV4F	|
-				     MLX4_CQE_STATUS_IPV6	|
-				     MLX4_CQE_STATUS_IPV4OPT	|
-				     MLX4_CQE_STATUS_TCP	|
-				     MLX4_CQE_STATUS_UDP	|
-				     MLX4_CQE_STATUS_IPOK)) ==
-		cpu_to_be16(MLX4_CQE_STATUS_IPV4 |
-			    MLX4_CQE_STATUS_IPOK |
-			    MLX4_CQE_STATUS_TCP);
-}
-
 struct mlx4_en_cq {
 	struct mlx4_cq          mcq;
 	struct mlx4_hwq_resources wqres;
