From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] net: gro: add a per device gro flush timer
Date: Wed, 05 Nov 2014 18:14:15 -0800
Message-ID: <1415240055.13896.57.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1415235320.13896.51.camel@edumazet-glaptop2.roam.corp.google.com>
	 <545AD11B.5050603@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Willem de Bruijn <willemb@google.com>
To: Rick Jones <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f178.google.com ([209.85.223.178]:34491 "EHLO
	mail-ie0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751046AbaKFCOR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Nov 2014 21:14:17 -0500
Received: by mail-ie0-f178.google.com with SMTP id rp18so2083987iec.9
        for <netdev@vger.kernel.org>; Wed, 05 Nov 2014 18:14:17 -0800 (PST)
In-Reply-To: <545AD11B.5050603@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2014-11-05 at 17:38 -0800, Rick Jones wrote:

> Speaking of QPS, what happens to 200 TCP_RR tests when the feature is 
> enabled?

Nothing at all (but the usual noise I guess)

200 TCP_RR send packets with 1 byte of payload and Push flag,
so no packet ever sits in napi->gro_list

lpaa5:~# echo 0 >/sys/class/net/eth0/gro_flush_timeout
lpaa6:~# echo 0 >/sys/class/net/eth0/gro_flush_timeout
lpaa5:~# time ./super_netperf 200 -H lpaa6 -t TCP_RR -l 20
3.13827e+06

real	0m32.170s
user	0m32.885s
sys	7m38.868s

lpaa5:~# echo 2000 >/sys/class/net/eth0/gro_flush_timeout
lpaa6:~# echo 2000 >/sys/class/net/eth0/gro_flush_timeout
lpaa5:~# time ./super_netperf 200 -H lpaa6 -t TCP_RR -l 20
3.19013e+06

real	0m37.152s
user	0m33.477s
sys	7m30.586s

Now lets try TCP_RR with -- -r 4000,4000 ;)

Reducing ACK packets allow us to better use the 10Gbe bandwith for
payload, so QPS actually increase.

lpaa5:~# echo 0 >/sys/class/net/eth0/gro_flush_timeout
lpaa6:~# echo 0 >/sys/class/net/eth0/gro_flush_timeout
lpaa5:~# time ./super_netperf 200 -H lpaa6 -t TCP_RR -l 20 -- -r
4000,4000
379645

real	0m32.201s
user	0m4.390s
sys	0m59.501s

lpaa5:~# echo 2000 >/sys/class/net/eth0/gro_flush_timeout
lpaa6:~# echo 2000 >/sys/class/net/eth0/gro_flush_timeout
lpaa5:~# time ./super_netperf 200 -H lpaa6 -t TCP_RR -l 20 -- -r
4000,4000
400610

real	0m37.159s
user	0m4.501s
sys	0m59.665s
