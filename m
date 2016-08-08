From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [5.3] ucc_geth: Fix to avoid IS_ERR_VALUE abuses and dead code on 64bit systems.
Date: Mon, 08 Aug 2016 17:13:02 +0200
Message-ID: <2862487.guU7g5Qkfj@wuerfel>
References: <1470386442-7208-1-git-send-email-arvind.yadav.cs@gmail.com> <063D6719AE5E284EB5DD2968C1650D6D5F50C493@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: David Laight <David.Laight@aculab.com>,
	'Arvind Yadav' <arvind.yadav.cs@gmail.com>,
	"zajec5@gmail.com" <zajec5@gmail.com>,
	"leoli@freescale.com" <leoli@freescale.com>,
	"qiang.zhao@freescale.com" <qiang.zhao@freescale.com>,
	"viresh.kumar@linaro.org" <viresh.kumar@linaro.org>,
	"linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"scottwood@freescale.com" <scottwood@freescale.com>,
	"akpm@linux-foundation.org" <akpm@linux-foundation.org>,
	"linux@roeck-us.net" <linux@roeck-us.net>
To: linuxppc-dev@lists.ozlabs.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.kundenserver.de ([212.227.17.10]:62831 "EHLO
	mout.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751473AbcHHPOC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Aug 2016 11:14:02 -0400
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D5F50C493@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Monday, August 8, 2016 2:49:11 PM CEST David Laight wrote:
> 
> > If qe_muram_alloc will return any error, Then IS_ERR_VALUE will always
> > return 0. it'll not call ucc_fast_free for any failure. Inside 'if code'
> > will be a dead code on 64bit. Even qe_muram_addr will return wrong
> > virtual address. Which can cause an error.
> > 
> >  kfree((void *)ugeth->tx_bd_ring_offset[i]);
> 
> Erm, kfree() isn't the right function for things allocated by qe_muram_alloc().
> 
> I still thing you need to stop this code using IS_ERR_VALUE() at all.

Those are two separate issues:

a) The ucc_geth driver mixing kmalloc() memory with muram, and assigning
   the result to "u32" and "void __iomem *" variables, both of which
   are wrong at least half of the time.

b) calling conventions of qe_muram_alloc() being defined in a way that
   requires the use of IS_ERR_VALUE(), because '0' is a valid address
   here.

The first one can be solved by updating the network driver, ideally
by getting rid of the casts and using proper types and accessors,
while the second would require updating all users of that interface.

	Arnd
