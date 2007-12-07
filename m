From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [RFC] TCP illinois max rtt aging
Date: Fri, 7 Dec 2007 13:05:46 +0200 (EET)
Message-ID: <Pine.LNX.4.64.0712071254070.18529@kivilampi-30.cs.helsinki.fi>
References: <aa7d2c6d0711261023m3d2dd850o76a8f44aef022f39@mail.gmail.com>
 <aa7d2c6d0711281625m44bf3ca3me188a7041d3421da@mail.gmail.com>
 <474E0B33.2060108@linux-foundation.org>  <001b01c83248$604f4120$20edc360$@edu>
  <20071203145207.40e4ac57@freepuppy.rosehill>
 <aa7d2c6d0712031506i73df4410p9ab8b1a60bc2ad2d@mail.gmail.com>
 <002f01c83608$8a2fb600$9e8f2200$@edu>  <20071203163217.27e4df3f@freepuppy.rosehill>
  <aa7d2c6d0712031723t314da471n8f033e8d1b523e1a@mail.gmail.com>
 <Pine.LNX.4.64.0712041031110.18529@kivilampi-30.cs.helsinki.fi>
 <aa7d2c6d0712061927g2e6f1679o8b05f76d723c0c76@mail.gmail.com>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-696243703-438326548-1197025546=:18529"
Cc: Netdev <netdev@vger.kernel.org>,
	Tom Quetchenbach <quetchen@caltech.edu>
To: Lachlan Andrew <lachlan.andrew@gmail.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:37740 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751216AbXLGLFt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Dec 2007 06:05:49 -0500
In-Reply-To: <aa7d2c6d0712061927g2e6f1679o8b05f76d723c0c76@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696243703-438326548-1197025546=:18529
Content-Type: TEXT/PLAIN; charset=iso-8859-1
Content-Transfer-Encoding: 8BIT

On Thu, 6 Dec 2007, Lachlan Andrew wrote:
> On 04/12/2007, Ilpo Järvinen <ilpo.jarvinen@helsinki.fi> wrote:
> > On Mon, 3 Dec 2007, Lachlan Andrew wrote:
> > >
> > > When SACK is active, the per-packet processing becomes more involved,
> > > tracking the list of lost/SACKed packets.  This causes a CPU spike
> > > just after a loss, which increases the RTTs, at least in my
> > > experience.
> >
> > I suspect that as long as old code was able to use hint, it wasn't doing
> > that bad. But it was seriously lacking ability to take advantage of sack
> > processing hint when e.g., a new hole appeared, or cumulative ACK arrived.
> >
> > ...Code available in net-2.6.25 might cure those.
> 
> We had been using one of your earlier patches, and still had the
> problem.  I think you've cured the problem with SACK itself, but there
> still seems to be something taking a lot of CPU while recovering from
> the loss. 

I guess if you get a large cumulative ACK, the amount of processing is 
still overwhelming (added DaveM if he has some idea how to combat it).

Even a simple scenario (this isn't anything fancy at all, will occur all 
the time): Just one loss => rest skbs grow one by one into a single 
very large SACK block (and we do that efficiently for sure) => then the 
fast retransmit gets delivered and a cumulative ACK for whole orig_window 
arrives => clean_rtx_queue has to do a lot of processing. In this case we 
could optimize RB-tree cleanup away (by just blanking it all) but still 
getting rid of all those skbs is going to take a larger moment than I'd 
like to see.

That tree blanking could be extended to cover anything which ACK more than 
half of the tree by just replacing the root (and dealing with potential 
recolorization of the root).

> It is possible that it was to do with  web100  which we
> have also been running, but I cut out most of the statistics from that
> and still had problems.

No idea about what it could do, haven't yet looked web100, I was planning 
at some point of time...

-- 
 i.
---696243703-438326548-1197025546=:18529--
