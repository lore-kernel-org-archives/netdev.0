From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH] net: ethernet: marvell: sky2.c:  Cleaning up missing
 null-terminate in conjunction with strncpy
Date: Sun, 14 Sep 2014 19:05:57 -0700
Message-ID: <20140914190557.690183d2@urahara>
References: <1410716023-16068-1-git-send-email-rickard_strandqvist@spectrumdigital.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Mirko Lindner <mlindner@marvell.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Rickard Strandqvist <rickard_strandqvist@spectrumdigital.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f172.google.com ([209.85.192.172]:62773 "EHLO
	mail-pd0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752512AbaIOCGB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 14 Sep 2014 22:06:01 -0400
Received: by mail-pd0-f172.google.com with SMTP id v10so5168343pde.17
        for <netdev@vger.kernel.org>; Sun, 14 Sep 2014 19:06:00 -0700 (PDT)
In-Reply-To: <1410716023-16068-1-git-send-email-rickard_strandqvist@spectrumdigital.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 14 Sep 2014 19:33:43 +0200
Rickard Strandqvist <rickard_strandqvist@spectrumdigital.se> wrote:

> Replacing strncpy with strlcpy to avoid strings that lacks null terminate.
> 
> Signed-off-by: Rickard Strandqvist <rickard_strandqvist@spectrumdigital.se>
> ---
>  drivers/net/ethernet/marvell/sky2.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/drivers/net/ethernet/marvell/sky2.c b/drivers/net/ethernet/marvell/sky2.c
> index dba48a5c..7053d38 100644
> --- a/drivers/net/ethernet/marvell/sky2.c
> +++ b/drivers/net/ethernet/marvell/sky2.c
> @@ -4907,7 +4907,7 @@ static const char *sky2_name(u8 chipid, char *buf, int sz)
>  	};
>  
>  	if (chipid >= CHIP_ID_YUKON_XL && chipid <= CHIP_ID_YUKON_OP_2)
> -		strncpy(buf, name[chipid - CHIP_ID_YUKON_XL], sz);
> +		strlcpy(buf, name[chipid - CHIP_ID_YUKON_XL], sz);
>  	else
>  		snprintf(buf, sz, "(chip %#x)", chipid);
>  	return buf;

Useless and unnecessary since the list of names is right there.
Why not avoid the copy all together?

Subject: sky2: avoid strncpy

Don't use strncpy() since security thought police think it is bad.

Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>


--- a/drivers/net/ethernet/marvell/sky2.c	2014-08-25 09:01:16.292060455 -0700
+++ b/drivers/net/ethernet/marvell/sky2.c	2014-09-14 19:02:26.731034094 -0700
@@ -4889,7 +4889,7 @@ static int sky2_test_msi(struct sky2_hw
 }
 
 /* This driver supports yukon2 chipset only */
-static const char *sky2_name(u8 chipid, char *buf, int sz)
+static const char *sky2_name(u8 chipid)
 {
 	const char *name[] = {
 		"XL",		/* 0xb3 */
@@ -4905,11 +4905,12 @@ static const char *sky2_name(u8 chipid,
 		"OptimaEEE",    /* 0xbd */
 		"Optima 2",	/* 0xbe */
 	};
+	static char buf[16];
 
 	if (chipid >= CHIP_ID_YUKON_XL && chipid <= CHIP_ID_YUKON_OP_2)
-		strncpy(buf, name[chipid - CHIP_ID_YUKON_XL], sz);
-	else
-		snprintf(buf, sz, "(chip %#x)", chipid);
+		return name[chipid - CHIP_ID_YUKON_XL];
+
+	snprintf(buf, sizeof(buf), "(chip %#x)", chipid);
 	return buf;
 }
 
@@ -4919,7 +4920,6 @@ static int sky2_probe(struct pci_dev *pd
 	struct sky2_hw *hw;
 	int err, using_dac = 0, wol_default;
 	u32 reg;
-	char buf1[16];
 
 	err = pci_enable_device(pdev);
 	if (err) {
@@ -5014,7 +5014,7 @@ static int sky2_probe(struct pci_dev *pd
 	}
 
 	dev_info(&pdev->dev, "Yukon-2 %s chip revision %d\n",
-		 sky2_name(hw->chip_id, buf1, sizeof(buf1)), hw->chip_rev);
+		 sky2_name(hw->chip_id), hw->chip_rev);
 
 	sky2_reset(hw);
 
