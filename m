From: Laurent Chavey <chavey@google.com>
Subject: Re: [PATCH v2 1/3] e1000e: add registers etc. printout code just
	before resetting adapters
Date: Fri, 19 Feb 2010 11:19:24 -0800
Message-ID: <97949e3e1002191119y67e65522x20d8c7ddd2df49eb@mail.gmail.com>
References: <4B593B74.2020601@jp.fujitsu.com> <4B593C33.5020208@jp.fujitsu.com>
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
Received: from smtp-out.google.com ([216.239.33.17]:49684 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755507Ab0BSTTt convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Feb 2010 14:19:49 -0500
Received: from spaceape9.eur.corp.google.com (spaceape9.eur.corp.google.com [172.28.16.143])
	by smtp-out.google.com with ESMTP id o1JJJkMb014705
	for <netdev@vger.kernel.org>; Fri, 19 Feb 2010 19:19:46 GMT
Received: from fg-out-1718.google.com (fgbl26.prod.google.com [10.86.88.26])
	by spaceape9.eur.corp.google.com with ESMTP id o1JJJiWb002048
	for <netdev@vger.kernel.org>; Fri, 19 Feb 2010 11:19:45 -0800
Received: by fg-out-1718.google.com with SMTP id l26so432715fgb.1
        for <netdev@vger.kernel.org>; Fri, 19 Feb 2010 11:19:44 -0800 (PST)
In-Reply-To: <4B593C33.5020208@jp.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

- are you sure you want KERN_ERR rather than KERN_DEBUG ?




2010/1/21 Taku Izumi <izumi.taku@jp.fujitsu.com>:
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
> =A0drivers/net/e1000e/hw.h =A0 =A0 | =A0 27 +++
> =A0drivers/net/e1000e/netdev.c | =A0341 +++++++++++++++++++++++++++++=
+++++++++++++++
> =A02 files changed, 368 insertions(+)
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
> @@ -65,6 +73,338 @@ static const struct e1000_info *e1000_in
> =A0 =A0 =A0 =A0[board_pchlan] =A0 =A0 =A0 =A0 =A0=3D &e1000_pch_info,
> =A0};
>
> +/*
> + * e1000_regdump - register printout routine
> + */
> +static void e1000_regdump(struct e1000_hw *hw, u32 reg,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 char *name, u32 (*g=
et_regofs)(int))
> +{
> + =A0 =A0 =A0 printk(KERN_ERR "%-15s %08x\n", name, __er32(hw, reg));
> +}
> +
> +/*
> + * e1000_regdump_n - register printout routine
> + */
> +static void e1000_regdump_n(struct e1000_hw *hw, u32 reg,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 char *name, u32=
 (*get_regofs)(int))
> +{
> + =A0 =A0 =A0 int n =3D 0;
> + =A0 =A0 =A0 char rname[16];
> +
> + =A0 =A0 =A0 if (!get_regofs)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return;
> +
> + =A0 =A0 =A0 snprintf(rname, 16, "%s%s", name, "[0-1]");
> + =A0 =A0 =A0 printk(KERN_ERR "%-15s ", rname);
> + =A0 =A0 =A0 for (n =3D 0; n < 2; n++)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 printk("%08x ", __er32(hw, get_regofs(n=
)));
> + =A0 =A0 =A0 printk("\n");
> +}
> +
> +static const struct e1000_reg_info e1000_reg_info_tbl[] =3D {
> +
> + =A0 =A0 =A0 /* General Registers */
> + =A0 =A0 =A0 {E1000_CTRL, "CTRL", NULL, e1000_regdump},
> + =A0 =A0 =A0 {E1000_STATUS, "STATUS", NULL, e1000_regdump},
> + =A0 =A0 =A0 {E1000_CTRL_EXT, "CTRL_EXT", NULL, e1000_regdump},
> +
> + =A0 =A0 =A0 /* Interrupt Registers */
> + =A0 =A0 =A0 {E1000_ICR, "ICR", NULL, e1000_regdump},
> +
> + =A0 =A0 =A0 /* RX Registers */
> + =A0 =A0 =A0 {E1000_RCTL, "RCTL", NULL, e1000_regdump},
> + =A0 =A0 =A0 {E1000_RDLEN, "RDLEN", NULL, e1000_regdump},
> + =A0 =A0 =A0 {E1000_RDH, "RDH", NULL, e1000_regdump},
> + =A0 =A0 =A0 {E1000_RDT, "RDT", NULL, e1000_regdump},
> + =A0 =A0 =A0 {E1000_RDTR, "RDTR", NULL, e1000_regdump},
> + =A0 =A0 =A0 {E1000_RXDCTL(0), "RXDCTL", get_regofs_RXDCTL, e1000_re=
gdump_n},
> + =A0 =A0 =A0 {E1000_ERT, "ERT", NULL, e1000_regdump},
> + =A0 =A0 =A0 {E1000_RDBAL, "RDBAL", NULL, e1000_regdump},
> + =A0 =A0 =A0 {E1000_RDBAH, "RDBAH", NULL, e1000_regdump},
> + =A0 =A0 =A0 {E1000_RDFH, "RDFH", NULL, e1000_regdump},
> + =A0 =A0 =A0 {E1000_RDFT, "RDFT", NULL, e1000_regdump},
> + =A0 =A0 =A0 {E1000_RDFHS, "RDFHS", NULL, e1000_regdump},
> + =A0 =A0 =A0 {E1000_RDFTS, "RDFTS", NULL, e1000_regdump},
> + =A0 =A0 =A0 {E1000_RDFPC, "RDFPC", NULL, e1000_regdump},
> +
> + =A0 =A0 =A0 /* TX Registers */
> + =A0 =A0 =A0 {E1000_TCTL, "TCTL", NULL, e1000_regdump},
> + =A0 =A0 =A0 {E1000_TDBAL, "TDBAL", NULL, e1000_regdump},
> + =A0 =A0 =A0 {E1000_TDBAH, "TDBAH", NULL, e1000_regdump},
> + =A0 =A0 =A0 {E1000_TDLEN, "TDLEN", NULL, e1000_regdump},
> + =A0 =A0 =A0 {E1000_TDH, "TDH", NULL, e1000_regdump},
> + =A0 =A0 =A0 {E1000_TDT, "TDT", NULL, e1000_regdump},
> + =A0 =A0 =A0 {E1000_TIDV, "TIDV", NULL, e1000_regdump},
> + =A0 =A0 =A0 {E1000_TXDCTL(0), "TXDCTL", get_regofs_TXDCTL, e1000_re=
gdump_n},
> + =A0 =A0 =A0 {E1000_TADV, "TADV", NULL, e1000_regdump},
> + =A0 =A0 =A0 {E1000_TARC(0), "TARC", get_regofs_TARC, e1000_regdump_=
n},
> + =A0 =A0 =A0 {E1000_TDFH, "TDFH", NULL, e1000_regdump},
> + =A0 =A0 =A0 {E1000_TDFT, "TDFT", NULL, e1000_regdump},
> + =A0 =A0 =A0 {E1000_TDFHS, "TDFHS", NULL, e1000_regdump},
> + =A0 =A0 =A0 {E1000_TDFTS, "TDFTS", NULL, e1000_regdump},
> + =A0 =A0 =A0 {E1000_TDFPC, "TDFPC", NULL, e1000_regdump},
> +
> + =A0 =A0 =A0 /* List Terminator */
> + =A0 =A0 =A0 {}
> +};
> +
> +/*
> + * e1000e_dump - Print registers, tx-ring and rx-ring
> + */
> +static void e1000e_dump(struct e1000_adapter *adapter)
> +{
> + =A0 =A0 =A0 struct net_device *netdev =3D adapter->netdev;
> + =A0 =A0 =A0 struct e1000_hw *hw =3D &adapter->hw;
> + =A0 =A0 =A0 struct e1000_reg_info *reginfo;
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
> + =A0 =A0 =A0 printk(KERN_ERR " Register Name =A0 Value\n");
> + =A0 =A0 =A0 for (reginfo =3D (struct e1000_reg_info *)e1000_reg_inf=
o_tbl;
> + =A0 =A0 =A0 =A0 =A0 =A0reginfo->name; reginfo++) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 reginfo->dump_reg(hw, reginfo->reg, reg=
info->name,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 reginfo->get_regofs);
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
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 print_hex_dump(KERN_ERR=
, "", DUMP_PREFIX_ADDRESS,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 16, 1, phys_to_virt(buffer_info->dma),
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 buffer_info->length, true);
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
 =A0 =A0 print_hex_dump(KERN_ERR, "",
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 DUMP_PREFIX_ADDRESS, 16, 1,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 phys_to_virt(buffer_info->dma),
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 adapter->rx_ps_bsize0, true);
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
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 print_h=
ex_dump(KERN_ERR, "",
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 DUMP_PREFIX_ADDRESS,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 16, 1, phys_to_virt(buffer_info->dma),
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 adapter->rx_buffer_len, true);
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
> @@ -4247,6 +4587,7 @@ static void e1000_reset_task(struct work
> =A0 =A0 =A0 =A0struct e1000_adapter *adapter;
> =A0 =A0 =A0 =A0adapter =3D container_of(work, struct e1000_adapter, r=
eset_task);
>
> + =A0 =A0 =A0 e1000e_dump(adapter);
> =A0 =A0 =A0 =A0e1000e_reinit_locked(adapter);
> =A0}
>
> Index: net-next-2.6/drivers/net/e1000e/hw.h
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> --- net-next-2.6.orig/drivers/net/e1000e/hw.h
> +++ net-next-2.6/drivers/net/e1000e/hw.h
> @@ -92,6 +92,11 @@ enum e1e_registers {
> =A0 =A0 =A0 =A0E1000_FCRTL =A0 =A0=3D 0x02160, /* Flow Control Receiv=
e Threshold Low - RW */
> =A0 =A0 =A0 =A0E1000_FCRTH =A0 =A0=3D 0x02168, /* Flow Control Receiv=
e Threshold High - RW */
> =A0 =A0 =A0 =A0E1000_PSRCTL =A0 =3D 0x02170, /* Packet Split Receive =
Control - RW */
> + =A0 =A0 =A0 E1000_RDFH =A0 =A0 =3D 0x02410, /* Rx Data FIFO Head - =
RW */
> + =A0 =A0 =A0 E1000_RDFT =A0 =A0 =3D 0x02418, /* Rx Data FIFO Tail - =
RW */
> + =A0 =A0 =A0 E1000_RDFHS =A0 =A0=3D 0x02420, /* Rx Data FIFO Head Sa=
ved - RW */
> + =A0 =A0 =A0 E1000_RDFTS =A0 =A0=3D 0x02428, /* Rx Data FIFO Tail Sa=
ved - RW */
> + =A0 =A0 =A0 E1000_RDFPC =A0 =A0=3D 0x02430, /* Rx Data FIFO Packet =
Count - RW */
> =A0 =A0 =A0 =A0E1000_RDBAL =A0 =A0=3D 0x02800, /* Rx Descriptor Base =
Address Low - RW */
> =A0 =A0 =A0 =A0E1000_RDBAH =A0 =A0=3D 0x02804, /* Rx Descriptor Base =
Address High - RW */
> =A0 =A0 =A0 =A0E1000_RDLEN =A0 =A0=3D 0x02808, /* Rx Descriptor Lengt=
h - RW */
> @@ -101,6 +106,11 @@ enum e1e_registers {
> =A0 =A0 =A0 =A0E1000_RXDCTL_BASE =3D 0x02828, /* Rx Descriptor Contro=
l - RW */
> =A0#define E1000_RXDCTL(_n) =A0 (E1000_RXDCTL_BASE + (_n << 8))
> =A0 =A0 =A0 =A0E1000_RADV =A0 =A0 =3D 0x0282C, /* RX Interrupt Absolu=
te Delay Timer - RW */
> + =A0 =A0 =A0 E1000_TDFH =A0 =A0 =3D 0x03410, /* Tx Data FIFO Head - =
RW */
> + =A0 =A0 =A0 E1000_TDFT =A0 =A0 =3D 0x03418, /* Tx Data FIFO Tail - =
RW */
> + =A0 =A0 =A0 E1000_TDFHS =A0 =A0=3D 0x03420, /* Tx Data FIFO Head Sa=
ved - RW */
> + =A0 =A0 =A0 E1000_TDFTS =A0 =A0=3D 0x03428, /* Tx Data FIFO Tail Sa=
ved - RW */
> + =A0 =A0 =A0 E1000_TDFPC =A0 =A0=3D 0x03430, /* Tx Data FIFO Packet =
Count - RW */
>
> =A0/* Convenience macros
> =A0*
> @@ -219,6 +229,23 @@ enum e1e_registers {
> =A0 =A0 =A0 =A0E1000_HICR =A0 =A0 =A0=3D 0x08F00, /* Host Interface C=
ontrol */
> =A0};
>
> +struct e1000_reg_info {
> + =A0 =A0 =A0 u32 reg;
> + =A0 =A0 =A0 char *name;
> + =A0 =A0 =A0 u32 (*get_regofs)(int);
> + =A0 =A0 =A0 void (*dump_reg)(struct e1000_hw *, u32, char *, u32 (*=
)(int));
> +};
> +
> +#define E1000_GET_REGOFS_FUNC(name) =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0\
> +static inline u32 get_regofs_##name(int n) =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 \
> +{ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0\
> + =A0 =A0 =A0 return E1000_##name(n); =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 \
> +} =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0\
> +
> +E1000_GET_REGOFS_FUNC(RXDCTL)
> +E1000_GET_REGOFS_FUNC(TXDCTL)
> +E1000_GET_REGOFS_FUNC(TARC)
> +
> =A0#define E1000_MAX_PHY_ADDR =A0 =A0 =A0 =A0 =A0 =A0 4
>
> =A0/* IGP01E1000 Specific Registers */
>
>
