From: Russell King - ARM Linux <linux@armlinux.org.uk>
Subject: Re: TCP performance problems - GSO/TSO, MSS, 8139cp related
Date: Fri, 11 Nov 2016 22:33:08 +0000
Message-ID: <20161111223307.GF1041@n2100.armlinux.org.uk>
References: <20161111210500.GE1041@n2100.armlinux.org.uk>
 <1478899423.3892.7.camel@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, qemu-devel@nongnu.org
To: David Woodhouse <dwmw2@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pandora.armlinux.org.uk ([78.32.30.218]:41044 "EHLO
        pandora.armlinux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934727AbcKKWdQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 11 Nov 2016 17:33:16 -0500
Content-Disposition: inline
In-Reply-To: <1478899423.3892.7.camel@infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Nov 11, 2016 at 09:23:43PM +0000, David Woodhouse wrote:
> On Fri, 2016-11-11 at 21:05 +0000, Russell King - ARM Linux wrote:
> > 
> > 18:59:38.782818 IP (tos 0x0, ttl 52, id 35619, offset 0, flags [DF], proto TCP (6), length 60)
> >     84.xx.xxx.196.61236 > 195.92.253.2.http: Flags [S], cksum 0x88db (correct), seq 158975430, win 29200, options [mss 1452,sackOK,TS val 1377914597 ecr 0,nop,wscale 7], length 0
> 
> ... (MSS 1452)
> 
> > 18:59:38.816371 IP (tos 0x0, ttl 64, id 25879, offset 0, flags [DF], proto TCP (6), length 1500)
> >     195.92.253.2.http > 84.xx.xxx.196.61236: Flags [.], seq 1:1449, ack 154, win 235, options [nop,nop,TS val 3363137952 ecr 1377914627], length 1448: HTTP, length: 1448
> > 18:59:38.816393 IP (tos 0x0, ttl 64, id 25880, offset 0, flags [DF], proto TCP (6), length 1484)
> >     195.92.253.2.http > 84.xx.xxx.196.61236: Flags [.], seq 1449:2881, ack 154, win 235, options [nop,nop,TS val 3363137952 ecr 1377914627], length 1432: HTTP
> 
> Can you instrument cp_start_xmit() in 8139cp.c and get it to print the
> value of 'mss' when this happens?

Well, I'm not going to fiddle in such a way with a public box... that
would be utter madness.  I'll fiddle with mvneta locally on 4.9-rc
instead - and yes, I know that's not the F23 4.4 kernel, so doesn't
really tell us very much.

I _could_ ask bryce to setup another VM on ZenV for me to play with,
but we'll have to wait for bryce to be around for that... I don't
want to break zenv or zeniv. :)

> All we do is take that value from skb_shinfo(skb)->gso_size, shift it a
> bit, and shove it in the descriptor ring. There's not much scope for a
> driver-specific bug.

Unless there's a different interpretation of what the MSS field in the
driver means...

Looking at mvneta, which works correctly,

- On mvneta (192.168.1.59):

21:39:38.535549 IP (tos 0x0, ttl 64, id 27668, offset 0, flags [DF], proto TCP (6), length 7252)
    192.168.1.59.55170 > 192.168.1.18.5001: Flags [.], seq 25:7225, ack 1, win 229, options [nop,nop,TS val 62231754 ecr 1387514367], length 7200

- On laptop (192.168.1.18):

21:39:38.537442 IP (tos 0x0, ttl 64, id 27668, offset 0, flags [DF], proto TCP (6), length 1492)
    192.168.1.59.55170 > 192.168.1.18.commplex-link: Flags [.], seq 25:1465, ack 1, win 229, options [nop,nop,TS val 62231754 ecr 1387514367], length 1440
21:39:38.537453 IP (tos 0x0, ttl 64, id 27669, offset 0, flags [DF], proto TCP (6), length 1492)
    192.168.1.59.55170 > 192.168.1.18.commplex-link: Flags [.], seq 1465:2905, ack 1, win 229, options [nop,nop,TS val 62231754 ecr 1387514367], length 1440
21:39:38.537461 IP (tos 0x0, ttl 64, id 27670, offset 0, flags [DF], proto TCP (6), length 1492)
    192.168.1.59.55170 > 192.168.1.18.commplex-link: Flags [.], seq 2905:4345, ack 1, win 229, options [nop,nop,TS val 62231754 ecr 1387514367], length 1440
21:39:38.537464 IP (tos 0x0, ttl 64, id 9968, offset 0, flags [DF], proto TCP (6), length 52)
    192.168.1.18.commplex-link > 192.168.1.59.55170: Flags [.], cksum 0x83c4 (incorrect -> 0xa338), ack 1465, win 249, options [nop,nop,TS val 1387514368 ecr 62231754], length 0
21:39:38.537465 IP (tos 0x0, ttl 64, id 27671, offset 0, flags [DF], proto TCP (6), length 1492)
    192.168.1.59.55170 > 192.168.1.18.commplex-link: Flags [.], seq 4345:5785, ack 1, win 229, options [nop,nop,TS val 62231754 ecr 1387514367], length 1440
21:39:38.537469 IP (tos 0x0, ttl 64, id 27672, offset 0, flags [DF], proto TCP (6), length 1492)
    192.168.1.59.55170 > 192.168.1.18.commplex-link: Flags [.], seq 5785:7225, ack 1, win 229, options [nop,nop,TS val 62231754 ecr 1387514367], length 1440

which is all correct.  Now, these packets have a larger TCP header
due to the options:

        0x0000:  0022 6815 37dd 0050 4321 0201 0800 4500  ."h.7..PC!....E.
                 ^mac                               ^iphdr
        0x0010:  05d4 6c14 4000 4006 4572 c0a8 013b c0a8  ..l.@.@.Er...;..
        0x0020:  0112 d782 1389 4cb4 f8f4 7454 ef10 8010  ......L...tT....
                      ^tcphdr
        0x0030:  00e5 2a80 0000 0101 080a 03b5 94ca 52b3  ..*...........R.
                                ^tcpopts
        0x0040:  c9ff 0000 0000 0000 0001 0000 1389 0000  ................
                      ^start of data
        0x0050:  0000 0000 0000 ffff fc18 3435 3637 3839  ..........456789
        0x0060:  3031 3233 3435 3637 3839 3031 3233 3435  0123456789012345

So the data starts at 66 (0x42) into this packet, followed by 1440 bytes
of data.  Looking at drivers/net/ethernet/marvell/mvneta.c, the only
way this can happen is if skb_shinfo(skb)->gso_size is 1440.  I'll
instrument mvneta to dump this value...

While waiting for the kernel to build, I've been reading the TCP code,
and found this:

/* Compute the current effective MSS, taking SACKs and IP options,
 * and even PMTU discovery events into account.
 */
unsigned int tcp_current_mss(struct sock *sk)
...
        /* The mss_cache is sized based on tp->tcp_header_len, which assumes
         * some common options. If this is an odd packet (because we have SACK
         * blocks etc) then our calculated header_len will be different, and
         * we have to adjust mss_now correspondingly */

mss_now is what becomes gso_size, which means that gso_size will be
adjusted for the TCP options - which makes sense.  So, because there
are 12 bytes of options in the above hex packet dump, negotiated MSS
- 12 gives the data payload size of 1440, and so gso_size will be
1440.

And now, going back to that kernel that finished compiling...

[   53.468319] skb len=7266 hdr len=66 gso_size=1440
...
[   53.728752] skb len=64866 hdr len=66 gso_size=1440

so my guesses were right, at least for 4.9-rc4.  Whether that holds
for the fedora f23 4.4 kernel is another matter.  For the record,
removing the TCPMSS clamp gives the expected result:

[  231.244018] skb len=7306 hdr len=66 gso_size=1448

So, gso_size is the size of the TCP data after the TCP header plus
TCP options.

The other thing to notice is that the SKB length minus header
length is divisible by the gso size for these full-sized packets.
There is no "one packet larger next packet smaller" here.

> It's also *fairly* unlikely that the kernel in the guest has developed
> a bug and isn't setting gso_size sanely. I'm more inclined to suspect
> that qemu isn't properly emulating those bits. But at first glance at
> the code, it looks like *that's* been there for the last decade too...

Whether or not it's been there for a decade is kind of irrelevant -
bugs can be around for a decade and remain undiscovered.

Looking at the 8139C information, it says:

"The new buffer management algorithm provides capabilities of Microsoft
Large-Send offload" and as yet I haven't found anything that describes
what this is or how it works.  How certain are we that the LSO MSS
value is the same as our gso_size, iow the size of the data after
the TCP header and options?

-- 
RMK's Patch system: http://www.armlinux.org.uk/developer/patches/
FTTC broadband for 0.8mile line: currently at 9.6Mbps down 400kbps up
according to speedtest.net.
