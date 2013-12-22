From: Ravi Patel <rapatel-qTEPVZfXA3Y@public.gmane.org>
Subject: Re: [PATCH V2 2/4] misc: xgene: Add base driver for APM X-Gene SoC
 Queue Manager/Traffic Manager
Date: Sat, 21 Dec 2013 17:45:30 -0800
Message-ID: <CAN1v_PsVdEbi4sz8n6kU+Gor0MqT3yde+t6znHjZLwf4Q_f+tw@mail.gmail.com>
References: <1387594651-25771-1-git-send-email-rapatel@apm.com>
	<1387594651-25771-3-git-send-email-rapatel@apm.com>
	<201312212104.58732.arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Greg KH <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
	jcm-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, "patches-qTEPVZfXA3Y@public.gmane.org" <patches-qTEPVZfXA3Y@public.gmane.org>,
	Keyur Chudgar <kchudgar-qTEPVZfXA3Y@public.gmane.org>
To: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <201312212104.58732.arnd-r2nGTMty4D4@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Sat, Dec 21, 2013 at 12:04 PM, Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org> wrote:
> On Saturday 21 December 2013, Ravi Patel wrote:
>> +/* CSR Address Macros */
>> +#define CSR_QM_CONFIG_ADDR   0x00000004
>> +#define  QM_ENABLE_WR(src)   (((u32)(src)<<31) & 0x80000000)
>> +
>> +#define CSR_PBM_ADDR         0x00000008
>> +#define  OVERWRITE_WR(src)   (((u32)(src)<<31) & 0x80000000)
>> +#define  SLVID_PBN_WR(src)   (((u32)(src)) & 0x000003ff)
>> +#define  SLAVE_ID_SHIFT              6
>> +
>> +#define CSR_PBM_BUF_WR_ADDR  0x0000000c
>> +#define CSR_PBM_BUF_RD_ADDR  0x00000010
>> +#define  PB_SIZE_WR(src)     (((u32)(src)<<31) & 0x80000000)
>> +#define  PREFETCH_BUF_EN_SET(dst, src) \
>> +     (((dst) & ~0x00200000) | (((u32)(src)<<21) & 0x00200000))
>> +#define  IS_FREE_POOL_SET(dst, src) \
>> +     (((dst) & ~0x00100000) | (((u32)(src)<<20) & 0x00100000))
>> +#define  TLVQ_SET(dst, src) \
>> +     (((dst) & ~0x00080000) | (((u32)(src)<<19) & 0x00080000))
>> +#define  CORRESPONDING_QNUM_SET(dst, src) \
>> +     (((dst) & ~0x0007fe00) | (((u32)(src)<<9) & 0x0007fe00))
>
> These macros are rather unreadable and unhelpful. Can't you just
> open-code them in the users?

Sure, will take of this in next patch.

>> +#define CSR_THRESHOLD0_SET1_ADDR     0x00000030
>> +#define CSR_THRESHOLD1_SET1_ADDR     0x00000034
>> +#define CSR_HYSTERESIS_ADDR          0x00000068
>> +#define CSR_QM_MBOX_NE_INT_MODE_ADDR 0x0000017c
>> +#define CSR_QMLITE_PBN_MAP_0_ADDR    0x00000228
>
> What about all the other registers in between?

All the other registers in between needs no change in values, default
values are fine.
These registers are not accessed and so we didn't defined them.
Let us know if you need them for a reason.

>> +void xgene_qmtm_wr32(struct xgene_qmtm *qmtm, u32 offset, u32 data)
>> +{
>> +     void *addr = (u8 *)qmtm->csr_vaddr + offset;
>> +     writel(data, addr);
>> +}
>
> Type mismatch: writel requires a "void __iomem*" pointer. Please check your
> driver using "sparse" to find bugs like this.

Sure, will take care of this in next patch

>> +/**
>> + * xgene_qmtm_set_qinfo - Create and configure a queue
>> + * @sdev:    Slave context
>> + * @qtype:   Queue type (P_QUEUE or FP_QUEUE)
>> + * @qsize:   Queue size see xgene_qmtm_qsize
>> + * @qaccess: Queue access method see xgene_qmtm_qaccess
>> + * @flags:   Queue Information flags
>> + * @qpaddr:  If Desire Queue Physical Address to use
>> + *
>> + * This API will be called by APM X-Gene SOC Ethernet, PktDMA (XOR Engine),
>> + * and Security Engine subsystems to create and configure a queue.
>> + *
>> + * Return:   0 on Success or -1 on Failure
>
> -1 on failure is not an appropriate return code. Please use standard
> error numbers such as -EINVAL.

Sure, will take care of this in next patch

>> +     rc = of_property_read_string(pdev->dev.of_node, "slave-name", &name);
>> +     if (rc < 0) {
>> +             dev_err(&pdev->dev, "Failed to get QMTM Ingress slave-name\n");
>> +             return rc;
>> +     }
>> +
>> +     sdev = xgene_qmtm_get_sdev((char *)name);
>> +     if (sdev == NULL) {
>> +             dev_err(&pdev->dev, "Ingress Slave error\n");
>> +             return -ENODEV;
>> +     }
>
> Why are you referring to another device by a string? Shouldn't that be a phandle?

Let me go through this and find the possibility.

>> +static struct of_device_id xgene_qmtm_match[] = {
>> +     {.compatible = "apm,xgene-qmtm-xge0",},
>> +     {.compatible = "apm,xgene-qmtm-soc",},
>> +     {.compatible = "apm,xgene-qmtm-xge2",},
>> +     {.compatible = "apm,xgene-qmtm-lite",},
>> +     {},
>> +};
>> +
>> +MODULE_DEVICE_TABLE(of, xgene_qmtm_match);
>
> You don't seem to differentiate between the four different strings. Why can't
> they just all be compatible to "apm,xgene-qmtm"?

All the QMTM manages resources for different subsystems.
So all the 4 QMTM are different, so each of them should have a unique identity.

>> +
>> +#define VIRT_TO_PHYS(x)      virt_to_phys(x)
>> +#define PHYS_TO_VIRT(x)      phys_to_virt(x)
>
> These don't belong here, use the standard functions. Also, it seems unlikely that a
> device driver actually wants physical addresses. Are these used for DMA?

The memory addresses passed in this macro/function are not used for DMA.
For creating a physical queue in the QMTM hardware, it needs the
physical address
of the queue kmalloc'ed by the driver,

>> +static struct xgene_qmtm_sdev storm_sdev[SLAVE_MAX] = {
>> +     [SLAVE_ETH0] = {
>> +                     .name = "SGMII0",
>> +                     .compatible = "apm,xgene-qmtm-soc",
>> +                     .slave = SLAVE_ETH0,
>> +                     .qmtm_ip = QMTM1,
>> +                     .slave_id = QMTM_SLAVE_ID_ETH0,
>> +                     .wq_pbn_start = 0x00,
>> +                     .wq_pbn_count = 0x08,
>> +                     .fq_pbn_start = 0x20,
>> +                     .fq_pbn_count = 0x08,
>> +                     },
>
> This table is backwards: the qmtm driver provides services to client drivers,
> it should have zero knowledge about what the clients are.
>
> Remove this array here and put the data into properties of the client
> drivers.

QMTM is managing the queue resources in its hardware for all the clients.
The clients meaning, Ethernet, PktDMA (XOR Engine) and Security Engine,
has zero knowledge of its qm resources.
So for that reason this array defining QMTM's client properties is
defined in QMTM driver

>> +     if (qinfo->flags & XGENE_SLAVE_Q_ADDR_ALLOC) {
>> +             qinfo->qdesc->qvaddr = kzalloc(qsize, GFP_KERNEL);
>> +             if (qinfo->qdesc->qvaddr == NULL) {
>> +                     kfree(qinfo->qdesc);
>> +                     rc = -ENOMEM;
>> +                     goto _ret_set_qstate;
>> +             }
>> +
>> +             qinfo->qpaddr = (u64) VIRT_TO_PHYS(qinfo->qdesc->qvaddr);
>> +     } else {
>> +             qinfo->qdesc->qvaddr = PHYS_TO_VIRT(qinfo->qpaddr);
>> +             memset(qinfo->qdesc->qvaddr, 0, qsize);
>> +     }
>
> This looks a lot like you are doing DMA. Please use the appropriate DMA
> abstractions for this.

Sure, will take are for the DMA abstraction in next revision.

>> +struct xgene_qmtm_sdev *storm_qmtm_get_sdev(char *name)
>> +{
>> +     struct xgene_qmtm *qmtm = NULL;
>> +     struct xgene_qmtm_sdev *sdev = NULL;
>> +     struct device_node *np = NULL;
>> +     struct platform_device *platdev;
>> +     u8 slave;
>> +
>> +     for (slave = 0; slave < SLAVE_MAX; slave++) {
>> +             sdev = &storm_sdev[slave];
>> +             if (sdev->name && strcmp(name, sdev->name) == 0) {
>> +                     np = of_find_compatible_node(NULL, NULL,
>> +                             sdev->compatible);
>> +                     break;
>> +             }
>> +     }
>> +
>> +     if (np == NULL)
>> +             return NULL;
>> +
>> +     platdev = of_find_device_by_node(np);
>> +     qmtm = platform_get_drvdata(platdev);
>
> Get rid of the of_find_compatible_node() here, this is another indication that
> you are doing things backwards.

Since QMTM is managing resource for its client, we have defined the mapping
in the QMTM driver.
So whenever QMTM client like Ethernet driver probe is called, it will
pass on its ID/slave-name
to get its context which is managed by QMTM

>> +/* QMTM messaging structures */
>> +/* 16 byte QMTM message format */
>> +struct xgene_qmtm_msg16 {
>> +     u32 UserInfo;
>> +
>> +     u32 FPQNum:12;
>> +     u32 Rv2:2;
>> +     u32 ELErr:2;
>> +     u32 LEI:2;
>> +     u32 NV:1;
>> +     u32 LL:1;
>> +     u32 PB:1;
>> +     u32 HB:1;
>> +     u32 Rv:1;
>> +     u32 IN:1;
>> +     u32 RType:4;
>> +     u32 LErr:3;
>> +     u32 HL:1;
>> +
>> +     u64 DataAddr:42;        /* 32/10 split */
>> +     u32 Rv6:6;
>> +     u32 BufDataLen:15;
>> +     u32 C:1;
>> +} __packed;
>
> Bitfields are generally not endian-safe. Better use raw u32 values and
> bit masks. Also don't use __packed in hardware descriptors, as it messes
> up atomicity of accesses.

I explained in another email the reason for using bit fields.
Let me know if you want me to paste it here again.

Thanks,
Ravi
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
