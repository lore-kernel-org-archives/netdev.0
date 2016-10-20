From: Arun Easi <arun.easi@cavium.com>
Subject: Re: [RFC 1/6] qed: Add support for hardware offloaded iSCSI.
Date: Wed, 19 Oct 2016 17:14:59 -0700
Message-ID: <alpine.LRH.2.00.1610191538530.25712@mvluser05.qlc.com>
References: <1476853273-22960-1-git-send-email-manish.rangankar@cavium.com> <1476853273-22960-2-git-send-email-manish.rangankar@cavium.com> <20161019090923.up3xgrbya3mxr7vu@linux-x5ow.site>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: <manish.rangankar@cavium.com>, <lduncan@suse.com>,
        <cleech@redhat.com>, <martin.petersen@oracle.com>,
        <jejb@linux.vnet.ibm.com>, <linux-scsi@vger.kernel.org>,
        <netdev@vger.kernel.org>, <Yuval.Mintz@cavium.com>,
        <QLogic-Storage-Upstream@cavium.com>,
        Yuval Mintz <Yuval.Mintz@qlogic.com>
To: Johannes Thumshirn <jthumshirn@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2nam03on0046.outbound.protection.outlook.com ([104.47.42.46]:64536
        "EHLO NAM03-BY2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1753353AbcJTAPN (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 19 Oct 2016 20:15:13 -0400
In-Reply-To: <20161019090923.up3xgrbya3mxr7vu@linux-x5ow.site>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thanks Johannes for the review, please see my response below.

On Wed, 19 Oct 2016, 2:09am, Johannes Thumshirn wrote:

> Hi Manish,
> 
> Some initital comments
> 
> On Wed, Oct 19, 2016 at 01:01:08AM -0400, manish.rangankar@cavium.com wrote:
> > From: Yuval Mintz <Yuval.Mintz@qlogic.com>
> > 
> > This adds the backbone required for the various HW initalizations
> > which are necessary for the iSCSI driver (qedi) for QLogic FastLinQ
> > 4xxxx line of adapters - FW notification, resource initializations, etc.
> > 
> > Signed-off-by: Arun Easi <arun.easi@cavium.com>
> > Signed-off-by: Yuval Mintz <yuval.mintz@cavium.com>
> > ---
> >  drivers/net/ethernet/qlogic/Kconfig            |   15 +
> >  drivers/net/ethernet/qlogic/qed/Makefile       |    1 +
> >  drivers/net/ethernet/qlogic/qed/qed.h          |    8 +-
> >  drivers/net/ethernet/qlogic/qed/qed_dev.c      |   15 +
> >  drivers/net/ethernet/qlogic/qed/qed_int.h      |    1 -
> >  drivers/net/ethernet/qlogic/qed/qed_iscsi.c    | 1310 ++++++++++++++++++++++++
> >  drivers/net/ethernet/qlogic/qed/qed_iscsi.h    |   52 +
> >  drivers/net/ethernet/qlogic/qed/qed_l2.c       |    1 -
> >  drivers/net/ethernet/qlogic/qed/qed_ll2.c      |   35 +-
> >  drivers/net/ethernet/qlogic/qed/qed_main.c     |    2 -
> >  drivers/net/ethernet/qlogic/qed/qed_mcp.h      |    6 -
> >  drivers/net/ethernet/qlogic/qed/qed_reg_addr.h |    2 +
> >  drivers/net/ethernet/qlogic/qed/qed_spq.c      |   15 +
> >  include/linux/qed/qed_if.h                     |    2 +
> >  include/linux/qed/qed_iscsi_if.h               |  249 +++++
> >  15 files changed, 1692 insertions(+), 22 deletions(-)
> >  create mode 100644 drivers/net/ethernet/qlogic/qed/qed_iscsi.c
> >  create mode 100644 drivers/net/ethernet/qlogic/qed/qed_iscsi.h
> >  create mode 100644 include/linux/qed/qed_iscsi_if.h
> > 
> > diff --git a/drivers/net/ethernet/qlogic/Kconfig b/drivers/net/ethernet/qlogic/Kconfig
> > index 0df1391f9..bad4fae 100644
> > --- a/drivers/net/ethernet/qlogic/Kconfig
> > +++ b/drivers/net/ethernet/qlogic/Kconfig
> > @@ -118,4 +118,19 @@ config INFINIBAND_QEDR
> >  	  for QLogic QED. This would be replaced by the 'real' option
> >  	  once the QEDR driver is added [+relocated].
> >  
> > +config QED_ISCSI
> > +	bool
> > +
> > +config QEDI
> > +	tristate "QLogic QED 25/40/100Gb iSCSI driver"
> > +	depends on QED
> > +	select QED_LL2
> > +	select QED_ISCSI
> > +	default n
> > +	---help---
> > +	  This provides a temporary node that allows the compilation
> > +	  and logical testing of the hardware offload iSCSI support
> > +	  for QLogic QED. This would be replaced by the 'real' option
> > +	  once the QEDI driver is added [+relocated].
> > +
> >  endif # NET_VENDOR_QLOGIC
> > diff --git a/drivers/net/ethernet/qlogic/qed/Makefile b/drivers/net/ethernet/qlogic/qed/Makefile
> > index cda0af7..b76669c 100644
> > --- a/drivers/net/ethernet/qlogic/qed/Makefile
> > +++ b/drivers/net/ethernet/qlogic/qed/Makefile
> > @@ -6,3 +6,4 @@ qed-y := qed_cxt.o qed_dev.o qed_hw.o qed_init_fw_funcs.o qed_init_ops.o \
> >  qed-$(CONFIG_QED_SRIOV) += qed_sriov.o qed_vf.o
> >  qed-$(CONFIG_QED_LL2) += qed_ll2.o
> >  qed-$(CONFIG_INFINIBAND_QEDR) += qed_roce.o
> > +qed-$(CONFIG_QED_ISCSI) += qed_iscsi.o
> > diff --git a/drivers/net/ethernet/qlogic/qed/qed.h b/drivers/net/ethernet/qlogic/qed/qed.h
> > index 653bb57..a61b1c0 100644
> > --- a/drivers/net/ethernet/qlogic/qed/qed.h
> > +++ b/drivers/net/ethernet/qlogic/qed/qed.h
> > @@ -35,6 +35,7 @@
> >  
> >  #define QED_WFQ_UNIT	100
> >  
> > +#define ISCSI_BDQ_ID(_port_id) (_port_id)
> 
> This looks a bit odd to me.
> 
> [...]
> 
> >  #endif
> > +		if (IS_ENABLED(CONFIG_QEDI) &&
> > +				p_hwfn->hw_info.personality == QED_PCI_ISCSI)
> > +			qed_iscsi_free(p_hwfn, p_hwfn->p_iscsi_info);
> 
> 
> Why not introduce a small helper like:
> static inline bool qed_is_iscsi_personality()
> {
> 	return IS_ENABLED(CONFIG_QEDI) && p_hwfn->hw_info.personality ==
> 		QED_PCI_ISCSI;
> }

I think I can remove the IS_ENABLED() check in places like this
and have the check contained in header file. qed_iscsi_free()
already is taken care, if I do the same fore qed_ooo*, I think
the check would just be "p_hwfn->hw_info.personality ==
QED_PCI_ISCSI", which would keep it consistent with the other
areas where similar check is done for other protocols.

> 
> >  		qed_iov_free(p_hwfn);
> 
> [...]
> 
> > +
> > +	if (!GET_FIELD(p_ramrod->iscsi.flags,
> > +		       ISCSI_CONN_OFFLOAD_PARAMS_TCP_ON_CHIP_1B)) {
> > +		p_tcp = &p_ramrod->tcp;
> > +		ucval = p_conn->local_mac[1];
> > +		((u8 *)(&p_tcp->local_mac_addr_hi))[0] = ucval;
> > +		ucval = p_conn->local_mac[0];
> > +		((u8 *)(&p_tcp->local_mac_addr_hi))[1] = ucval;
> > +		ucval = p_conn->local_mac[3];
> > +		((u8 *)(&p_tcp->local_mac_addr_mid))[0] = ucval;
> > +		ucval = p_conn->local_mac[2];
> > +		((u8 *)(&p_tcp->local_mac_addr_mid))[1] = ucval;
> > +		ucval = p_conn->local_mac[5];
> > +		((u8 *)(&p_tcp->local_mac_addr_lo))[0] = ucval;
> > +		ucval = p_conn->local_mac[4];
> > +		((u8 *)(&p_tcp->local_mac_addr_lo))[1] = ucval;
> > +		ucval = p_conn->remote_mac[1];
> > +		((u8 *)(&p_tcp->remote_mac_addr_hi))[0] = ucval;
> > +		ucval = p_conn->remote_mac[0];
> > +		((u8 *)(&p_tcp->remote_mac_addr_hi))[1] = ucval;
> > +		ucval = p_conn->remote_mac[3];
> > +		((u8 *)(&p_tcp->remote_mac_addr_mid))[0] = ucval;
> > +		ucval = p_conn->remote_mac[2];
> > +		((u8 *)(&p_tcp->remote_mac_addr_mid))[1] = ucval;
> > +		ucval = p_conn->remote_mac[5];
> > +		((u8 *)(&p_tcp->remote_mac_addr_lo))[0] = ucval;
> > +		ucval = p_conn->remote_mac[4];
> > +		((u8 *)(&p_tcp->remote_mac_addr_lo))[1] = ucval;
> > +
> > +		p_tcp->vlan_id = cpu_to_le16(p_conn->vlan_id);
> > +
> > +		p_tcp->flags = p_conn->tcp_flags;
> > +		p_tcp->ip_version = p_conn->ip_version;
> > +		for (i = 0; i < 4; i++) {
> > +			dval = p_conn->remote_ip[i];
> > +			p_tcp->remote_ip[i] = cpu_to_le32(dval);
> > +			dval = p_conn->local_ip[i];
> > +			p_tcp->local_ip[i] = cpu_to_le32(dval);
> > +		}
> > +		p_tcp->ka_max_probe_cnt = p_conn->ka_max_probe_cnt;
> > +		p_tcp->dup_ack_theshold = p_conn->dup_ack_theshold;
> > +
> > +		p_tcp->rcv_next = cpu_to_le32(p_conn->rcv_next);
> > +		p_tcp->snd_una = cpu_to_le32(p_conn->snd_una);
> > +		p_tcp->snd_next = cpu_to_le32(p_conn->snd_next);
> > +		p_tcp->snd_max = cpu_to_le32(p_conn->snd_max);
> > +		p_tcp->snd_wnd = cpu_to_le32(p_conn->snd_wnd);
> > +		p_tcp->rcv_wnd = cpu_to_le32(p_conn->rcv_wnd);
> > +		p_tcp->snd_wl1 = cpu_to_le32(p_conn->snd_wl1);
> > +		p_tcp->cwnd = cpu_to_le32(p_conn->cwnd);
> > +		p_tcp->ss_thresh = cpu_to_le32(p_conn->ss_thresh);
> > +		p_tcp->srtt = cpu_to_le16(p_conn->srtt);
> > +		p_tcp->rtt_var = cpu_to_le16(p_conn->rtt_var);
> > +		p_tcp->ts_time = cpu_to_le32(p_conn->ts_time);
> > +		p_tcp->ts_recent = cpu_to_le32(p_conn->ts_recent);
> > +		p_tcp->ts_recent_age = cpu_to_le32(p_conn->ts_recent_age);
> > +		p_tcp->total_rt = cpu_to_le32(p_conn->total_rt);
> > +		dval = p_conn->ka_timeout_delta;
> > +		p_tcp->ka_timeout_delta = cpu_to_le32(dval);
> > +		dval = p_conn->rt_timeout_delta;
> > +		p_tcp->rt_timeout_delta = cpu_to_le32(dval);
> > +		p_tcp->dup_ack_cnt = p_conn->dup_ack_cnt;
> > +		p_tcp->snd_wnd_probe_cnt = p_conn->snd_wnd_probe_cnt;
> > +		p_tcp->ka_probe_cnt = p_conn->ka_probe_cnt;
> > +		p_tcp->rt_cnt = p_conn->rt_cnt;
> > +		p_tcp->flow_label = cpu_to_le32(p_conn->flow_label);
> > +		p_tcp->ka_timeout = cpu_to_le32(p_conn->ka_timeout);
> > +		p_tcp->ka_interval = cpu_to_le32(p_conn->ka_interval);
> > +		p_tcp->max_rt_time = cpu_to_le32(p_conn->max_rt_time);
> > +		dval = p_conn->initial_rcv_wnd;
> > +		p_tcp->initial_rcv_wnd = cpu_to_le32(dval);
> > +		p_tcp->ttl = p_conn->ttl;
> > +		p_tcp->tos_or_tc = p_conn->tos_or_tc;
> > +		p_tcp->remote_port = cpu_to_le16(p_conn->remote_port);
> > +		p_tcp->local_port = cpu_to_le16(p_conn->local_port);
> > +		p_tcp->mss = cpu_to_le16(p_conn->mss);
> > +		p_tcp->snd_wnd_scale = p_conn->snd_wnd_scale;
> > +		p_tcp->rcv_wnd_scale = p_conn->rcv_wnd_scale;
> > +		dval = p_conn->ts_ticks_per_second;
> > +		p_tcp->ts_ticks_per_second = cpu_to_le32(dval);
> > +		wval = p_conn->da_timeout_value;
> > +		p_tcp->da_timeout_value = cpu_to_le16(wval);
> > +		p_tcp->ack_frequency = p_conn->ack_frequency;
> > +		p_tcp->connect_mode = p_conn->connect_mode;
> > +	} else {
> > +		p_tcp2 =
> > +		    &((struct iscsi_spe_conn_offload_option2 *)p_ramrod)->tcp;
> > +		ucval = p_conn->local_mac[1];
> > +		((u8 *)(&p_tcp2->local_mac_addr_hi))[0] = ucval;
> > +		ucval = p_conn->local_mac[0];
> > +		((u8 *)(&p_tcp2->local_mac_addr_hi))[1] = ucval;
> > +		ucval = p_conn->local_mac[3];
> > +		((u8 *)(&p_tcp2->local_mac_addr_mid))[0] = ucval;
> > +		ucval = p_conn->local_mac[2];
> > +		((u8 *)(&p_tcp2->local_mac_addr_mid))[1] = ucval;
> > +		ucval = p_conn->local_mac[5];
> > +		((u8 *)(&p_tcp2->local_mac_addr_lo))[0] = ucval;
> > +		ucval = p_conn->local_mac[4];
> > +		((u8 *)(&p_tcp2->local_mac_addr_lo))[1] = ucval;
> > +
> > +		ucval = p_conn->remote_mac[1];
> > +		((u8 *)(&p_tcp2->remote_mac_addr_hi))[0] = ucval;
> > +		ucval = p_conn->remote_mac[0];
> > +		((u8 *)(&p_tcp2->remote_mac_addr_hi))[1] = ucval;
> > +		ucval = p_conn->remote_mac[3];
> > +		((u8 *)(&p_tcp2->remote_mac_addr_mid))[0] = ucval;
> > +		ucval = p_conn->remote_mac[2];
> > +		((u8 *)(&p_tcp2->remote_mac_addr_mid))[1] = ucval;
> > +		ucval = p_conn->remote_mac[5];
> > +		((u8 *)(&p_tcp2->remote_mac_addr_lo))[0] = ucval;
> > +		ucval = p_conn->remote_mac[4];
> > +		((u8 *)(&p_tcp2->remote_mac_addr_lo))[1] = ucval;
> > +
> > +		p_tcp2->vlan_id = cpu_to_le16(p_conn->vlan_id);
> > +		p_tcp2->flags = p_conn->tcp_flags;
> > +
> > +		p_tcp2->ip_version = p_conn->ip_version;
> > +		for (i = 0; i < 4; i++) {
> > +			dval = p_conn->remote_ip[i];
> > +			p_tcp2->remote_ip[i] = cpu_to_le32(dval);
> > +			dval = p_conn->local_ip[i];
> > +			p_tcp2->local_ip[i] = cpu_to_le32(dval);
> > +		}
> > +
> > +		p_tcp2->flow_label = cpu_to_le32(p_conn->flow_label);
> > +		p_tcp2->ttl = p_conn->ttl;
> > +		p_tcp2->tos_or_tc = p_conn->tos_or_tc;
> > +		p_tcp2->remote_port = cpu_to_le16(p_conn->remote_port);
> > +		p_tcp2->local_port = cpu_to_le16(p_conn->local_port);
> > +		p_tcp2->mss = cpu_to_le16(p_conn->mss);
> > +		p_tcp2->rcv_wnd_scale = p_conn->rcv_wnd_scale;
> > +		p_tcp2->connect_mode = p_conn->connect_mode;
> > +		wval = p_conn->syn_ip_payload_length;
> > +		p_tcp2->syn_ip_payload_length = cpu_to_le16(wval);
> > +		p_tcp2->syn_phy_addr_lo = DMA_LO_LE(p_conn->syn_phy_addr);
> > +		p_tcp2->syn_phy_addr_hi = DMA_HI_LE(p_conn->syn_phy_addr);
> > +	}
> 
> Is there any chance you could factor out above blocks into own functions so
> you have
> 
> 
> 	if (!GET_FIELD(p_ramrod->iscsi.flags,
> 		       ISCSI_CONN_OFFLOAD_PARAMS_TCP_ON_CHIP_1B)) {
> 		qedi_do_stuff_off_chip();
> 	else 
> 		qedi_do_stuff_on_chip();
> 

This function mostly fills data needed for the firmware interface.
By having all data necessary for the command
ISCSI_RAMROD_CMD_ID_OFFLOAD_CONN in this function it is easier to
refer what is being fed to firmware. If you do not have strong
objections, I would like to keep it this way.

> > +
> 
> [...]
> 
> > +static void __iomem *qed_iscsi_get_db_addr(struct qed_hwfn *p_hwfn, u32 cid)
> > +{
> > +	return (u8 __iomem *)p_hwfn->doorbells +
> > +			     qed_db_addr(cid, DQ_DEMS_LEGACY);
> > +}
> > +
> > +static void __iomem *qed_iscsi_get_primary_bdq_prod(struct qed_hwfn *p_hwfn,
> > +						    u8 bdq_id)
> > +{
> > +	u8 bdq_function_id = ISCSI_BDQ_ID(p_hwfn->port_id);
> > +
> > +	return (u8 __iomem *)p_hwfn->regview + GTT_BAR0_MAP_REG_MSDM_RAM +
> > +			     MSTORM_SCSI_BDQ_EXT_PROD_OFFSET(bdq_function_id,
> > +							     bdq_id);
> > +}
> > +
> > +static void __iomem *qed_iscsi_get_secondary_bdq_prod(struct qed_hwfn *p_hwfn,
> > +						      u8 bdq_id)
> > +{
> > +	u8 bdq_function_id = ISCSI_BDQ_ID(p_hwfn->port_id);
> > +
> > +	return (u8 __iomem *)p_hwfn->regview + GTT_BAR0_MAP_REG_TSDM_RAM +
> > +			     TSTORM_SCSI_BDQ_EXT_PROD_OFFSET(bdq_function_id,
> > +							     bdq_id);
> > +}
> 
> Why are you casting to u8* here, you're returning void*? 
> 

The cast is for the "p_hwfn->regview".

> [...]
> 
> > +
> > +	if (tasks) {
> > +		struct qed_tid_mem *tid_info = kzalloc(sizeof(*tid_info),
> > +						       GFP_KERNEL);
> > +
> > +		if (!tid_info) {
> > +			DP_NOTICE(cdev,
> > +				  "Failed to allocate tasks information\n");
> > +			qed_iscsi_stop(cdev);
> > +			return -ENOMEM;
> > +		}
> > +
> > +		rc = qed_cxt_get_tid_mem_info(QED_LEADING_HWFN(cdev),
> > +					      tid_info);
> > +		if (rc) {
> > +			DP_NOTICE(cdev, "Failed to gather task information\n");
> > +			qed_iscsi_stop(cdev);
> > +			kfree(tid_info);
> > +			return rc;
> > +		}
> > +
> > +		/* Fill task information */
> > +		tasks->size = tid_info->tid_size;
> > +		tasks->num_tids_per_block = tid_info->num_tids_per_block;
> > +		memcpy(tasks->blocks, tid_info->blocks, MAX_TID_BLOCKS);
> > +
> > +		kfree(tid_info);
> > +	}
> > +
> > +	return 0;
> > +}
> 
> Maybe:
> 
> struct qed_tid_mem *tid_info;
> [...]
> if (!tasks)
> 	return 0;
> 
> tid_info = kzalloc(sizeof(*tid_info), GFP_KERNEL);
> 
> if (!tid_info) {
> 	DP_NOTICE(cdev, "Failed to allocate tasks information\n");
> 	qed_iscsi_stop(cdev);
> 	return -ENOMEM;
> }
> 
> rc = qed_cxt_get_tid_mem_info(QED_LEADING_HWFN(cdev), tid_info);
> if (rc) {
> 	DP_NOTICE(cdev, "Failed to gather task information\n");
> 	qed_iscsi_stop(cdev);
> 	kfree(tid_info);
> 	return rc;
> }
> 
> /* Fill task information */
> tasks->size = tid_info->tid_size;
> tasks->num_tids_per_block = tid_info->num_tids_per_block;
> memcpy(tasks->blocks, tid_info->blocks, MAX_TID_BLOCKS);
> 
> kfree(tid_info);
> 

Sure, will do.

> > +
> 
> [...]
> 
> > +/**
> > + * @brief start iscsi in FW
> > + *
> > + * @param cdev
> > + * @param tasks - qed will fill information about tasks
> > + *
> 
> Please use proper kerneldoc and not doxygen syntax.
> 

Sure, will do.

Regards,
-Arun
