From: Mason <slash.tmp@free.fr>
Subject: Re: [RFC PATCH v1] net: ethernet: nb8800: Reset HW block in ndo_open
Date: Mon, 31 Jul 2017 17:18:02 +0200
Message-ID: <b1a6cd1d-ce02-708f-6c8e-defe0d8f3cd8@free.fr>
References: <823b1540-b528-bbd7-7f99-5dc39a08868a@sigmadesigns.com>
 <yw1xk22slemx.fsf@mansr.com>
 <c1bf54ee-8634-23a1-abda-55bc3fafe2a8@sigmadesigns.com>
 <yw1xfudgl7am.fsf@mansr.com> <446e3a95-80c3-0742-9cb1-69a8dfc9b1ae@free.fr>
 <yw1x7eyrlc3s.fsf@mansr.com> <f04a0cba-6c09-e9e4-f2d1-d8b2a7e276c9@free.fr>
 <4ff343de-41c7-c309-04dc-983b5fe3e066@gmail.com>
 <a5ef2294-2adf-743b-f877-144a8f3958b4@free.fr> <yw1x60e8kebc.fsf@mansr.com>
 <31792688-7720-1d1e-4fd4-a0f96ac8af59@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Florian Fainelli <f.fainelli@gmail.com>,
        Marc Gonzalez <marc_gonzalez@sigmadesigns.com>,
        netdev <netdev@vger.kernel.org>,
        Linux ARM <linux-arm-kernel@lists.infradead.org>
To: Mans Rullgard <mans@mansr.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp5-g21.free.fr ([212.27.42.5]:37748 "EHLO smtp5-g21.free.fr"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752192AbdGaPSP (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 31 Jul 2017 11:18:15 -0400
In-Reply-To: <31792688-7720-1d1e-4fd4-a0f96ac8af59@free.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 31/07/2017 16:08, Mason wrote:

> Other things make no sense to me, for example in nb8800_dma_stop()
> there is a polling loop:
> 
> 	do {
> 		mdelay(100);
> 		nb8800_writel(priv, NB8800_TX_DESC_ADDR, txb->dma_desc);
> 		wmb();
> 		mdelay(100);
> 		nb8800_writel(priv, NB8800_TXC_CR, txcr | TCR_EN);
> 
> 		mdelay(5500);
> 
> 		err = readl_poll_timeout_atomic(priv->base + NB8800_RXC_CR,
> 						rxcr, !(rxcr & RCR_EN),
> 						1000, 100000);
> 		printk("err=%d retry=%d\n", err, retry);
> 	} while (err && --retry);
> 
> 
> (It was me who added the delays.)
> 
> *Whatever* delays I insert, it always goes 3 times through the loop.
> 
> [   29.654492] ++ETH++ gw32 reg=f002610c val=9ecc8000
> [   29.759320] ++ETH++ gw32 reg=f0026100 val=005c0aff
> [   35.364705] err=-110 retry=5
> [   35.467609] ++ETH++ gw32 reg=f002610c val=9ecc8000
> [   35.572436] ++ETH++ gw32 reg=f0026100 val=005c0aff
> [   41.177822] err=-110 retry=4
> [   41.280726] ++ETH++ gw32 reg=f002610c val=9ecc8000
> [   41.385553] ++ETH++ gw32 reg=f0026100 val=005c0aff
> [   46.890907] err=0 retry=3
> 
> How is that possible?

First time through the loop, it doesn't matter how long we poll,
it *always* times out. Second time as well (only on BOARD B).

Third time, it succeeds quickly (first or second poll).
(This explains why various delays had no impact.)

In fact, requesting the transfer 3 times *before* polling
makes the polling succeed quickly:

	nb8800_writel(priv, NB8800_TX_DESC_ADDR, txb->dma_desc);
	wmb();
	nb8800_writel(priv, NB8800_TXC_CR, txcr | TCR_EN);

[   16.464596] ++ETH++ gw32 reg=f002610c val=9ef28000
[   16.469414] ++ETH++ gw32 reg=f0026100 val=005c0aff
[   16.474231] ++ETH++ gw32 reg=f002610c val=9ef28000
[   16.479048] ++ETH++ gw32 reg=f0026100 val=005c0aff
[   16.483865] ++ETH++ gw32 reg=f002610c val=9ef28000
[   16.488682] ++ETH++ gw32 reg=f0026100 val=005c0aff
[   16.493500] ++ETH++ POLL reg=f0026200 val=06100a8f
[   16.499317] ++ETH++ POLL reg=f0026200 val=06100a8e
[   16.504134] err=0 retry=5


With my changes, I get *exactly* the same logs on BOARD A
and BOARD B (modulo the descriptors addresses).

Yet BOARD A stays functional, but BOARD B is hosed...

Depressing. I've run out of ideas.


BOARD A LOGS:

# test_eth.sh 
[   18.037782] nb8800 26000.ethernet eth0: Link is Up - 1Gbps/Full - flow control rx/tx
172.27.64.1 : xmt/rcv/%loss = 1/1/0%, min/avg/max = 0.39/0.39/0.39
[   20.617917] nb8800_stop from __dev_close_many
[   20.622314] ++ETH++ gw32 reg=f0026020 val=00920000
[   20.627135] ++ETH++ gw32 reg=f0026020 val=80920000
[   20.631973] ++ETH++ gr32 reg=f0026024 val=0000ec00
[   20.636782] ++ETH++ gw32 reg=f0026020 val=04920000
[   20.641601] ++ETH++ gw32 reg=f0026020 val=84920000
[   20.646440] ++ETH++ gw32 reg=f0026020 val=00930000
[   20.651258] ++ETH++ gw32 reg=f0026020 val=80930000
[   20.656095] ++ETH++ gr32 reg=f0026024 val=00000000
[   20.660909] ++ETH++ POLL reg=f0026100 val=005c0afe
[   20.665743] ++ETH++ gr8  reg=f0026004 val=2b
[   20.670028] ++ETH++ gw8  reg=f0026004 val=0b
[   20.674313] ++ETH++ gr8  reg=f0026044 val=81
[   20.678598] ++ETH++ gw8  reg=f0026044 val=85
[   20.682883] ++ETH++ gw32 reg=f002610c val=9de0c000
[   20.687693] ++ETH++ gw32 reg=f0026100 val=005c0aff
[   20.692503] ++ETH++ gw32 reg=f002610c val=9de0c000
[   20.697312] ++ETH++ gw32 reg=f0026100 val=005c0aff
[   20.702121] ++ETH++ gw32 reg=f002610c val=9de0c000
[   20.706929] ++ETH++ gw32 reg=f0026100 val=005c0aff
[   20.712738] ++ETH++ POLL reg=f0026200 val=06100a8e
[   20.717547] err=0 retry=5
[   20.720172] ++ETH++ gr8  reg=f0026004 val=0b
[   20.724456] ++ETH++ gw8  reg=f0026004 val=2b
[   20.728742] ++ETH++ gr8  reg=f0026044 val=85
[   20.733026] ++ETH++ gw8  reg=f0026044 val=81
[   20.737349] ++ETH++ gw32 reg=f002620c val=9de04000
[   20.742158] nb8800_dma_stop=0
[   21.845224] ENTER nb8800_irq
[   21.848116] ++ETH++ gr32 reg=f0026104 val=00000005
[   21.852927] ++ETH++ gw32 reg=f0026104 val=00000005
[   21.857738] ++ETH++ gr32 reg=f0026204 val=00000004
[   21.862547] ++ETH++ gw32 reg=f0026204 val=00000004
[   21.867356] ++ETH++ gw32 reg=f0026218 val=003cc4a4
[   21.872164]  EXIT nb8800_irq
[   24.373448] ++ETH++ gr8  reg=f0026004 val=2b
[   24.377755] ++ETH++ gw8  reg=f0026004 val=2a
[   24.382054] ++ETH++ gr32 reg=f0026100 val=00080afe
[   24.386876] ++ETH++ gr8  reg=f0026000 val=1d
[   24.391192] ++ETH++ gw8  reg=f0026000 val=1c
[   25.706747] ++ETH++ gw32 reg=f0026020 val=00920000
[   25.711578] ++ETH++ gw32 reg=f0026020 val=80920000
[   25.716427] ++ETH++ gr32 reg=f0026024 val=00000000
[   25.721248] ++ETH++ gw32 reg=f0026020 val=04920000
[   25.726091] ++ETH++ gw32 reg=f0026020 val=84920000
[   25.730942] ++ETH++ gw32 reg=f0026020 val=00930000
[   25.735782] ++ETH++ gw32 reg=f0026020 val=80930000
[   25.740631] ++ETH++ gr32 reg=f0026024 val=00000000
[   25.745604] nb8800 26000.ethernet eth0: Link is Down
[   25.750617] ++ETH++ gw32 reg=f0026020 val=00920000
[   25.755464] ++ETH++ gw32 reg=f0026020 val=80920000
[   25.760377] ++ETH++ gr32 reg=f0026024 val=00000000
[   25.765205] ++ETH++ gw32 reg=f0026020 val=00920000
[   25.770085] ++ETH++ gw32 reg=f0026020 val=80920000
[   25.774962] ++ETH++ gr32 reg=f0026024 val=00000000
[   25.779784] ++ETH++ gw32 reg=f0026020 val=00800000
[   25.784614] ++ETH++ gw32 reg=f0026020 val=80800000
[   25.789510] ++ETH++ gr32 reg=f0026024 val=00001000
[   25.794333] ++ETH++ gw32 reg=f0026020 val=04801800
[   25.799199] ++ETH++ gw32 reg=f0026020 val=84801800
[   25.804081] ++ETH++ gw32 reg=f0026020 val=00920000
[   25.808918] ++ETH++ gw32 reg=f0026020 val=80920000
[   25.813825] ++ETH++ gr32 reg=f0026024 val=00000000
[   25.818684] ++ETH++ gw32 reg=f0026020 val=00920000
[   25.823551] ++ETH++ gw32 reg=f0026020 val=80920000
[   25.828435] ++ETH++ gr32 reg=f0026024 val=00000000
[   25.833291] ++ETH++ gw32 reg=f0026020 val=00800000
[   25.838156] ++ETH++ gw32 reg=f0026020 val=80800000
[   25.843041] ++ETH++ gr32 reg=f0026024 val=00001800
[   25.847897] ++ETH++ gw32 reg=f0026020 val=04801800
[   25.852763] ++ETH++ gw32 reg=f0026020 val=84801800
[   25.857719] EXIT nb8800_stop
[   30.096432] nb8800 26000.ethernet eth0: Link is Up - 1Gbps/Full - flow control rx/tx
172.27.64.1 : xmt/rcv/%loss = 1/1/0%, min/avg/max = 0.37/0.37/0.37



BOARD B LOGS:

# test_eth.sh 
[   13.796651] nb8800 26000.ethernet eth0: Link is Up - 1Gbps/Full - flow control rx/tx
172.27.64.1 : xmt/rcv/%loss = 1/1/0%, min/avg/max = 0.34/0.34/0.34
[   16.379613] nb8800_stop from __dev_close_many
[   16.384016] ++ETH++ gw32 reg=f0026020 val=00920000
[   16.388845] ++ETH++ gw32 reg=f0026020 val=80920000
[   16.393691] ++ETH++ gr32 reg=f0026024 val=0000ec00
[   16.398508] ++ETH++ gw32 reg=f0026020 val=04920000
[   16.403335] ++ETH++ gw32 reg=f0026020 val=84920000
[   16.408183] ++ETH++ gw32 reg=f0026020 val=00930000
[   16.413009] ++ETH++ gw32 reg=f0026020 val=80930000
[   16.417854] ++ETH++ gr32 reg=f0026024 val=00000000
[   16.422673] ++ETH++ POLL reg=f0026100 val=005c0afe
[   16.427514] ++ETH++ gr8  reg=f0026004 val=2b
[   16.431806] ++ETH++ gw8  reg=f0026004 val=0b
[   16.436100] ++ETH++ gr8  reg=f0026044 val=81
[   16.440392] ++ETH++ gw8  reg=f0026044 val=85
[   16.444684] ++ETH++ gw32 reg=f002610c val=9efa8000
[   16.449501] ++ETH++ gw32 reg=f0026100 val=005c0aff
[   16.454318] ++ETH++ gw32 reg=f002610c val=9efa8000
[   16.459134] ++ETH++ gw32 reg=f0026100 val=005c0aff
[   16.463951] ++ETH++ gw32 reg=f002610c val=9efa8000
[   16.468768] ++ETH++ gw32 reg=f0026100 val=005c0aff
[   16.474586] ++ETH++ POLL reg=f0026200 val=06100a8e
[   16.479403] err=0 retry=5
[   16.482034] ++ETH++ gr8  reg=f0026004 val=0b
[   16.486327] ++ETH++ gw8  reg=f0026004 val=2b
[   16.490619] ++ETH++ gr8  reg=f0026044 val=85
[   16.494912] ++ETH++ gw8  reg=f0026044 val=81
[   16.499217] ++ETH++ gw32 reg=f002620c val=9ed22000
[   16.504035] nb8800_dma_stop=0
[   17.607126] ENTER nb8800_irq
[   17.610032] ++ETH++ gr32 reg=f0026104 val=00000005
[   17.614851] ++ETH++ gw32 reg=f0026104 val=00000005
[   17.619669] ++ETH++ gr32 reg=f0026204 val=00000004
[   17.624486] ++ETH++ gw32 reg=f0026204 val=00000004
[   17.629303] ++ETH++ gw32 reg=f0026218 val=003cc4a4
[   17.634120]  EXIT nb8800_irq
[   20.108802] ++ETH++ gr8  reg=f0026004 val=2b
[   20.113115] ++ETH++ gw8  reg=f0026004 val=2a
[   20.117478] ++ETH++ gr32 reg=f0026100 val=00080afe
[   20.122348] ++ETH++ gr8  reg=f0026000 val=1d
[   20.126688] ++ETH++ gw8  reg=f0026000 val=1c
[   21.442246] ++ETH++ gw32 reg=f0026020 val=00920000
[   21.447107] ++ETH++ gw32 reg=f0026020 val=80920000
[   21.452027] ++ETH++ gr32 reg=f0026024 val=00000000
[   21.456907] ++ETH++ gw32 reg=f0026020 val=04920000
[   21.461783] ++ETH++ gw32 reg=f0026020 val=84920000
[   21.466684] ++ETH++ gw32 reg=f0026020 val=00930000
[   21.471559] ++ETH++ gw32 reg=f0026020 val=80930000
[   21.476457] ++ETH++ gr32 reg=f0026024 val=00000000
[   21.481395] nb8800 26000.ethernet eth0: Link is Down
[   21.486461] ++ETH++ gw32 reg=f0026020 val=00920000
[   21.491338] ++ETH++ gw32 reg=f0026020 val=80920000
[   21.496237] ++ETH++ gr32 reg=f0026024 val=00000000
[   21.501102] ++ETH++ gw32 reg=f0026020 val=00920000
[   21.505983] ++ETH++ gw32 reg=f0026020 val=80920000
[   21.510877] ++ETH++ gr32 reg=f0026024 val=00000000
[   21.515748] ++ETH++ gw32 reg=f0026020 val=00800000
[   21.520621] ++ETH++ gw32 reg=f0026020 val=80800000
[   21.525489] ++ETH++ gr32 reg=f0026024 val=00001000
[   21.530319] ++ETH++ gw32 reg=f0026020 val=04801800
[   21.535157] ++ETH++ gw32 reg=f0026020 val=84801800
[   21.540025] ++ETH++ gw32 reg=f0026020 val=00920000
[   21.544866] ++ETH++ gw32 reg=f0026020 val=80920000
[   21.549730] ++ETH++ gr32 reg=f0026024 val=00000000
[   21.554560] ++ETH++ gw32 reg=f0026020 val=00920000
[   21.559400] ++ETH++ gw32 reg=f0026020 val=80920000
[   21.564257] ++ETH++ gr32 reg=f0026024 val=00000000
[   21.569083] ++ETH++ gw32 reg=f0026020 val=00800000
[   21.573921] ++ETH++ gw32 reg=f0026020 val=80800000
[   21.578777] ++ETH++ gr32 reg=f0026024 val=00001800
[   21.583603] ++ETH++ gw32 reg=f0026020 val=04801800
[   21.588441] ++ETH++ gw32 reg=f0026020 val=84801800
[   21.593349] EXIT nb8800_stop
[   25.811889] nb8800 26000.ethernet eth0: Link is Up - 1Gbps/Full - flow control rx/tx
172.27.64.1 : xmt/rcv/%loss = 1/0/100%
