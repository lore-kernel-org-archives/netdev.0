From: "David S. Miller" <davem@redhat.com>
Subject: Re: tg3 DMA RW Control register settings
Date: Mon, 30 Aug 2004 14:29:42 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040830142942.55c399bb.davem@redhat.com>
References: <20040830092211.GB5745@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, johnip@sgi.com, akepner@sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Greg Banks <gnb@sgi.com>
In-Reply-To: <20040830092211.GB5745@sgi.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 30 Aug 2004 19:22:11 +1000
Greg Banks <gnb@sgi.com> wrote:

> 1.  Are the values for the Write Boundary field in the PCI-E case
>     correct?  The diff adds
> 
> #define  DMA_RWCTRL_WRITE_BNDRY_64_PCIE	 0x10000000
> #define  DMA_RWCTRL_WRITE_BNDRY_128_PCIE 0x30000000
> #define  DMA_RWCTRL_WRITE_BNDRY_DISAB_PCIE 0x70000000
> 
>     but these seem to set the Default PCI Write field instead.
>     It seems to me (based on version PG101-R of the manual) that
>     the right values would be
> 
> #define  DMA_RWCTRL_WRITE_BNDRY_64_PCIE	   0x00000000
> #define  DMA_RWCTRL_WRITE_BNDRY_128_PCIE   0x00000800
> #define  DMA_RWCTRL_WRITE_BNDRY_DISAB_PCIE 0x00001800

What I've done is exactly the same as the bcn5700 code, which reads
for these bits:

    T3_32BIT_REGISTER DmaReadWriteCtrl;
    #define DMA_CTRL_WRITE_CMD                      0x70000000
    #define DMA_CTRL_WRITE_BOUNDARY_64_PCIE         0x10000000
    #define DMA_CTRL_WRITE_BOUNDARY_128_PCIE        0x30000000
    #define DMA_CTRL_WRITE_BOUNDARY_DISABLE_PCIE    0x70000000
    #define DMA_CTRL_READ_CMD                       0x06000000

    #define DMA_CTRL_WRITE_BOUNDARY_MASK            (BIT_11 | BIT_12 | BIT_13)
    #define DMA_CTRL_WRITE_BOUNDARY_DISABLE         0
    #define DMA_CTRL_WRITE_BOUNDARY_16              BIT_11
    #define DMA_CTRL_WRITE_BOUNDARY_128_PCIX        BIT_11
    #define DMA_CTRL_WRITE_BOUNDARY_32              BIT_12
    #define DMA_CTRL_WRITE_BOUNDARY_256_PCIX        BIT_12
    #define DMA_CTRL_WRITE_BOUNDARY_64              (BIT_12 | BIT_11)
    #define DMA_CTRL_WRITE_BOUNDARY_384_PCIX        (BIT_12 | BIT_11)
    #define DMA_CTRL_WRITE_BOUNDARY_128             BIT_13
    #define DMA_CTRL_WRITE_BOUNDARY_256             (BIT_13 | BIT_11)
    #define DMA_CTRL_WRITE_BOUNDARY_512             (BIT_13 | BIT_12)
    #define DMA_CTRL_WRITE_BOUNDARY_1024            (BIT_13 | BIT_12 | BIT_11)
    #define DMA_CTRL_WRITE_ONE_DMA_AT_ONCE          BIT_14

    #define DMA_CTRL_READ_BOUNDARY_MASK             (BIT_10 | BIT_9 | BIT_8)
    #define DMA_CTRL_READ_BOUNDARY_DISABLE          0
    #define DMA_CTRL_READ_BOUNDARY_16               BIT_8
    #define DMA_CTRL_READ_BOUNDARY_128_PCIX         BIT_8
    #define DMA_CTRL_READ_BOUNDARY_32               BIT_9
    #define DMA_CTRL_READ_BOUNDARY_256_PCIX         BIT_9
    #define DMA_CTRL_READ_BOUNDARY_64               (BIT_9 | BIT_8)
    #define DMA_CTRL_READ_BOUNDARY_384_PCIX         (BIT_9 | BIT_8)
    #define DMA_CTRL_READ_BOUNDARY_128              BIT_10
    #define DMA_CTRL_READ_BOUNDARY_256              (BIT_10 | BIT_8)
    #define DMA_CTRL_READ_BOUNDARY_512              (BIT_10 | BIT_9)
    #define DMA_CTRL_READ_BOUNDARY_1024             (BIT_10 | BIT_9 | BIT_8)


> 2.  The Write Boundary field has a whole bunch of code to set it
>     up.  The Read Boundary field is never set and defaults to 0
>     (=disabled for PCI and PCI-X). Is this deliberate?

Yes, I copied the logic from the bcm5700 driver.
They don't muck with that setting either, even on non-x86.

I'd like to tweak the settings a bit for non-x86 systems,
but I currently don't have the time.  There are bigger
fires to put out in this driver.

> 3.  The new code seems to use a lot of 32bit magic numbers, for
>     which #defines already exist in the header.  Ummm....?

Feel free to submit a patch :)

> 4.  Is there any explanation of how the following were chosen
>     (assuming cache size of 128 bytes) ?
> 
>     DMA Write Watermark:        0b11 => 384 bytes
>     DMA Read Watermark:         0b111 => 1536 bytes
>     DMA Write Address Boundary: 0b11 => 384 bytes
>     DMA Read Address Boundary:  0b00 => disabled
>     One DMA at Once:            0b01

I don't know, ask Broadcom, they have all the internal test
suites they use to tweak these things.  I just copied these
values over since I don't have logic analyzers et al. to
work on such things.

ONE_DMA_AT_ONCE is a hw bug workaround btw, not for performance.
If your chips are getting that set, it would explain somewhat
the performance problems.

WRT 5704 you may be interested in the following hw bug fix which
I have yet to push from my tree.  It's going to make performance
worse though, not better, if anything, sorry :)

Also Fibre handling on many 5704 veriants is busted.  We're
trying to get hw fibre autonegotiation working, but making
that work across all 5704 fibre variants is proving intreresting.
We want this because, otherwise the 5704 chip uses a different
code path where it inspects every incoming packet to see if
it is an fibre negotiation packet.  This can lead to framing
errors (1 in 30,000 packets, something like that) under high
load.

# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2004/08/18 19:37:24-07:00 davem@nuts.davemloft.net 
#   [TG3]: Disable CIOBE split, as per Broadcom's driver.
#   
#   Signed-off-by: David S. Miller <davem@redhat.com>
# 
# drivers/net/tg3.c
#   2004/08/18 19:36:35-07:00 davem@nuts.davemloft.net +3 -1
#   [TG3]: Disable CIOBE split, as per Broadcom's driver.
#   
#   Signed-off-by: David S. Miller <davem@redhat.com>
# 
diff -Nru a/drivers/net/tg3.c b/drivers/net/tg3.c
--- a/drivers/net/tg3.c	2004-08-30 14:10:58 -07:00
+++ b/drivers/net/tg3.c	2004-08-30 14:10:58 -07:00
@@ -7620,12 +7620,14 @@
 	grc_misc_cfg = tr32(GRC_MISC_CFG);
 	grc_misc_cfg &= GRC_MISC_CFG_BOARD_ID_MASK;
 
+	/* Broadcom's driver says that CIOBE multisplit has a bug */
+#if 0
 	if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5704 &&
 	    grc_misc_cfg == GRC_MISC_CFG_BOARD_ID_5704CIOBE) {
 		tp->tg3_flags |= TG3_FLAG_SPLIT_MODE;
 		tp->split_mode_max_reqs = SPLIT_MODE_5704_MAX_REQ;
 	}
-
+#endif
 	if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5705 &&
 	    (grc_misc_cfg == GRC_MISC_CFG_BOARD_ID_5788 ||
 	     grc_misc_cfg == GRC_MISC_CFG_BOARD_ID_5788M))
