From: Paolo Abeni <pabeni@redhat.com>
Subject: Re: [RFC PATCH 0/3] udp: scalability improvements
Date: Mon, 08 May 2017 09:29:10 +0200
Message-ID: <1494228550.2397.3.camel@redhat.com>
References: <cover.1494103184.git.pabeni@redhat.com>
         <CALx6S349K0_61uKs0Aje4f-8yjkQdLgFTxgF=Xd1jOyS0uddVQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        "David S. Miller" <davem@davemloft.net>,
        Eric Dumazet <edumazet@google.com>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:43676 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753161AbdEHH3S (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 8 May 2017 03:29:18 -0400
In-Reply-To: <CALx6S349K0_61uKs0Aje4f-8yjkQdLgFTxgF=Xd1jOyS0uddVQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2017-05-06 at 16:09 -0700, Tom Herbert wrote:
> On Sat, May 6, 2017 at 1:42 PM, Paolo Abeni <pabeni@redhat.com> wrote:
> > This patch series implement an idea suggested by Eric Dumazet to
> > reduce the contention of the udp sk_receive_queue lock when the socket is
> > under flood.
> > 
> > An ancillary queue is added to the udp socket, and the socket always
> > tries first to read packets from such queue. If it's empty, we splice
> > the content from sk_receive_queue into the ancillary queue.
> > 
> > The first patch introduces some helpers to keep the udp code small, and the
> > following two implement the ancillary queue strategy. The code is split
> > to hopefully help the reviewing process.
> > 
> > The measured overall gain under udp flood is in the 20-35% range depending on
> > the numa layout and the number of ingress queue used by the relevant nic.
> > 
> 
> Certainly sounds good, but can you give real reproducible performance
> numbers including the test that was run?

You are right, and I'm sorry, the cover letter was too terse.

I used pktgen as sender, with 64 bytes packets, random src port on an
host b2b connected via a 10Gbs link with the dut.

On the receiver I used the udp_sink program by Jesper (https://github.c
om/netoptimizer/network-testing/blob/master/src/udp_sink.c) and I
configured an h/w l4 rx hash, so that I could control the number of
ingress nic rx queues hit by the udp traffic via ethtool -L.

The udp_sink program was bound to the first idle cpu, to get more
stable numbers.

Using a single numa note as receiver, I got the following:

nic rx queues		vanilla			patched kernel
1			1820 kpps		1900 kpps
2			1950 kpps		2500 kpps
16			1670 kpps		2120 kpps

When using a single nic rx queue I also enabled busy polling;
elsewhere, in my scenario, the bh processing becames the bottle-neck
and this produces large artifacts in the measured performances (e.g.
improving the udp sink run time, decreases the overall tput, since more
action from the scheduler comes into play).

Cheers,

Paolo
