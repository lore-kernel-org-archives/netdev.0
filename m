From: Laurent Chavey <chavey@google.com>
Subject: Re: [PATCH 1/3] e1000e: add registers etc. printout code just before
	resetting adapters
Date: Thu, 7 Jan 2010 11:00:15 -0800
Message-ID: <97949e3e1001071100u166b6178v580b60e027de9f59@mail.gmail.com>
References: <4B45BBA5.8010407@jp.fujitsu.com> <4B45BEF6.6000400@jp.fujitsu.com>
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
Received: from smtp-out.google.com ([216.239.33.17]:3366 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751317Ab0AGTAk convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jan 2010 14:00:40 -0500
Received: from kpbe12.cbf.corp.google.com (kpbe12.cbf.corp.google.com [172.25.105.76])
	by smtp-out.google.com with ESMTP id o07J0a4k017095
	for <netdev@vger.kernel.org>; Thu, 7 Jan 2010 19:00:37 GMT
Received: from pzk4 (pzk4.prod.google.com [10.243.19.132])
	by kpbe12.cbf.corp.google.com with ESMTP id o07IxsRN014659
	for <netdev@vger.kernel.org>; Thu, 7 Jan 2010 11:00:35 -0800
Received: by pzk4 with SMTP id 4so2494699pzk.32
        for <netdev@vger.kernel.org>; Thu, 07 Jan 2010 11:00:35 -0800 (PST)
In-Reply-To: <4B45BEF6.6000400@jp.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

can the call to e1000e_dump(adapter) be
set at runtime / compile time  to only be call
when in debug mode (however debug mode is
defined).

why not add all the new registers
+#define E1000_RDFH     0x02410 etc...
to e1000_hw.h



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
> =A0drivers/net/e1000e/netdev.c | =A0386 +++++++++++++++++++++++++++++=
+++++++++++++++
> =A01 file changed, 386 insertions(+)
> Index: net-next-2.6/drivers/net/e1000e/netdev.c
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> --- net-next-2.6.orig/drivers/net/e1000e/netdev.c
> +++ net-next-2.6/drivers/net/e1000e/netdev.c
> @@ -52,6 +52,14 @@
> =A0char e1000e_driver_name[] =3D "e1000e";
> =A0const char e1000e_driver_version[] =3D DRV_VERSION;
>
> +static unsigned int dump_flag =3D 1;
> +module_param(dump_flag, uint, 0644);
> +MODULE_PARM_DESC(dump_flag, "Dump Flag");
> +#define E1000_DUMP_REGS =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0(1 << 0)
> +#define E1000_DUMP_TX_RINGS =A0 =A0(1 << 1)
> +#define E1000_DUMP_RX_RINGS =A0 =A0(1 << 2)
> +#define E1000_DUMP_BUFFERS =A0 =A0 (1 << 3)
> +
> =A0static const struct e1000_info *e1000_info_tbl[] =3D {
> =A0 =A0 =A0 =A0[board_82571] =A0 =A0 =A0 =A0 =A0 =3D &e1000_82571_inf=
o,
> =A0 =A0 =A0 =A0[board_82572] =A0 =A0 =A0 =A0 =A0 =3D &e1000_82572_inf=
o,
> @@ -65,6 +73,383 @@ static const struct e1000_info *e1000_in
> =A0 =A0 =A0 =A0[board_pchlan] =A0 =A0 =A0 =A0 =A0=3D &e1000_pch_info,
> =A0};
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
> + * e1000e_dump - Print registers, tx-ring and rx-ring
> + */
> +static void e1000e_dump(struct e1000_adapter *adapter)
> +{
> + =A0 =A0 =A0 struct net_device *netdev =3D adapter->netdev;
> + =A0 =A0 =A0 struct e1000_hw *hw =3D &adapter->hw;
> + =A0 =A0 =A0 u32 reg;
> + =A0 =A0 =A0 char rname[16];
> + =A0 =A0 =A0 int n =3D 0;
> + =A0 =A0 =A0 struct e1000_ring *tx_ring =3D adapter->tx_ring;
> + =A0 =A0 =A0 struct e1000_tx_desc *tx_desc;
> + =A0 =A0 =A0 struct my_u0 { u64 a; u64 b; } *u0;
> + =A0 =A0 =A0 struct e1000_buffer *buffer_info;
> + =A0 =A0 =A0 struct e1000_ring *rx_ring =3D adapter->rx_ring;
> + =A0 =A0 =A0 union e1000_rx_desc_packet_split *rx_desc_ps;
> + =A0 =A0 =A0 struct e1000_rx_desc *rx_desc;
> + =A0 =A0 =A0 struct my_u1 { u64 a; u64 b; u64 c; u64 d; } *u1;
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
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 netdev->name,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 netdev->state,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 netdev->trans_start,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 netdev->last_rx);
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 /* Print Registers */
> + =A0 =A0 =A0 if ((dump_flag & E1000_DUMP_REGS) =3D=3D 0)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto tx_ring_summary;
> +
> + =A0 =A0 =A0 dev_err(&adapter->pdev->dev, "Register Dump\n");
> +
> +#define E1000_RDFH =A0 =A0 0x02410
> +#define E1000_RDFT =A0 =A0 0x02418
> +#define E1000_RDFHS =A0 =A00x02420
> +#define E1000_RDFTS =A0 =A00x02428
> +#define E1000_RDFPC =A0 =A00x02430
> +
> +#define E1000_TDFH =A0 =A0 0x03410
> +#define E1000_TDFT =A0 =A0 0x03418
> +#define E1000_TDFHS =A0 =A00x03420
> +#define E1000_TDFTS =A0 =A00x03428
> +#define E1000_TDFPC =A0 =A00x03430
> +
> + =A0 =A0 =A0 printk(KERN_ERR " Register Name =A0 [value ]\n");
> + =A0 =A0 =A0 for (reg =3D 0; reg < 0x04000; reg +=3D sizeof(u32)) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 switch (reg & 0xffffffff) {
> +
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
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 case E1000_RDLEN:
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 sprintf(rname, "RDLEN")=
; break;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 case E1000_RDH:
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 sprintf(rname, "RDH"); =
break;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 case E1000_RDT:
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 sprintf(rname, "RDT"); =
break;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 case E1000_RDTR:
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 sprintf(rname, "RDTR");=
 break;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 case E1000_RXDCTL(0):
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 sprintf(rname, "RXDCTL[=
0]"); break;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 case E1000_ERT:
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 sprintf(rname, "ERT"); =
break;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 case E1000_RDBAL:
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 sprintf(rname, "RDBAL")=
; break;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 case E1000_RDBAH:
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 sprintf(rname, "RDBAH")=
; break;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 case E1000_RDFH:
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 sprintf(rname, "RDFH");=
 break;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 case E1000_RDFT:
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 sprintf(rname, "RDFT");=
 break;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 case E1000_RDFHS:
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 sprintf(rname, "RDFHS")=
; break;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 case E1000_RDFTS:
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 sprintf(rname, "RDFTS")=
; break;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 case E1000_RDFPC:
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 sprintf(rname, "RDFPC")=
; break;
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* TX */
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 case E1000_TCTL:
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 sprintf(rname, "TCTL");=
 break;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 case E1000_TDBAL:
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 sprintf(rname, "TDBAL")=
; break;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 case E1000_TDBAH:
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 sprintf(rname, "TDBAH")=
; break;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 case E1000_TDLEN:
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 sprintf(rname, "TDLEN")=
; break;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 case E1000_TDH:
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 sprintf(rname, "TDH"); =
break;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 case E1000_TDT:
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 sprintf(rname, "TDT"); =
break;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 case E1000_TIDV:
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 sprintf(rname, "TIDV");=
 break;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 case E1000_TXDCTL(0):
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 sprintf(rname, "TXDCTL[=
0-1]");
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 printk(KERN_ERR "%-15s =
", rname);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 for (n =3D 0; n < 2; n+=
+)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 printk(=
"%08x ", readl(hw->hw_addr +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 (reg & 0xffffffff)));
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 printk("\n");
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 continue;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 case E1000_TADV:
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 sprintf(rname, "TADV");=
 break;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 case E1000_TARC(0):
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 sprintf(rname, "TARC[0-=
1]");
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 printk(KERN_ERR "%-15s =
", rname);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 for (n =3D 0; n < 2; n+=
+)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 printk(=
"%08x ", readl(hw->hw_addr +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 (reg & 0xffffffff)));
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
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 case E1000_TDFTS:
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 sprintf(rname, "TDFTS")=
; break;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 case E1000_TDFPC:
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 sprintf(rname, "TDFPC")=
; break;
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 default:
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 continue;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 printk(KERN_ERR "%-15s %08x\n", rname,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 readl(hw->hw_addr + (re=
g & 0xffffffff)));
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
> + =A0 =A0 =A0 buffer_info =3D &tx_ring->buffer_info[tx_ring->next_to_=
clean];
> + =A0 =A0 =A0 printk(KERN_ERR " %5d %5X %5X %016llX %04X %3X %016llX\=
n",
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 0, tx_ring->next_to_use, tx_ring->next_=
to_clean,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 (u64)buffer_info->dma,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 buffer_info->length,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 buffer_info->next_to_watch,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 (u64)buffer_info->time_stamp);
> +
> + =A0 =A0 =A0 /* Print TX Rings */
> + =A0 =A0 =A0 if ((dump_flag & E1000_DUMP_TX_RINGS) =3D=3D 0)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto rx_ring_summary;
> +
> + =A0 =A0 =A0 dev_err(&adapter->pdev->dev, "TX Rings Dump\n");
> +
> + =A0 =A0 =A0 /* Transmit Descriptor Formats - DEXT[29] is 0 (Legacy)=
 or 1 (Extended)
> + =A0 =A0 =A0 =A0*
> + =A0 =A0 =A0 =A0* Legacy Transmit Descriptor
> + =A0 =A0 =A0 =A0* =A0 +---------------------------------------------=
-----------------+
> + =A0 =A0 =A0 =A0* 0 | =A0 =A0 =A0 =A0 Buffer Address [63:0] (Reserve=
d on Write Back) =A0 =A0 =A0 |
> + =A0 =A0 =A0 =A0* =A0 +---------------------------------------------=
-----------------+
> + =A0 =A0 =A0 =A0* 8 | Special =A0| =A0 =A0CSS =A0 =A0 | Status | =A0=
CMD =A0 =A0| =A0CSO =A0 | =A0Length =A0|
> + =A0 =A0 =A0 =A0* =A0 +---------------------------------------------=
-----------------+
> + =A0 =A0 =A0 =A0* =A0 63 =A0 =A0 =A0 48 47 =A0 =A0 =A0 =A036 35 =A0 =
=A032 31 =A0 =A0 24 23 =A0 =A016 15 =A0 =A0 =A0 =A00
> + =A0 =A0 =A0 =A0*
> + =A0 =A0 =A0 =A0* Extended Context Descriptor (DTYP=3D0x0) for TSO o=
r checksum offload
> + =A0 =A0 =A0 =A0* =A0 63 =A0 =A0 =A048 47 =A0 =A040 39 =A0 =A0 =A0 3=
2 31 =A0 =A0 =A0 =A0 =A0 =A0 16 15 =A0 =A08 7 =A0 =A0 =A00
> + =A0 =A0 =A0 =A0* =A0 +---------------------------------------------=
-------------------+
> + =A0 =A0 =A0 =A0* 0 | =A0TUCSE =A0| TUCS0 =A0| =A0 TUCSS =A0 | =A0 =A0=
 IPCSE =A0 =A0 =A0 | IPCS0 | IPCSS |
> + =A0 =A0 =A0 =A0* =A0 +---------------------------------------------=
-------------------+
> + =A0 =A0 =A0 =A0* 8 | =A0 MSS =A0 | HDRLEN | RSV | STA | TUCMD | DTY=
P | =A0 =A0 =A0PAYLEN =A0 =A0 =A0|
> + =A0 =A0 =A0 =A0* =A0 +---------------------------------------------=
-------------------+
> + =A0 =A0 =A0 =A0* =A0 63 =A0 =A0 =A048 47 =A0 =A040 39 36 35 32 31 =A0=
 24 23 =A020 19 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A00
> + =A0 =A0 =A0 =A0*
> + =A0 =A0 =A0 =A0* Extended Data Descriptor (DTYP=3D0x1)
> + =A0 =A0 =A0 =A0* =A0 +---------------------------------------------=
-------------------+
> + =A0 =A0 =A0 =A0* 0 | =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 Buffer=
 Address [63:0] =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0|
> + =A0 =A0 =A0 =A0* =A0 +---------------------------------------------=
-------------------+
> + =A0 =A0 =A0 =A0* 8 | VLAN tag | =A0POPTS =A0| Rsvd | Status | Comma=
nd | DTYP | =A0DTALEN =A0|
> + =A0 =A0 =A0 =A0* =A0 +---------------------------------------------=
-------------------+
> + =A0 =A0 =A0 =A0* =A0 63 =A0 =A0 =A0 48 47 =A0 =A0 40 39 =A036 35 =A0=
 =A032 31 =A0 =A0 24 23 =A020 19 =A0 =A0 =A0 =A00
> + =A0 =A0 =A0 =A0*/
> + =A0 =A0 =A0 printk(KERN_ERR "Tl[desc] =A0 =A0 [address 63:0 =A0] [S=
peCssSCmCsLen]"
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 " [bi->dma =A0 =A0 =A0 ] leng =A0ntw ti=
mestamp =A0 =A0 =A0 =A0bi->skb "
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 "<-- Legacy format\n");
> + =A0 =A0 =A0 printk(KERN_ERR "Tc[desc] =A0 =A0 [Ce CoCsIpceCoS] [Mss=
HlRSCm0Plen]"
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 " [bi->dma =A0 =A0 =A0 ] leng =A0ntw ti=
mestamp =A0 =A0 =A0 =A0bi->skb "
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 "<-- Ext Context format\n");
> + =A0 =A0 =A0 printk(KERN_ERR "Td[desc] =A0 =A0 [address 63:0 =A0] [V=
laPoRSCm1Dlen]"
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 " [bi->dma =A0 =A0 =A0 ] leng =A0ntw ti=
mestamp =A0 =A0 =A0 =A0bi->skb "
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 "<-- Ext Data format\n");
> + =A0 =A0 =A0 for (i =3D 0; tx_ring->desc && (i < tx_ring->count); i+=
+) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 tx_desc =3D E1000_TX_DESC(*tx_ring, i);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 buffer_info =3D &tx_ring->buffer_info[i=
];
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 u0 =3D (struct my_u0 *)tx_desc;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 printk(KERN_ERR "T%c[0x%03X] =A0 =A0%01=
6llX %016llX %016llX "
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 "%04X =A0%3X %016llX %p=
",
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0(!(le64_to_cpu(u0->b) & =
(1<<29)) ? 'l' :
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ((le64_to_cpu(u0->b) & =
(1<<20)) ? 'd' : 'c')), i,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0le64_to_cpu(u0->a), le64=
_to_cpu(u0->b),
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0(u64)buffer_info->dma, b=
uffer_info->length,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0buffer_info->next_to_wat=
ch, (u64)buffer_info->time_stamp,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0buffer_info->skb);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (i =3D=3D tx_ring->next_to_use && i =
=3D=3D tx_ring->next_to_clean)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 printk(" NTC/U\n");
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 else if (i =3D=3D tx_ring->next_to_use)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 printk(" NTU\n");
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 else if (i =3D=3D tx_ring->next_to_clea=
n)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 printk(" NTC\n");
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 else
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 printk("\n");
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if ((dump_flag & E1000_DUMP_BUFFERS) &&=
 buffer_info->dma !=3D 0)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 hexdump(buffer_info->dm=
a, buffer_info->length);
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 /* Print RX Rings Summary */
> +rx_ring_summary:
> + =A0 =A0 =A0 dev_err(&adapter->pdev->dev, "RX Rings Summary\n");
> + =A0 =A0 =A0 printk(KERN_ERR "Queue [NTU] [NTC]\n");
> + =A0 =A0 =A0 printk(KERN_ERR " %5d %5X %5X\n", 0,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 rx_ring->next_to_use, rx_ring->next_to_=
clean);
> +
> + =A0 =A0 =A0 /* Print RX Rings */
> + =A0 =A0 =A0 if ((dump_flag & E1000_DUMP_RX_RINGS) =3D=3D 0)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto exit;
> +
> + =A0 =A0 =A0 dev_err(&adapter->pdev->dev, "RX Rings Dump\n");
> + =A0 =A0 =A0 switch (adapter->rx_ps_pages) {
> + =A0 =A0 =A0 case 1:
> + =A0 =A0 =A0 case 2:
> + =A0 =A0 =A0 case 3:
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* [Extended] Packet Split Receive Desc=
riptor Format
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* =A0 =A0+--------------------------=
---------------------------+
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* =A00 | =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0Buffer Address 0 [63:0] =A0 =A0 =A0 =A0 =A0 =A0 =A0|
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* =A0 =A0+--------------------------=
---------------------------+
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* =A08 | =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0Buffer Address 1 [63:0] =A0 =A0 =A0 =A0 =A0 =A0 =A0|
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* =A0 =A0+--------------------------=
---------------------------+
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* 16 | =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
Buffer Address 2 [63:0] =A0 =A0 =A0 =A0 =A0 =A0 =A0|
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* =A0 =A0+--------------------------=
---------------------------+
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* 24 | =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
Buffer Address 3 [63:0] =A0 =A0 =A0 =A0 =A0 =A0 =A0|
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* =A0 =A0+--------------------------=
---------------------------+
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*/
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 printk(KERN_ERR "R =A0[desc] =A0 =A0 =A0=
[buffer 0 63:0 ] "
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 "[buffer 1 63:0 ] "
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0"[buffer 2 63:0 ] [buffe=
r 3 63:0 ] [bi->dma =A0 =A0 =A0 ] "
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0"[bi->skb] <-- Ext Pkt S=
plit format\n");
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* [Extended] Receive Descriptor (Write=
-Back) Format
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* =A0 63 =A0 =A0 =A0 48 47 =A0 =A032=
 31 =A0 =A0 13 12 =A0 =A08 7 =A0 =A04 3 =A0 =A0 =A0 =A00
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* =A0 +-----------------------------=
-------------------------+
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* 0 | Packet =A0 | IP =A0 =A0 | =A0R=
svd =A0 | MRQ =A0 | Rsvd | MRQ RSS |
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* =A0 | Checksum | Ident =A0| =A0 =A0=
 =A0 =A0 | Queue | =A0 =A0 =A0| =A0Type =A0 |
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* =A0 +-----------------------------=
-------------------------+
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* 8 | VLAN Tag | Length | Extended E=
rror | Extended Status |
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* =A0 +-----------------------------=
-------------------------+
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* =A0 63 =A0 =A0 =A0 48 47 =A0 =A032=
 31 =A0 =A0 =A0 =A0 =A0 =A020 19 =A0 =A0 =A0 =A0 =A0 =A0 =A0 0
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*/
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 printk(KERN_ERR "RWB[desc] =A0 =A0 =A0[=
ck ipid mrqhsh] "
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 "[vl =A0 l0 ee =A0es] "
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0"[ l3 =A0l2 =A0l1 hs] [r=
eserved =A0 =A0 =A0] ---------------- "
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0"[bi->skb] <-- Ext Rx Wr=
ite-Back format\n");
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 for (i =3D 0; i < rx_ring->count; i++) =
{
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 buffer_info =3D &rx_rin=
g->buffer_info[i];
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 rx_desc_ps =3D E1000_RX=
_DESC_PS(*rx_ring, i);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 u1 =3D (struct my_u1 *)=
rx_desc_ps;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 staterr =3D
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 le32_to=
_cpu(rx_desc_ps->wb.middle.status_error);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (staterr & E1000_RXD=
_STAT_DD) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* Desc=
riptor Done */
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 printk(=
KERN_ERR "RWB[0x%03X] =A0 =A0 %016llX "
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 "%016llX %016llX %016llX "
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 "---------------- %p", i,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 le64_to_cpu(u1->a),
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 le64_to_cpu(u1->b),
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 le64_to_cpu(u1->c),
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 le64_to_cpu(u1->d),
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 buffer_info->skb);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 } else {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 printk(=
KERN_ERR "R =A0[0x%03X] =A0 =A0 %016llX "
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 "%016llX %016llX %016llX %016llX %p", i,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 le64_to_cpu(u1->a),
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 le64_to_cpu(u1->b),
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 le64_to_cpu(u1->c),
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 le64_to_cpu(u1->d),
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 (u64)buffer_info->dma,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 buffer_info->skb);
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (dum=
p_flag & E1000_DUMP_BUFFERS)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 hexdump(buffer_info->dma,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 adapter->rx_ps_bsize0);
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
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
> + =A0 =A0 =A0 default:
> + =A0 =A0 =A0 case 0:
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* Legacy Receive Descriptor Format
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* +---------------------------------=
--------------------+
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* | =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0B=
uffer Address [63:0] =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0|
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* +---------------------------------=
--------------------+
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* | VLAN Tag | Errors | Status 0 | P=
acket csum | Length |
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* +---------------------------------=
--------------------+
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* 63 =A0 =A0 =A0 48 47 =A0 =A040 39 =
=A0 =A0 =A032 31 =A0 =A0 =A0 =A0 16 15 =A0 =A0 =A00
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*/
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 printk(KERN_ERR "Rl[desc] =A0 =A0 [addr=
ess 63:0 =A0] "
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 "[vl er S cks ln] [bi->=
dma =A0 =A0 =A0 ] [bi->skb] "
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 "<-- Legacy format\n");
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 for (i =3D 0; rx_ring->desc && (i < rx_=
ring->count); i++) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 rx_desc =3D E1000_RX_DE=
SC(*rx_ring, i);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 buffer_info =3D &rx_rin=
g->buffer_info[i];
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 u0 =3D (struct my_u0 *)=
rx_desc;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 printk(KERN_ERR "Rl[0x%=
03X] =A0 =A0%016llX %016llX "
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 "%016ll=
X %p",
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 i, le64=
_to_cpu(u0->a), le64_to_cpu(u0->b),
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 (u64)bu=
ffer_info->dma, buffer_info->skb);
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
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (dump_flag & E1000_D=
UMP_BUFFERS)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 hexdump=
(buffer_info->dma,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 adapter->rx_buffer_len);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> + =A0 =A0 =A0 }
> +
> +exit:
> + =A0 =A0 =A0 return;
> +}
> +
> =A0/**
> =A0* e1000_desc_unused - calculate if we have unused descriptors
> =A0**/
> @@ -4257,6 +4642,7 @@ static void e1000_reset_task(struct work
> =A0 =A0 =A0 =A0struct e1000_adapter *adapter;
> =A0 =A0 =A0 =A0adapter =3D container_of(work, struct e1000_adapter, r=
eset_task);
>
> + =A0 =A0 =A0 e1000e_dump(adapter);
> =A0 =A0 =A0 =A0e1000e_reinit_locked(adapter);
> =A0}
>
>
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
>
