From: Lekensteyn <lekensteyn@gmail.com>
Subject: Re: [REGRESSION, v3.7-rc5, bisected] 100% CPU usage in softirqd, unable to shutdown(Internet mail)
Date: Tue, 13 Nov 2012 19:25:50 +0100
Message-ID: <1821565.8nx6NH6PfI@al>
References: <5934660.4HuQirPM4Z@al> <0ED22CD02BE51541A6BCC0D6BDA097AE0F5A6D@EXMBX-BJ003.tencent.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: "David S. Miller" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: =?utf-8?B?ZGFubnlmZW5nKOWGr+Wwj+WkqSk=?= <dannyfeng@tencent.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:37032 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752384Ab2KMSZy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Nov 2012 13:25:54 -0500
Received: by mail-bk0-f46.google.com with SMTP id q16so708492bkw.19
        for <netdev@vger.kernel.org>; Tue, 13 Nov 2012 10:25:53 -0800 (PST)
In-Reply-To: <0ED22CD02BE51541A6BCC0D6BDA097AE0F5A6D@EXMBX-BJ003.tencent.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tuesday 13 November 2012 10:26:03 dannyfeng wrote:
> I'm sorry, I didn't noticed that jme_open use tasklet_enable, which may
> reuse a killed tasklet... Could you please try following patch?
> ---
> diff --git a/drivers/net/ethernet/jme.c b/drivers/net/ethernet/jme.c
> index 92317e9..c0314c1 100644
> --- a/drivers/net/ethernet/jme.c
> +++ b/drivers/net/ethernet/jme.c
> @@ -1860,10 +1860,14 @@ jme_open(struct net_device *netdev)
>         jme_clear_pm(jme);
>         JME_NAPI_ENABLE(jme);
>  
> -       tasklet_enable(&jme->linkch_task);
> -       tasklet_enable(&jme->txclean_task);
> -       tasklet_hi_enable(&jme->rxclean_task);
> -       tasklet_hi_enable(&jme->rxempty_task);
> +       tasklet_init(&jme->linkch_task, jme_link_change_tasklet,
> +                     (unsigned long) jme);
> +       tasklet_init(&jme->txclean_task, jme_tx_clean_tasklet,
> +                     (unsigned long) jme);
> +       tasklet_init(&jme->rxclean_task, jme_rx_clean_tasklet,
> +                     (unsigned long) jme);
> +       tasklet_init(&jme->rxempty_task, jme_rx_empty_tasklet,
> +                     (unsigned long) jme);
>  
>         rc = jme_request_irq(jme);
>         if (rc)
> @@ -3079,22 +3083,6 @@ jme_init_one(struct pci_dev *pdev,
>         tasklet_init(&jme->pcc_task,
>                      jme_pcc_tasklet,
>                      (unsigned long) jme);
> -       tasklet_init(&jme->linkch_task,
> -                    jme_link_change_tasklet,
> -                    (unsigned long) jme);
> -       tasklet_init(&jme->txclean_task,
> -                    jme_tx_clean_tasklet,
> -                    (unsigned long) jme);
> -       tasklet_init(&jme->rxclean_task,
> -                    jme_rx_clean_tasklet,
> -                    (unsigned long) jme);
> -       tasklet_init(&jme->rxempty_task,
> -                    jme_rx_empty_tasklet,
> -                    (unsigned long) jme);
> -       tasklet_disable_nosync(&jme->linkch_task);
> -       tasklet_disable_nosync(&jme->txclean_task);
> -       tasklet_disable_nosync(&jme->rxclean_task);
> -       tasklet_disable_nosync(&jme->rxempty_task);
>         jme->dpi.cur = PCC_P1;
>  
>         jme->reg_ghc = 0;
Tested-by: Peter Wu <lekensteyn@gmail.com>

I have no idea what this does, but it seems to help as I can suspend/resume 
without rapidly rising softirqs. (applied on top of 3.7-rc5.)

I tested it like this:
- rmmod jme
- insmod <path to new patched build>/jme.ko

I hand-edited the code as your patch does not apply due to tab to space 
conversion. You might want to use a real email client instead of the web 
interface.

Regards,
Peter
