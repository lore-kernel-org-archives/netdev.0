From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [RFC net-next PATCH 4/5] net: new XDP feature for reading HW
 rxhash from drivers
Date: Fri, 19 May 2017 20:34:00 -0700
Message-ID: <20170520033358.hjz7ocy2fupwplym@ast-mbp>
References: <149512205297.14733.15729847433404265933.stgit@firesoul>
 <149512210827.14733.13997041998775151648.stgit@firesoul>
 <20170520030750.c2b55oqdms5n764c@ast-mbp>
 <20170519202147.3c6bda7f@cakuba.netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jesper Dangaard Brouer <brouer@redhat.com>,
        Daniel Borkmann <borkmann@iogearbox.net>,
        John Fastabend <john.r.fastabend@intel.com>,
        netdev@vger.kernel.org
To: Jakub Kicinski <kubakici@wp.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:35804 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751417AbdETDeE (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 19 May 2017 23:34:04 -0400
Received: by mail-pf0-f193.google.com with SMTP id u26so11306377pfd.2
        for <netdev@vger.kernel.org>; Fri, 19 May 2017 20:34:03 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20170519202147.3c6bda7f@cakuba.netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, May 19, 2017 at 08:21:47PM -0700, Jakub Kicinski wrote:
> On Fri, 19 May 2017 20:07:52 -0700, Alexei Starovoitov wrote:
> > How about exposing 'struct mlx5_cqe64 *' to XDP programs as-is?
> > We can make sure that XDP program does read only access into it and
> > it will see cqe->rss_hash_result, cqe->rss_hash_type and everything else
> > in there, but this will not be uapi and it will be pretty obvious
> > to program authors that their programs are vendor specific.
> > 'not uapi' here means that mellanox is free to change their HW descriptor
> > and its contents as they wish.
> 
> Hm..  Would that mean we have to teach the verifier about all possible
> drivers and their metadata structures (i.e. sizes thereof).  And add an
> UAPI enum of known drivers?

why? no uapi other than a pointer to this hw rx descriptor.
Different sizeof(hw_rx_descriptor) is not a problem.
We deal with it already in tracing. All tracepoints have different
sizeof(*ctx), yet the safety is preserved.

> Other idea I floated in early days was to standardize the fields but
> let the driver "JIT" the accesses to look at the right offset of the
> right structure.  Admittedly that would be a lot more work.

'standardize the fields' sounds nice, but failed here already.
As far as I can see the meaning of packet 'hash' is quite different
across the drivers and 'hash' is just a beginning.
I hope we can standardize on 'csum' field and make it checksum_complete,
but so far out of 10+G nics only mlx5 and nfp do it in hw.
We need it at least for mlx4, but it can only fake it via expensive math.
