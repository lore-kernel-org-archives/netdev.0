From: David Miller <davem@davemloft.net>
Subject: Re: [net-next] bnx2x: Handle Rx and Tx together in NAPI
Date: Mon, 16 Nov 2009 03:24:00 -0800 (PST)
Message-ID: <20091116.032400.204096446.davem@davemloft.net>
References: <1258365669.8392.3.camel@lb-tlvb-vladz.il.broadcom.com>
	<20091116.022012.81633492.davem@davemloft.net>
	<8628FE4E7912BF47A96AE7DD7BAC0AADCB2D07B367@SJEXCHCCR02.corp.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eilong@broadcom.com
To: vladz@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50655
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751651AbZKPLXo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Nov 2009 06:23:44 -0500
In-Reply-To: <8628FE4E7912BF47A96AE7DD7BAC0AADCB2D07B367@SJEXCHCCR02.corp.ad.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Vladislav Zolotarov" <vladz@broadcom.com>
Date: Mon, 16 Nov 2009 03:11:27 -0800

> To say the truth, limiting the amount of Tx work done in one NAPI
> round is about to harm single NAPI performance, however I thought it
> would be a nice thing to do in global (all network devices/queues in
> the system) perspective. In Tx only case: when all NAPIs do only Tx
> DPC work (UDP Tx only case) I need to ensure fairness somehow, so I
> chose NAPI's budget. Could u advice on this?

The extra loop you'll trigger in the code above ->poll() that loops
over NAPI context is more expensive than the TX freeing work.

The size of your TX ring will be enough all by itself to ensure
enough fairness.

If you try to use the NAPI quota, you're just adding overhead.

> There is another decision to make: what to do when Rx hasn't
> consumed the whole budget and there is still Tx work to do. I think
> that in this case we need to return "budget", so that we pushed to
> the end on the local NAPI's list, "consuming" some global Rx budget
> of the local NAPI. Another option is to return the number of Rx
> packets handled and make this NAPI be called at once. My decision is
> based on the fact that there were scenarios when net_tx_action and
> net_rx_action were running on different CPUs in UDP Tx test and were
> feeding each other. In this case if I implemented the later option I
> would prevent other local NAPIs to run.

I think you should always process all of the pending TX work first,
then do RX work and base your budget and rescheduling decisions
purely on RX work.

If you want to see it codified look at the tg3 driver or any other
driver that has been NAPI for a long ti me.
