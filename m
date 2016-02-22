From: Claudiu Manoil <claudiu.manoil@nxp.com>
Subject: RE: [PATCH net-next 1/3] gianfar: Map head TxBD first to skip a wmb()
Date: Mon, 22 Feb 2016 10:14:37 +0000
Message-ID: <DB4PR04MB3799AF95B8C7FB8C949476496A30@DB4PR04MB379.eurprd04.prod.outlook.com>
References: <1455878854-28290-1-git-send-email-claudiu.manoil@freescale.com>
	<1455878854-28290-2-git-send-email-claudiu.manoil@freescale.com>
 <20160221.215843.877041303205905380.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>,
	"claudiu.manoil@freescale.com" <claudiu.manoil@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-db3on0098.outbound.protection.outlook.com ([157.55.234.98]:34412
	"EHLO emea01-db3-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753955AbcBVK3S convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Feb 2016 05:29:18 -0500
In-Reply-To: <20160221.215843.877041303205905380.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>-----Original Message-----
>From: David Miller [mailto:davem@davemloft.net]
>Sent: Monday, February 22, 2016 4:59 AM
>To: claudiu.manoil@freescale.com
>Cc: netdev@vger.kernel.org
>Subject: Re: [PATCH net-next 1/3] gianfar: Map head TxBD first to skip a
>wmb()
>
>From: Claudiu Manoil <claudiu.manoil@freescale.com>
>Date: Fri, 19 Feb 2016 12:47:32 +0200
>
>> The main point of this change is to update the buffer pointer of
>> the first BD way before the status field is updated, so that a
>> wmb() between these two operations is no longer needed.
>
>This is the completely bogus.
>
>The distance between two memory operations has no bearing upon
>whether a memory barrier is necessary between them or not.
>
>There could be 1,000 loads and stores between two dependant
>operations, you still need the memory barrier for full correctness
>if the ordering between them is important.
>
>I am not applying this patch series because it's is doing things
>and stating things which are entirely incorrect.
>

I think it can be proven that the wmb() is not needed in this case.
If it weren't so, then all the other eth drivers would require a wmb()
in their xmit(), between buffer address update and status update
for the last descriptor of a frame.
Let's take a random driver - igb, there is no wmb() between:
tx_desc->read.buffer_addr = cpu_to_le64(dma);
and
/* write last descriptor with RS and EOP bits */
cmd_type |= size | IGB_TXD_DCMD;
tx_desc->read.cmd_type_len = cpu_to_le32(cmd_type);

Anyway, the patch series is far from being "entirely incorrect".
Even with the contested gfar_wmb() statement left in place,
the proposed code refactoring of xmit() improves execution
time, and code maintainability.
