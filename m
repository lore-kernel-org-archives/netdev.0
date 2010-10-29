From: Oliver Hartkopp <socketcan-fJ+pQTUTwRTk1uMJSBkQmQ@public.gmane.org>
Subject: Re: [PATCH net-next-2.6 v2] can: Topcliff: PCH_CAN driver: Fix build
	warnings
Date: Fri, 29 Oct 2010 18:46:32 +0200
Message-ID: <4CCAFA68.2030903@hartkopp.net>
References: <4CCAA3D4.8070408@dsn.okisemi.com>
	<4CCAC4CD.7000503@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: andrew.chih.howe.khor-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	Masayuki Ohtake <masa-korg-ECg8zkTtlr0C6LszWs/t0g@public.gmane.org>,
	Samuel Ortiz <sameo-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>, margie.foster-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org, yong.y.wang-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	kok.howg.ewe-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>,
	joel.clark-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Christian Pellegrin <chripell-VaTbYqLCNhc@public.gmane.org>, qi.wang-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org
To: Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>,
	Tomoya <tomoya-linux-ECg8zkTtlr0C6LszWs/t0g@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <4CCAC4CD.7000503-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
List-Unsubscribe: <https://lists.berlios.de/mailman/options/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=unsubscribe>
List-Archive: <https://lists.berlios.de/pipermail/socketcan-core>
List-Post: <mailto:socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
List-Help: <mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=help>
List-Subscribe: <https://lists.berlios.de/mailman/listinfo/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=subscribe>
Sender: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Errors-To: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
List-Id: netdev.vger.kernel.org

On 29.10.2010 14:57, Marc Kleine-Budde wrote:
> Hello,
> 
> On 10/29/2010 12:37 PM, Tomoya wrote:

>>>> If you figured out how to use the endianess conversion functions from
>>>> the cpu_to_{le,be}-{le,to}_to_cpup family use them here, too.
> 
>> Sorry, I misunderstood the spec of Topcliff CAN endianess.
>> I have understood endianess conversion is not necessary.
>> (CAN data is set as Big-Endian in Topcliff CAN register)
> 
>>> You have to change the definition of the regs struct a bit:
>>>> 	u32 if1_mcont;
>>>> 	u32 if1_data[4];
>>>> 	u32 reserve2;
>> Uh, I can't find this. Where is this ?
> 
> Here's a patch to illustrate what I meant:
> 
> diff --git a/drivers/net/can/pch_can.c b/drivers/net/can/pch_can.c
> index 55ec324..5ee7589 100644
> --- a/drivers/net/can/pch_can.c
> +++ b/drivers/net/can/pch_can.c
> @@ -150,10 +150,7 @@ struct pch_can_regs {
>         u32 if1_id1;
>         u32 if1_id2;
>         u32 if1_mcont;
> -       u32 if1_dataa1;
> -       u32 if1_dataa2;
> -       u32 if1_datab1;
> -       u32 if1_datab2;
> +       u32 if1_data[4];
>         u32 reserve2;
>         u32 reserve3[12];
>         u32 if2_creq;
> 

Indeed the access to the data registers does not seem to be endian aware.

See in pch_can_rx_normal():

+			cf->can_dlc = get_can_dlc((ioread32(&priv->regs->
+						   if1_mcont)) & 0xF);
+			*(u16 *)(cf->data + 0) = ioread16(&priv->regs->
+							  if1_dataa1);
+			*(u16 *)(cf->data + 2) = ioread16(&priv->regs->
+							  if1_dataa2);
+			*(u16 *)(cf->data + 4) = ioread16(&priv->regs->
+							  if1_datab1);
+			*(u16 *)(cf->data + 6) = ioread16(&priv->regs->
+							  if1_datab2);

See in pch_xmit():

+	/* Copy data to register */
+	if (cf->can_dlc > 0) {
+		u32 data1 = *((u16 *)&cf->data[0]);
+		iowrite32(data1, &priv->regs->if2_dataa1);
+	}
+	if (cf->can_dlc > 2) {
+		u32 data1 = *((u16 *)&cf->data[2]);
+		iowrite32(data1, &priv->regs->if2_dataa2);
+	}
+	if (cf->can_dlc > 4) {
+		u32 data1 = *((u16 *)&cf->data[4]);
+		iowrite32(data1, &priv->regs->if2_datab1);
+	}
+	if (cf->can_dlc > 6) {
+		u32 data1 = *((u16 *)&cf->data[6]);
+		iowrite32(data1, &priv->regs->if2_datab2);
+	}
+

It's just a question if the driver for an Intel Chipset should/could ignore
the endian problematic.

If this is intended the driver should only appear in Kconfig depending on X86
or little endian systems.

Besides this remark, the struct pch_can_regs could also be defined in a way
that every single CAN payload data byte could be accessed directly to allow
e.g. this code in pch_can_rx_normal():

cf->data[0] = ioread8(&priv->regs->if1_data0);
cf->data[1] = ioread8(&priv->regs->if1_data1);
cf->data[2] = ioread8(&priv->regs->if1_data2);
(..)
cf->data[6] = ioread8(&priv->regs->if1_data6);
cf->data[7] = ioread8(&priv->regs->if1_data7);

This is easy to understand and additionally endian aware.

In opposite to this:

+	if (cf->can_dlc > 2) {
+		u32 data1 = *((u16 *)&cf->data[2]);
+		iowrite32(data1, &priv->regs->if2_dataa2);
+	}

Which puts a little? endian u16 into the big endian register layout.
Sorry i'm just getting curious on this register access implementation.

Regards,
Oliver
