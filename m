From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: brcm80211 breakage..
Date: Tue, 31 Jan 2012 14:25:21 -0500
Message-ID: <20120131192520.GA2974@tuxdriver.com>
References: <CA+55aFx2UnVZP1Z44dMHeifB2nD1zJ87kz25zZjUdwv0ozwKPA@mail.gmail.com>
 <20120131120846.GA8799@polaris.bitmath.org>
 <CA+55aFy5-x6Zevga=rX_q+6vsmXFHyMJ+m8YqrqjC6yELqS6mw@mail.gmail.com>
 <4F283C16.5090508@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	Henrik Rydberg <rydberg@euromail.se>,
	"Franky (Zhenhui) Lin" <frankyl@broadcom.com>,
	"John W. Linville" <linville@redhat.com>,
	Network Development <netdev@vger.kernel.org>,
	=?utf-8?B?UmFmYcWCIE1pxYJlY2tp?= <zajec5@gmail.com>
To: Arend van Spriel <arend@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:46815 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753626Ab2AaTb2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 Jan 2012 14:31:28 -0500
Content-Disposition: inline
In-Reply-To: <4F283C16.5090508@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 31, 2012 at 08:08:06PM +0100, Arend van Spriel wrote:
> On 01/31/2012 06:02 PM, Linus Torvalds wrote:
> > On Tue, Jan 31, 2012 at 4:08 AM, Henrik Rydberg <rydberg@euromail.se> wrote:
> >>
> >> probing simply fails on my machine,
> >>
> >> [  882.064120] bcma: Failed to get SPROM: -71
> >> [  882.064256] bcma-pci-bridge: probe of 0000:01:00.0 failed with error -2
> >>
> >> resulting in no wireless. Since the bcma SPROM setup allegedly is
> >> unused, simply ignoring the error with this hack
> > 
> > I personally hit the "No SPROM available" case, which is apparently
> > why it works for me.
> > 
> > That said, I obviously agree with your patch: if we don't fail for the
> > "No SPROM available" case, then we damn well shouldn't fail just
> > because it *is* available but we can't read it or whatever.
> > 
> > So Ack on the patch from me, but it should go through the network
> > guys. Arend, John?
> > 
> 
> The SPROM code in bcma needs some attention, because the availability of
> it depends between chipsets. I think in bcma not all variations are
> known and thus lacking implementation to handle those. So ultimately
> bcma sprom code needs to be extended (looking at brcmsmac code). The
> sprom code in brcmsmac can go when that has happened.
> 
> I will dive into that. I have not hit the "Failed to get SPROM" case so
> any chipset info would be appreciated (Henrik?).

Making the SPROM code be better informed sounds great.  In the
meantime, Henrik's patch seems reasonable.  Any objections?

---

>From 1f3587dd7cdb8e2a505c76041bd5b816e7bcfb67 Mon Sep 17 00:00:00 2001
From: Henrik Rydberg <rydberg@euromail.se>
Date: Tue, 31 Jan 2012 14:22:15 -0500
Subject: [PATCH] bcma: don't fail for bad SPROM CRC

If it is OK not to have an SPROM, it should be OK to have a bad one...?

Signed-off-by: John W. Linville <linville@tuxdriver.com>
---
Henrik, may I add a Signed-off-by line for you?

 drivers/bcma/main.c |    4 +---
 1 files changed, 1 insertions(+), 3 deletions(-)

diff --git a/drivers/bcma/main.c b/drivers/bcma/main.c
index febbc0a..ec31f7d 100644
--- a/drivers/bcma/main.c
+++ b/drivers/bcma/main.c
@@ -169,10 +169,8 @@ int bcma_bus_register(struct bcma_bus *bus)
 	err = bcma_sprom_get(bus);
 	if (err == -ENOENT) {
 		pr_err("No SPROM available\n");
-	} else if (err) {
+	} else if (err)
 		pr_err("Failed to get SPROM: %d\n", err);
-		return -ENOENT;
-	}
 
 	/* Register found cores */
 	bcma_register_cores(bus);
-- 
1.7.4.4

-- 
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.
