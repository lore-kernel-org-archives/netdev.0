From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: [RFC] multiqueue changes
Date: Sat, 31 Oct 2009 10:25:52 -0700
Message-ID: <1257009952.9706.30.camel@HP1>
References: <4ACD9255.4020008@gmail.com>
 <20091008090344.GA7409@ff.dom.local>
 <20091008120039.GA8691@ff.dom.local> <4AE87EEE.4020703@trash.net>
 <20091028212337.GA3218@ami.dom.local> <4AE9C4C3.9040503@trash.net>
 <20091029211543.GA3036@ami.dom.local> <4AEA1357.3090307@trash.net>
 <20091030100033.GA6150@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Patrick McHardy" <kaber@trash.net>,
	"Eric Dumazet" <eric.dumazet@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	"Linux Netdev List" <netdev@vger.kernel.org>
To: "Jarek Poplawski" <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:3182 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932417AbZJaRfR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 31 Oct 2009 13:35:17 -0400
In-Reply-To: <20091030100033.GA6150@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Fri, 2009-10-30 at 03:00 -0700, Jarek Poplawski wrote:
> On Thu, Oct 29, 2009 at 11:12:39PM +0100, Patrick McHardy wrote:
> > Jarek Poplawski wrote:
> > > On Thu, Oct 29, 2009 at 05:37:23PM +0100, Patrick McHardy wrote:
> > > ...
> > >> Well, we do need both values for supporting changes to the actually
> > >> used numbers of TX queues. If I understood Dave's explanation correctly,
> > >> this is also what's intended. It also doesn't seem unreasonable
> > >> what bnx2 is doing.
> > > 
> > > Exactly. With a growing number of cores, both available and powered
> > > off, these values will be soon treated more carefully than now.
> > > 
> > >> But getting back to the problem Eric reported - so you're suggesting
> > >> that bnx2.c should also adjust num_tx_queues in case the hardware
> > >> doesn't support multiqueue? That seems reasonable as well.
> > > 
> > > Currently, declaring num_tx_queues with alloc_netdev_mq() looks like
> > > too soon for some drivers. It seems they should be able to do it
> > > separately later during the .probe.
> > 
> > The value passed into alloc_netdev_mq() is just used for allocation
> > purposes, from what I can tell there's no downside in reducing it
> > before the dev_activate() call.
> 
> Right, but IMHO this reducing (or reallocation) should be done with
> some API. Simple overwriting of num_tx_queues proposed by Eric, even
> if no downside now, seems to be asking for problems in the future.
> 
> > > There is a question if .ndo_open should be considered too.
> > 
> > I currently can't see any purpose in decreasing num_tx_queues after
> > registration instead of real_num_tx_queues.
> 
> I agree, but since Eric's example shows some drivers do it (almost)
> like this, I'd prefer authors/maintainers answer this question.
> 

We need the netdev and the private structure at the beginning of
->probe() to store values as we probe the device.  Later on in
->probe(), we'll know whether the device supports MSI-X and multiqueue.
If we successfully enable MSI-X in ->ndo_open(), tx multiqueue will be
used.

So if we can separate the allocation of the netdev and the private
structure from the tx queues, we can allocate and set the exact number
of num_tx_queues in ->ndo_open().


