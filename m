From: Tony Battersby <tonyb@cybernetics.com>
Subject: Re: TG3 network data corruption regression 2.6.24/2.6.23.4
Date: Wed, 20 Feb 2008 11:13:51 -0500
Message-ID: <47BC51BF.7000908@cybernetics.com>
References: <47BA0984.2070306@cybernetics.com> <1203381120.13495.78.camel@dell> <20080218.163554.74130592.davem@davemloft.net> <1203383046.13495.87.camel@dell> <47BB00EC.3010607@cybernetics.com> <1203448265.13495.95.camel@dell> <47BB54C2.6090501@cybernetics.com> <20080220013824.GA5416@localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Michael Chan <mchan@broadcom.com>,
	David Miller <davem@davemloft.net>,
	herbert@gondor.apana.org.au, netdev <netdev@vger.kernel.org>,
	gregkh@suse.de, linux-kernel@vger.kernel.org
To: Matt Carlson <mcarlson@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from host64.cybernetics.com ([70.169.137.4]:3294 "EHLO
	mail.cybernetics.com" rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org
	with ESMTP id S932358AbYBTQNu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Feb 2008 11:13:50 -0500
In-Reply-To: <20080220013824.GA5416@localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Matt Carlson wrote:
> Hi Tony.  Can you give us the output of :
>
> sudo lspci -vvv -xxxx -s 03:01.0'
>   
03:01.0 Ethernet controller: Broadcom Corporation NetXtreme BCM5701 Gigabit Ethernet (rev 15)
	Subsystem: Compaq Computer Corporation NC7770 Gigabit Server Adapter (PCI-X, 10/100/1000-T)
	Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
	Status: Cap+ 66MHz+ UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 64 (16000ns min), Cache Line Size: 64 bytes
	Interrupt: pin A routed to IRQ 17
	Region 0: Memory at df7f0000 (64-bit, non-prefetchable) [size=64K]
	[virtual] Expansion ROM at dfc00000 [disabled] [size=64K]
	Capabilities: [40] PCI-X non-bridge device
		Command: DPERE- ERO- RBC=512 OST=1
		Status: Dev=03:01.1 64bit+ 133MHz+ SCD- USC- DC=simple DMMRBC=512 DMOST=1 DMCRS=8 RSCEM- 266MHz- 533MHz-
	Capabilities: [48] Power Management version 2
		Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA PME(D0-,D1-,D2-,D3hot+,D3cold+)
		Status: D0 PME-Enable- DSel=0 DScale=1 PME-
	Capabilities: [50] Vital Product Data <?>
	Capabilities: [58] Message Signalled Interrupts: Mask- 64bit+ Queue=0/3 Enable-
		Address: 063000119b608000  Data: 0423
00: e4 14 45 16 06 00 b0 02 15 00 00 02 10 40 00 00
10: 04 00 7f df 00 00 00 00 00 00 00 00 00 00 00 00
20: 00 00 00 00 00 00 00 00 00 00 00 00 11 0e 7c 00
30: 00 00 00 00 40 00 00 00 00 00 00 00 0b 01 40 00
40: 07 48 00 00 09 03 03 00 01 50 02 c0 00 20 00 64
50: 03 58 00 00 08 10 21 08 05 00 86 00 00 80 60 9b
60: 11 00 30 06 23 04 00 00 98 02 05 01 0f 00 db 76
70: 8a 10 00 00 c7 00 00 80 50 00 00 00 00 00 00 00
80: 03 58 00 00 00 00 00 00 34 80 13 04 82 10 00 00
90: 09 06 00 01 00 00 00 00 00 00 00 00 c6 01 00 00
a0: 00 00 00 00 fe 02 00 00 00 00 00 00 af 01 00 00
b0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
c0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
d0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
e0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
f0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00



> Also, after some digging, I found that the 5701 can run into trouble if
> a 64-bit DMA read terminates early and then completes as a 32-bit transfer.
> The problem is reportedly very rare, but the failure mode looks like a
> match.  Can you apply the following patch and see if it helps your
> performance / corruption problems?
>
>
> diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
> index db606b6..7ad08ce 100644
> --- a/drivers/net/tg3.c
> +++ b/drivers/net/tg3.c
> @@ -11409,6 +11409,8 @@ static int __devinit tg3_get_invariants(struct tg3 *tp)
>  		tp->tg3_flags |= TG3_FLAG_PCI_HIGH_SPEED;
>  	if ((pci_state_reg & PCISTATE_BUS_32BIT) != 0)
>  		tp->tg3_flags |= TG3_FLAG_PCI_32BIT;
> +	else if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5701)
> +		tp->grc_mode |= GRC_MODE_FORCE_PCI32BIT;
>  
>  	/* Chip-specific fixup from Broadcom driver */
>  	if ((tp->pci_chip_rev_id == CHIPREV_ID_5704_A0) &&
>
>   
Sorry, this didn't help.  I still get data corruption with hardware
checksumming or poor performance with software checksumming.

Tony

