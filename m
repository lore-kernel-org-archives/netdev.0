From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: Re: TG3 network data corruption regression 2.6.24/2.6.23.4
Date: Tue, 19 Feb 2008 17:38:24 -0800
Message-ID: <20080220013824.GA5416@localdomain>
References: <47BA0984.2070306@cybernetics.com>
 <1203381120.13495.78.camel@dell>
 <20080218.163554.74130592.davem@davemloft.net>
 <1203383046.13495.87.camel@dell> <47BB00EC.3010607@cybernetics.com>
 <1203448265.13495.95.camel@dell> <47BB54C2.6090501@cybernetics.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: "Michael Chan" <mchan@broadcom.com>,
	"David Miller" <davem@davemloft.net>, herbert@gondor.apana.org.au,
	netdev <netdev@vger.kernel.org>, gregkh@suse.de,
	linux-kernel@vger.kernel.org
To: "Tony Battersby" <tonyb@cybernetics.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1762625AbYBTBmW@vger.kernel.org>
In-Reply-To: <47BB54C2.6090501@cybernetics.com>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Feb 19, 2008 at 05:14:26PM -0500, Tony Battersby wrote:
> Michael Chan wrote:
> > On Tue, 2008-02-19 at 11:16 -0500, Tony Battersby wrote:
> >   
> >> iSCSI
> >> performance drops to 6 - 15 MB/s when the 3Com NIC is doing heavy rx
> >> with light tx,
> >>     
> >
> > That's strange.  The patch should only affect TX performance slightly
> > since we are just turning off SG for TX.  Please take an ethereal trace
> > to see what's happening and compare with a good trace.
> >
> >   
> 
> Update: when I revert Herbert's patch in addition to applying your
> patch, the iSCSI performance goes back up to 115 MB/s again in both
> directions.  So it looks like turning off SG for TX didn't itself cause
> the performance drop, but rather that the performance drop is just
> another manifestation of whatever bug is causing the data corruption.
> 
> I do not regularly use wireshark or look at network packet dumps, so I
> am not really sure what to look for.  Given the above information, do
> you still believe that there is value in examining the packet dump?
> 
> Tony

Hi Tony.  Can you give us the output of :

sudo lspci -vvv -xxxx -s 03:01.0'

(assuming that is still the correct address of the 3Com NIC.)

Also, after some digging, I found that the 5701 can run into trouble if
a 64-bit DMA read terminates early and then completes as a 32-bit transfer.
The problem is reportedly very rare, but the failure mode looks like a
match.  Can you apply the following patch and see if it helps your
performance / corruption problems?


diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index db606b6..7ad08ce 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -11409,6 +11409,8 @@ static int __devinit tg3_get_invariants(struct tg3 *tp)
 		tp->tg3_flags |= TG3_FLAG_PCI_HIGH_SPEED;
 	if ((pci_state_reg & PCISTATE_BUS_32BIT) != 0)
 		tp->tg3_flags |= TG3_FLAG_PCI_32BIT;
+	else if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5701)
+		tp->grc_mode |= GRC_MODE_FORCE_PCI32BIT;
 
 	/* Chip-specific fixup from Broadcom driver */
 	if ((tp->pci_chip_rev_id == CHIPREV_ID_5704_A0) &&
