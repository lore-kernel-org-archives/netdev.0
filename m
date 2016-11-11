From: Arun Easi <arun.easi@cavium.com>
Subject: Re: [PATCH v2 1/6] qed: Add support for hardware offloaded iSCSI.
Date: Fri, 11 Nov 2016 10:12:05 -0800
Message-ID: <alpine.LRH.2.00.1611111006100.28058@mvluser05.qlc.com>
References: <1478588223-16183-1-git-send-email-manish.rangankar@cavium.com> <1478588223-16183-2-git-send-email-manish.rangankar@cavium.com> <1c5639c1-4160-72fe-ecc7-ca6257ec333f@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: Manish Rangankar <manish.rangankar@cavium.com>,
        <martin.petersen@oracle.com>, <lduncan@suse.com>,
        <cleech@redhat.com>, <linux-scsi@vger.kernel.org>,
        <netdev@vger.kernel.org>, <QLogic-Storage-Upstream@cavium.com>,
        <Yuval.Mintz@cavium.com>
To: Hannes Reinecke <hare@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-co1nam03on0081.outbound.protection.outlook.com ([104.47.40.81]:27456
        "EHLO NAM03-CO1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S934727AbcKKUrf (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 11 Nov 2016 15:47:35 -0500
In-Reply-To: <1c5639c1-4160-72fe-ecc7-ca6257ec333f@suse.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 11 Nov 2016, 7:57am, Hannes Reinecke wrote:

> On 11/08/2016 07:56 AM, Manish Rangankar wrote:
> > From: Yuval Mintz <Yuval.Mintz@cavium.com>
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
> >  drivers/net/ethernet/qlogic/qed/qed.h          |    7 +-
> >  drivers/net/ethernet/qlogic/qed/qed_dev.c      |   12 +
> >  drivers/net/ethernet/qlogic/qed/qed_int.h      |    1 -
> >  drivers/net/ethernet/qlogic/qed/qed_iscsi.c    | 1276
> > ++++++++++++++++++++++++
> >  drivers/net/ethernet/qlogic/qed/qed_iscsi.h    |   52 +
> >  drivers/net/ethernet/qlogic/qed/qed_l2.c       |    1 -
> >  drivers/net/ethernet/qlogic/qed/qed_ll2.c      |    4 +-
> >  drivers/net/ethernet/qlogic/qed/qed_reg_addr.h |    2 +
> >  drivers/net/ethernet/qlogic/qed/qed_spq.c      |   15 +
> >  include/linux/qed/qed_if.h                     |    2 +
> >  include/linux/qed/qed_iscsi_if.h               |  229 +++++
> >  13 files changed, 1613 insertions(+), 4 deletions(-)
> >  create mode 100644 drivers/net/ethernet/qlogic/qed/qed_iscsi.c
> >  create mode 100644 drivers/net/ethernet/qlogic/qed/qed_iscsi.h
> >  create mode 100644 include/linux/qed/qed_iscsi_if.h
> > 
> > diff --git a/drivers/net/ethernet/qlogic/Kconfig
> > b/drivers/net/ethernet/qlogic/Kconfig
> > index 32f2a45..2832570 100644
> > --- a/drivers/net/ethernet/qlogic/Kconfig
> > +++ b/drivers/net/ethernet/qlogic/Kconfig
> > @@ -110,4 +110,19 @@ config QEDE
> >  config QED_RDMA
> >  	bool
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
> > diff --git a/drivers/net/ethernet/qlogic/qed/Makefile
> > b/drivers/net/ethernet/qlogic/qed/Makefile
> > index 967acf3..597e15c 100644
> > --- a/drivers/net/ethernet/qlogic/qed/Makefile
> > +++ b/drivers/net/ethernet/qlogic/qed/Makefile
> > @@ -6,3 +6,4 @@ qed-y := qed_cxt.o qed_dev.o qed_hw.o qed_init_fw_funcs.o
> > qed_init_ops.o \
> >  qed-$(CONFIG_QED_SRIOV) += qed_sriov.o qed_vf.o
> >  qed-$(CONFIG_QED_LL2) += qed_ll2.o
> >  qed-$(CONFIG_QED_RDMA) += qed_roce.o
> > +qed-$(CONFIG_QED_ISCSI) += qed_iscsi.o
> > diff --git a/drivers/net/ethernet/qlogic/qed/qed.h
> > b/drivers/net/ethernet/qlogic/qed/qed.h
> > index 50b8a01..15286c1 100644
> > --- a/drivers/net/ethernet/qlogic/qed/qed.h
> > +++ b/drivers/net/ethernet/qlogic/qed/qed.h
> > @@ -35,6 +35,7 @@
> > 
> >  #define QED_WFQ_UNIT	100
> > 
> > +#define ISCSI_BDQ_ID(_port_id) (_port_id)
> >  #define QED_WID_SIZE            (1024)
> >  #define QED_PF_DEMS_SIZE        (4)
> > 
> > @@ -392,6 +393,7 @@ struct qed_hwfn {
> >  	bool				using_ll2;
> >  	struct qed_ll2_info		*p_ll2_info;
> >  	struct qed_rdma_info		*p_rdma_info;
> > +	struct qed_iscsi_info		*p_iscsi_info;
> >  	struct qed_pf_params		pf_params;
> > 
> >  	bool b_rdma_enabled_in_prs;
> > @@ -593,6 +595,8 @@ struct qed_dev {
> >  	/* Linux specific here */
> >  	struct  qede_dev		*edev;
> >  	struct  pci_dev			*pdev;
> > +	u32 flags;
> > +#define QED_FLAG_STORAGE_STARTED	(BIT(0))
> >  	int				msg_enable;
> > 
> >  	struct pci_params		pci_params;
> > @@ -606,6 +610,7 @@ struct qed_dev {
> >  	union {
> >  		struct qed_common_cb_ops	*common;
> >  		struct qed_eth_cb_ops		*eth;
> > +		struct qed_iscsi_cb_ops		*iscsi;
> >  	} protocol_ops;
> >  	void				*ops_cookie;
> > 
> > @@ -615,7 +620,7 @@ struct qed_dev {
> >  	struct qed_cb_ll2_info		*ll2;
> >  	u8				ll2_mac_address[ETH_ALEN];
> >  #endif
> > -
> > +	DECLARE_HASHTABLE(connections, 10);
> >  	const struct firmware		*firmware;
> > 
> >  	u32 rdma_max_sge;
> 10 connections? Only?
> Hmm.

10 is the hash bits => 2^10 hash buckets, allowing for a large number of 
connections. qedi driver currently uses 1k connections per port.

Thanks for the reviews, Hannes.

Regards,
-Arun

> 
> Other than that:
> 
> Reviewed-by: Hannes Reinecke <hare@suse.com>
> 
> Cheers,
> 
> Hannes
> 
