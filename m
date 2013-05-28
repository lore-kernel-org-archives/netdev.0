From: Shawn Bohrer <shawn.bohrer@gmail.com>
Subject: Re: 3.10.0-rc2 mlx4 not receiving packets for some multicast groups
Date: Tue, 28 May 2013 15:15:08 -0500
Message-ID: <20130528201508.GA6409@sbohrermbp13-local.rgmadvisors.com>
References: <20130524154931.GA9245@sbohrermbp13-local.rgmadvisors.com>
 <20130524163446.GC9245@sbohrermbp13-local.rgmadvisors.com>
 <CAJZOPZJwe6xAj7xRK5_BnWN2wNT+oVS329+iYtE4hYTqPMLwJQ@mail.gmail.com>
 <20130525151347.GB25744@lintop.rgmadvisors.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Hadar Hen Zion <hadarh@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>
To: Or Gerlitz <or.gerlitz@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f49.google.com ([209.85.219.49]:35388 "EHLO
	mail-oa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755587Ab3E1UPR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 May 2013 16:15:17 -0400
Received: by mail-oa0-f49.google.com with SMTP id k14so10724553oag.36
        for <netdev@vger.kernel.org>; Tue, 28 May 2013 13:15:16 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20130525151347.GB25744@lintop.rgmadvisors.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, May 25, 2013 at 10:13:47AM -0500, Shawn Bohrer wrote:
> On Sat, May 25, 2013 at 06:41:05AM +0300, Or Gerlitz wrote:
> > On Fri, May 24, 2013 at 7:34 PM, Shawn Bohrer <shawn.bohrer@gmail.com> wrote:
> > > On Fri, May 24, 2013 at 10:49:31AM -0500, Shawn Bohrer wrote:
> > > > I just started testing the 3.10 kernel, previously we were on 3.4 so
> > > > there is a fairly large jump.  I've additionally applied the following
> > > > four patches to the 3.10.0-rc2 kernel that I'm testing:
> > > >
> > > > https://patchwork.kernel.org/patch/2484651/
> > > > https://patchwork.kernel.org/patch/2484671/
> > > > https://patchwork.kernel.org/patch/2484681/
> > > > https://patchwork.kernel.org/patch/2484641/
> > > >
> > >> I don't know if those patches are related to my issues or not but I
> > >> plan on trying to reproduce without them soon.
> > 
> > > I've reverted the four patches above from my test kernel and still see
> > > the issue so they don't appear to be the cause.
> > 
> > Hi Shawn,
> > 
> > So 3.4 works, 3.10-rc2 breaks? its indeed a fairly large gap, maybe
> > try to bisec that? just to make sure, did use touch any mlx4
> > non-default config? specifically did you turn DMFS (Device Managed
> > Flow Steering) on using the  set the mlx4_core module param of
> > log_num_mgm_entry_size or you were using B0 steering (the default)?
> 
> Initially my goal is to sanity check 3.10 before I start playing with
> the knobs, so I haven't explicitly changed any new mlx4 settings yet.
> We do however set some non-default values but I'm doing that on both
> kernels:
> 
> mlx4_core log_num_vlan=7
> mlx4_en pfctx=0xff pfcrx=0xff

Naturally I was wrong and we set more than the above non-default
values.  We additionally set high_rate_steer=1 on mlx4_core. As
you may know this parameter isn't currently available in the upstream
driver, so I've been carrying the following patch in my 3.4 and 3.10
trees:

---
 drivers/net/ethernet/mellanox/mlx4/main.c |   10 ++++++++++
 1 files changed, 10 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/main.c b/drivers/net/ethernet/mellanox/mlx4/main.c
index 0d32a82..7808e4a 100644
--- a/drivers/net/ethernet/mellanox/mlx4/main.c
+++ b/drivers/net/ethernet/mellanox/mlx4/main.c
@@ -71,6 +71,11 @@ static int msi_x = 1;
 module_param(msi_x, int, 0444);
 MODULE_PARM_DESC(msi_x, "attempt to use MSI-X if nonzero");
 
+static int high_rate_steer;
+module_param(high_rate_steer, int, 0444);
+MODULE_PARM_DESC(high_rate_steer, "Enable steering mode for higher packet rate"
+                                  " (default off)");
+
 #else /* CONFIG_PCI_MSI */
 
 #define msi_x (0)
@@ -288,6 +293,11 @@ static int mlx4_dev_cap(struct mlx4_dev *dev, struct mlx4_dev_cap *dev_cap)
 	if (mlx4_is_mfunc(dev))
 		dev->caps.flags &= ~MLX4_DEV_CAP_FLAG_SENSE_SUPPORT;
 
+	if (high_rate_steer && !mlx4_is_mfunc(dev)) {
+		dev->caps.flags &= ~MLX4_DEV_CAP_FLAG_VEP_UC_STEER;
+		dev->caps.flags &= ~MLX4_DEV_CAP_FLAG_VEP_MC_STEER;
+	}
+
 	dev->caps.log_num_macs  = log_num_mac;
 	dev->caps.log_num_vlans = MLX4_LOG_NUM_VLANS;
 	dev->caps.log_num_prios = use_prio ? 3 : 0;
-- 

What I've found really happened is:

1. Installed 3.10 rebooted and everything worked.  high_rate_steer=1
was set at this point.
2. Our configuration management software saw the new kernel and
disabled high_rate_steer.
3. As I rebooted machines high_rate_steer was cleared and they no
longer received multicast data on most of their addresses.

I've confirmed that with the above high_rate_steer patch and
high_rate_steer=1 I receive data on 3.10.0-rc3 and with
high_rate_steer=0 I only receive data on a small number of multicast
addresses.  With 3.4 and the same patch I receive data in both cases.

I also previously claimed that rebooting one machine appeared to make
a different machine receive data.  I doubt this was true.  Instead
what I think happened was that each time I start my application a
different set of multicast groups will receive data and the rest will
not.  I did not verify that all groups were actually receiving data
and thus am guessing I just happened to get lucky and see a few new
ones working that previously were not.

So now that we know that high_rate_steer=1 fixes my multicast issue
does that provide any clues as to why I do not receive data on all
multicast groups without it?  Additionally as I'm sure I should have
done earlier is there a reason the high_rate_steer option has not been
upstreamed?  I can see that the out of tree Mellanox driver now
additionally clears MLX4_DEV_CAP_FLAG2_FS_EN when high_rate_steer=1
and has moved that code into choose_steering_mode() so my local patch
probably needs an update if this isn't going upstream.  For a little
bit of background the reason we are using the high_rate_steer=1 option
was because it enabled us to handle larger/faster bursts of packets
without dropping packets.  Historically we got very similar results by
using log_num_mgm_entry_size=7 but we stuck with high_rate_steer=1
simply because we had tried/verified it first.  For those wondering
using log_num_mgm_entry_size=7 and high_rate_steer=0 on 3.10 does not
work since I do not receive data on all multicast groups.

--
Shawn
