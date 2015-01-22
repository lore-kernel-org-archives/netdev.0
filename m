From: Mike Galbraith <umgwanakikbuti@gmail.com>
Subject: netxen: box stuck in netxen_napi_disable()
Date: Thu, 22 Jan 2015 05:43:25 +0100
Message-ID: <1421901805.5286.37.camel@marge.simpson.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f171.google.com ([74.125.82.171]:34606 "EHLO
	mail-we0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751764AbbAVEn2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Jan 2015 23:43:28 -0500
Received: by mail-we0-f171.google.com with SMTP id q58so1290863wes.2
        for <netdev@vger.kernel.org>; Wed, 21 Jan 2015 20:43:27 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Greetings network wizards,

After doing some generic NO_HZ_FULL isolated core perturbation
measurements with a 64 core DL980G7 running 3.19-rc5, everything seeming
just peachy, I came back later to check on the box only to find that I
could no longer ssh into the thing.  NO_HZ_FULL doesn't seem to be
involved in any obvious way, but I thought I should mention it.

No idea how repeatable this is, the box has other work to do atm.  File
under 'noted', or if you want me to peek at something, holler.

rtnl_mutex was holding up the show, was held by the kworker below, who
was stuck in napi_synchronize() waiting for NAPI_STATE_SCHED to go away,
but whoever was supposed to make that happen, didn't.

crash> ps | grep UN
    405      2   2  ffff880273958000  UN   0.0       0      0  [kworker/2:1]
    419      2  16  ffff880273bf0000  UN   0.0       0      0  [kworker/16:1]
   4259      1  21  ffff88026f3cbaa0  UN   0.0   14636   1908  dhcpcd
   6007      1   3  ffff8802736d1d50  UN   0.0   32292   3200  ntpd
   6048      1   0  ffff880272521d50  UN   0.0   59568   3460  ypbind
  13650      2   2  ffff8802749b0000  UN   0.0       0      0  [kworker/2:2]
crash> bt ffff880273958000
PID: 405    TASK: ffff880273958000  CPU: 2   COMMAND: "kworker/2:1"
 #0 [ffff880273957c10] __schedule at ffffffff81588c59
 #1 [ffff880273957c80] schedule at ffffffff81589119
 #2 [ffff880273957c90] schedule_timeout at ffffffff8158bbe6
 #3 [ffff880273957d30] msleep at ffffffff810c5aa7
 #4 [ffff880273957d50] netxen_napi_disable at ffffffffa032892a [netxen_nic]
 #5 [ffff880273957d80] __netxen_nic_down at ffffffffa032c6fc [netxen_nic]
 #6 [ffff880273957dc0] netxen_nic_reset_context at ffffffffa032d56b [netxen_nic]
 #7 [ffff880273957de0] netxen_tx_timeout_task at ffffffffa032d63d [netxen_nic]
 #8 [ffff880273957e00] process_one_work at ffffffff81077b7a
 #9 [ffff880273957e50] worker_thread at ffffffff81078231
#10 [ffff880273957ec0] kthread at ffffffff8107d139
#11 [ffff880273957f50] ret_from_fork at ffffffff8158cf7c
