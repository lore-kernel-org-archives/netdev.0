From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: sky2 problem on powerpc
Date: Mon, 04 Sep 2006 15:24:22 +1000
Message-ID: <1157347462.22705.16.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:36770 "EHLO gate.crashing.org")
	by vger.kernel.org with ESMTP id S932294AbWIDFYc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Sep 2006 01:24:32 -0400
To: Stephen Hemminger <shemminger@osdl.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Stephen !

To try to validate some PCIe code we have around, I got myself a
SysKonnect SK-9Exx card (one x1 lane one port and one x4 lanes 2 ports
actually, though I've only tested the first one at this point, based on
a 88E8061 Marvell chip).

I've used the sky2 driver as of a random last week's git snapshot. I'll
double check tomorrow if there have been any update.

So far, I had no success on a couple of different machines, and I was
wondering if you had an idea of what's wrong. Here's what I've seen far:

 - Card is probed fine

sky2 v1.5 addr 0xa0000000 irq 63 Yukon-XL (0xb3) rev 1
sky2 eth2: addr 00:00:5a:72:4c:2a

 - As soon as I ifconfig it up, I get a steady stream of

sky2 eth2: receive descriptor error (hardware problem)
sky2 eth2: Link is down.

mesages in my kernel log, which makes me think that it's unhappy about
the format of the descriptors or something like that (endian issue ? see
below my notes about that). I'm also wondering why it seems to be
flooding me which makes me think the error condition is never cleared on
the chip.

Some of the things I've noticed and tweaked in the driver, without luck
so far:

 - There is that bit when initializing the chip:

#ifdef __BIG_ENDIAN
        /* byte swap descriptors in hardware */
        {
                u32 reg;

  .../...

However, if you look at some of the routines filling up descriptors,
they still do swap the values put into some of the fields like lenght,
address. (Except an incosistency with rx_set_checksum which doesn't swap
whatever it writes to le->addr, though I've tried fixing that without
much success).

Thus I don't quite understand what the above is supposed to do. I've
tried disabling it but it didn't fix the problem. However, that leads me
to wondering wether there might be a deeper problem with descriptor
swapping. What kind of access size and what kind of swapping the chip is
supposedly doing ? 32 bits accesses ? 64 bits accesses ?

Because if you look at the definition for:

struct sky2_rx_le {
	__le32	addr;
	__le16	length;
	u8	ctrl;
	u8	opcode;
} __attribute((packed));

(As an example)

If the chips does LE accesses, then marking "lenght" as being an LE
value isn't enough. It also needs to be swapped with ctrl and opcode.
The layout then becomes:

struct sky2_rx_le {
	__le32	addr;
	u8	opcode;
	u8	ctrl;
	__le16	length;
} __attribute((packed));

Unless the chip does 2x16 bits accesses here but I very much doubt it.
Now, it's possible that this bit about "byteswapping descriptor" is
about doing that address munging, but would it do it without also
byteswapping the content of the individual fields ? That looks
unlikely... Thus I wonder wether we should either keep this HW byteswap
option _and_ remove all the byteswapping of fields when accessing addr
and lenght, or leave the byteswapping in, remove the HW byteswap option
_and_ fixup the structure definitions of the descriptor in the big
endian case ....

I haven't had time to try all those options yet, and I don't have access
to any documentation for that chip, but I wondered if, in the meantime,
you had any other idea about what may be going wrong or see any flaw in
my reasoning above.

Cheers,
Ben.



-- 
VGER BF report: U 0.505334
