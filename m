From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [RFC PATCH v2 1/5] bpf: add PHYS_DEV prog type for early driver
 filter
Date: Sat, 9 Apr 2016 10:00:02 -0700
Message-ID: <20160409170000.GA53526@ast-mbp.thefacebook.com>
References: <1460090930-11219-1-git-send-email-bblanco@plumgrid.com>
 <CALx6S34m8cVNgvuGp845bicixodfavH9cj-rARSwwEAvFCjd7g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Brenden Blanco <bblanco@plumgrid.com>,
	"David S. Miller" <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Jesper Dangaard Brouer <brouer@redhat.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Edward Cree <ecree@solarflare.com>,
	john fastabend <john.fastabend@gmail.com>,
	Thomas Graf <tgraf@suug.ch>,
	Johannes Berg <johannes@sipsolutions.net>,
	eranlinuxmellanox@gmail.com, Lorenzo Colitti <lorenzo@google.com>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f170.google.com ([209.85.192.170]:33177 "EHLO
	mail-pf0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753818AbcDIRAI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 Apr 2016 13:00:08 -0400
Received: by mail-pf0-f170.google.com with SMTP id 184so95217236pff.0
        for <netdev@vger.kernel.org>; Sat, 09 Apr 2016 10:00:07 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <CALx6S34m8cVNgvuGp845bicixodfavH9cj-rARSwwEAvFCjd7g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Apr 09, 2016 at 08:17:04AM -0300, Tom Herbert wrote:
> >
> > +/* user return codes for PHYS_DEV prog type */
> > +enum bpf_phys_dev_action {
> > +       BPF_PHYS_DEV_DROP,
> > +       BPF_PHYS_DEV_OK,
> 
> I don't like OK. Maybe this mean LOCAL. We also need FORWARD (not sure
> how to handle GRO yet).
> 
> I would suggest that we format the return code as code:subcode, where
> the above are codes. subcode is relevant to major code. For instance
> in forwarding the subcodes indicate a forwarding instruction (maybe a
> queue). DROP subcodes might answer why.

for tc redirect we use hidden percpu variable to pass additional
info together with return code. The cost of it is extra bpf_redirect() call.
Here we can do better and embed such info for xmit,
but subcodes for drop is slippery slop, since it's adding concepts
to design that are not going to be used by everyone.
If necessary bpf programs can count drop reasons internally.
Drops due to protocol!=ipv6 or drops due to ip frags present
will be program internal reasons. No need to expose them in api.

We need to get xmit part implemented first and see how it looks
before deciding on this part of api.
Right now I think we do not need tx queue number actually.
The prog should just return 'XMIT' and xdp(driver) side will decide
which tx queue to use.

> One other API issue is how to deal with encapsulation. In this case a
> header may be prepended to the packet, I assume there are BPF helper
> functions and we don't need to return a new length or start?

a bit of history:
for tc+bpf we've been trying to come up with clean helpers to do
header push/pop and it was very difficult, since skb keeps a ton
of metedata about header offsets, csum offsets, encap flag, etc
we've lost the count on number of different approaches we've
implemented and discarded.
For XDP there is no such issue.
Likely we'll have single bpf_packet_change(ctx, off, len) helper
that will grow(len) or trim(-len) bytes at offset(off) in the packet.
ctx->len will be adjusted automatically by the helper.
The headroom, tailroom will not be exposed and will never be known
to the bpf side. It's up to the helper and the driver to decide how to
insert N bytes at offset M. If the driver reserved headroom in dma
buffer, it can grow into it, if not it can grow tail and move
the whole packet. For performance reasons we obviously want some
headroom in dma buffer, but it's not exposed to bpf.

But it could be that directly adjusting ctx->len and ctx->data is faster.
For cls_bpf ctx->data is hidden and packet access is done via
special instructions and helpers. For XDP we can hopefully do better
and do packet access with direct loads. I outlined that plan
in the previous thread.
