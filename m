From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [RFC PATCH 1/5] bpf: add PHYS_DEV prog type for early driver
 filter
Date: Tue, 5 Apr 2016 10:11:23 +0200
Message-ID: <20160405101123.4e128d13@redhat.com>
References: <57022A85.6040002@iogearbox.net>
	<20160404150700.1456ae80@redhat.com>
	<57026DFA.3090201@iogearbox.net>
	<CALx6S37aK79AbkUPBFTHkonUziSb7A1KV47vnG1OgciPD2qXcA@mail.gmail.com>
	<20160404171227.1f862cb1@redhat.com>
	<20160404152948.GA495@gmail.com>
	<57029127.3040303@gmail.com>
	<20160404161720.GB495@gmail.com>
	<20160404200032.GA69842@ast-mbp.thefacebook.com>
	<20160404220439.GA9972@pox.localdomain>
	<20160405022507.GB80209@ast-mbp.thefacebook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Thomas Graf <tgraf@suug.ch>, Brenden Blanco <bblanco@plumgrid.com>,
	John Fastabend <john.fastabend@gmail.com>,
	Tom Herbert <tom@herbertland.com>,
	Daniel Borkmann <daniel@iogearbox.net>,
	"David S. Miller" <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Or Gerlitz <ogerlitz@mellanox.com>, brouer@redhat.com
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:55640 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757097AbcDEILd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Apr 2016 04:11:33 -0400
In-Reply-To: <20160405022507.GB80209@ast-mbp.thefacebook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Mon, 4 Apr 2016 19:25:08 -0700
Alexei Starovoitov <alexei.starovoitov@gmail.com> wrote:

> On Tue, Apr 05, 2016 at 12:04:39AM +0200, Thomas Graf wrote:
> > On 04/04/16 at 01:00pm, Alexei Starovoitov wrote:  
> > > Exactly. That the most important part of this rfc.
> > > Right now redirect to different queue, batching, prefetch and tons of
> > > other code are mising. We have to plan the whole project, so we can
> > > incrementally add features without breaking abi.
> > > So new IFLA, xdp_metadata struct and enum for bpf return codes are
> > > the main things to agree on.  
> > 
> > +1
> > This is the most important statement in this thread so far. A plan
> > that gets us from this RFC series to a functional forwarding engine
> > with redirect and load/write is essential. [...]  

+1 agreed, I love to see the energy in this thread! :-)
 
> exactly. I think the next step 2 is to figure out the redirect return code
> and 'rewiring' of the rx dma buffer into tx ring and auto-batching.
>
> As this rfc showed even when using standard page alloc/free the peformance
> is hitting 10Gbps hw limit and not being cpu bounded, so recycling of
> the pages and avoiding map/unmap will come at step 3.

Yes, I've also noticed the standard page alloc/free performance is
slowing us down.  I will be working on identifying (and measuring) page
allocator bottlenecks.

For the early drop case, we should be able to hack the driver to,
recycle the page directly (and even avoid the DMA unmap).  But for the
TX (forward) case, we would need some kind of page-pool cache API to
recycle the page through (also useful for normal netstack usage).
  I'm interested in implementing a generic page-pool cache mechanism,
and I plan to bring up this topic at the MM-summit in 2 weeks.  Input
are welcome... but as Alexei says this is likely a step 3 project.


> Batching is necessary even for basic redirect, since ringing doorbell
> for every tx buffer is not an option.

Yes, we know TX batching is essential for performance.  If we create a
RX bundle/batch step (in the driver) then eBFP forward step can work on
a RX-bundle and build up TX-bundle(s) (per TX device), that can TX bulk
send these.  Notice that I propose building TX-bundles, not sending
each individual packet and flushing tail/doorbell, because I want to
maximize icache efficiency of the eBFP program.

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer
