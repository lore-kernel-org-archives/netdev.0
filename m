From: "Brown, Aaron F" <aaron.f.brown@intel.com>
Subject: RE: [Intel-wired-lan] [PATCH 1/2] e1000e: Don't return
 uninitialized stats
Date: Tue, 25 Apr 2017 07:10:22 +0000
Message-ID: <309B89C4C689E141A5FF6A0C5FB2118B8C5EF4F7@ORSMSX101.amr.corp.intel.com>
References: <20170421212012.25950-1-bpoirier@suse.com>
 <630A6B92B7EDEB45A87E20D3D286660171182EED@hasmsx109.ger.corp.intel.com>
 <caef8d69-9e47-bbcc-0758-e5900e1cb291@intel.com>
 <20170424191026.wpnpyhdaurfjixl7@f1.synalogic.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Kirsher@f1.synalogic.ca" <Kirsher@f1.synalogic.ca>,
        Stefan Priebe <s.priebe@profihost.ag>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "intel-wired-lan@lists.osuosl.org" <intel-wired-lan@lists.osuosl.org>
To: Benjamin Poirier <bpoirier@suse.com>,
        "Neftin, Sasha" <sasha.neftin@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:60267 "EHLO mga02.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1172231AbdDYHKZ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 25 Apr 2017 03:10:25 -0400
In-Reply-To: <20170424191026.wpnpyhdaurfjixl7@f1.synalogic.ca>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> From: Intel-wired-lan [mailto:intel-wired-lan-bounces@lists.osuosl.org] On
> Behalf Of Benjamin Poirier
> Sent: Monday, April 24, 2017 12:10 PM
> To: Neftin, Sasha <sasha.neftin@intel.com>
> Cc: Kirsher@f1.synalogic.ca; Stefan Priebe <s.priebe@profihost.ag>;
> netdev@vger.kernel.org; intel-wired-lan@lists.osuosl.org
> Subject: Re: [Intel-wired-lan] [PATCH 1/2] e1000e: Don't return uninitialized
> stats
> 
> Sasha, please use reply-all to keep everyone in cc (including me...).
> 
> On 2017/04/24 11:17, Neftin, Sasha wrote:
> > On 4/23/2017 15:53, Neftin, Sasha wrote:
> > > -----Original Message-----
> > > From: Intel-wired-lan [mailto:intel-wired-lan-bounces@lists.osuosl.org]
> On Behalf Of Benjamin Poirier
> > > Sent: Saturday, April 22, 2017 00:20
> > > To: Kirsher, Jeffrey T <jeffrey.t.kirsher@intel.com>
> > > Cc: netdev@vger.kernel.org; intel-wired-lan@lists.osuosl.org; Stefan
> Priebe <s.priebe@profihost.ag>
> > > Subject: [Intel-wired-lan] [PATCH 1/2] e1000e: Don't return uninitialized
> stats
> > >
> > > Some statistics passed to ethtool are garbage because
> e1000e_get_stats64() doesn't write them, for example: tx_heartbeat_errors.
> This leaks kernel memory to userspace and confuses users.
> > >
> > > Do like ixgbe and use dev_get_stats() which first zeroes out
> rtnl_link_stats64.
> > >
> > > Reported-by: Stefan Priebe <s.priebe@profihost.ag>
> > > Signed-off-by: Benjamin Poirier <bpoirier@suse.com>
> > > ---
> > >   drivers/net/ethernet/intel/e1000e/ethtool.c | 2 +-
> > >   1 file changed, 1 insertion(+), 1 deletion(-)
> > >
> > > diff --git a/drivers/net/ethernet/intel/e1000e/ethtool.c
> b/drivers/net/ethernet/intel/e1000e/ethtool.c
> > > index 7aff68a4a4df..f117b90cdc2f 100644
> > > --- a/drivers/net/ethernet/intel/e1000e/ethtool.c
> > > +++ b/drivers/net/ethernet/intel/e1000e/ethtool.c
> > > @@ -2063,7 +2063,7 @@ static void e1000_get_ethtool_stats(struct
> net_device *netdev,
> > >   	pm_runtime_get_sync(netdev->dev.parent);
> > > -	e1000e_get_stats64(netdev, &net_stats);
> > > +	dev_get_stats(netdev, &net_stats);
> > >   	pm_runtime_put_sync(netdev->dev.parent);
> > > --
> > > 2.12.2
> > >
> > > _______________________________________________
> > > Intel-wired-lan mailing list
> > > Intel-wired-lan@lists.osuosl.org
> > > http://lists.osuosl.org/mailman/listinfo/intel-wired-lan
> >
> > Hello,
> >
> > We would like to not accept this patch. Suggested generic method
> > '*dev_get_stats' (net/core/dev.c) calls 'ops->ndo_get_stats64' method
> which
> > eventually calls e1000e_get_stats64 (netdev.c) - so there is same
> > functionality. Also, see that 'e1000e_get_stats64' method in netdev.c (line
> 
> No, it's not the same functionality because dev_get_stats() does a
> memset on the rtnl_link_stats64 struct.
> 
> > 5928) calls 'memset' with 0's before update statistics.  Local sanity check
> 
> I don't see any memset in e1000e_get_stats64(). What kernel version are
> you looking at?

The call to memset was removed from the upstream kernel with:
------------------------------------------------------------------------------------
commit 5944701df90d9577658e2354cc27c4ceaeca30fe
Author: stephen hemminger <stephen@networkplumber.org>
Date:   Fri Jan 6 19:12:53 2017 -0800

    net: remove useless memset's in drivers get_stats64

    In dev_get_stats() the statistic structure storage has already been
    zeroed. Therefore network drivers do not need to call memset() again.
...
< changes to other drivers snipped out >
...
diff --git a/drivers/net/ethernet/intel/e1000e/netdev.c b/drivers/net/ethernet/int
index 723025b..79651eb 100644
--- a/drivers/net/ethernet/intel/e1000e/netdev.c
+++ b/drivers/net/ethernet/intel/e1000e/netdev.c
@@ -5925,7 +5925,6 @@ void e1000e_get_stats64(struct net_device *netdev,
 {
        struct e1000_adapter *adapter = netdev_priv(netdev);

-       memset(stats, 0, sizeof(struct rtnl_link_stats64));
        spin_lock(&adapter->stats64_lock);
        e1000e_update_stats(adapter);
        /* Fill out the OS statistics structure */
------------------------------------------------------------------------------------

This also is where the bad counters start to show up for e1000e for my test systems.  From this driver on I see (very) large values for tx_dropped, rx_over_errors and tx_fifo_errors on driver load (even before bringing the interface up.  It seems the memset is not so useless for this driver after all.  Would simply reverting the e1000e portion of this patch resolve the issue?

> 
> > in our lab shows 'tx_heartbeat_errors' counter reported as 0.
> >
> 
> Please see the mail I just sent to Paul Menzel <pmenzel@molgen.mpg.de>
> for more information about the issue and how to reproduce it.
> _______________________________________________
> Intel-wired-lan mailing list
> Intel-wired-lan@lists.osuosl.org
> http://lists.osuosl.org/mailman/listinfo/intel-wired-lan
