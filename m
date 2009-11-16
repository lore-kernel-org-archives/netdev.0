From: "Vladislav Zolotarov" <vladz@broadcom.com>
Subject: RE: [net-next] bnx2x: Handle Rx and Tx together in NAPI
Date: Mon, 16 Nov 2009 03:11:27 -0800
Message-ID: <8628FE4E7912BF47A96AE7DD7BAC0AADCB2D07B367@SJEXCHCCR02.corp.ad.broadcom.com>
References: <1258365669.8392.3.camel@lb-tlvb-vladz.il.broadcom.com>
 <20091116.022012.81633492.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Eilon Greenstein" <eilong@broadcom.com>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:2268 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751214AbZKPLLb convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Nov 2009 06:11:31 -0500
In-Reply-To: <20091116.022012.81633492.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ok. I'll fix it shortly and send u a new patch.

To say the truth, limiting the amount of Tx work done in one NAPI round is
about to harm single NAPI performance, however I thought it would be a nice thing to
do in global (all network devices/queues in the system) perspective. In Tx only
case: when all NAPIs do only Tx DPC work (UDP Tx only case) I need to ensure fairness
somehow, so I chose NAPI's budget. Could u advice on this?

There is another decision to make: what to do when Rx hasn't consumed the whole budget
and there is still Tx work to do. I think that in this case we need to return "budget", so that
we pushed to the end on the local NAPI's list, "consuming" some global Rx budget of the 
local NAPI. Another option is to return the number of Rx
packets handled and make this NAPI be called at once. My decision is based on the fact
that there were scenarios when net_tx_action and net_rx_action were running on different
CPUs in UDP Tx test and were feeding each other. In this case if I implemented the later option
I would prevent other local NAPIs to run.

What is your opinion on this?

Thanks,
vlad

> -----Original Message-----
> From: David Miller [mailto:davem@davemloft.net] 
> Sent: Monday, November 16, 2009 12:20 PM
> To: Vladislav Zolotarov
> Cc: netdev@vger.kernel.org; Eilon Greenstein
> Subject: Re: [net-next] bnx2x: Handle Rx and Tx together in NAPI
> 
> From: "Vladislav Zolotarov" <vladz@broadcom.com>
> Date: Mon, 16 Nov 2009 12:01:09 +0200
> 
> >   - Limit Tx work done in one iteration by the same number 
> of packets as
> > Rx in order to ensure both fair work load balancing 
> relatively to other
> > devices scheduled for NAPI on the local CPU and sane Tx/Rx 
> skb resource
> > management from single QP perspective.
> 
> You should not do this.
> 
> RX is several orders of magnitude more work than TX is.  TX therefore
> should not be charged against the NAPI polling quota.
> 
> Don't try to be different from other drivers unless you have detailed
> performance numbers from various situations (local TCP flows _and_
> routing) to justify it. :-)
> 
> All NAPI drivers ignore TX work when considering NAPI polling quotas
> and you should too :-)
> 
> 
