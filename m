From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] alx: Reset phy speed after resume
Date: Thu, 14 Nov 2013 08:57:02 -0800
Message-ID: <1384448222.15774.12.camel@joe-AO722>
References: <1384445773.29057.5.camel@localhost.tld>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: jcliburn@gmail.com, chris.snook@gmail.com, davem@davemloft.net,
	johannes@sipsolutions.net, wangyijing@huawei.com,
	maarten.lankhorst@canonical.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: hahnjo <linux@hahnjo.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0166.hostedemail.com ([216.40.44.166]:52690 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1755786Ab3KNQ5E (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Nov 2013 11:57:04 -0500
In-Reply-To: <1384445773.29057.5.camel@localhost.tld>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-11-14 at 17:16 +0100, hahnjo wrote:
> From 27744b24f9291782c1342dbd6cac511e68da907c Mon Sep 17 00:00:00 2001
> From: hahnjo <hahnjo@hahnjo.de>
> Date: Tue, 12 Nov 2013 18:19:24 +0100
> Subject: [PATCH] alx: Reset phy speed after resume
> 
> This fixes bug 62491 (https://bugzilla.kernel.org/show_bug.cgi?id=62491).
> After resuming some users got the following error flooding the kernel log:
> alx 0000:02:00.0: invalid PHY speed/duplex: 0xffff
> 
> Signed-off-by: Jonas Hahnfeld <linux@hahnjo.de>
> ---
>  drivers/net/ethernet/atheros/alx/main.c | 3 +++
>  1 file changed, 3 insertions(+)
> 
> diff --git a/drivers/net/ethernet/atheros/alx/main.c b/drivers/net/ethernet/atheros/alx/main.c
> index fc95b23..6305a5d 100644
> --- a/drivers/net/ethernet/atheros/alx/main.c
> +++ b/drivers/net/ethernet/atheros/alx/main.c
> @@ -1389,6 +1389,9 @@ static int alx_resume(struct device *dev)
>  {
>  	struct pci_dev *pdev = to_pci_dev(dev);
>  	struct alx_priv *alx = pci_get_drvdata(pdev);
> +	struct alx_hw *hw = &alx->hw;
> +
> +	alx_reset_phy(hw);
>  
>  	if (!netif_running(alx->dev))
>  		return 0;

Perhaps this would help too:
---
 drivers/net/ethernet/atheros/alx/hw.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/atheros/alx/hw.c b/drivers/net/ethernet/atheros/alx/hw.c
index 1e8c24a..3396224 100644
--- a/drivers/net/ethernet/atheros/alx/hw.c
+++ b/drivers/net/ethernet/atheros/alx/hw.c
@@ -908,7 +908,8 @@ int alx_read_phy_link(struct alx_hw *hw)
 	return 0;
 
 wrong_speed:
-	dev_err(&pdev->dev, "invalid PHY speed/duplex: 0x%x\n", giga);
+	dev_err_ratelimited(&pdev->dev, "invalid PHY speed/duplex: 0x%x\n",
+			    giga);
 	return -EINVAL;
 }
 
