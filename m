From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH V2 2/4] misc: xgene: Add base driver for APM X-Gene SoC Queue Manager/Traffic Manager
Date: Sun, 22 Dec 2013 07:54:40 +0100
Message-ID: <1671121.m7aRMI6X8q@wuerfel>
References: <1387594651-25771-1-git-send-email-rapatel@apm.com> <201312212104.58732.arnd@arndb.de> <CAN1v_PsVdEbi4sz8n6kU+Gor0MqT3yde+t6znHjZLwf4Q_f+tw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: Greg KH <gregkh@linuxfoundation.org>, davem@davemloft.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	devicetree@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	jcm@redhat.com, "patches@apm.com" <patches@apm.com>,
	Keyur Chudgar <kchudgar@apm.com>
To: Ravi Patel <rapatel@apm.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAN1v_PsVdEbi4sz8n6kU+Gor0MqT3yde+t6znHjZLwf4Q_f+tw@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Saturday 21 December 2013 17:45:30 Ravi Patel wrote:
> On Sat, Dec 21, 2013 at 12:04 PM, Arnd Bergmann <arnd@arndb.de> wrote:
> > On Saturday 21 December 2013, Ravi Patel wrote:
> 
> >> +#define CSR_THRESHOLD0_SET1_ADDR     0x00000030
> >> +#define CSR_THRESHOLD1_SET1_ADDR     0x00000034
> >> +#define CSR_HYSTERESIS_ADDR          0x00000068
> >> +#define CSR_QM_MBOX_NE_INT_MODE_ADDR 0x0000017c
> >> +#define CSR_QMLITE_PBN_MAP_0_ADDR    0x00000228
> >
> > What about all the other registers in between?
> 
> All the other registers in between needs no change in values, default
> values are fine.
> These registers are not accessed and so we didn't defined them.
> Let us know if you need them for a reason.

Ok, this is fine. I was just making sure there isn't another driver
that talks to these registers.

> >> +     rc = of_property_read_string(pdev->dev.of_node, "slave-name", &name);
> >> +     if (rc < 0) {
> >> +             dev_err(&pdev->dev, "Failed to get QMTM Ingress slave-name\n");
> >> +             return rc;
> >> +     }
> >> +
> >> +     sdev = xgene_qmtm_get_sdev((char *)name);
> >> +     if (sdev == NULL) {
> >> +             dev_err(&pdev->dev, "Ingress Slave error\n");
> >> +             return -ENODEV;
> >> +     }
> >
> > Why are you referring to another device by a string? Shouldn't that be a phandle?
> 
> Let me go through this and find the possibility.

To clarify, I think the slave driver should look up a phandle to find
the qmtm device.

> >> +static struct of_device_id xgene_qmtm_match[] = {
> >> +     {.compatible = "apm,xgene-qmtm-xge0",},
> >> +     {.compatible = "apm,xgene-qmtm-soc",},
> >> +     {.compatible = "apm,xgene-qmtm-xge2",},
> >> +     {.compatible = "apm,xgene-qmtm-lite",},
> >> +     {},
> >> +};
> >> +
> >> +MODULE_DEVICE_TABLE(of, xgene_qmtm_match);
> >
> > You don't seem to differentiate between the four different strings. Why can't
> > they just all be compatible to "apm,xgene-qmtm"?
> 
> All the QMTM manages resources for different subsystems.
> So all the 4 QMTM are different, so each of them should have a unique identity.

Are you sure it's not just four instances of the same hardware block
connected to different slaves?

The "compatible" value should only identify differences in the register set.

> >> +#define VIRT_TO_PHYS(x)      virt_to_phys(x)
> >> +#define PHYS_TO_VIRT(x)      phys_to_virt(x)
> >
> > These don't belong here, use the standard functions. Also, it seems unlikely that a
> > device driver actually wants physical addresses. Are these used for DMA?
> 
> The memory addresses passed in this macro/function are not used for DMA.
> For creating a physical queue in the QMTM hardware, it needs the
> physical address
> of the queue kmalloc'ed by the driver,

Who is accessing the physical address then? Does this get passed to
some sort of hypervisor?

> >> +static struct xgene_qmtm_sdev storm_sdev[SLAVE_MAX] = {
> >> +     [SLAVE_ETH0] = {
> >> +                     .name = "SGMII0",
> >> +                     .compatible = "apm,xgene-qmtm-soc",
> >> +                     .slave = SLAVE_ETH0,
> >> +                     .qmtm_ip = QMTM1,
> >> +                     .slave_id = QMTM_SLAVE_ID_ETH0,
> >> +                     .wq_pbn_start = 0x00,
> >> +                     .wq_pbn_count = 0x08,
> >> +                     .fq_pbn_start = 0x20,
> >> +                     .fq_pbn_count = 0x08,
> >> +                     },
> >
> > This table is backwards: the qmtm driver provides services to client drivers,
> > it should have zero knowledge about what the clients are.
> >
> > Remove this array here and put the data into properties of the client
> > drivers.
> 
> QMTM is managing the queue resources in its hardware for all the clients.
> The clients meaning, Ethernet, PktDMA (XOR Engine) and Security Engine,
> has zero knowledge of its qm resources.
> So for that reason this array defining QMTM's client properties is
> defined in QMTM driver

No, that's the wrong way around. Please have a look at how other
subsystems (irq, dmaengine, clock, ...) manage the split between
knowledge.

> >> +struct xgene_qmtm_sdev *storm_qmtm_get_sdev(char *name)
> >> +{
> >> +     struct xgene_qmtm *qmtm = NULL;
> >> +     struct xgene_qmtm_sdev *sdev = NULL;
> >> +     struct device_node *np = NULL;
> >> +     struct platform_device *platdev;
> >> +     u8 slave;
> >> +
> >> +     for (slave = 0; slave < SLAVE_MAX; slave++) {
> >> +             sdev = &storm_sdev[slave];
> >> +             if (sdev->name && strcmp(name, sdev->name) == 0) {
> >> +                     np = of_find_compatible_node(NULL, NULL,
> >> +                             sdev->compatible);
> >> +                     break;
> >> +             }
> >> +     }
> >> +
> >> +     if (np == NULL)
> >> +             return NULL;
> >> +
> >> +     platdev = of_find_device_by_node(np);
> >> +     qmtm = platform_get_drvdata(platdev);
> >
> > Get rid of the of_find_compatible_node() here, this is another indication that
> > you are doing things backwards.
> 
> Since QMTM is managing resource for its client, we have defined the mapping
> in the QMTM driver.
> So whenever QMTM client like Ethernet driver probe is called, it will
> pass on its ID/slave-name
> to get its context which is managed by QMTM

The client/slave driver should instead pass the slave ID and other
required information, essentially the stuff from the table above,
in an abstract form.

> >> +/* QMTM messaging structures */
> >> +/* 16 byte QMTM message format */
> >> +struct xgene_qmtm_msg16 {
> >> +     u32 UserInfo;
> >> +
> >> +     u32 FPQNum:12;
> >> +     u32 Rv2:2;
> >> +     u32 ELErr:2;
> >> +     u32 LEI:2;
> >> +     u32 NV:1;
> >> +     u32 LL:1;
> >> +     u32 PB:1;
> >> +     u32 HB:1;
> >> +     u32 Rv:1;
> >> +     u32 IN:1;
> >> +     u32 RType:4;
> >> +     u32 LErr:3;
> >> +     u32 HL:1;
> >> +
> >> +     u64 DataAddr:42;        /* 32/10 split */
> >> +     u32 Rv6:6;
> >> +     u32 BufDataLen:15;
> >> +     u32 C:1;
> >> +} __packed;
> >
> > Bitfields are generally not endian-safe. Better use raw u32 values and
> > bit masks. Also don't use __packed in hardware descriptors, as it messes
> > up atomicity of accesses.
> 
> I explained in another email the reason for using bit fields.
> Let me know if you want me to paste it here again.

No need for that. But driver code really needs to be written in an
endian-neutral way if the CPU supports both little-endian and
big-endian modes.

	Arnd
