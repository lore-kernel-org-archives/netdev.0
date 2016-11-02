From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [PATCH net-next RFC WIP] Patch for XDP support for virtio_net
Date: Wed, 2 Nov 2016 15:27:08 +0100
Message-ID: <20161102152708.5cb40a0c@redhat.com>
References: <20161028011739-mutt-send-email-mst@kernel.org>
        <20161027.213512.334468356710231957.davem@davemloft.net>
        <CAKgT0Ufe3QYtFpmtsL39-nbyy+YEt=gZKU_WUr9Wir+LTYLuEQ@mail.gmail.com>
        <20161027.221027.109834362557507518.davem@davemloft.net>
        <58137533.4030105@gmail.com>
        <20161028171812.48073f1f@jkicinski-Precision-T1700>
        <20161028182223.GA53930@ast-mbp.thefacebook.com>
        <ec23c734c23d81884349484927140741@mail.gmail.com>
        <20161029112514.GC1810@pox.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Shrijeet Mukherjee <shm@cumulusnetworks.com>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        Jakub Kicinski <kubakici@wp.pl>,
        John Fastabend <john.fastabend@gmail.com>,
        David Miller <davem@davemloft.net>, alexander.duyck@gmail.com,
        mst@redhat.com, shrijeet@gmail.com, tom@herbertland.com,
        netdev@vger.kernel.org, Roopa Prabhu <roopa@cumulusnetworks.com>,
        Nikolay Aleksandrov <nikolay@cumulusnetworks.com>,
        brouer@redhat.com
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:54526 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1755715AbcKBO1R (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 2 Nov 2016 10:27:17 -0400
In-Reply-To: <20161029112514.GC1810@pox.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 29 Oct 2016 13:25:14 +0200
Thomas Graf <tgraf@suug.ch> wrote:

> On 10/28/16 at 08:51pm, Shrijeet Mukherjee wrote:
> > Generally agree, but SRIOV nics with multiple queues can end up in a bad
> > spot if each buffer was 4K right ? I see a specific page pool to be used
> > by queues which are enabled for XDP as the easiest to swing solution that
> > way the memory overhead can be restricted to enabled queues and shared
> > access issues can be restricted to skb's using that pool no ?

Yes, that is why that I've been arguing so strongly for having the
flexibility to attach a XDP program per RX queue, as this only change
the memory model for this one queue.

 
> Isn't this clearly a must anyway? I may be missing something
> fundamental here so please enlighten me :-)
> 
> If we dedicate a page per packet, that could translate to 14M*4K worth
> of memory being mapped per second for just a 10G NIC under DoS attack.
> How can one protect such as system? Is the assumption that we can always
> drop such packets quickly enough before we start dropping randomly due
> to memory pressure? If a handshake is required to determine validity
> of a packet then that is going to be difficult.

Under DoS attacks you don't run out of memory, because a diverse set of
socket memory limits/accounting avoids that situation.  What does
happen is the maximum achievable PPS rate is directly dependent on the
time you spend on each packet.   This use of CPU resources (and
hitting mem-limits-safe-guards) push-back on the drivers speed to
process the RX ring.  In effect, packets are dropped in the NIC HW as
RX-ring queue is not emptied fast-enough.

Given you don't control what HW drops, the attacker will "successfully"
cause your good traffic to be among the dropped packets.

This is where XDP change the picture. If you can express (by eBPF) a
filter that can separate "bad" vs "good" traffic, then you can take
back control.  Almost like controlling what traffic the HW should drop.
Given the cost of XDP-eBPF filter + serving regular traffic does not
use all of your CPU resources, you have overcome the attack.

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer
