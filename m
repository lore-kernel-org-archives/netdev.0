From: Laurent Chavey <chavey@google.com>
Subject: Re: [PATCH 2/3] igb: add registers etc. printout code just before
	resetting adapters
Date: Thu, 7 Jan 2010 11:16:10 -0800
Message-ID: <97949e3e1001071116m3ffc8734p5285e16bcdb7b468@mail.gmail.com>
References: <4B45BBA5.8010407@jp.fujitsu.com> <4B45BF26.3020600@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Bruce Allan <bruce.w.allan@intel.com>,
	"David S. Miller" <davem@davemloft.net>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	John Ronciak <john.ronciak@intel.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	PJ Waskiewicz <peter.p.waskiewicz.jr@intel.com>,
	Koki Sanagi <sanagi.koki@jp.fujitsu.com>,
	Kenji Kaneshige <kaneshige.kenji@jp.fujitsu.com>
To: Taku Izumi <izumi.taku@jp.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.44.51]:54349 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753641Ab0AGTQe convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jan 2010 14:16:34 -0500
Received: from kpbe14.cbf.corp.google.com (kpbe14.cbf.corp.google.com [172.25.105.78])
	by smtp-out.google.com with ESMTP id o07JGW6e019164
	for <netdev@vger.kernel.org>; Thu, 7 Jan 2010 11:16:32 -0800
Received: from pwi19 (pwi19.prod.google.com [10.241.219.19])
	by kpbe14.cbf.corp.google.com with ESMTP id o07JG2nE027538
	for <netdev@vger.kernel.org>; Thu, 7 Jan 2010 11:16:31 -0800
Received: by pwi19 with SMTP id 19so13084463pwi.35
        for <netdev@vger.kernel.org>; Thu, 07 Jan 2010 11:16:30 -0800 (PST)
In-Reply-To: <4B45BF26.3020600@jp.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

since hexdump() is already in patch 1/3, could this be moved
to lib/hexdump.c (or could the code make use of hex_dump_to_buffer())

same comment as for patch1/3 for the call to igb_dump()
[use of dump_flag] I can see how it the flag is use thru out the
call but did not see how it prevents the  logging of netdev
info.

it looks like the code in each of the case statement is identical
except for some naming. Could this be converted to
a data driven table (register definition, type, dump routine.)
The later may actually be leveraged across drivers and
use full to implement some semi standard debug dump
reg tool.


2010/1/7 Taku Izumi <izumi.taku@jp.fujitsu.com>:
>
> This patch adds registers (,tx/rx rings' status and so on) printout
> code just before resetting adapters. This will be helpful for detecti=
ng
> the root cause of adapters reset.
>
> The default output is netdevice status (transstart, last_rx), registe=
rs,
> and tx/rx rings' simple information. TX/RX descriptors information an=
d
> buffer_info =A0can be output by changing the dump_flag module option,=
 but,
> of course, the amount of output becomes quite large.
>
> Signed-off-by: Taku Izumi <izumi.taku@jp.fujitsu.com>
> Signed-off-by: Koki Sanagi <sanagi.koki@jp.fujitsu.com>
> ---
> =A0drivers/net/igb/igb_main.c | =A0360 ++++++++++++++++++++++++++++++=
+++++++++++++++
> =A01 file changed, 360 insertions(+)
>
> Index: net-next-2.6/drivers/net/igb/igb_main.c
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> --- net-next-2.6.orig/drivers/net/igb/igb_main.c
> +++ net-next-2.6/drivers/net/igb/igb_main.c
> @@ -60,6 +60,14 @@ static const struct e1000_info *igb_info
> =A0 =A0 =A0 =A0[board_82575] =3D &e1000_82575_info,
> =A0};
>
> +static unsigned int dump_flag =3D 1;
> +module_param(dump_flag, uint, 0644);
> +MODULE_PARM_DESC(dump_flag, "Dump Flag");
> +#define IGB_DUMP_REGS =A0 =A0 =A0 =A0 =A0(1 << 0)
> +#define IGB_DUMP_TX_RINGS =A0 =A0 =A0(1 << 1)
> +#define IGB_DUMP_RX_RINGS =A0 =A0 =A0(1 << 2)
> +#define IGB_DUMP_BUFFERS =A0 =A0 =A0 (1 << 3)
> +
> =A0static struct pci_device_id igb_pci_tbl[] =3D {
> =A0 =A0 =A0 =A0{ PCI_VDEVICE(INTEL, E1000_DEV_ID_82580_COPPER), board=
_82575 },
> =A0 =A0 =A0 =A0{ PCI_VDEVICE(INTEL, E1000_DEV_ID_82580_FIBER), board_=
82575 },
> @@ -189,6 +197,357 @@ MODULE_DESCRIPTION("Intel(R) Gigabit Eth
> =A0MODULE_LICENSE("GPL");
> =A0MODULE_VERSION(DRV_VERSION);
>
> +static void hexdump(dma_addr_t dma, u16 len)
> +{
> + =A0 =A0 =A0 uint16_t offset, i;
> + =A0 =A0 =A0 char str[80], byte[4];
> + =A0 =A0 =A0 void *va =3D phys_to_virt((unsigned long)dma);
> +
> + =A0 =A0 =A0 printk(KERN_ERR "buffer at %016llX (%d)\n", (u64)dma, l=
en);
> + =A0 =A0 =A0 for (offset =3D 0; offset < len; offset +=3D 16) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 sprintf(str, "%04x: ", offset);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 for (i =3D 0; i < 16; i++) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if ((offset + i) < len)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 sprintf=
(byte, "%02x ",
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ((unsig=
ned char *)va)[offset + i]);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 else
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 strcpy(=
byte, " =A0 ");
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 strcat(str, byte);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 printk(KERN_ERR "%s\n", str);
> + =A0 =A0 =A0 }
> +}
> +
> +/*
> + * igb_dump - Print registers, tx-rings and rx-rings
> + */
> +static void igb_dump(struct igb_adapter *adapter)
> +{
> + =A0 =A0 =A0 struct net_device *netdev =3D adapter->netdev;
> + =A0 =A0 =A0 struct e1000_hw *hw =3D &adapter->hw;
> + =A0 =A0 =A0 u32 reg;
> + =A0 =A0 =A0 char rname[16];
> + =A0 =A0 =A0 int n =3D 0;
> + =A0 =A0 =A0 struct igb_ring *tx_ring;
> + =A0 =A0 =A0 union e1000_adv_tx_desc *tx_desc;
> + =A0 =A0 =A0 struct my_u0 { u64 a; u64 b; } *u0;
> + =A0 =A0 =A0 struct igb_buffer *buffer_info;
> + =A0 =A0 =A0 struct igb_ring *rx_ring;
> + =A0 =A0 =A0 union e1000_adv_rx_desc *rx_desc;
> + =A0 =A0 =A0 u32 staterr;
> + =A0 =A0 =A0 int i =3D 0;
> +
> + =A0 =A0 =A0 /* Print netdevice Info */
> + =A0 =A0 =A0 if (netdev) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 dev_err(&adapter->pdev->dev, "Net devic=
e Info\n");
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 printk(KERN_ERR "Device Name =A0 =A0 st=
ate =A0 =A0 =A0 =A0 =A0 =A0"
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 "trans_start =A0 =A0 =A0=
last_rx\n");
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 printk(KERN_ERR "%-15s %016lX %016lX %0=
16lX\n",
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 netdev->name,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 netdev->state,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 netdev->trans_start,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 netdev->last_rx);
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 /* Print Registers */
> + =A0 =A0 =A0 if ((dump_flag & IGB_DUMP_REGS) =3D=3D 0)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto tx_ring_summary;
> +
> + =A0 =A0 =A0 dev_err(&adapter->pdev->dev, "Register Dump\n");
> +
> + =A0 =A0 =A0 printk(KERN_ERR " Register Name =A0 [value ]\n");
> + =A0 =A0 =A0 for (reg =3D 0; reg < 0x04000; reg +=3D sizeof(u32)) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 switch (reg & 0xffffffff) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* General Registers */
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 case E1000_CTRL:
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 sprintf(rname, "CTRL");=
 break;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 case E1000_STATUS:
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 sprintf(rname, "STATUS"=
); break;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 case E1000_CTRL_EXT:
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 sprintf(rname, "CTRL_EX=
T"); break;
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* Interrupt Registers*/
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 case E1000_ICR:
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 sprintf(rname, "ICR"); =
break;
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* RX */
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 case E1000_RCTL:
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 sprintf(rname, "RCTL");=
 break;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 case E1000_RDLEN(0):
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 sprintf(rname, "RDLEN[0=
-3]");
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 printk(KERN_ERR "%-15s =
", rname);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 for (n =3D 0; n < 4; n+=
+)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 printk(=
"%08x ", rd32(E1000_RDLEN(n)));
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 printk("\n");
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 continue;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 case E1000_RDH(0):
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 sprintf(rname, "RDH[0-3=
]");
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 printk(KERN_ERR "%-15s =
", rname);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 for (n =3D 0; n < 4; n+=
+)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 printk(=
"%08x ", rd32(E1000_RDH(n)));
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 printk("\n");
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 continue;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 case E1000_RDT(0):
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 sprintf(rname, "RDT[0-3=
]");
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 printk(KERN_ERR "%-15s =
", rname);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 for (n =3D 0; n < 4; n+=
+)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 printk(=
"%08x ", rd32(E1000_RDT(n)));
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 printk("\n");
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 continue;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 case E1000_RXDCTL(0):
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 sprintf(rname, "RXDCTL[=
0-3]");
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 printk(KERN_ERR "%-15s =
", rname);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 for (n =3D 0; n < 4; n+=
+)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 printk(=
"%08x ", rd32(E1000_RXDCTL(n)));
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 printk("\n");
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 continue;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 case E1000_RDBAL(0):
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 sprintf(rname, "RDBAL[0=
-3]");
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 printk(KERN_ERR "%-15s =
", rname);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 for (n =3D 0; n < 4; n+=
+)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 printk(=
"%08x ", rd32(E1000_RDBAL(n)));
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 printk("\n");
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 continue;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 case E1000_RDBAH(0):
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 sprintf(rname, "RDBAH[0=
-3]");
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 printk(KERN_ERR "%-15s =
", rname);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 for (n =3D 0; n < 4; n+=
+)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 printk(=
"%08x ", rd32(E1000_RDBAH(n)));
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 printk("\n");
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 continue;
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* TX */
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 case E1000_TCTL:
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 sprintf(rname, "TCTL");=
 break;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 case E1000_TDBAL(0):
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 sprintf(rname, "TDBAL[0=
-3]");
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 printk(KERN_ERR "%-15s =
", rname);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 for (n =3D 0; n < 4; n+=
+)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 printk(=
"%08x ", rd32(E1000_TDBAL(n)));
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 printk("\n");
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 continue;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 case E1000_TDBAH(0):
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 sprintf(rname, "TDBAH[0=
-3]");
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 printk(KERN_ERR "%-15s =
", rname);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 for (n =3D 0; n < 4; n+=
+)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 printk(=
"%08x ", rd32(E1000_TDBAH(n)));
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 printk("\n");
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 continue;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 case E1000_TDLEN(0):
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 sprintf(rname, "TDLEN[0=
-3]");
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 printk(KERN_ERR "%-15s =
", rname);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 for (n =3D 0; n < 4; n+=
+)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 printk(=
"%08x ", rd32(E1000_TDLEN(n)));
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 printk("\n");
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 continue;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 case E1000_TDH(0):
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 sprintf(rname, "TDH[0-3=
]");
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 printk(KERN_ERR "%-15s =
", rname);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 for (n =3D 0; n < 4; n+=
+)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 printk(=
"%08x ", rd32(E1000_TDH(n)));
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 printk("\n");
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 continue;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 case E1000_TDT(0):
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 sprintf(rname, "TDT[0-3=
]");
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 printk(KERN_ERR "%-15s =
", rname);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 for (n =3D 0; n < 4; n+=
+)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 printk(=
"%08x ", rd32(E1000_TDT(n)));
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 printk("\n");
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 continue;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 case E1000_TXDCTL(0):
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 sprintf(rname, "TXDCTL[=
0-3]");
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 printk(KERN_ERR "%-15s =
", rname);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 for (n =3D 0; n < 4; n+=
+)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 printk(=
"%08x ", rd32(E1000_TXDCTL(n)));
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 printk("\n");
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 continue;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 case E1000_TDFH:
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 sprintf(rname, "TDFH");=
 break;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 case E1000_TDFT:
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 sprintf(rname, "TDFT");=
 break;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 case E1000_TDFHS:
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 sprintf(rname, "TDFHS")=
; break;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 case E1000_TDFPC:
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 sprintf(rname, "TDFPC")=
; break;
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 default:
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 continue;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 printk(KERN_ERR "%-15s %08x\n", rname,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 rd32((reg & 0xffffffff)=
));
> +
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 /* Print TX Ring Summary */
> +tx_ring_summary:
> + =A0 =A0 =A0 if (!netdev || !netif_running(netdev))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto exit;
> +
> + =A0 =A0 =A0 dev_err(&adapter->pdev->dev, "TX Rings Summary\n");
> + =A0 =A0 =A0 printk(KERN_ERR "Queue [NTU] [NTC] [bi(ntc)->dma =A0]"
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 " leng ntw timestamp\n");
> + =A0 =A0 =A0 for (n =3D 0; n < adapter->num_tx_queues; n++) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 tx_ring =3D &adapter->tx_ring[n];
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 buffer_info =3D &tx_ring->buffer_info[t=
x_ring->next_to_clean];
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 printk(KERN_ERR " %5d %5X %5X %016llX %=
04X %3X %016llX\n",
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0n, tx_ring->next=
_to_use, tx_ring->next_to_clean,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0(u64)buffer_info=
->dma,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0buffer_info->len=
gth,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0buffer_info->nex=
t_to_watch,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0(u64)buffer_info=
->time_stamp);
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 /* Print TX Rings */
> + =A0 =A0 =A0 if ((dump_flag & IGB_DUMP_TX_RINGS) =3D=3D 0)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto rx_ring_summary;
> +
> + =A0 =A0 =A0 dev_err(&adapter->pdev->dev, "TX Rings Dump\n");
> +
> + =A0 =A0 =A0 /* Transmit Descriptor Formats
> + =A0 =A0 =A0 =A0*
> + =A0 =A0 =A0 =A0* Advanced Transmit Descriptor
> + =A0 =A0 =A0 =A0* =A0 +---------------------------------------------=
-----------------+
> + =A0 =A0 =A0 =A0* 0 | =A0 =A0 =A0 =A0 Buffer Address [63:0] =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0|
> + =A0 =A0 =A0 =A0* =A0 +---------------------------------------------=
-----------------+
> + =A0 =A0 =A0 =A0* 8 | PAYLEN =A0| PORTS =A0|CC|IDX | STA | DCMD =A0|=
DTYP|MAC|RSV| DTALEN |
> + =A0 =A0 =A0 =A0* =A0 +---------------------------------------------=
-----------------+
> + =A0 =A0 =A0 =A0* =A0 63 =A0 =A0 =A046 45 =A0 =A040 39 38 36 35 32 3=
1 =A0 24 =A0 =A0 =A0 =A0 =A0 =A0 15 =A0 =A0 =A0 0
> + =A0 =A0 =A0 =A0*/
> +
> + =A0 =A0 =A0 for (n =3D 0; n < adapter->num_tx_queues; n++) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 tx_ring =3D &adapter->tx_ring[n];
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 printk(KERN_ERR "----------------------=
--------------\n");
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 printk(KERN_ERR "TX QUEUE INDEX =3D %d\=
n", tx_ring->queue_index);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 printk(KERN_ERR "----------------------=
--------------\n");
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 printk(KERN_ERR "T [desc] =A0 =A0 [addr=
ess 63:0 =A0] "
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 "[PlPOCIStDDM Ln] [bi->=
dma =A0 =A0 =A0 ] "
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 "leng =A0ntw timestamp =
=A0 =A0 =A0 =A0bi->skb\n");
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 for (i =3D 0; tx_ring->desc && (i < tx_=
ring->count); i++) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 tx_desc =3D E1000_TX_DE=
SC_ADV(*tx_ring, i);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 buffer_info =3D &tx_rin=
g->buffer_info[i];
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 u0 =3D (struct my_u0 *)=
tx_desc;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 printk(KERN_ERR "T [0x%=
03X] =A0 =A0%016llX %016llX %016llX"
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 " %04X =
=A0%3X %016llX %p", i,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 le64_to=
_cpu(u0->a),
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 le64_to=
_cpu(u0->b),
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 (u64)bu=
ffer_info->dma,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 buffer_=
info->length,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 buffer_=
info->next_to_watch,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 (u64)bu=
ffer_info->time_stamp,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 buffer_=
info->skb);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (i =3D=3D tx_ring->n=
ext_to_use &&
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 i =3D=3D=
 tx_ring->next_to_clean)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 printk(=
" NTC/U\n");
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 else if (i =3D=3D tx_ri=
ng->next_to_use)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 printk(=
" NTU\n");
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 else if (i =3D=3D tx_ri=
ng->next_to_clean)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 printk(=
" NTC\n");
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 else
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 printk(=
"\n");
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if ((dump_flag & IGB_DU=
MP_BUFFERS) &&
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 buffer_=
info->dma !=3D 0)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 hexdump=
(buffer_info->dma, buffer_info->length);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 /* Print RX Rings Summary */
> +rx_ring_summary:
> + =A0 =A0 =A0 dev_err(&adapter->pdev->dev, "RX Rings Summary\n");
> + =A0 =A0 =A0 printk(KERN_ERR "Queue [NTU] [NTC]\n");
> + =A0 =A0 =A0 for (n =3D 0; n < adapter->num_rx_queues; n++) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 rx_ring =3D &adapter->rx_ring[n];
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 printk(KERN_ERR " %5d %5X %5X\n", n,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0rx_ring->next_to=
_use, rx_ring->next_to_clean);
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 /* Print RX Rings */
> + =A0 =A0 =A0 if ((dump_flag & IGB_DUMP_RX_RINGS) =3D=3D 0)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto exit;
> +
> + =A0 =A0 =A0 dev_err(&adapter->pdev->dev, "RX Rings Dump\n");
> +
> + =A0 =A0 =A0 /* Advanced Receive Descriptor (Read) Format
> + =A0 =A0 =A0 =A0* =A0 =A063 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 1 =A0 =A0 =A0 =A00
> + =A0 =A0 =A0 =A0* =A0 =A0+------------------------------------------=
-----------+
> + =A0 =A0 =A0 =A0* =A00 | =A0 =A0 =A0 Packet Buffer Address [63:1] =A0=
 =A0 =A0 =A0 =A0 |A0/NSE|
> + =A0 =A0 =A0 =A0* =A0 =A0+------------------------------------------=
----+------+
> + =A0 =A0 =A0 =A0* =A08 | =A0 =A0 =A0 Header Buffer Address [63:1] =A0=
 =A0 =A0 =A0 =A0 | =A0DD =A0|
> + =A0 =A0 =A0 =A0* =A0 =A0+------------------------------------------=
-----------+
> + =A0 =A0 =A0 =A0*
> + =A0 =A0 =A0 =A0*
> + =A0 =A0 =A0 =A0* Advanced Receive Descriptor (Write-Back) Format
> + =A0 =A0 =A0 =A0*
> + =A0 =A0 =A0 =A0* =A0 63 =A0 =A0 =A0 48 47 =A0 =A032 31 =A030 =A0 =A0=
 =A021 20 17 16 =A0 4 3 =A0 =A0 0
> + =A0 =A0 =A0 =A0* =A0 +---------------------------------------------=
---------+
> + =A0 =A0 =A0 =A0* 0 | Packet =A0 =A0 IP =A0 =A0 |SPH| HDR_LEN =A0 | =
RSV|Packet| =A0RSS |
> + =A0 =A0 =A0 =A0* =A0 | Checksum =A0 Ident =A0| =A0 | =A0 =A0 =A0 =A0=
 =A0 | =A0 =A0| Type | Type |
> + =A0 =A0 =A0 =A0* =A0 +---------------------------------------------=
---------+
> + =A0 =A0 =A0 =A0* 8 | VLAN Tag | Length | Extended Error | Extended =
Status |
> + =A0 =A0 =A0 =A0* =A0 +---------------------------------------------=
---------+
> + =A0 =A0 =A0 =A0* =A0 63 =A0 =A0 =A0 48 47 =A0 =A032 31 =A0 =A0 =A0 =
=A0 =A0 =A020 19 =A0 =A0 =A0 =A0 =A0 =A0 =A0 0
> + =A0 =A0 =A0 =A0*/
> +
> + =A0 =A0 =A0 for (n =3D 0; n < adapter->num_rx_queues; n++) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 rx_ring =3D &adapter->rx_ring[n];
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 printk(KERN_ERR "----------------------=
--------------\n");
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 printk(KERN_ERR "RX QUEUE INDEX =3D %d\=
n", rx_ring->queue_index);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 printk(KERN_ERR "----------------------=
--------------\n");
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 printk(KERN_ERR "R =A0[desc] =A0 =A0 =A0=
[ PktBuf =A0 =A0 A0] "
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 "[ =A0HeadBuf =A0 DD] [=
bi->dma =A0 =A0 =A0 ] [bi->skb] "
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 "<-- Adv Rx Read format=
\n");
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 printk(KERN_ERR "RWB[desc] =A0 =A0 =A0[=
PcsmIpSHl PtRs] "
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 "[vl er S cks ln] -----=
----------- [bi->skb] "
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 "<-- Adv Rx Write-Back =
format\n");
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 for (i =3D 0; i < rx_ring->count; i++) =
{
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 buffer_info =3D &rx_rin=
g->buffer_info[i];
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 rx_desc =3D E1000_RX_DE=
SC_ADV(*rx_ring, i);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 u0 =3D (struct my_u0 *)=
rx_desc;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 staterr =3D le32_to_cpu=
(rx_desc->wb.upper.status_error);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (staterr & E1000_RXD=
_STAT_DD) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* Desc=
riptor Done */
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 printk(=
KERN_ERR "RWB[0x%03X] =A0 =A0 %016llX "
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 "%016llX ---------------- %p", i,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 le64_to_cpu(u0->a),
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 le64_to_cpu(u0->b),
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 buffer_info->skb);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 } else {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 printk(=
KERN_ERR "R =A0[0x%03X] =A0 =A0 %016llX "
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 "%016llX %016llX %p", i,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 le64_to_cpu(u0->a),
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 le64_to_cpu(u0->b),
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 (u64)buffer_info->dma,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 buffer_info->skb);
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (dum=
p_flag & IGB_DUMP_BUFFERS) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 hexdump(buffer_info->dma,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 rx_ring->rx_buffer_len);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 if (rx_ring->rx_buffer_len
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 < IGB_RXBUFFER_1024)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 hexdump(buffer_info->page_dma +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0buffer_info->page_offset,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0PAGE_SIZE/2);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (i =3D=3D rx_ring->n=
ext_to_use)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 printk(=
" NTU\n");
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 else if (i =3D=3D rx_ri=
ng->next_to_clean)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 printk(=
" NTC\n");
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 else
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 printk(=
"\n");
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> + =A0 =A0 =A0 }
> +
> +exit:
> + =A0 =A0 =A0 return;
> +}
> +
> +
> =A0/**
> =A0* igb_read_clock - read raw cycle counter (to be used by time coun=
ter)
> =A0*/
> @@ -3859,6 +4218,7 @@ static void igb_reset_task(struct work_s
> =A0 =A0 =A0 =A0struct igb_adapter *adapter;
> =A0 =A0 =A0 =A0adapter =3D container_of(work, struct igb_adapter, res=
et_task);
>
> + =A0 =A0 =A0 igb_dump(adapter);
> =A0 =A0 =A0 =A0igb_reinit_locked(adapter);
> =A0}
>
>
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
>
