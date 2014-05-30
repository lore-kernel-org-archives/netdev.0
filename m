From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: RE: [PATCH v1 4/6] net: fec: Increase buffer descriptor entry number
Date: Fri, 30 May 2014 08:58:12 -0700
Message-ID: <1401465492.3645.122.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1401415552-2263-1-git-send-email-b38611@freescale.com>
	 <1401415552-2263-5-git-send-email-b38611@freescale.com>
	 <063D6719AE5E284EB5DD2968C1650D6D1725053E@AcuExch.aculab.com>
	 <bf938381e86b4ef5b4e3cbec8733fd2e@BLUPR03MB373.namprd03.prod.outlook.com>
	 <1401455586.3645.96.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20140530140137.GC783@arch.cereza>
	 <1401461642.3645.104.camel@edumazet-glaptop2.roam.corp.google.com>
	 <417d6b6ae192430f9fee0a339074d9c6@BLUPR03MB373.namprd03.prod.outlook.com>
	 <063D6719AE5E284EB5DD2968C1650D6D17250953@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "'fugang.duan@freescale.com'" <fugang.duan@freescale.com>,
	"ezequiel.garcia@free-electrons.com"
	<ezequiel.garcia@free-electrons.com>,
	"Frank.Li@freescale.com" <Frank.Li@freescale.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"shawn.guo@linaro.org" <shawn.guo@linaro.org>,
	"bhutchings@solarflare.com" <bhutchings@solarflare.com>,
	"stephen@networkplumber.org" <stephen@networkplumber.org>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f43.google.com ([209.85.220.43]:52741 "EHLO
	mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932165AbaE3P6O (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 May 2014 11:58:14 -0400
Received: by mail-pa0-f43.google.com with SMTP id hz1so1845790pad.16
        for <netdev@vger.kernel.org>; Fri, 30 May 2014 08:58:13 -0700 (PDT)
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D17250953@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2014-05-30 at 15:34 +0000, David Laight wrote:

> Software TSO generates lots of separate ethernet frames, there is no
> absolute requirement to be able to put all of them into the tx ring at once.

Yes there is absolute requirement. It is driver responsibility to block
the queue if the available slots in TX ring would not allow the
following packet to be sent.

Thats why a TSO emulation needs to set gso_max_segs to some sane value

(sfc sets it to 100)

In Fugang patch this part was a wrong way to deal with this :

+       if (tso_count_descs(skb) >= fec_enet_txdesc_entry_free(fep)) {
+               if (net_ratelimit())
+                       netdev_err(ndev, "tx queue full!\n");
+               return NETDEV_TX_BUSY;
+       }
+

This was copy/pasted from buggy
drivers/net/ethernet/marvell/mv643xx_eth.c

> 
> The required size for the tx ring is much more likely to be related
> to any interrupt mitigation that delays the refilling of ring entries.
> 512 sounds like a lot of tx ring entries.

512 slots -> 256 frames (considering SG : headers/payload use 2 desc)

-> 3 ms on a Gbit NIC. Its about the right size.
