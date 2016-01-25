From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: Bypass at packet-page level (Was: Optimizing instruction-cache,
 more packets at each stage)
Date: Mon, 25 Jan 2016 23:10:16 +0100
Message-ID: <20160125231016.4f0d2cd5@redhat.com>
References: <1453330945.1223.329.camel@edumazet-glaptop2.roam.corp.google.com>
	<CALx6S34H67o64q3YoYiHQ+VSSuSsuSjBXmexSSXF_Hq8fcN0iw@mail.gmail.com>
	<20160121122730.6330a84b@redhat.com>
	<20160121.105401.1793719917762270884.davem@davemloft.net>
	<20160124152814.2ea5e99b@redhat.com>
	<20160124163846-mutt-send-email-mst@redhat.com>
	<56A509C4.3030706@gmail.com>
	<20160125141516.795f3eb7@redhat.com>
	<CALx6S37EmUh7SXmVSjTN9DLMTicr6-VwL-i25VV1fM=V2E6giQ@mail.gmail.com>
	<56A66058.1090308@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Tom Herbert <tom@herbertland.com>,
	"Michael S. Tsirkin" <mst@redhat.com>,
	David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Or Gerlitz <gerlitz.or@gmail.com>,
	Eric Dumazet <edumazet@google.com>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Alexander Duyck <alexander.duyck@gmail.com>,
	Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	Daniel Borkmann <borkmann@iogearbox.net>,
	Marek Majkowski <marek@cloudflare.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Florian Westphal <fw@strlen.de>,
	Paolo Abeni <pabeni@redhat.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	Amir Vadai <amirva@gmail.com>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Vladislav Yasevich <vyasevich@gmail.com>, brouer@redhat.com
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:36507 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751275AbcAYWKZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 25 Jan 2016 17:10:25 -0500
In-Reply-To: <56A66058.1090308@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Mon, 25 Jan 2016 09:50:16 -0800 John Fastabend <john.fastabend@gmail.com> wrote:

> On 16-01-25 09:09 AM, Tom Herbert wrote:
> > On Mon, Jan 25, 2016 at 5:15 AM, Jesper Dangaard Brouer
> > <brouer@redhat.com> wrote:  
> >>
[...]
> >>
> >> There are two ideas, getting mixed up here.  (1) bundling from the
> >> RX-ring, (2) allowing to pick up the "packet-page" directly.
> >>
> >> Bundling (1) is something that seems natural, and which help us
> >> amortize the cost between layers (and utilizes icache better). Lets
> >> keep that in another thread.
> >>
> >> This (2) direct forward of "packet-pages" is a fairly extreme idea,
> >> BUT it have the potential of being an new integration point for
> >> "selective" bypass-solutions and bringing RAW/af_packet (RX) up-to
> >> speed with bypass-solutions.
>
[...]
> 
> Jesper, at least for you (2) case what are we missing with the
> bifurcated/queue splitting work? Are you really after systems
> without SR-IOV support or are you trying to get this on the order
> of queues instead of VFs.

I'm not saying something is missing for bifurcated/queue splitting work.
I'm not trying to work-around SR-IOV.

This an extreme idea, which I got while looking at the lowest RX layer.


Before working any further on this idea/path, I need/want to evaluate
if it makes sense from a performance point of view.  I need to evaluate
if "pulling" out these "packet-pages" is fast enough to compete with
DPDK/netmap.  Else it makes no sense to work on this path.

As a first step to evaluate this lowest RX layer, I'm simply hacking
the drivers (ixgbe and mlx5) to drop/discard packets within-the-driver.
For now, simply replacing napi_gro_receive() with dev_kfree_skb(), and
measuring the "RX-drop" performance.

Next step was to avoid the skb alloc+free calls, but doing so is more
complicated that I first anticipated, as the SKB is tied in fairly
heavily.  Thus, right now I'm instead hooking in my bulk alloc+free
API, as that will remove/mitigate most of the overhead of the
kmem_cache/slab-allocators.

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer
