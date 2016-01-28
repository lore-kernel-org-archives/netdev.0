From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: Bypass at packet-page level (Was: Optimizing instruction-cache,
 more packets at each stage)
Date: Thu, 28 Jan 2016 18:04:38 +0100
Message-ID: <20160128180438.59dbb937@redhat.com>
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
	<20160125231016.4f0d2cd5@redhat.com>
	<20160127214750.51fe2392@redhat.com>
	<CALx6S350ra6fmZrcabasndWBq4A3L-xKLS__jy1gi3xmhMc=sA@mail.gmail.com>
	<20160128102530.5c07a8e7@redhat.com>
	<1453985153.7627.8.camel@edumazet-glaptop2.roam.corp.google.com>
	<CALx6S36nQ6-PnyDUrQseeeNYJM1wnPSkjcERw0GehzMYSUxR6w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	John Fastabend <john.fastabend@gmail.com>,
	"Michael S. Tsirkin" <mst@redhat.com>,
	David Miller <davem@davemloft.net>,
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
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:35416 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755701AbcA1REr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 28 Jan 2016 12:04:47 -0500
In-Reply-To: <CALx6S36nQ6-PnyDUrQseeeNYJM1wnPSkjcERw0GehzMYSUxR6w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 28 Jan 2016 08:37:07 -0800
Tom Herbert <tom@herbertland.com> wrote:

> On Thu, Jan 28, 2016 at 4:45 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> > On Thu, 2016-01-28 at 10:25 +0100, Jesper Dangaard Brouer wrote:
> >  
> >> Yes, that is exactly what I'm contemplating :-)  That is idea "(1)".
> >>
> >> A natural extension to this work, which I expect Tom will love, is to
> >> also use the idea for RPS.  Once we have a SKB list in stack/GRO-layer,
> >> then we could build a local sk_buff_head list for each remote CPU, by
> >> calling get_rps_cpu().   And then enqueue_list_to_backlog, by a
> >> skb_queue_splice_tail(&cpu_list, &cpu->sd->input_pkt_queue) call.
> >>
> >> This would amortize the cost of transferring packets to a remote CPU,
> >> which Eric AFAIK points out is costing approx ~133ns.
> >>  
> >
> > Jesper, RPS and RFS already defer sending the IPI and submit batches to
> > remote cpus.
> >
> > See commits
> >
> > e326bed2f47d0365da5a8faaf8ee93ed2d86325b ("rps: immediate send IPI in
> > process_backlog()")
> >
> > 88751275b8e867d756e4f86ae92afe0232de129f ("rps: shortcut
> > net_rps_action()")
> >
> > And of course all the discussions we had to come up with
> > 0a9627f2649a02bea165cfd529d7bcb625c2fcad ("rps: Receive Packet
> > Steering")
> >
> > The current state :
> >
> > net_rps_action_and_irq_enable() sends the IPI at the end of
> > net_rx_action() once all NAPI handlers have been called, and therefore
> > have accumulated packets and cook rps_ipi_list (via calls to
> > rps_ipi_queued() from enqueue_to_backlog())

Yes, thanks for pointing this out. Then we already have amortized the
IPI call. Great.

> > Adding another stage in the pipeline would not help.
> >  
> skbs are enqueued on a CPU queue one at at time through
> enqueue_to_backlog. It would be nice to do that as a batch of skbs.

Yes, this was what I was looking at doing, a bulk enqueue to backlog.
Thus, amortizing the lock.  And if some remote CPU is reading/using
input_pkt_queue, then we don't bounce that cache line.

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer
