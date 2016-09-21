From: Tom Herbert <tom@herbertland.com>
Subject: Re: [ANNOUNCE] ndiv: line-rate network traffic processing
Date: Wed, 21 Sep 2016 10:16:45 -0700
Message-ID: <CALx6S34Oy6QeOxR45PuuX70hfm-TR=2mpDwwqr82c7tvpWLX+Q@mail.gmail.com>
References: <20160921112852.GA991@1wt.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Willy Tarreau <w@1wt.eu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f196.google.com ([209.85.220.196]:35520 "EHLO
        mail-qk0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1757962AbcIURQq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 21 Sep 2016 13:16:46 -0400
Received: by mail-qk0-f196.google.com with SMTP id w204so3469116qka.2
        for <netdev@vger.kernel.org>; Wed, 21 Sep 2016 10:16:46 -0700 (PDT)
In-Reply-To: <20160921112852.GA991@1wt.eu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 21, 2016 at 4:28 AM, Willy Tarreau <w@1wt.eu> wrote:
> Hi,
>
> Over the last 3 years I've been working a bit on high traffic processing
> for various reasons. It started with the wish to capture line-rate GigE
> traffic on very small fanless ARM machines and the framework has evolved
> to be used at my company as a basis for our anti-DDoS engine capable of
> dealing with multiple 10G links saturated with floods.
>
> I know it comes a bit late now that there is XDP, but it's my first
> vacation since then and I needed to have a bit of calm time to collect
> the patches from the various branches and put them together. Anyway I'm
> sending this here in case it can be of interest to anyone, for use or
> just to study it.
>
> I presented it in 2014 at kernel recipes :
>   http://kernel-recipes.org/en/2014/ndiv-a-low-overhead-network-traffic-diverter/
>
> It now supports drivers mvneta, ixgbe, e1000e, e1000 and igb. It is
> very light, and retrieves the packets in the NIC's driver before they
> are converted to an skb, then submits them to a registered RX handler
> running in softirq context so we have the best of all worlds by
> benefitting from CPU scalability, delayed processing, and not paying
> the cost of switching to userland. Also an rx_done() function allows
> handlers to batch their processing. The RX handler returns an action
> among accepting the packet as-is, accepting it modified (eg: vlan or
> tunnel decapsulation), dropping it, postponing the processing
> (equivalent to EAGAIN), or building a new packet to send back.
>
> This last function is the one requiring the most changes in existing
> drivers, but offers the widest range of possibilities. We use it to
> send SYN cookies, but I have also implemented a stateless HTTP server
> supporting keep-alive using it, achieving line-rate traffic processing
> on a single CPU core when the NIC supports it. It's very convenient to
> test various stateful TCP components as it's easy to sustain millions
> of connections per second on it.
>
> It does not support forwarding between NICs. It was my first goal
> because I wanted to implement a TAP with it, bridging the traffic
> between two ports, but figured it was adding some complexity to the
> system back then. However since then we've implemented traffic
> capture in our product, exploiting this framework to capture without
> losses at 14 Mpps. I may find some time to try to extract it later.
> It uses the /sys API so that you can simply plug tcpdump -r on a
> file there, though there's also an mmap version which uses less CPU
> (that's important at 10G).
>
> In its current form since the initial code's intent was to limit
> core changes, it happens not to modify anything in the kernel by
> default and to reuse the net_device's ax25_ptr to attach devices
> (idea borrowed from netmap), so it can be used on an existing
> kernel just by loading the patched network drivers (yes, I know
> it's not a valid solution for the long term).
>
> The current code is available here :
>
>   http://git.kernel.org/cgit/linux/kernel/git/wtarreau/ndiv.git/
>
> Please let me know if there could be some interest in rebasing it
> on more recent versions (currently 3.10, 3.14 and 4.4 are supported).
> I don't have much time to assign to it since it works fine as-is,
> but will be glad to do so if that can be useful.
>
Hi Willy,

This does seem interesting and indeed the driver datapath looks very
much like XDP. It would be quite interesting if you could rebase and
then maybe look at how this can work with XDP that would be helpful.
The return actions are identical, but processing descriptor meta data
(like checksum, vlan) is not yet implemented in XDP-- maybe this is
something we can leverage from ndiv?

Tom

> Also the stateless HTTP server provided in it definitely is a nice
> use case for testing such a framework.
>
> Regards,
> Willy
