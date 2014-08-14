From: "fugang.duan@freescale.com" <fugang.duan@freescale.com>
Subject: RE: [PATCH v2 1/1] net: fec: ptp: avoid register access when ipg
 clock is disabled
Date: Thu, 14 Aug 2014 09:26:45 +0000
Message-ID: <4f93901dbe7a4746aacc795ae825ee60@BLUPR03MB373.namprd03.prod.outlook.com>
References: <1407905705-27984-1-git-send-email-b38611@freescale.com>
 <1407905705-27984-2-git-send-email-b38611@freescale.com>
 <20140813211941.GB4840@netboy>
 <4dcf48cd1c11473c82fcec0c8963ece2@BLUPR03MB373.namprd03.prod.outlook.com>
 <20140814081036.GB7555@netboy>
 <e84f5b51501e4add8cf08819c64ef554@BLUPR03MB373.namprd03.prod.outlook.com>
 <20140814084251.GC7555@netboy>
 <4977c4d325c949019549211d74c6982d@BLUPR03MB373.namprd03.prod.outlook.com>
 <20140814091259.GA11727@netboy>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "shawn.guo@linaro.org" <shawn.guo@linaro.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn1blp0189.outbound.protection.outlook.com ([207.46.163.189]:35554
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752726AbaHNJ0t convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Aug 2014 05:26:49 -0400
In-Reply-To: <20140814091259.GA11727@netboy>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Richard Cochran <richardcochran@gmail.com> Sent: Thursday, August 14, 2014 5:13 PM
>To: Duan Fugang-B38611
>Cc: shawn.guo@linaro.org; davem@davemloft.net; netdev@vger.kernel.org
>Subject: Re: [PATCH v2 1/1] net: fec: ptp: avoid register access when ipg
>clock is disabled
>
>On Thu, Aug 14, 2014 at 09:02:07AM +0000, fugang.duan@freescale.com wrote:
>>
>> I know your means. Even if cancel the time_keep work, ptp timer still is
>running and continutious.
>> The time_keep work just to avoid timer overrun because FEC just support
>32bit counter.
>
>Right, so the time_keep must continue when the clock is running. It does
>not depend on whether time stamping is enabled.

So, your mean we need to start the time_keep early like the orignal method, on the contrary,
The patch like below is not reasonable:

@@ -289,9 +289,11 @@ int fec_ptp_set(struct net_device *ndev, struct ifreq *ifr)
        switch (config.tx_type) {
        case HWTSTAMP_TX_OFF:
                fep->hwts_tx_en = 0;
+               cancel_delayed_work_sync(&fep->time_keep);
                break;
        case HWTSTAMP_TX_ON:
                fep->hwts_tx_en = 1;
+               schedule_delayed_work(&fep->time_keep, HZ);
                break;
        default:

>
>> And, you said "return an error", I don't know your mean.
>> In addition, when clock is disabled, FEC ptp counter don't run any more.
>
>You can return an error from your 'gettime' method.
>
In the driver:
Gettime()->fec_ptp_gettime()->timecounter_read()->fec_ptp_read()
Period delayed work: fec_time_keep()->timecounter_read()->fec_ptp_read()

When ethx disable, all clocks are disabled. For gettime(), your mean that we check clock is on or not,
If clock is disabled, return an error in .fec_ptp_gettime() ?
How did it in the delayed work ?

Thanks for your review, I am confused by your suggestion.

Thanks,
Andy
