From: Sucheta Chakraborty <sucheta.chakraborty@qlogic.com>
Subject: RE: [PATCH net-next-2.6 12/12] qlcnic: convert to set_phys_id
Date: Wed, 6 Apr 2011 07:56:39 -0500
Message-ID: <13A253B3F9BEFE43B93C09CF75F63CAA6E95E6626F@MNEXMB1.qlogic.org>
References: <99737F4847ED0A48AECC9F4A1974A4B80FD1383A55@MNEXMB2.qlogic.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"bhutchings@solarflare.com" <bhutchings@solarflare.com>,
	Amit Salecha <amit.salecha@qlogic.com>,
	Anirban Chakraborty <anirban.chakraborty@qlogic.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Sucheta Chakraborty <sucheta.chakraborty@qlogic.com>
To: "Stephen Hemminger "
	<IMCEAMAILTO-shemminger+40vyatta+2Ecom@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from va3ehsobe006.messaging.microsoft.com ([216.32.180.16]:42396
	"EHLO VA3EHSOBE009.bigfish.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1755886Ab1DFM5f convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Apr 2011 08:57:35 -0400
In-Reply-To: <99737F4847ED0A48AECC9F4A1974A4B80FD1383A55@MNEXMB2.qlogic.org>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -     if (!test_bit(__QLCNIC_DEV_UP, &adapter->state)) {
> -             dev_down = 1;
> -             if (test_and_set_bit(__QLCNIC_RESETTING, &adapter->state))
> -                     return -EIO;
> -
> -             ret = qlcnic_diag_alloc_res(dev, QLCNIC_LED_TEST);
> +     switch (state) {
> +     case ETHTOOL_ID_ACTIVE:
> +             if (!test_bit(__QLCNIC_DEV_UP, &adapter->state)) {
> +                     if (test_and_set_bit(__QLCNIC_RESETTING, &adapter-
> >state))
> +                             return -EIO;
> +
> +                     ret = qlcnic_diag_alloc_res(dev, QLCNIC_LED_TEST);
> +                     if (ret) {
> +                             clear_bit(__QLCNIC_RESETTING, &adapter->state);
> +                             return ret;
> +                     }
> +             }
> +
> +             ret = adapter->nic_ops->config_led(adapter, 1, 0xf);
>               if (ret) {
> -                     clear_bit(__QLCNIC_RESETTING, &adapter->state);
> -                     return ret;
> +                     dev_err(&adapter->pdev->dev,
> +                             "Failed to set LED blink state.\n");
> +                     break;
>               }
> -     }
> -
> -     ret = adapter->nic_ops->config_led(adapter, 1, 0xf);
> -     if (ret) {
> -             dev_err(&adapter->pdev->dev,
> -                     "Failed to set LED blink state.\n");
> -             goto done;
> -     }
> +             return 0;
>
> -     msleep_interruptible(val * 1000);
> +     case ETHTOOL_ID_INACTIVE:
> +             ret = adapter->nic_ops->config_led(adapter, 0, 0xf);
> +             if (ret)
> +                     dev_err(&adapter->pdev->dev,
> +                             "Failed to reset LED blink state.\n");
> +             break;
>
> -     ret = adapter->nic_ops->config_led(adapter, 0, 0xf);
> -     if (ret) {
> -             dev_err(&adapter->pdev->dev,
> -                     "Failed to reset LED blink state.\n");
> -             goto done;
> +     default:
> +             return -EINVAL;
>       }
>
> -done:
> -     if (dev_down) {
> +     if (!netif_running(dev)) {
>               qlcnic_diag_free_res(dev, max_sds_rings);
>               clear_bit(__QLCNIC_RESETTING, &adapter->state);
>       }

netif_running() check will not work here because interface can be brought down when LED test is ACTIVE.
This may result in freeing resources unnecessarily.
You can have a bit flag in adapter->state to track resources allocation (qlcnic_diag_alloc_res()).

Thanks,
Sucheta.


This message and any attached documents contain information from QLogic Corporation or its wholly-owned subsidiaries that may be confidential. If you are not the intended recipient, you may not read, copy, distribute, or use this information. If you have received this transmission in error, please notify the sender immediately by reply e-mail and then delete this message.

