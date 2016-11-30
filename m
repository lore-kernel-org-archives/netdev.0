From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: macb: Write only necessary bits in NCR in macb
 reset
Date: Tue, 29 Nov 2016 19:05:26 -0500 (EST)
Message-ID: <20161129.190526.1414678491662084583.davem@davemloft.net>
References: <1480325029-39224-1-git-send-email-harinik@xilinx.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nicolas.ferre@atmel.com, harinikatakamlinux@gmail.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        harinik@xilinx.com, michals@xilinx.com
To: harini.katakam@xilinx.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1480325029-39224-1-git-send-email-harinik@xilinx.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Harini Katakam <harini.katakam@xilinx.com>
Date: Mon, 28 Nov 2016 14:53:49 +0530

> In macb_reset_hw, use read-modify-write to disable RX and TX.
> This way exiting settings and reserved bits wont be disturbed.
> Use the same method for clearing statistics as well.
> 
> Signed-off-by: Harini Katakam <harinik@xilinx.com>

This doesn't make much sense to me.

Consider the two callers of this function.

macb_init_hw() is going to do a non-masking write to the NCR
register:

	/* Enable TX and RX */
	macb_writel(bp, NCR, MACB_BIT(RE) | MACB_BIT(TE) | MACB_BIT(MPE));

So obviously no other writable fields matter at all for programming
the chip properly, otherwise macb_init_hw() would "or" in the bits
after a read of NCR.  But that's not what this code does, it
writes "RE | TE | MPE" directly.

And the other caller is macb_close() which is shutting down the
chip so can zero out all the other bits and it can't possibly
matter, also due to the assertion above about macb_init_hw()
showing that only the RE, TE, and MPE bits matter for proper
functioning of the chip.

You haven't shown a issue caused by the way the code works now, so
this patch isn't fixing a bug.  In fact, the "bit preserving" would
even be misleading to someone reading the code.  They will ask
themselves what bits need to be preserved, and as shown above none of
them need to be.

I'm not applying this, sorry.
