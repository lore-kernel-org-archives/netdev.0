From: Brenden Blanco <bblanco@plumgrid.com>
Subject: Re: [PATCH] net/mlx4_en: protect ring->xdp_prog with rcu_read_lock
Date: Fri, 2 Sep 2016 10:50:10 -0700
Message-ID: <20160902175006.GA14176@gmail.com>
References: <20160826203808.23664-1-bblanco@plumgrid.com>
 <c03157a0-b7d0-bde7-0fe9-4f3b19a68d08@mellanox.com>
 <20160829155558.GA13971@gmail.com>
 <CALx6S34nt0iLEse45y4UrJFbfBFNoZ6oYzu+3Hdq3A=6Rn9hrg@mail.gmail.com>
 <CALzJLG8WGA5+cbyMd2f8Y2Qpcx=b72r2hSZ7Vn7+N-o3BzBvZw@mail.gmail.com>
 <20160831015058.GA30198@gmail.com>
 <CALzJLG-RPMuiFTku4BVE5MgtAQV6WS0DLhxHymE6ydh9JccdKQ@mail.gmail.com>
 <CALx6S37A9QimRinL7YAcoSh8MRn6jpJ7pMZwqGLGiTeaBoBORg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Saeed Mahameed <saeedm@dev.mellanox.co.il>,
        Tariq Toukan <tariqt@mellanox.com>,
        "David S. Miller" <davem@davemloft.net>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        Tariq Toukan <ttoukan.linux@gmail.com>,
        Or Gerlitz <gerlitz.or@gmail.com>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f181.google.com ([209.85.192.181]:36232 "EHLO
        mail-pf0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752509AbcIBRuN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 2 Sep 2016 13:50:13 -0400
Received: by mail-pf0-f181.google.com with SMTP id h186so44392080pfg.3
        for <netdev@vger.kernel.org>; Fri, 02 Sep 2016 10:50:13 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <CALx6S37A9QimRinL7YAcoSh8MRn6jpJ7pMZwqGLGiTeaBoBORg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 01, 2016 at 04:30:28PM -0700, Tom Herbert wrote:
[...]
> > Yep, but this is an unlikely condition and the critical code here is
> > much smaller and it is more clear that the rcu_read_lock here meant to
> > protect the ring->xdp_prog under this small xdp critical section in
> > comparison to your patch where it is held across the whole RX
> > function.
> 
> Note that there is already an rcu_read_lock potentially per packet
> buried in the function, if the whole function is under rcu_read_lock
> then that can be removed.
Yes I was aware of that, I had left it as-is since: 1. it seemed to be
in an exception path and less performance sensitive to nested calls, and
2. in case some future developer removed the top-level rcu_read_lock,
the finer-grained one would have been unprotected if not code reviewed
carefully.

I'll instead add a note at the top pointing out the dual need for the
lock, to address both yours and Saeed's comments.

As a side note, when considering the idea of moving the rcu_read_lock to
a more generic location (napi), I had toyed with the idea of
benchmarking to see if removing the actually-fast-path use of
rcu_read_lock in netif_receive_skb_internal could have any performance
benefit for the universal use case (non-xdp). However, that seems
completely out of scope at the moment, and only beneficial for
non-standard (IMO) .configs, besides being much harder to review. It was
showing up in perf at about 1-2% overhead in preempt=y kernels.
> 
> Tom
