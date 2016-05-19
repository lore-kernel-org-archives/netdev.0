From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [RFC] net: remove busylock
Date: Thu, 19 May 2016 10:08:36 -0700
Message-ID: <1463677716.18194.203.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Alexander Duyck <aduyck@mirantis.com>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:34932 "EHLO
	mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754514AbcESRIj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 May 2016 13:08:39 -0400
Received: by mail-pf0-f195.google.com with SMTP id b66so8698599pfb.2
        for <netdev@vger.kernel.org>; Thu, 19 May 2016 10:08:39 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

busylock was added at the time we had expensive ticket spinlocks

(commit 79640a4ca6955e3ebdb7038508fa7a0cd7fa5527 ("net: add additional
lock to qdisc to increase throughput")

Now kernel spinlocks are MCS, this busylock things is no longer
relevant. It is slowing down things a bit.


With HTB qdisc, here are the numbers for 200 concurrent TCP_RR, on a host with 48 hyperthreads.

lpaa5:~# sar -n DEV 4 4 |grep eth0
10:05:44         eth0 798951.25 798951.75  52276.22  52275.26      0.00      0.00      0.50
10:05:48         eth0 798576.00 798572.75  52251.24  52250.39      0.00      0.00      0.75
10:05:52         eth0 798746.00 798748.75  52262.89  52262.13      0.00      0.00      0.50
10:05:56         eth0 798303.25 798291.50  52235.22  52233.10      0.00      0.00      0.50
Average:         eth0 798644.12 798641.19  52256.39  52255.22      0.00      0.00      0.56

Disabling busylock (by using a local sysctl)

lpaa5:~# sar -n DEV 4 4 |grep eth0
10:05:14         eth0 864085.75 864091.50  56538.09  56537.46      0.00      0.00      0.50
10:05:18         eth0 864734.75 864729.25  56580.35  56579.05      0.00      0.00      0.75
10:05:22         eth0 864366.00 864361.50  56556.74  56555.00      0.00      0.00      0.50
10:05:26         eth0 864246.50 864248.75  56549.19  56547.65      0.00      0.00      0.50
Average:         eth0 864358.25 864357.75  56556.09  56554.79      0.00      0.00      0.56

That would be a 8 % increase.
