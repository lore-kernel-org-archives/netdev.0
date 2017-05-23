From: Niklas Cassel <niklas.cassel@axis.com>
Subject: stmmac tx timeout
Date: Tue, 23 May 2017 14:06:34 +0200
Message-ID: <fc8e5141-5815-9a6d-51ed-ddd7e5c2bbc8@axis.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Alexandre Torgue <alexandre.torgue@st.com>,
        Giuseppe Cavallaro <peppe.cavallaro@st.com>,
        Joao Pinto <Joao.Pinto@synopsys.com>,
        Pavel Machek <pavel@ucw.cz>, Lars Persson <larper@axis.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bastet.se.axis.com ([195.60.68.11]:44606 "EHLO
        bastet.se.axis.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1763827AbdEWMGi (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 23 May 2017 08:06:38 -0400
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello


I'm debugging a transmit queue 0 timeout on stmmac with DWMAC4 (4.10a).
I'm using kernel v4.9.23, which is before multi queue support was added.
I've cherry-picked
98a29944774a ("net: ethernet: stmmac: remove private tx queue lock")
84c53b4baef8 ("stmmac: fix memory barriers")
but I still get tx timeouts with these patches.

I've managed to reproduce the problem several times,
mainly by transmitting the syslog over HTTP.

The stmmac driver does not reset the IP in its .ndo_tx_timeout function,
so when the timeout occurs, the device does not recover.

I've added some code in the .ndo_tx_timeout function, before the
driver tries to restart the transmission (which fails anyway),
that dumps all registers and the triggers a kernel crashdump.


Here is some of the registers:

GMAC4 DMA registers
       DMA_BUS_MODE, offset: 0x1000, val: 0x0
       DMA_SYS_BUS_MODE, offset: 0x1004, val: 0x10f1008
       DMA_STATUS, offset: 0x1008, val: 0x0
       DMA_DEBUG_STATUS_0, offset: 0x100c, val: 0x7701
       DMA_DEBUG_STATUS_1, offset: 0x1010, val: 0x0
       DMA_DEBUG_STATUS_2, offset: 0x1014, val: 0x0
Channel 0
       DMA_CHAN_CONTROL, offset: 0x0, val: 0x0
       DMA_CHAN_TX_CONTROL, offset: 0x4, val: 0x41001
       DMA_CHAN_RX_CONTROL, offset: 0x8, val: 0x100001
       DMA_CHAN_TX_BASE_ADDR, offset: 0x14, val: 0x9005e000
       DMA_CHAN_RX_BASE_ADDR, offset: 0x1c, val: 0x9005c000
       DMA_CHAN_TX_END_ADDR, offset: 0x20, val: 0x90060000
       DMA_CHAN_RX_END_ADDR, offset: 0x28, val: 0x9005e000
       DMA_CHAN_TX_RING_LEN, offset: 0x2c, val: 0x1ff
       DMA_CHAN_RX_RING_LEN, offset: 0x30, val: 0x1ff
       DMA_CHAN_INTR_ENA, offset: 0x34, val: 0xd041
       DMA_CHAN_RX_WATCHDOG, offset: 0x38, val: 0xff
       DMA_CHAN_SLOT_CTRL_STATUS, offset: 0x3c, val: 0x0
       DMA_CHAN_CUR_TX_DESC, offset: 0x44, val: 0x9005e610
       DMA_CHAN_CUR_RX_DESC, offset: 0x4c, val: 0x9005de50
       DMA_CHAN_CUR_TX_BUF_ADDR, offset: 0x54, val: 0x8d723fff
       DMA_CHAN_CUR_RX_BUF_ADDR, offset: 0x5c, val: 0x8eb02942
       DMA_CHAN_STATUS, offset: 0x60, val: 0x0


DMA_DEBUG_STATUS_0 gives us:
DMA Channel 0 Transmit Process State:
3'b111: Running (Closing Tx Descriptor)

DMA Channel 0 Receive Process State:
3'b111: Running (Transferring the received packet
data from the Rx buffer to the system memory)

In some of the hangs, DMA_DEBUG_STATUS_0 has been 0x3300


In all of the hangs the current application transmit
buffer address register (DMA_CHAN_CUR_TX_BUF_ADDR)
has been on an unaligned address.

Examples from three different crash dumps:
       DMA_CHAN_CUR_TX_BUF_ADDR, offset: 0x54, val: 0x8d723fff
       DMA_CHAN_CUR_TX_BUF_ADDR, offset: 0x54, val: 0x8732bfff
       DMA_CHAN_CUR_TX_BUF_ADDR, offset: 0x54, val: 0x8ffc3fff


By inspecting struct stmmac_priv in the
crashdump, we can see that
cur_tx = 78 => 78*16+0x9005e000=0x9005e4e0
which is the address of the descriptor that
will be used next by stmmac_xmit().
When the IP starts processing descriptors,
it will eventually read this descriptor.

dirty_tx = 97 => 97*16+0x9005e000=0x9005e610
which is the address where stmmac_tx_clean()
will start checking for completed descriptors,
the next time the function gets called.

That means that descriptors from
0x9005e4e0 to 0x9005e610 have recently been
cleaned by stmmac_tx_clean().

Excerpt from DMA desc ring:
each descriptor is 16 bytes, so each row is
a new descriptor.

           TDES0    TDES1    TDES2    TDES3
9005e460:  b541e210 875a1910 0000008a b000008a
9005e470:  b738c410 875a6110 0000008a b000008a
9005e480:  bc255202 871e7110 0000002a b000002a
9005e490:  bc255302 871e1910 0000002a b000002a
9005e4a0:  bc255002 875a6110 0000002a b000002a
9005e4b0:  b738d010 871e4110 0000008a b000008a
9005e4c0:  b541e610 875a2110 0000008a b000008a
9005e4d0:  b738c210 871e3910 0000008a b000008a
9005e4e0:  8b74ee66 85f5d110 00000000 00000000
9005e4f0:  bc0f3cce 871e1910 00000000 00000000
9005e500:  8b74f7ef 875a3910 00000000 00000000
9005e510:  81940000 875a5110 00000000 00000000
9005e520:  81943fff 871e1910 00000000 00000000
9005e530:  bc0f32ce 871e4910 00000000 00000000
9005e540:  81944177 875a3110 00000000 00000000
9005e550:  bc0f38ce 871e4110 00000000 00000000
9005e560:  8194471f 871e4910 00000000 00000000
9005e570:  84508000 875a4910 00000000 00000000
9005e580:  bc0f3ece 871e2910 00000000 00000000
9005e590:  8450964f 875a6110 00000000 00000000
9005e5a0:  8450d64e 871e6910 00000000 00000000
9005e5b0:  bc0f32ce 875a7110 00000000 00000000
9005e5c0:  8450e57f 875a0910 00000000 00000000
9005e5d0:  bc0f3cce 875a4910 00000000 00000000
9005e5e0:  8450eb27 875a4110 00000000 00000000
9005e5f0:  8d720000 871e0110 00000000 00000000
9005e600:  bc0f38ce 875a0910 00000000 00000000
9005e610:  8d723fff 875a2110 000005a8 900305ea
9005e620:  bc0f22ce 875a6110 00000042 a0444f30
9005e630:  8d7245a7 85f5c110 00003a59 80000000
9005e640:  8c6a8000 871e7910 000014d7 90000000
9005e650:  bc0f32ce 875a7910 00000042 a00305ea
9005e660:  8c6a94d7 85f59110 000005a8 900305ea
9005e670:  bc0f3cce 875a6110 00000042 a00305ea
9005e680:  8450eb27 85f5f910 000005a8 900305ea
9005e690:  bc1e0610 871e5110 0000009f b000009f
9005e6a0:  bb112802 875a3910 000001d9 b00301d9
9005e6b0:  bb112002 875a4910 000001df b00301df
9005e6c0:  bb113402 875a7110 00000201 b0030201
9005e6d0:  bb110402 85f58110 00000201 b0030201

Looking at the DMA_CHAN_CUR_TX_DESC (0x9005e610)
TDES0 and TDES1 can contain tx buffers.

TDES2 tells us that the length of TDES1 is zero,
so let's ignore the address in TDES1.
(It would be clearer if we actually did set TDES1
to zero when TDES1's size is set to zero.)

TDES2 tells us that length of TDES0 is 1448.

TDES3 tells us that we have the DMA own bit set.
Last descriptor is set, but not first descriptor,
and that the total packet length is 1514.

TDES0 matches DMA_CHAN_CUR_TX_BUF_ADDR.
The buffer is on an unaligned address.
Reading the buffer in TDES0 shows text
that appears to be from the syslog,
so it appears to be a valid buffer.

Looking at the previous descriptor (9005e600),
and reading contents from its TDES0,
it's an ethernet hdr + ip hdr + tcp hdr,
total size 14 + 20 + 32 = 66,
1448+66=1514, so this matches the size
we previously saw is TDES3.

Note that TDES* has different formats depending
on if it's before the IP has handled the packet
or not. I was thinking that TDES0 and TDES1
might be timestamps, but I have not enabled
PTP, and the Transmit Timestamp Enable bit
is not set in any descriptor.


By debugging, I could see that we can get
unaligned buffers when we have fragments
(skb_shinfo(skb)->nr_frags > 0), so having
unaligned tx buffers in itself in not that
unusual.


In struct stmmac_priv we also have
stmmac_priv->tx_skbuff_dma
which contains all txbuf addresses, i.e.
dma_map_single(.., skb->data, ..) or
skb_frag_dma_map(.., frag, ..)
which we will put in the descriptors'
TDES0 (or TDES1).

tx_skbuff_dma contains elements of stmmac_tx_info,
which each are 16 bytes, so each row corresponds
to a descriptor.

struct stmmac_tx_info {
        dma_addr_t buf;
	bool map_as_page;
        unsigned len;
        bool last_segment;
	bool is_jumbo;
};

Here we see our txbuff, 8d723fff (as we know,
we are last descriptor, and the desc before
us is first descriptor)

be282600:  00000000 040a4100 00000000 4d2d0000
be282610:  8d723fff 9c316501 000005a8 54520001



Then in struct stmmac_priv we also have
stmmac_priv->tx_skbuff
which contains a list of pointers to skbs.
Each 32 bits corresponds to a descriptor.
For descs that are fragments, stmmac sets
the value to NULL, so only the descs which
has first descriptor set will have a skb
pointer.

bd42e940:  00000000 00000000 00000000 00000000
bd42e950:  00000000 00000000 00000000 00000000
bd42e960:  00000000 00000000 00000000 00000000
bd42e970:  00000000 00000000 00000000 00000000
bd42e980:  00000000 00000000 bb2c8530 00000000
bd42e990:  00000000 bb2c8fb0 00000000 bb2c80b0
bd42e9a0:  00000000 b7ecfa80 be241600 be241000
bd42e9b0:  be241cc0 be241540 be241240 be2413c0
bd42e9c0:  be241b40 be241480 b53e8c00 bb005b40

We can see that the cell which has bb2c8530 is
first desc, followed by a desc which is neither
first or last, followed by a desc that is last.
Then we have bb2c8fb0 which is first, followed by
a last.

Calculating the address where our desc should be:
The index that corresponds to a certain desc is
always the same, and from the dma ring we know
that desc 9005e610 has index 97, so
(stmmac_priv->tx_skbuff)+4*97=
0xbd42e800+4*97=0xbd42e984

Looking at address 0xbd42e984 in the output above,
we can see that is it zero, which is correct,
since we are not first desc, however the one
before us should be a first desc, but is zero.

This means that stmmac_tx_clean() has
done dev_consume_skb_any() (which calls kfree_skb)
and has set it to NULL, before the IP has sent
out our fragment which is part of the same skb.
I'm not sure that this is related to the hangs
that I'm debugging, but is this really allowed?


I've also tried adding attribute ____cacheline_aligned
to struct dma_desc in stmmac/descs.h, together
with setting a matching Descriptor Skip Length
in the IP, but I still get tx timeouts.


I've also noted that
84c53b4baef8 ("stmmac: fix memory barriers")
replaced some wmb()'s with dma_wmb()'s.
On arm, wmb() calls arm_heavy_mb(), which also
flushes L2. A dma_wmb() doesn't flush L2.
I'm not sure if this is of any importance,
since I've seen tx timeouts even before
cherry-picking this commit to v4.9.23.


Regards,
Niklas
