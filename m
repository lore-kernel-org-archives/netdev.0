From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [net-next PATCH v3 2/3] e1000: add initial XDP support
Date: Mon, 12 Sep 2016 18:21:21 -0700
Message-ID: <20160913012119.GA25756@ast-mbp.thefacebook.com>
References: <20160912220312.5610.77528.stgit@john-Precision-Tower-5810>
 <20160912221351.5610.29043.stgit@john-Precision-Tower-5810>
 <1473720399.18970.91.camel@edumazet-glaptop3.roam.corp.google.com>
 <20160912230745.GA24171@ast-mbp.thefacebook.com>
 <1473723968.18970.111.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: John Fastabend <john.fastabend@gmail.com>, bblanco@plumgrid.com,
        jeffrey.t.kirsher@intel.com, brouer@redhat.com,
        davem@davemloft.net, xiyou.wangcong@gmail.com,
        intel-wired-lan@lists.osuosl.org, u9012063@gmail.com,
        netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:32907 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751561AbcIMBVZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 12 Sep 2016 21:21:25 -0400
Received: by mail-pf0-f196.google.com with SMTP id 128so8826417pfb.0
        for <netdev@vger.kernel.org>; Mon, 12 Sep 2016 18:21:25 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1473723968.18970.111.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Sep 12, 2016 at 04:46:08PM -0700, Eric Dumazet wrote:
> On Mon, 2016-09-12 at 16:07 -0700, Alexei Starovoitov wrote:
> 
> > yep. there are various ways to shoot yourself in the foot with xdp.
> > The simplest program that drops all the packets will make the box unpingable.
> 
> Well, my comment was about XDP_TX only, not about XDP_DROP or driving a
> scooter on 101 highway ;)
> 
> This XDP_TX thing was one of the XDP marketing stuff, but there is
> absolutely no documentation on it, warning users about possible
> limitations/outcomes.

that's fair critique. there is no documentation for xdp in general.

> BTW, I am not sure mlx4 implementation even works, vs BQL :

it doesn't and it shouldn't. xdp and stack use different tx queues.

> mlx4_en_xmit_frame() does not call netdev_tx_sent_queue(),
> but tx completion will call netdev_tx_completed_queue() -> crash

not quite. netdev_tx_completed_queue() is not called for xdp queues.

> Do we have one test to validate that a XDP_TX implementation is actually
> correct ?

it's correct in the scope that it was defined for.
There is no objective to share the same tx queue with the stack in xdp.
The queues must be absolutely separate otherwise performance will tank.

This e1k patch is really special, because the e1k has one tx queue,
but this is for debugging of the programs, so it's ok to cut corners.
The e1k xdp support doesn't need to interact nicely with stack.
It's impossible in the first place. xdp is the layer before the stack.
