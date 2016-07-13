From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [net-next PATCH RFC] mlx4: RX prefetch loop
Date: Tue, 12 Jul 2016 18:37:14 -0700
Message-ID: <20160713013711.GA65916@ast-mbp.thefacebook.com>
References: <20160708172024.4a849b7a@redhat.com>
 <20160708160135.27507.77711.stgit@firesoul>
 <20160711130922.636ee4e6@redhat.com>
 <20160711230509.GA45195@ast-mbp.thefacebook.com>
 <20160712144521.4244e8ab@redhat.com>
 <CAKgT0Ud8wrz8jRe5JzaiycZmO3fxNhPudRiv7up4ZWFfYWfj4A@mail.gmail.com>
 <20160712215252.7c72cbed@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alexander Duyck <alexander.duyck@gmail.com>,
	Netdev <netdev@vger.kernel.org>, kafai@fb.com,
	Daniel Borkmann <daniel@iogearbox.net>,
	Tom Herbert <tom@herbertland.com>,
	Brenden Blanco <bblanco@plumgrid.com>,
	john fastabend <john.fastabend@gmail.com>,
	Or Gerlitz <gerlitz.or@gmail.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	rana.shahot@gmail.com, Thomas Graf <tgraf@suug.ch>,
	"David S. Miller" <davem@davemloft.net>, as754m@att.com,
	Saeed Mahameed <saeedm@mellanox.com>, amira@mellanox.com,
	tzahio@mellanox.com, Eric Dumazet <eric.dumazet@gmail.com>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f180.google.com ([209.85.192.180]:33684 "EHLO
	mail-pf0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750907AbcGMBhp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Jul 2016 21:37:45 -0400
Received: by mail-pf0-f180.google.com with SMTP id i123so12584409pfg.0
        for <netdev@vger.kernel.org>; Tue, 12 Jul 2016 18:37:39 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20160712215252.7c72cbed@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 12, 2016 at 09:52:52PM +0200, Jesper Dangaard Brouer wrote:
> > 
> > >> Also unconditionally doing batch of 8 may also hurt depending on what
> > >> is happening either with the stack, bpf afterwards or even cpu version.  
> > >
> > > See this as software DDIO, if the unlikely case that data will get
> > > evicted, it will still exist in L2 or L3 cache (like DDIO). Notice,
> > > only 1024 bytes are getting prefetched here.  
> > 
> > I disagree.  DDIO only pushes received frames into the L3 cache.  What
> > you are potentially doing is flooding the L2 cache.  The difference in
> > size between the L3 and L2 caches is very significant.  L3 cache size
> > is in the MB range while the L2 cache is only 256KB or so for Xeon
> > processors and such.  In addition DDIO is really meant for an
> > architecture that has a fairly large cache region to spare and it it
> > limits itself to that cache region, the approach taken in this code
> > could potentially prefetch a fairly significant chunk of memory.
> 
> No matter how you slice it, reading this memory is needed, as I'm
> making sure only to prefetch packets that are "ready" and are within
> the NAPI budget.  (eth_type_trans/eth_get_headlen)

when compilers insert prefetches it typically looks like:
for (int i;...; i += S) {
  prefetch(data + i + N);
  access data[i]
}
the N is calculated based on weight of the loop and there is
no check that i + N is within loop bounds.
prefetch by definition is speculative. Too many prefetches hurt.
Wrong prefetch distance N hurts too.
Modern cpus compute stride in hw and do automatic prefetch, so
compilers rarely emit sw prefetch anymore, but the same logic
still applies. The ideal packet processing loop:
for (...) {
  prefetch(packet + i + N);
  access packet + i
}
if there is no loop there is no value in prefetch, since there
is no deterministic way to figure out exact time when packet
data would be accessed.
In case of bpf the program author can tell us 'weight' of
the program and since the program processes the packets
mostly through the same branches and lookups we can issue
prefetch based on author's hint.
Compilers never do:
prefetch data + i
prefetch data + i + 1
prefetch data + i + 2
access data + i
access data + i + 1
access data + i + 2
because by the time access is happening the prefetched data
may be already evicted.
