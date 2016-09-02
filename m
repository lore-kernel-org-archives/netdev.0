From: Brenden Blanco <bblanco@plumgrid.com>
Subject: Re: [PATCH] net/mlx4_en: protect ring->xdp_prog with rcu_read_lock
Date: Fri, 2 Sep 2016 11:01:38 -0700
Message-ID: <20160902180136.GB14176@gmail.com>
References: <20160826203808.23664-1-bblanco@plumgrid.com>
 <c03157a0-b7d0-bde7-0fe9-4f3b19a68d08@mellanox.com>
 <20160829155558.GA13971@gmail.com>
 <CALx6S34nt0iLEse45y4UrJFbfBFNoZ6oYzu+3Hdq3A=6Rn9hrg@mail.gmail.com>
 <CALzJLG8WGA5+cbyMd2f8Y2Qpcx=b72r2hSZ7Vn7+N-o3BzBvZw@mail.gmail.com>
 <20160831015058.GA30198@gmail.com>
 <CALzJLG-RPMuiFTku4BVE5MgtAQV6WS0DLhxHymE6ydh9JccdKQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Tom Herbert <tom@herbertland.com>,
        Tariq Toukan <tariqt@mellanox.com>,
        "David S. Miller" <davem@davemloft.net>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        Tariq Toukan <ttoukan.linux@gmail.com>,
        Or Gerlitz <gerlitz.or@gmail.com>
To: Saeed Mahameed <saeedm@dev.mellanox.co.il>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f172.google.com ([209.85.192.172]:36853 "EHLO
        mail-pf0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754623AbcIBSBl (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 2 Sep 2016 14:01:41 -0400
Received: by mail-pf0-f172.google.com with SMTP id h186so44472687pfg.3
        for <netdev@vger.kernel.org>; Fri, 02 Sep 2016 11:01:41 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <CALzJLG-RPMuiFTku4BVE5MgtAQV6WS0DLhxHymE6ydh9JccdKQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Sep 02, 2016 at 01:59:40AM +0300, Saeed Mahameed wrote:
> On Wed, Aug 31, 2016 at 4:50 AM, Brenden Blanco <bblanco@plumgrid.com> wrote:
> > On Tue, Aug 30, 2016 at 12:35:58PM +0300, Saeed Mahameed wrote:
[...]
> >> Sorry folks I am with Tariq on this, you can't just add a single
> >> instruction which is only valid/needed for 1% of the use cases
> >> to the driver's general data path, even if it was as cheap as one cpu cycle!
> > How about 0?
> >
> > $ diff mlx4_en.ko.norcu.s mlx4_en.ko.rcu.s | wc -l
> > 0
> >
> 
> Well, If you put it this way, it seems OK then.
> 
> Anyway I would add a friendly comment beside the rcu_read_lock that
> "this is needed to protect
> access to ring->xdp_prog".

Thanks, I will go ahead with this then.

> 
> >>
> >> Let me try to suggest something:
> >> instead of taking the rcu_read_lock for the whole
> >> mlx4_en_process_rx_cq, we can minimize to XDP code path only
> >> by double checking xdp_prog (non-protected check followed by a
> >> protected check inside mlx4 XDP critical path).
> >>
> >> i.e instead of:
> >>
> >> rcu_read_lock();
> >>
> >> xdp_prog = ring->xdp_prog;
> >>
> >> //__Do lots of non-XDP related stuff__
> >>
> >> if (xdp_prog) {
> >>     //Do XDP magic ..
> >> }
> >> //__Do more of non-XDP related stuff__
> >>
> >> rcu_read_unlock();
> >>
> >>
> >> We can minimize it to XDP critical path only:
> >>
> >> //Non protected xdp_prog dereference.
> >> if (xdp_prog) {
> >>      rcu_read_lock();
> >>      //Protected dereference to ring->xdp_prog
> >>      xdp_prog = ring->xdp_prog;
> >>      if(unlikely(!xdp_prg)) goto unlock;
> >
> > The addition of this branch and extra deref is now slowing down the xdp
> > path compared to the current proposal.
> >
> 
> Yep, but this is an unlikely condition and the critical code here is
> much smaller and it is more clear that the rcu_read_lock here meant to
> protect the ring->xdp_prog under this small xdp critical section in
> comparison to your patch where it is held across the whole RX
> function.

It's really an improper use of RCU though.

RCU is meant to provide correctness without sacrificing any performance
in the fastpath. It is designed to avoid having to double-dereference
and other such tricks, so shouldn't we use it how it was designed?
Having a larger scoped rcu_read_lock doesn't hurt anybody here, but the
extra memory reads certainly _does_ impact the XDP path, which folks are
going to start relying on to be performant. Let's not start chipping
away at that.
