From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: rhashtable: ENOMEM errors when hit with a flood of insertions
Date: Thu, 3 Dec 2015 15:08:20 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D1CBE32C4@AcuExch.aculab.com>
References: <1448039840-11367-1-git-send-email-phil@nwl.cc>
 <20151130093755.GA8159@gondor.apana.org.au>
 <20151130101401.GA17712@orbit.nwl.cc>
 <20151130101859.GA8378@gondor.apana.org.au>
 <20151203125117.GB5505@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
To: 'Herbert Xu' <herbert@gondor.apana.org.au>,
	Phil Sutter <phil@nwl.cc>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"tgraf@suug.ch" <tgraf@suug.ch>,
	"fengguang.wu@intel.com" <fengguang.wu@intel.com>,
	"wfg@linux.intel.com" <wfg@linux.intel.com>,
	"lkp@01.org" <lkp@01.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out4.electric.net ([192.162.216.193]:64959 "EHLO
	smtp-out4.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751510AbbLCPJ4 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Dec 2015 10:09:56 -0500
In-Reply-To: <20151203125117.GB5505@gondor.apana.org.au>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu
> Sent: 03 December 2015 12:51
> On Mon, Nov 30, 2015 at 06:18:59PM +0800, Herbert Xu wrote:
> >
> > OK that's better.  I think I see the problem.  The test in
> > rhashtable_insert_rehash is racy and if two threads both try
> > to grow the table one of them may be tricked into doing a rehash
> > instead.
> >
> > I'm working on a fix.
> 
> While the EBUSY errors are gone for me, I can still see plenty
> of ENOMEM errors.  In fact it turns out that the reason is quite
> understandable.  When you pound the rhashtable hard so that it
> doesn't actually get a chance to grow the table in process context,
> then the table will only grow with GFP_ATOMIC allocations.
> 
> For me this starts failing regularly at around 2^19 entries, which
> requires about 1024 contiguous pages if I'm not mistaken.

ISTM that you should always let the insert succeed - even if it makes
the average/maximum chain length increase beyond some limit.
Any limit on the number of hashed items should have been done earlier
by the calling code.
The slight performance decrease caused by scanning longer chains
is almost certainly more 'user friendly' than an error return.

Hoping to get 1024+ contiguous VA pages does seem over-optimistic.

With a 2-level lookup you could make all the 2nd level tables
a fixed size (maybe 4 or 8 pages?) and extend the first level
table as needed.

	David
