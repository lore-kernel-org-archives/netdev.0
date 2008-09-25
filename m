From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [patch 2/2] qeth: avoid qeth recovery problems
Date: Wed, 24 Sep 2008 20:52:09 -0400
Message-ID: <48DAE0B9.9010701@pobox.com>
References: <20080919105601.986966000@de.ibm.com> <20080919105703.089971000@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
	Ursula Braun <ursula.braun@de.ibm.com>
To: frank.blaschka@de.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:47086 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752543AbYIYAwQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 24 Sep 2008 20:52:16 -0400
In-Reply-To: <20080919105703.089971000@de.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

frank.blaschka@de.ibm.com wrote:
> From: Ursula Braun <ursula.braun@de.ibm.com>
> 
> Do not touch IFF_UP flag during qeth recovery, but invoke dev_close()
> in case of failing recovery.
> Cancel outstanding control commands in case of Data Checks or
> Channel Checks.
> Do not invoke qeth_l2_del_all_mc() in case of a hard stop to speed up
> removal of qeth devices.
> 
> Signed-off-by: Ursula Braun <ursula.braun@de.ibm.com>
> Signed-off-by: Frank Blaschka <frank.blaschka@de.ibm.com>
> ---
> 
>  drivers/s390/net/qeth_core_main.c |    4 +++-
>  drivers/s390/net/qeth_l2_main.c   |   11 +++++++----
>  drivers/s390/net/qeth_l3_main.c   |    8 +++++---
>  3 files changed, 15 insertions(+), 8 deletions(-)
> 
> Index: git_linus/drivers/s390/net/qeth_core_main.c
> ===================================================================
> --- git_linus.orig/drivers/s390/net/qeth_core_main.c	2008-09-17 13:46:00.000000000 +0200
> +++ git_linus/drivers/s390/net/qeth_core_main.c	2008-09-19 11:08:55.000000000 +0200
> @@ -760,7 +760,7 @@
>  		if (sense[SENSE_COMMAND_REJECT_BYTE] &
>  		    SENSE_COMMAND_REJECT_FLAG) {
>  			QETH_DBF_TEXT(TRACE, 2, "CMDREJi");
> -			return 0;
> +			return 1;
>  		}
>  		if ((sense[2] == 0xaf) && (sense[3] == 0xfe)) {
>  			QETH_DBF_TEXT(TRACE, 2, "AFFE");
> @@ -884,6 +884,7 @@
>  		}
>  		rc = qeth_get_problem(cdev, irb);
>  		if (rc) {
> +			qeth_clear_ipacmd_list(card);
>  			qeth_schedule_recovery(card);
>  			goto out;
>  		}
> @@ -4147,6 +4148,7 @@
>  	unsigned long flags;
>  	struct qeth_card *card = dev_get_drvdata(&gdev->dev);
>  
> +	QETH_DBF_TEXT(SETUP, 2, "removedv");
>  	if (card->discipline.ccwgdriver) {
>  		card->discipline.ccwgdriver->remove(gdev);
>  		qeth_core_free_discipline(card);
> Index: git_linus/drivers/s390/net/qeth_l2_main.c
> ===================================================================
> --- git_linus.orig/drivers/s390/net/qeth_l2_main.c	2008-09-19 11:08:36.000000000 +0200
> +++ git_linus/drivers/s390/net/qeth_l2_main.c	2008-09-19 11:08:55.000000000 +0200
> @@ -395,7 +395,8 @@
>  	}
>  	if (card->state == CARD_STATE_SOFTSETUP) {
>  		qeth_l2_process_vlans(card, 1);
> -		qeth_l2_del_all_mc(card);
> +		if (!card->use_hard_stop)
> +			qeth_l2_del_all_mc(card);
>  		qeth_clear_ipacmd_list(card);
>  		card->state = CARD_STATE_HARDSETUP;
>  	}
> @@ -826,7 +827,6 @@
>  	}
>  	card->data.state = CH_STATE_UP;
>  	card->state = CARD_STATE_UP;
> -	card->dev->flags |= IFF_UP;
>  	netif_start_queue(dev);
>  
>  	if (!card->lan_online && netif_carrier_ok(dev))
> @@ -841,7 +841,6 @@
>  
>  	QETH_DBF_TEXT(TRACE, 4, "qethstop");
>  	netif_tx_disable(dev);
> -	card->dev->flags &= ~IFF_UP;
>  	if (card->state == CARD_STATE_UP)
>  		card->state = CARD_STATE_SOFTSETUP;
>  	return 0;
> @@ -1138,9 +1137,13 @@
>  	if (!rc)
>  		PRINT_INFO("Device %s successfully recovered!\n",
>  			   CARD_BUS_ID(card));
> -	else
> +	else {
> +		rtnl_lock();
> +		dev_close(card->dev);
> +		rtnl_unlock();
>  		PRINT_INFO("Device %s could not be recovered!\n",
>  			   CARD_BUS_ID(card));
> +	}
>  	return 0;
>  }
>  
> Index: git_linus/drivers/s390/net/qeth_l3_main.c
> ===================================================================
> --- git_linus.orig/drivers/s390/net/qeth_l3_main.c	2008-09-17 13:46:00.000000000 +0200
> +++ git_linus/drivers/s390/net/qeth_l3_main.c	2008-09-19 11:08:55.000000000 +0200
> @@ -2795,7 +2795,6 @@
>  		return -ENODEV;
>  	card->data.state = CH_STATE_UP;
>  	card->state = CARD_STATE_UP;
> -	card->dev->flags |= IFF_UP;
>  	netif_start_queue(dev);
>  
>  	if (!card->lan_online && netif_carrier_ok(dev))
> @@ -2809,7 +2808,6 @@
>  
>  	QETH_DBF_TEXT(TRACE, 4, "qethstop");
>  	netif_tx_disable(dev);
> -	card->dev->flags &= ~IFF_UP;
>  	if (card->state == CARD_STATE_UP)
>  		card->state = CARD_STATE_SOFTSETUP;
>  	return 0;
> @@ -3218,9 +3216,13 @@
>  	if (!rc)
>  		PRINT_INFO("Device %s successfully recovered!\n",
>  			   CARD_BUS_ID(card));
> -	else
> +	else {
> +		rtnl_lock();
> +		dev_close(card->dev);
> +		rtnl_unlock();
>  		PRINT_INFO("Device %s could not be recovered!\n",
>  			   CARD_BUS_ID(card));
> +	}
>  	return 0;

applied 1-2


