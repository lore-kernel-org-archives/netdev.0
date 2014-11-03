From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 0/1] mv643xx_eth: Disable TSO by default
Date: Mon, 03 Nov 2014 11:04:08 -0800
Message-ID: <1415041448.31570.0.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1414855820-15094-1-git-send-email-ezequiel.garcia@free-electrons.com>
	 <1414862766.31792.7.camel@edumazet-glaptop2.roam.corp.google.com>
	 <063D6719AE5E284EB5DD2968C1650D6D1C9E44F5@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Ezequiel Garcia <ezequiel.garcia@free-electrons.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	Gregory Clement <gregory.clement@free-electrons.com>,
	Tawfik Bayouk <tawfik@marvell.com>,
	Lior Amsalem <alior@marvell.com>,
	Nadav Haklai <nadavh@marvell.com>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f177.google.com ([209.85.213.177]:65415 "EHLO
	mail-ig0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751971AbaKCTEO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Nov 2014 14:04:14 -0500
Received: by mail-ig0-f177.google.com with SMTP id hl2so5186017igb.10
        for <netdev@vger.kernel.org>; Mon, 03 Nov 2014 11:04:13 -0800 (PST)
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D1C9E44F5@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2014-11-03 at 14:51 +0000, David Laight wrote:
> From: Eric Dumazet
> > On Sat, 2014-11-01 at 12:30 -0300, Ezequiel Garcia wrote:
> > > Several users ([1], [2]) have been reporting data corruption with TSO on
> > > Kirkwood platforms (i.e. using the mv643xx_eth driver).
> > >
> > > Until we manage to find what's causing this, this simple patch will make
> > > the TSO path disabled by default. This patch should be queued for stable,
> > > fixing the TSO feature introduced in v3.16.
> > >
> > > The corruption itself is very easy to reproduce: checking md5sum on a mounted
> > > NFS directory gives a different result each time. Same tests using the mvneta
> > > driver (Armada 370/38x/XP SoC) pass with no issues.
> > >
> > > Frankly, I'm a bit puzzled about this, and so any ideas or debugging hints
> > > are well received.
> > 
> > lack of barriers maybe ?
> > 
> > It seems you might need to populate all TX descriptors but delay the
> > first, like doing the populate in descending order.
> > 
> > If you take a look at txq_submit_skb(), you'll see the final
> > desc->cmd_sts = cmd_sts (line 959) is done _after_ frags were cooked by
> > txq_submit_frag_skb()
> > 
> > You should kick the nick only when all TX descriptors are ready and
> > committed to memory.
> 
> Don't forget that the nick might process the first descriptor without
> being given a 'kick' - it will read it when it finishes processing the
> previous frame.
> This also means that you have to be careful about the order of the writes
> to the first descriptor.

This is what I implied and implemented in the patch ;)
