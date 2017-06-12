From: Ding Tianhong <dingtianhong@huawei.com>
Subject: Re: [PATCH v3 3/3] net/cxgb4: Use new
 PCI_DEV_FLAGS_NO_RELAXED_ORDERING flag
Date: Mon, 12 Jun 2017 14:53:29 +0800
Message-ID: <2805c6bb-9d1d-0216-60ef-48cb7c377c4b@huawei.com>
References: <1496826968-10152-1-git-send-email-dingtianhong@huawei.com>
 <1496826968-10152-4-git-send-email-dingtianhong@huawei.com>
 <CAKgT0UeN7BK94wgU=LiD9CAo0ihrFgv2bZLFrTtr_+bgSbswxQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Mark Rutland <mark.rutland@arm.com>,
 Gabriele Paoloni <gabriele.paoloni@huawei.com>,
 Asit K Mallick <asit.k.mallick@intel.com>,
 Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>,
 Ashok Raj <ashok.raj@intel.com>, Bjorn Helgaas <helgaas@kernel.org>,
 Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
 "linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>,
 Ganesh Goudar <ganeshgr@chelsio.com>, Bob Shaw <Bob.Shaw@amd.com>,
 Casey Leedom <leedom@chelsio.com>,
 Patrick J Cramer <patrick.j.cramer@intel.com>,
 Michael Werner <werner@chelsio.com>, linux-arm-kernel@lists.infradead.org,
 Amir Ancel <amira@mellanox.com>, Netdev <netdev@vger.kernel.org>,
 "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
 David Laight <David.Laight@aculab.com>,
 Suravee Suthikulpanit <Suravee.Suthikulpanit@amd.com>,
 Robin Murphy <robin.murphy@arm.com>, David Miller <davem@
To: Alexander Duyck <alexander.duyck@gmail.com>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <CAKgT0UeN7BK94wgU=LiD9CAo0ihrFgv2bZLFrTtr_+bgSbswxQ@mail.gmail.com>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org



On 2017/6/8 7:24, Alexander Duyck wrote:
> On Wed, Jun 7, 2017 at 2:16 AM, Ding Tianhong <dingtianhong@huawei.com> wrote:
>> From: Casey Leedom <leedom@chelsio.com>
>>
>> cxgb4 Ethernet driver now queries Root Complex Port to determine if it can
>> send TLPs to it with the Relaxed Ordering Attribute set.
>>
>> Signed-off-by: Casey Leedom <leedom@chelsio.com>
>> Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
> 
> So I am pretty sure this patch doesn't work with patch 2. We need to
> update it so that it doesn't check the root complex but instead checks
> itself to see if it is allowed to use relaxed ordering.
> 

Right, we should check the End Point PCIe device configuration space, not RC.

> What we need here is the ability to detect if relaxed ordering is
> disabled, and if so take the steps needed to enable peer to peer
> relaxed ordering without enabling relaxed ordering to the root
> complex. Do I have that right Casey?
> 

I am not very clear to this driver about how to enable peer to peer
relaxed ordering without enabling relaxed ordering to the RC, need
some help from Casey, so I will still focus on this patch and only
fix the peer to RC relaxed ordering problem, I hope Casey could send
another patch to fix it later.

Thanks
Ding

>> ---
>>  drivers/net/ethernet/chelsio/cxgb4/cxgb4.h      |  1 +
>>  drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c | 17 +++++++++++++++++
>>  drivers/net/ethernet/chelsio/cxgb4/sge.c        |  5 +++--
>>  3 files changed, 21 insertions(+), 2 deletions(-)
>>
>> diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h b/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
>> index e88c180..478f25a 100644
>> --- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
>> +++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
>> @@ -521,6 +521,7 @@ enum {                                 /* adapter flags */
>>         USING_SOFT_PARAMS  = (1 << 6),
>>         MASTER_PF          = (1 << 7),
>>         FW_OFLD_CONN       = (1 << 9),
>> +       ROOT_NO_RELAXED_ORDERING = (1 << 10),
>>  };
>>
>>  enum {
>> diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
>> index 38a5c67..fbfe341 100644
>> --- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
>> +++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
>> @@ -4628,6 +4628,7 @@ static int init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
>>  #ifdef CONFIG_PCI_IOV
>>         u32 v, port_vec;
>>  #endif
>> +       struct pci_dev *root;
>>
>>         printk_once(KERN_INFO "%s - version %s\n", DRV_DESC, DRV_VERSION);
>>
>> @@ -4726,6 +4727,22 @@ static int init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
>>         adapter->msg_enable = DFLT_MSG_ENABLE;
>>         memset(adapter->chan_map, 0xff, sizeof(adapter->chan_map));
>>
>> +       /* If possible, we use PCIe Relaxed Ordering Attribute to deliver
>> +        * Ingress Packet Data to Free List Buffers in order to allow for
>> +        * chipset performance optimizations between the Root Complex and
>> +        * Memory Controllers.  (Messages to the associated Ingress Queue
>> +        * notifying new Packet Placement in the Free Lists Buffers will be
>> +        * send without the Relaxed Ordering Attribute thus guaranteing that
>> +        * all preceding PCIe Transaction Layer Packets will be processed
>> +        * first.)  But some Root Complexes have various issues with Upstream
>> +        * Transaction Layer Packets with the Relaxed Ordering Attribute set.
>> +        * So we check our Root Complex to see if it's flaged with advice
>> +        * against using Relaxed Ordering.
>> +        */
>> +       root = pci_find_pcie_root_port(adapter->pdev);
>> +       if (pcie_get_relaxed_ordering(root))
>> +               adapter->flags |= ROOT_NO_RELAXED_ORDERING;
>> +
>>         spin_lock_init(&adapter->stats_lock);
>>         spin_lock_init(&adapter->tid_release_lock);
>>         spin_lock_init(&adapter->win0_lock);
>> diff --git a/drivers/net/ethernet/chelsio/cxgb4/sge.c b/drivers/net/ethernet/chelsio/cxgb4/sge.c
>> index f05f0d4..ac229a3 100644
>> --- a/drivers/net/ethernet/chelsio/cxgb4/sge.c
>> +++ b/drivers/net/ethernet/chelsio/cxgb4/sge.c
>> @@ -2571,6 +2571,7 @@ int t4_sge_alloc_rxq(struct adapter *adap, struct sge_rspq *iq, bool fwevtq,
>>         struct fw_iq_cmd c;
>>         struct sge *s = &adap->sge;
>>         struct port_info *pi = netdev_priv(dev);
>> +       int relaxed = !(adap->flags & ROOT_NO_RELAXED_ORDERING);
>>
>>         /* Size needs to be multiple of 16, including status entry. */
>>         iq->size = roundup(iq->size, 16);
>> @@ -2624,8 +2625,8 @@ int t4_sge_alloc_rxq(struct adapter *adap, struct sge_rspq *iq, bool fwevtq,
>>
>>                 flsz = fl->size / 8 + s->stat_len / sizeof(struct tx_desc);
>>                 c.iqns_to_fl0congen |= htonl(FW_IQ_CMD_FL0PACKEN_F |
>> -                                            FW_IQ_CMD_FL0FETCHRO_F |
>> -                                            FW_IQ_CMD_FL0DATARO_F |
>> +                                            FW_IQ_CMD_FL0FETCHRO_V(relaxed) |
>> +                                            FW_IQ_CMD_FL0DATARO_V(relaxed) |
>>                                              FW_IQ_CMD_FL0PADEN_F);
>>                 if (cong >= 0)
>>                         c.iqns_to_fl0congen |=
>> --
>> 1.9.0
>>
>>
> 
> .
> 
