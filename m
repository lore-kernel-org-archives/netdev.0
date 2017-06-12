From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [PATCH v4 3/3] net/cxgb4: Use new PCI_DEV_FLAGS_NO_RELAXED_ORDERING
 flag
Date: Mon, 12 Jun 2017 14:33:00 -0700
Message-ID: <CAKgT0UczQwfxLxsYR807WKH1ZMNcXmt97GwYWQDQn5ES8kyk3A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Ashok Raj <ashok.raj@intel.com>,
        Ding Tianhong <dingtianhong@huawei.com>,
        Bjorn Helgaas <helgaas@kernel.org>,
        Michael Werner <werner@chelsio.com>,
        Ganesh Goudar <ganeshgr@chelsio.com>,
        Asit K Mallick <asit.k.mallick@intel.com>,
        Patrick J Cramer <patrick.j.cramer@intel.com>,
        Suravee Suthikulpanit <Suravee.Suthikulpanit@amd.com>,
        Bob Shaw <Bob.Shaw@amd.com>, h <l.stach@pengutronix.de>,
        Amir Ancel <amira@mellanox.com>,
        Gabriele Paoloni <gabriele.paoloni@huawei.com>,
        David Laight <David.Laight@aculab.com>,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
        Catalin Marinas <catalin.marinas@arm.com>,
        Will Deacon <will.deacon@arm.com>,
        Mark Rutland <mark.rutland@arm.com>,
        Robin Murphy <robin.murphy@arm.com>,
        David Miller <davem@davemloft.net>,
        linux-arm-ke
To: Casey Leedom <leedom@chelsio.com>
Return-path: <linux-pci-owner@vger.kernel.org>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jun 12, 2017 at 4:05 AM, Ding Tianhong <dingtianhong@huawei.com> wrote:
> From: Casey Leedom <leedom@chelsio.com>
>
> cxgb4 Ethernet driver now queries PCIe configuration space to determine
> if it can send TLPs to it with the Relaxed Ordering Attribute set.
>
> Signed-off-by: Casey Leedom <leedom@chelsio.com>
> Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>

Casey, does this patch work for you? I just want to make sure Ding
didn't miss anything. The effect of this is that the relaxed ordering
bits being set from your original patch are now dependent on them
being set in the PCIe configuration space of the device. I recall you
mentioning something about peer to peer and this currently disables
that for the case where the root complex or any PCIe bridges in
between cannot support relaxed ordering. Does that work for you or
will you need additional changes for this driver to enable peer to
peer in the that case?

> ---
>  drivers/net/ethernet/chelsio/cxgb4/cxgb4.h      |  1 +
>  drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c | 17 +++++++++++++++++
>  drivers/net/ethernet/chelsio/cxgb4/sge.c        |  5 +++--
>  3 files changed, 21 insertions(+), 2 deletions(-)
>
> diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h b/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
> index e88c180..478f25a 100644
> --- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
> +++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
> @@ -521,6 +521,7 @@ enum {                                 /* adapter flags */
>         USING_SOFT_PARAMS  = (1 << 6),
>         MASTER_PF          = (1 << 7),
>         FW_OFLD_CONN       = (1 << 9),
> +       ROOT_NO_RELAXED_ORDERING = (1 << 10),
>  };
>
>  enum {
> diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
> index 38a5c67..1dd093d 100644
> --- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
> +++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
> @@ -4726,6 +4726,23 @@ static int init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
>         adapter->msg_enable = DFLT_MSG_ENABLE;
>         memset(adapter->chan_map, 0xff, sizeof(adapter->chan_map));
>
> +       /* If possible, we use PCIe Relaxed Ordering Attribute to deliver
> +        * Ingress Packet Data to Free List Buffers in order to allow for
> +        * chipset performance optimizations between the Root Complex and
> +        * Memory Controllers.  (Messages to the associated Ingress Queue
> +        * notifying new Packet Placement in the Free Lists Buffers will be
> +        * send without the Relaxed Ordering Attribute thus guaranteeing that
> +        * all preceding PCIe Transaction Layer Packets will be processed
> +        * first.)  But some Root Complexes have various issues with Upstream
> +        * Transaction Layer Packets with the Relaxed Ordering Attribute set.
> +        * The PCIe devices which under the Root Complexes will be cleared the
> +        * Relaxed Ordering bit in the configuration space, So we check our
> +        * PCIe configuration space to see if it's flagged with advice against
> +        * using Relaxed Ordering.
> +        */
> +       if (pcie_relaxed_ordering_supported(pdev))
> +               adapter->flags |= ROOT_NO_RELAXED_ORDERING;
> +
>         spin_lock_init(&adapter->stats_lock);
>         spin_lock_init(&adapter->tid_release_lock);
>         spin_lock_init(&adapter->win0_lock);
> diff --git a/drivers/net/ethernet/chelsio/cxgb4/sge.c b/drivers/net/ethernet/chelsio/cxgb4/sge.c
> index f05f0d4..ac229a3 100644
> --- a/drivers/net/ethernet/chelsio/cxgb4/sge.c
> +++ b/drivers/net/ethernet/chelsio/cxgb4/sge.c
> @@ -2571,6 +2571,7 @@ int t4_sge_alloc_rxq(struct adapter *adap, struct sge_rspq *iq, bool fwevtq,
>         struct fw_iq_cmd c;
>         struct sge *s = &adap->sge;
>         struct port_info *pi = netdev_priv(dev);
> +       int relaxed = !(adap->flags & ROOT_NO_RELAXED_ORDERING);
>
>         /* Size needs to be multiple of 16, including status entry. */
>         iq->size = roundup(iq->size, 16);
> @@ -2624,8 +2625,8 @@ int t4_sge_alloc_rxq(struct adapter *adap, struct sge_rspq *iq, bool fwevtq,
>
>                 flsz = fl->size / 8 + s->stat_len / sizeof(struct tx_desc);
>                 c.iqns_to_fl0congen |= htonl(FW_IQ_CMD_FL0PACKEN_F |
> -                                            FW_IQ_CMD_FL0FETCHRO_F |
> -                                            FW_IQ_CMD_FL0DATARO_F |
> +                                            FW_IQ_CMD_FL0FETCHRO_V(relaxed) |
> +                                            FW_IQ_CMD_FL0DATARO_V(relaxed) |
>                                              FW_IQ_CMD_FL0PADEN_F);
>                 if (cong >= 0)
>                         c.iqns_to_fl0congen |=
> --
> 1.9.0
>
>
