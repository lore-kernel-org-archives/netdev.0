From: Lino Sanfilippo <LinoSanfilippo@gmx.de>
Subject: Re: [PATCH net-next,V2] Add LAN9352 Ethernet Driver
Date: Tue, 16 Feb 2016 23:09:56 +0100
Message-ID: <56C39E34.9080801@gmx.de>
References: <90A7E81AE28BAE4CBDDB3B35F187D264402EF4A2@CHN-SV-EXMX02.mchp-main.com>
 <56BD23E0.1090403@gmx.de>
 <90A7E81AE28BAE4CBDDB3B35F187D264402EF62A@CHN-SV-EXMX02.mchp-main.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Bryan.Whitehead@microchip.com, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.gmx.net ([212.227.15.18]:53909 "EHLO mout.gmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756022AbcBPWKJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 16 Feb 2016 17:10:09 -0500
In-Reply-To: <90A7E81AE28BAE4CBDDB3B35F187D264402EF62A@CHN-SV-EXMX02.mchp-main.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12.02.2016 20:10, Bryan.Whitehead@microchip.com wrote:
> Lino,
> 
> Regarding "a matching smp_rmb() in the irq handler"
> There is a smp_wmb() in the irq handler, since in both cases we are forcing a write operation on software_irq_signal.
> 
> I suppose using atomic operations on software_irq_signal would also work, but this driver was based on 
> drivers/net/ethernet/smsc/smsc911x.c
> And if possible I'd prefer to keep logical changes to a minimum.
> Plus this is not a "read modify write" scenario so I think the memory barrier is sufficient.
> Do you agree?
> 

Hi Bryan,

youre right, smsc911x.c does the same thing and probably its ok. As far
as I have understood smp memory barriers (mainly from reading
memory-barriers.txt), they normally should be paired to ensure that a
"reader" thread actually sees what an "updater" thread writes - paired
in a sense that there is a corresponding smp_rmb() for a smp_wmb().

So in this case I expected the need for a smp_rmb() at least in that
loop in open() which waits for the software_irq_signal flag to toggle.
Something like

	while (timeout--) {
		smp_rmb();
		if (pdata->software_irq_signal)
			break;
		usleep_range(1000, 10000);
	}

But AFAICS calling usleep_range() already implies memory barriers, so I
agree that there is probably no need for an explicit smp_rmb.


Regards,
Lino
