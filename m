From: Russell King - ARM Linux <linux@armlinux.org.uk>
Subject: Re: Alignment issues with freescale FEC driver
Date: Fri, 23 Sep 2016 18:37:52 +0100
Message-ID: <20160923173751.GA1041@n2100.armlinux.org.uk>
References: <troy.kisky@boundarydevices.com>
 <02afb707-65de-5101-a79b-355929c4e00b@nelint.com>
 <CANn89iLb+QJu+MYh859oAAjcLCsKRpBbzVf43yOdq+HJVtZDpQ@mail.gmail.com>
 <5ee28ee0-cf0c-bdab-1271-f17755365c13@nelint.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <edumazet@google.com>,
        "linux-arm-kernel@lists.infradead.org"
        <linux-arm-kernel@lists.infradead.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Fugang Duan <fugang.duan@nxp.com>,
        Troy Kisky <troy.kisky@boundarydevices.com>,
        Otavio Salvador <otavio@ossystems.com.br>,
        Simone <cjb.sw.nospam@gmail.com>
To: Eric Nelson <eric@nelint.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pandora.armlinux.org.uk ([78.32.30.218]:52622 "EHLO
        pandora.armlinux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1758793AbcIWRiH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 23 Sep 2016 13:38:07 -0400
Content-Disposition: inline
In-Reply-To: <5ee28ee0-cf0c-bdab-1271-f17755365c13@nelint.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Sep 23, 2016 at 10:19:50AM -0700, Eric Nelson wrote:
> Oddly, it does prevent the vast majority (90%+) of the alignment errors.
> 
> I believe this is because the compiler is generating an ldm instruction
> when the ntohl() call is used, but I'm stumped about why these aren't
> generating faults:

ldm generates alignment faults when the address is not aligned to a
32-bit boundary.  ldr on ARMv6+ does not.

> I don't think that's the case.
> 
> # CONFIG_IPV6_GRE is not set
> 
> Hmm... Instrumenting the kernel, it seems that iphdr **is** aligned on
> a 4-byte boundary.
> 
> Does the ldm instruction require 8-byte alignment?
> 
> There's definitely a compiler-version dependency involved here,
> since using gcc 4.9 also reduced the number of faults dramatically.

Well, I don't think it's that gcc related:

User:           0
System:         312855 (ip6_route_input+0x6c/0x1e0)
Skipped:        0
Half:           0
Word:           0
DWord:          2
Multi:          312853

c06d8998 <ip6_route_input>:
c06d89ac:       e1a04000        mov     r4, r0
c06d89b0:       e1d489b4        ldrh    r8, [r4, #148]  ; 0x94
c06d89b8:       e594a0a0        ldr     sl, [r4, #160]  ; 0xa0
c06d89cc:       e08ac008        add     ip, sl, r8
c06d89d4:       e28c3018        add     r3, ip, #24
c06d89dc:       e28c7008        add     r7, ip, #8
c06d89e4:       e893000f        ldm     r3, {r0, r1, r2, r3}
c06d89ec:       e24be044        sub     lr, fp, #68     ; 0x44
c06d89f4:       e24b5054        sub     r5, fp, #84     ; 0x54
c06d89fc:       e885000f        stm     r5, {r0, r1, r2, r3}
c06d8a04:       e897000f        ldm     r7, {r0, r1, r2, r3}
c06d8a10:       e88e000f        stm     lr, {r0, r1, r2, r3}

This is from:

        struct flowi6 fl6 = {
                .flowi6_iif = l3mdev_fib_oif(skb->dev),
                .daddr = iph->daddr,
                .saddr = iph->saddr,
                .flowlabel = ip6_flowinfo(iph),
                .flowi6_mark = skb->mark,
                .flowi6_proto = iph->nexthdr,
        };

specifically, I suspect, the saddr and daddr initialisations.

There's not much to get away from this - the FEC on iMX requires a
16-byte alignment for DMA addresses, which violates the network
stack's requirement for the ethernet packet to be received with a
two byte offset.  So the IP header (and IPv6 headers) will always
be mis-aligned in memory, which leads to a huge number of alignment
faults.

There's not much getting away from this - the problem is not in the
networking stack, but the FEC hardware/network driver.  See:

        struct  fec_enet_private *fep = netdev_priv(ndev);
        int off;

        off = ((unsigned long)skb->data) & fep->rx_align;
        if (off)
                skb_reserve(skb, fep->rx_align + 1 - off);

        bdp->cbd_bufaddr = cpu_to_fec32(dma_map_single(&fep->pdev->dev, skb->data, FEC_ENET_RX_FRSIZE - fep->rx_align, DMA_FROM_DEVICE));

in fec_enet_new_rxbdp().

-- 
RMK's Patch system: http://www.armlinux.org.uk/developer/patches/
FTTC broadband for 0.8mile line: currently at 9.6Mbps down 400kbps up
according to speedtest.net.
