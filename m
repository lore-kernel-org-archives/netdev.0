From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: netxen: box stuck in netxen_napi_disable()
Date: Wed, 21 Jan 2015 21:57:54 -0800
Message-ID: <1421906274.4832.35.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1421901805.5286.37.camel@marge.simpson.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Mike Galbraith <umgwanakikbuti@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f175.google.com ([209.85.223.175]:58808 "EHLO
	mail-ie0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750885AbbAVF57 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Jan 2015 00:57:59 -0500
Received: by mail-ie0-f175.google.com with SMTP id ar1so14646770iec.6
        for <netdev@vger.kernel.org>; Wed, 21 Jan 2015 21:57:58 -0800 (PST)
In-Reply-To: <1421901805.5286.37.camel@marge.simpson.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2015-01-22 at 05:43 +0100, Mike Galbraith wrote:
> Greetings network wizards,
> 
> After doing some generic NO_HZ_FULL isolated core perturbation
> measurements with a 64 core DL980G7 running 3.19-rc5, everything seeming
> just peachy, I came back later to check on the box only to find that I
> could no longer ssh into the thing.  NO_HZ_FULL doesn't seem to be
> involved in any obvious way, but I thought I should mention it.
> 
> No idea how repeatable this is, the box has other work to do atm.  File
> under 'noted', or if you want me to peek at something, holler.
> 
> rtnl_mutex was holding up the show, was held by the kworker below, who
> was stuck in napi_synchronize() waiting for NAPI_STATE_SCHED to go away,
> but whoever was supposed to make that happen, didn't.
> 
> crash> ps | grep UN
>     405      2   2  ffff880273958000  UN   0.0       0      0  [kworker/2:1]
>     419      2  16  ffff880273bf0000  UN   0.0       0      0  [kworker/16:1]
>    4259      1  21  ffff88026f3cbaa0  UN   0.0   14636   1908  dhcpcd
>    6007      1   3  ffff8802736d1d50  UN   0.0   32292   3200  ntpd
>    6048      1   0  ffff880272521d50  UN   0.0   59568   3460  ypbind
>   13650      2   2  ffff8802749b0000  UN   0.0       0      0  [kworker/2:2]
> crash> bt ffff880273958000
> PID: 405    TASK: ffff880273958000  CPU: 2   COMMAND: "kworker/2:1"
>  #0 [ffff880273957c10] __schedule at ffffffff81588c59
>  #1 [ffff880273957c80] schedule at ffffffff81589119
>  #2 [ffff880273957c90] schedule_timeout at ffffffff8158bbe6
>  #3 [ffff880273957d30] msleep at ffffffff810c5aa7
>  #4 [ffff880273957d50] netxen_napi_disable at ffffffffa032892a [netxen_nic]
>  #5 [ffff880273957d80] __netxen_nic_down at ffffffffa032c6fc [netxen_nic]
>  #6 [ffff880273957dc0] netxen_nic_reset_context at ffffffffa032d56b [netxen_nic]
>  #7 [ffff880273957de0] netxen_tx_timeout_task at ffffffffa032d63d [netxen_nic]
>  #8 [ffff880273957e00] process_one_work at ffffffff81077b7a
>  #9 [ffff880273957e50] worker_thread at ffffffff81078231
> #10 [ffff880273957ec0] kthread at ffffffff8107d139
> #11 [ffff880273957f50] ret_from_fork at ffffffff8158cf7c

Hi Mike

This driver doesn't follow the NAPI model correctly.

Please try following fix :

diff --git a/drivers/net/ethernet/qlogic/netxen/netxen_nic_main.c b/drivers/net/ethernet/qlogic/netxen/netxen_nic_main.c
index 613037584d08..c531c8ae1be4 100644
--- a/drivers/net/ethernet/qlogic/netxen/netxen_nic_main.c
+++ b/drivers/net/ethernet/qlogic/netxen/netxen_nic_main.c
@@ -2388,7 +2388,10 @@ static int netxen_nic_poll(struct napi_struct *napi, int budget)
 
 	work_done = netxen_process_rcv_ring(sds_ring, budget);
 
-	if ((work_done < budget) && tx_complete) {
+	if (!tx_complete)
+		work_done = budget;
+
+	if (work_done < budget) {
 		napi_complete(&sds_ring->napi);
 		if (test_bit(__NX_DEV_UP, &adapter->state))
 			netxen_nic_enable_int(sds_ring);
