From: Ian Campbell <Ian.Campbell@eu.citrix.com>
Subject: Re: [GIT/PATCH v3] xen network backend driver
Date: Tue, 1 Mar 2011 13:38:44 +0000
Message-ID: <1298986724.17907.135.camel@zakaz.uk.xensource.com>
References: <1298914061.5034.996.camel@zakaz.uk.xensource.com>
	 <1298919198.2569.14.camel@bwh-desktop>
	 <1298974009.5034.2029.camel@zakaz.uk.xensource.com>
	 <1298982526.3437.5.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	xen-devel <xen-devel@lists.xensource.com>,
	Jeremy Fitzhardinge <jeremy@goop.org>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
	Francois Romieu <romieu@fr.zoreil.com>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:34991 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752709Ab1CANis (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Mar 2011 08:38:48 -0500
In-Reply-To: <1298982526.3437.5.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2011-03-01 at 12:28 +0000, Ben Hutchings wrote:
> On Tue, 2011-03-01 at 10:06 +0000, Ian Campbell wrote:
> > On Mon, 2011-02-28 at 18:53 +0000, Ben Hutchings wrote:
> > > On Mon, 2011-02-28 at 17:27 +0000, Ian Campbell wrote:
> > 
> > > This should be defined as unsigned long (ideally it would be u64, but
> > > that can't be updated atomically on 32-bit systems).
> > [...]
> > > Don't update last_rx; it's only needed on slave devices of a bond, and
> > > the bonding driver takes care of it now.
> > 
> > I made these two changes.
> > 
> > > [...]
> > > > +static int xenvif_change_mtu(struct net_device *dev, int mtu)
> > > > +{
> > > > +	struct xenvif *vif = netdev_priv(dev);
> > > > +	int max = vif->can_sg ? 65535 - ETH_HLEN : ETH_DATA_LEN;
> > > > +	if (mtu > max)
> > > > +		return -EINVAL;
> > > > +	dev->mtu = mtu;
> > > > +	return 0;
> > > > +}
> > > [...]
> > > 
> > > Since any VLAN tag must be inserted inline, shouldn't the MTU limit be
> > > 65535 - VLAN_ETH_HLEN?
> > 
> > In that case shouldn't the other case also be ETH_FRAME_LEN -
> > VLAN_ETH_HLEN?
> [...]
> 
> IEEE 802.3, in its infinite wisdom, says that the maximum frame length
> is 1514, except that when an 802.1q tag is present it is 1518.  So the
> MTU for standard Ethernet remains 1500, regardless of the use of VLANs.

Super ;-)

I've made that change too and repushed the branch with all 3 of your
suggestions. The incremental patch is below.

The following changes since commit 2e820f58f7ad8eaca2f194ccdfea0de63e9c6d78:
  Ian Campbell (1):
        xen/irq: implement bind_interdomain_evtchn_to_irqhandler for backend drivers

are available in the git repository at:

  git://xenbits.xen.org/people/ianc/linux-2.6.git upstream/dom0/backend/netback

Bastian Blank (1):
      xen: netback: Fix null-pointer access in netback_uevent

Christophe Saout (1):
      xen: netback: use dev_name() instead of removed ->bus_id.

Dongxiao Xu (5):
      xen: netback: Move global/static variables into struct xen_netbk.
      xen: netback: Introduce a new struct type page_ext.
      xen: netback: Multiple tasklets support.
      xen: netback: Use Kernel thread to replace the tasklet.
      xen: netback: Set allocated memory to zero from vmalloc.

Ian Campbell (61):
      xen: netback: Initial import of linux-2.6.18-xen.hg netback driver.
      xen: netback: first cut at porting to upstream and cleaning up
      xen: netback: add ethtool stat to track copied skbs.
      xen: netback: make queue length parameter writeable in sysfs
      xen: netback: parent sysfs device should be set before registering.
      xen: rename netbk module xen-netback.
      xen: netback: remove unused xen_network_done code
      xen: netback: factor disconnect from backend into new function.
      xen: netback: wait for hotplug scripts to complete before signalling connected to frontend
      xen: netback: Always pull through PKT_PROT_LEN bytes into the linear part of an skb.
      xen: netback: Allow setting of large MTU before rings have connected.
      xen: netback: correctly setup skb->ip_summed on receive
      xen: netback: handle NET_SKBUFF_DATA_USES_OFFSET correctly
      xen: netback: drop frag member from struct netbk_rx_meta
      xen: netback: linearise SKBs as we copy them into guest memory on guest-RX.
      xen: netback: drop more relics of flipping mode
      xen: netback: check if foreign pages are actually netback-created foreign pages.
      xen: netback: do not unleash netback threads until initialisation is complete
      xen: netback: save interrupt state in add_to_net_schedule_list_tail
      xen: netback: increase size of rx_meta array.
      xen: netback: take net_schedule_list_lock when removing entry from net_schedule_list
      xen: netback: Drop GSO SKBs which do not have csum_blank.
      xen: netback: completely remove tx_queue_timer
      Revert "xen: netback: Drop GSO SKBs which do not have csum_blank."
      xen: netback: handle incoming GSO SKBs which are not CHECKSUM_PARTIAL
      xen: netback: rationalise types used in count_skb_slots
      xen: netback: refactor logic for moving to a new receive buffer.
      xen: netback: refactor code to get next rx buffer into own function.
      xen: netback: simplify use of netbk_add_frag_responses
      xen: netback: cleanup coding style
      xen: netback: drop private ?PRINTK macros in favour of pr_*
      xen: netback: move under drivers/net/xen-netback/
      xen: netback: remove queue_length module option
      xen: netback: correct error return from ethtool hooks.
      xen: netback: avoid leading _ in function parameter names.
      xen: netback: drop unused debug interrupt handler.
      xen: netif: properly namespace the Xen netif protocol header.
      xen: netif: improve Kconfig help text for front- and backend drivers.
      xen: netback: drop ethtool drvinfo callback
      xen: netback: use xen_netbk prefix where appropriate
      xen: netback: refactor to make all xen_netbk knowledge internal to netback.c
      xen: netback: use xenvif_ prefix where appropriate
      xen: netback: add reference from xenvif to xen_netbk
      xen: netback: refactor to separate network device from worker pools
      xen: netback: switch to kthread mode and drop tasklet mode
      xen: netback: handle frames whose head crosses a page boundary
      xen: netback: return correct values from start_xmit
      xen: netback: remove useless memset to zero.
      xen: netback: use register_netdev()
      xen: netback: simplify unwinding netback_init's work on failure.
      xen: netback: use core network carrier flag.
      xen: netback: s/xenvif_queue_full/xenvif_rx_queue_full/
      xen: netback: add xenvif_rx_schedulable
      xen: netback: further separate xen_netbk and xenvif
      xen: netback: use netdev_LEVEL instead of pr_LEVEL
      xen: netback: drop rx_notify and notify_list array in favour of a normal list
      xen: netback: Make dependency on PageForeign conditional
      xen: netback: completely drop foreign page support
      xen: netback: ethtool stats fields should be unsigned long
      xen: netback: do not update last_rx on receive.
      xen: netback: Allow headroom for VLAN header in SG MTU calculation.

James Harper (1):
      xen: netback: avoid null-pointer access in netback_uevent

Jan Beulich (1):
      xen: netback: unmap tx ring gref when mapping of rx ring gref failed

Jeremy Fitzhardinge (21):
      xen: netback: don't include xen/evtchn.h
      xen: netback: use mod_timer
      xen: netback: use NET_SKB_PAD rather than "16"
      xen: netback: completely drop flip support
      xen: netback: demacro MASK_PEND_IDX
      xen: netback: convert PEND_RING_IDX into a proper typedef name
      xen: netback: rename NR_PENDING_REQS to nr_pending_reqs()
      xen: netback: pre-initialize list and spinlocks; use empty list to indicate not on list
      xen: netback: remove CONFIG_XEN_NETDEV_PIPELINED_TRANSMITTER
      xen: netback: make netif_get/put inlines
      xen: netback: move code around
      xen: netback: document PKT_PROT_LEN
      xen: netback: convert to net_device_ops
      xen: netback: reinstate missing code
      xen: netback: remove debug noise
      xen: netback: don't screw around with packet gso state
      xen: netback: use dev_get/set_drvdata() inteface
      xen: netback: include linux/sched.h for TASK_* definitions
      xen: netback: use get_sset_count rather than obsolete get_stats_count
      xen: netback: minor code formatting fixup
      xen: netback: only initialize for PV domains

Keir Fraser (1):
      xen: netback: Fixes for delayed copy of tx network packets.

Konrad Rzeszutek Wilk (1):
      Fix compile warnings: ignoring return value of 'xenbus_register_backend' ..

Paul Durrant (8):
      xen: netback: Fix basic indentation issue
      xen: netback: Add a new style of passing GSO packets to frontends.
      xen: netback: Make frontend features distinct from netback feature flags.
      xen: netback: Re-define PKT_PROT_LEN to be bigger.
      xen: netback: Don't count packets we don't actually receive.
      xen: netback: Remove the 500ms timeout to restart the netif queue.
      xen: netback: Add a missing test to tx_work_todo.
      xen: netback: Re-factor net_tx_action_dealloc() slightly.

Steven Smith (2):
      xen: netback: make sure that pg->mapping is never NULL for a page mapped from a foreign domain.
      xen: netback: try to pull a minimum of 72 bytes into the skb data area

 drivers/net/Kconfig                 |   38 +-
 drivers/net/Makefile                |    1 +
 drivers/net/xen-netback/Makefile    |    3 +
 drivers/net/xen-netback/common.h    |  162 ++++
 drivers/net/xen-netback/interface.c |  424 +++++++++
 drivers/net/xen-netback/netback.c   | 1745 +++++++++++++++++++++++++++++++++++
 drivers/net/xen-netback/xenbus.c    |  490 ++++++++++
 drivers/net/xen-netfront.c          |   20 +-
 include/xen/interface/io/netif.h    |   80 +-
 9 files changed, 2909 insertions(+), 54 deletions(-)
 create mode 100644 drivers/net/xen-netback/Makefile
 create mode 100644 drivers/net/xen-netback/common.h
 create mode 100644 drivers/net/xen-netback/interface.c
 create mode 100644 drivers/net/xen-netback/netback.c
 create mode 100644 drivers/net/xen-netback/xenbus.c

Ian.

diff --git a/drivers/net/xen-netback/common.h b/drivers/net/xen-netback/common.h
index 21f4c0c..406fbef 100644
--- a/drivers/net/xen-netback/common.h
+++ b/drivers/net/xen-netback/common.h
@@ -99,7 +99,7 @@ struct xenvif {
 	struct timer_list credit_timeout;
 
 	/* Statistics */
-	int rx_gso_checksum_fixup;
+	unsigned long rx_gso_checksum_fixup;
 
 	/* Miscellaneous private stuff. */
 	struct list_head schedule_list;
diff --git a/drivers/net/xen-netback/interface.c b/drivers/net/xen-netback/interface.c
index 1614ba5..887e2ce 100644
--- a/drivers/net/xen-netback/interface.c
+++ b/drivers/net/xen-netback/interface.c
@@ -32,6 +32,7 @@
 
 #include <linux/ethtool.h>
 #include <linux/rtnetlink.h>
+#include <linux/if_vlan.h>
 
 #include <xen/events.h>
 #include <asm/xen/hypercall.h>
@@ -107,7 +108,6 @@ static int xenvif_start_xmit(struct sk_buff *skb, struct net_device *dev)
 void xenvif_receive_skb(struct xenvif *vif, struct sk_buff *skb)
 {
 	netif_rx_ni(skb);
-	vif->dev->last_rx = jiffies;
 }
 
 void xenvif_notify_tx_completion(struct xenvif *vif)
@@ -157,7 +157,7 @@ static int xenvif_close(struct net_device *dev)
 static int xenvif_change_mtu(struct net_device *dev, int mtu)
 {
 	struct xenvif *vif = netdev_priv(dev);
-	int max = vif->can_sg ? 65535 - ETH_HLEN : ETH_DATA_LEN;
+	int max = vif->can_sg ? 65535 - VLAN_ETH_HLEN : ETH_DATA_LEN;
 
 	if (mtu > max)
 		return -EINVAL;


