From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [net-next PATCH v2 2/6] i40e: Introduce VF Port
 Representator(VFPR) netdevs.
Date: Thu, 5 Jan 2017 13:44:25 +0100
Message-ID: <20170105124425.GA2211@nanopsycho>
References: <1483466874-2962-1-git-send-email-sridhar.samudrala@intel.com>
 <1483466874-2962-3-git-send-email-sridhar.samudrala@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: alexander.h.duyck@intel.com, john.r.fastabend@intel.com,
        anjali.singhai@intel.com, jakub.kicinski@netronome.com,
        davem@davemloft.net, intel-wired-lan@lists.osuosl.org,
        netdev@vger.kernel.org
To: Sridhar Samudrala <sridhar.samudrala@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wj0-f195.google.com ([209.85.210.195]:33336 "EHLO
        mail-wj0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751650AbdAEMoc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 5 Jan 2017 07:44:32 -0500
Received: by mail-wj0-f195.google.com with SMTP id kp2so79017877wjc.0
        for <netdev@vger.kernel.org>; Thu, 05 Jan 2017 04:44:31 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1483466874-2962-3-git-send-email-sridhar.samudrala@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tue, Jan 03, 2017 at 07:07:50PM CET, sridhar.samudrala@intel.com wrote:
>VF Port Representator netdevs are created for each VF if the switch mode
>is set to 'switchdev'. These netdevs can be used to control and configure
>VFs from PFs namespace. They enable exposing VF statistics, configure and
>monitor link state, mtu, filters, fdb/vlan entries etc. of VFs.
>Broadcast filters are not enabled in switchdev mode.
>
>Sample script to create VF port representors
># rmmod i40e; modprobe i40e
># devlink dev eswitch set pci/0000:05:00.0 mode switchdev
># echo 2 > /sys/class/net/enp5s0f0/device/sriov_numvfs
># ip l show
>297: enp5s0f0: <BROADCAST,MULTICAST> mtu 1500 qdisc noop portid 6805ca2e7268 state DOWN mode DEFAULT group default qlen 1000
>     link/ether 68:05:ca:2e:72:68 brd ff:ff:ff:ff:ff:ff
>     vf 0 MAC 00:00:00:00:00:00, spoof checking on, link-state auto, trust off
>     vf 1 MAC 00:00:00:00:00:00, spoof checking on, link-state auto, trust off
>299: enp5s0f0-vf0: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN mode DEFAULT group default qlen 1000
>     link/ether 00:00:00:00:00:00 brd ff:ff:ff:ff:ff:ff
>300: enp5s0f0-vf1: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN mode DEFAULT group default qlen 1000
>     link/ether 00:00:00:00:00:00 brd ff:ff:ff:ff:ff:ff
>
>Signed-off-by: Sridhar Samudrala <sridhar.samudrala@intel.com>
>---
> drivers/net/ethernet/intel/i40e/i40e_main.c        |  21 ++-
> drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c | 154 ++++++++++++++++++++-
> drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.h |  14 ++
> 3 files changed, 182 insertions(+), 7 deletions(-)
>
>diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
>index c01a620..17428f0 100644
>--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
>+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
>@@ -10938,15 +10938,34 @@ static int i40e_devlink_eswitch_mode_get(struct devlink *devlink, u16 *mode)
> static int i40e_devlink_eswitch_mode_set(struct devlink *devlink, u16 mode)
> {
> 	struct i40e_pf *pf = devlink_priv(devlink);
>-	int err = 0;
>+	struct i40e_vf *vf;
>+	int i, j, err = 0;
> 
> 	if (mode == pf->eswitch_mode)
> 		goto done;
> 
> 	switch (mode) {
> 	case DEVLINK_ESWITCH_MODE_LEGACY:
>+		for (i = 0; i < pf->num_alloc_vfs; i++) {
>+			vf = &(pf->vf[i]);
>+			i40e_free_vfpr_netdev(vf);
>+		}
> 		pf->eswitch_mode = mode;
> 		break;
>+	case DEVLINK_ESWITCH_MODE_SWITCHDEV:
>+		for (i = 0; i < pf->num_alloc_vfs; i++) {
>+			vf = &(pf->vf[i]);
>+			err = i40e_alloc_vfpr_netdev(vf, i);
>+			if (err) {
>+				for (j = 0; j < i; j++) {
>+					vf = &(pf->vf[j]);
>+					i40e_free_vfpr_netdev(vf);
>+				}
>+				goto done;
>+			}
>+		}
>+                pf->eswitch_mode = mode;

 ^^^^^^^^^^^^^^^^ wrong indent
