From: Dimitrios Michailidis <dm@chelsio.com>
Subject: RE: [PATCH 2/2] net/cxgb4: Don't retrieve stats during recovery
Date: Thu, 23 Jan 2014 02:17:39 +0000
Message-ID: <CBA48B605613B640864883107238931C0E5789@nice.asicdesigners.com>
References: <1390187144-15495-1-git-send-email-shangw@linux.vnet.ibm.com>
 <1390187144-15495-2-git-send-email-shangw@linux.vnet.ibm.com>
 <52DD9D9E.3010205@chelsio.com> <20140121023404.GA6575@shangw.(null)>
 <20140123013134.GA5947@shangw.(null)>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Gavin Shan <shangw@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 99-65-72-228.uvs.sntcca.sbcglobal.net ([99.65.72.228]:10702
	"EHLO stargate.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752609AbaAWCme convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 22 Jan 2014 21:42:34 -0500
In-Reply-To: <20140123013134.GA5947@shangw.(null)>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 22, 2014 at 5:32 PM, Gavin Shan wrote:
> >On Mon, Jan 20, 2014 at 02:05:18PM -0800, Dimitris Michailidis wrote:
> >>On 01/19/2014 07:05 PM, Gavin Shan wrote:
> >>>We possiblly retrieve the adapter's statistics during EEH recovery
> >>>and that should be disallowed. Otherwise, it would possibly incur
> >>>replicate EEH error and EEH recovery is going to fail eventually.
> >>>The patch checks if the PCI device is off-line before statistic
> >>>retrieval.
> >>
> >>The net_devices are detached during EEH so I think
> >>netif_device_present is a better check than pci_channel_offline.  I
> >>am not sure such a test should be left to each driver though.  If you
> >>do end up putting it in the driver it needs better synchronization
> >>with the EEH handlers as Ben mentioned.
> >>
> >
> >Ok. I agree that netif_device_present() is better since the statistics
> >is more net_device specific (other than pci_dev). And it's more accurate
> >to use netif_device_present() based on what we have:
> >
> >	pci_channel_offline()	----------+
> >	eeh_err_detected()		  |
> >		!netif_device_present() --+-----+
> >	<EEH recovery>			  |	|
> >	!pci_channel_offline()	----------+	|
> >	eeh_slot_reset()			|
> >	eeh_resume()				|
> >		netif_device_present()	--------+
> >
> >For the syncrhonization, I think we can just reuse the "adap->stats_lock".
> >Something like this:
> >
> >static pci_ers_result_t eeh_err_detected(struct pci_dev *pdev,
> >					 pci_channel_state_t state)
> >{
> >	:
> >	spin_lock(&adap->stats_lock);
> >        for_each_port(adap, i) {
> >                struct net_device *dev = adap->port[i];
> >
> >                netif_device_detach(dev);
> >                netif_carrier_off(dev);
> >        }
> >	spin_unlock(&adap->stats_lock);
> >	:
> >}
> >
> >static void eeh_resume(struct pci_dev *pdev)
> >{
> >	:
> >	spin_lock(&adap->stats_lock);
> >        for_each_port(adap, i) {
> >                struct net_device *dev = adap->port[i];
> >
> >                if (netif_running(dev)) {
> >                        link_start(dev);
> >                        cxgb_set_rxmode(dev);
> >                }
> >                netif_device_attach(dev);
> >        }
> >	spin_unlock(&adap->stats_lock);
> >	:
> >}

Both link_start and cxgb_set_rxmode here issue blocking commands to FW, these two cannot be under a spinlock.  In fact I don't think you need locking here at all.  The devices can be attached asynchronously relative to the stats code, we don't care if it races.  On detach it matters but not here.

> >static struct rtnl_link_stats64 *cxgb_get_stats(struct net_device *dev,
> >                                                struct rtnl_link_stats64 *ns)
> >{
> >	:
> >        spin_lock(&adapter->stats_lock);
> >	if (!netif_device_present(dev)) {
> >		spin_unlock(&adapter->stats_lock);
> >		return ns;
> >	}
> >        t4_get_port_stats(adapter, p->tx_chan, &stats);
> >        spin_unlock(&adapter->stats_lock);
> >	:
> >}
> >
> 
> Dimitris, Any more comments on this? :-)
 
Just the above.  Thanks.

> If you think it's fine, I'm going to change it like this and send
> out "v2".
> 
> Thanks,
> Gavin
> 
> >>>
> >>>Signed-off-by: Gavin Shan <shangw@linux.vnet.ibm.com>
> >>>---
> >>>  drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c |   11 +++++++++++
> >>>  1 file changed, 11 insertions(+)
> >>>
> >>>diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
> b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
> >>>index c8eafbf..b0e72fb 100644
> >>>--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
> >>>+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
> >>>@@ -4288,6 +4288,17 @@ static struct rtnl_link_stats64
> *cxgb_get_stats(struct net_device *dev,
> >>>  	struct port_info *p = netdev_priv(dev);
> >>>  	struct adapter *adapter = p->adapter;
> >>>
> >>>+	/*
> >>>+	 * We possibly retrieve the statistics while the PCI
> >>>+	 * device is off-line. That would cause the recovery
> >>>+	 * on off-lined PCI device going to fail. So it's
> >>>+	 * reasonable to block it during the recovery period.
> >>>+	 */
> >>>+	if (pci_channel_offline(adapter->pdev)) {
> >>>+		memset(ns, 0, sizeof(*ns));
> >>>+		return ns;
> >>>+	}
> >>>+
> >>>  	spin_lock(&adapter->stats_lock);
> >>>  	t4_get_port_stats(adapter, p->tx_chan, &stats);
> >>>  	spin_unlock(&adapter->stats_lock);
> >>>
