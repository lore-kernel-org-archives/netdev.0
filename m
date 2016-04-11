From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next 09/11] fjes: Enhance changing MTU related work
Date: Mon, 11 Apr 2016 14:03:38 +0200
Message-ID: <20160411120338.GD2175@nanopsycho.orion>
References: <1460362136-14968-1-git-send-email-izumi.taku@jp.fujitsu.com>
 <1460362246-15380-1-git-send-email-izumi.taku@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Taku Izumi <izumi.taku@jp.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f49.google.com ([74.125.82.49]:36321 "EHLO
	mail-wm0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754123AbcDKMDl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Apr 2016 08:03:41 -0400
Received: by mail-wm0-f49.google.com with SMTP id v188so83321390wme.1
        for <netdev@vger.kernel.org>; Mon, 11 Apr 2016 05:03:40 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1460362246-15380-1-git-send-email-izumi.taku@jp.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mon, Apr 11, 2016 at 10:10:46AM CEST, izumi.taku@jp.fujitsu.com wrote:
>This patch enhances the fjes_change_mtu() method
>by introducing new flag named FJES_RX_MTU_CHANGING_DONE
>in rx_status. At the same time, default MTU value is
>changed into 65510 bytes.
>
>Signed-off-by: Taku Izumi <izumi.taku@jp.fujitsu.com>

<snip>	
	
>@@ -793,19 +798,54 @@ static int fjes_change_mtu(struct net_device *netdev, int new_mtu)
> 			if (new_mtu == netdev->mtu)
> 				return 0;
> 
>-			if (running)
>-				fjes_close(netdev);
>+			ret = 0;
>+			break;
>+		}
>+	}
>+
>+	if (ret)
>+		return ret;
> 
>-			netdev->mtu = new_mtu;
>+	if (running) {
>+		for (epidx = 0; epidx < hw->max_epid; epidx++) {
>+			if (epidx == hw->my_epid)
>+				continue;
>+			hw->ep_shm_info[epidx].tx.info->v1i.rx_status &=
>+				~FJES_RX_MTU_CHANGING_DONE;
>+		}
>+		netif_tx_stop_all_queues(netdev);
>+		netif_carrier_off(netdev);
>+		cancel_work_sync(&adapter->tx_stall_task);
>+		napi_disable(&adapter->napi);
> 
>-			if (running)
>-				ret = fjes_open(netdev);
>+		msleep(1000);

Will it be enough? I would rather sleep 2000ms here, just to be sure :)
