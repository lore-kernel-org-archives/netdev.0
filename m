From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [RFC PATCH 1/5] bpf: add PHYS_DEV prog type for early driver
 filter
Date: Mon, 4 Apr 2016 19:25:08 -0700
Message-ID: <20160405022507.GB80209@ast-mbp.thefacebook.com>
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
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Brenden Blanco <bblanco@plumgrid.com>,
	John Fastabend <john.fastabend@gmail.com>,
	Jesper Dangaard Brouer <brouer@redhat.com>,
	Tom Herbert <tom@herbertland.com>,
	Daniel Borkmann <daniel@iogearbox.net>,
	"David S. Miller" <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	ogerlitz@mellanox.com
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f170.google.com ([209.85.192.170]:33551 "EHLO
	mail-pf0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751579AbcDEC0B (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Apr 2016 22:26:01 -0400
Received: by mail-pf0-f170.google.com with SMTP id 184so293097pff.0
        for <netdev@vger.kernel.org>; Mon, 04 Apr 2016 19:25:38 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20160404220439.GA9972@pox.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 05, 2016 at 12:04:39AM +0200, Thomas Graf wrote:
> On 04/04/16 at 01:00pm, Alexei Starovoitov wrote:
> > Exactly. That the most important part of this rfc.
> > Right now redirect to different queue, batching, prefetch and tons of
> > other code are mising. We have to plan the whole project, so we can
> > incrementally add features without breaking abi.
> > So new IFLA, xdp_metadata struct and enum for bpf return codes are
> > the main things to agree on.
> 
> +1
> This is the most important statement in this thread so far. A plan
> that gets us from this RFC series to a functional forwarding engine
> with redirect and load/write is essential. [...]

exactly. I think the next step 2 is to figure out the redirect return code
and 'rewiring' of the rx dma buffer into tx ring and auto-batching.
As this rfc showed even when using standard page alloc/free the peformance
is hitting 10Gbps hw limit and not being cpu bounded, so recycling of
the pages and avoiding map/unmap will come at step 3.
Batching is necessary even for basic redirect, since ringing doorbell
for every tx buffer is not an option.

> [...] I would really like to see a common set of helpers which
> applies to both cls_bpf and phys_dev. Given the existing skb based
> helpers cannot be overloaded, at least the phys_dev helpers should
> be made to work in cls_bpf context as well to allow for some
> portability. Otherwise we'll end up with half a dozen flavours of
> BPF which are all incompatible.

The helpers can be 'overloaded'. In my upcoming patches for
bpf+tracepoints the bpf_perf_event_output() helper is different
depending on program type (kprobe vs tracepoint), but logically
it looks exactly the same from program point of view and
BPF_FUNC_id is reused.
So for cls_bpf vs bpf_phys_dev we can have the same bpf_csum_diff()
helper which will have different internal implementation depending
on program type.
