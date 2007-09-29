From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [patch 02/18] sundance: PHY address form 0, only for device ID
 0x0200 (IP100A) (20070605)
Date: Sat, 29 Sep 2007 01:11:01 -0400
Message-ID: <46FDDE65.5000709@garzik.org>
References: <200708102105.l7AL57OJ008948@imap1.linux-foundation.org>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------070902030007090503070707"
Cc: netdev@vger.kernel.org, jesse@icplus.com.tw
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:57898 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751965AbXI2FLI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 29 Sep 2007 01:11:08 -0400
In-Reply-To: <200708102105.l7AL57OJ008948@imap1.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------070902030007090503070707
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

akpm@linux-foundation.org wrote:
> From: Jesse Huang <jesse@icplus.com.tw>
> 
> Search PHY address form 0, only for device ID 0x0200 (IP100A).  Other
> device are from PHY address 1.
> 
> Signed-off-by: Jesse Huang <jesse@icplus.com.tw>
> Cc: Jeff Garzik <jeff@garzik.org>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> ---
> 
>  drivers/net/sundance.c |    6 +++++-
>  1 files changed, 5 insertions(+), 1 deletion(-)
> 
> diff -puN drivers/net/sundance.c~sundance-phy-address-form-0-only-for-device-id-0x0200 drivers/net/sundance.c
> --- a/drivers/net/sundance.c~sundance-phy-address-form-0-only-for-device-id-0x0200
> +++ a/drivers/net/sundance.c
> @@ -559,7 +559,11 @@ static int __devinit sundance_probe1 (st
>  	 * It seems some phys doesn't deal well with address 0 being accessed
>  	 * first, so leave address zero to the end of the loop (32 & 31).
>  	 */
> -	for (phy = 1; phy <= 32 && phy_idx < MII_CNT; phy++) {
> +	if (sundance_pci_tbl[np->chip_id].device == 0x0200)
> +		phy = 0;
> +	else
> +		phy = 1;
> +	for (; phy <= 32 && phy_idx < MII_CNT; phy++) {
>  		int phyx = phy & 0x1f;
>  		int mii_status = mdio_read(dev, phyx, MII_BMSR);
>  		if (mii_status != 0xffff  &&  mii_status != 0x0000) {

applied the attached patch.



--------------070902030007090503070707
Content-Type: text/plain;
 name="patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="patch"

commit 0dc9d326e42aebd895cb989bd904cc82fd1b6b22
Author: Jeff Garzik <jeff@garzik.org>
Date:   Sat Sep 29 01:10:14 2007 -0400

    [netdrvr] sundance: fix phy scanning on IP100A
    
    Based on a based from Jesse Huang <jesse@icplus.com.tw>.
    
    Signed-off-by: Jeff Garzik <jeff@garzik.org>

 drivers/net/sundance.c |   14 +++++++++++---
 1 file changed, 11 insertions(+), 3 deletions(-)

0dc9d326e42aebd895cb989bd904cc82fd1b6b22
diff --git a/drivers/net/sundance.c b/drivers/net/sundance.c
index a37637e..ff98f5d 100644
--- a/drivers/net/sundance.c
+++ b/drivers/net/sundance.c
@@ -466,7 +466,7 @@ static int __devinit sundance_probe1 (struct pci_dev *pdev,
 #else
 	int bar = 1;
 #endif
-	int phy, phy_idx = 0;
+	int phy, phy_end, phy_idx = 0;
 	DECLARE_MAC_BUF(mac);
 
 /* when built into the kernel, we only print version if device is found */
@@ -552,11 +552,19 @@ static int __devinit sundance_probe1 (struct pci_dev *pdev,
 
 	np->phys[0] = 1;		/* Default setting */
 	np->mii_preamble_required++;
+
 	/*
 	 * It seems some phys doesn't deal well with address 0 being accessed
-	 * first, so leave address zero to the end of the loop (32 & 31).
+	 * first
 	 */
-	for (phy = 1; phy <= 32 && phy_idx < MII_CNT; phy++) {
+	if (sundance_pci_tbl[np->chip_id].device == 0x0200) {
+		phy = 0;
+		phy_end = 31;
+	} else {
+		phy = 1;
+		phy_end = 32;	/* wraps to zero, due to 'phy & 0x1f' */
+	}
+	for (; phy <= phy_end && phy_idx < MII_CNT; phy++) {
 		int phyx = phy & 0x1f;
 		int mii_status = mdio_read(dev, phyx, MII_BMSR);
 		if (mii_status != 0xffff  &&  mii_status != 0x0000) {

--------------070902030007090503070707--
