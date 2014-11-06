From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] net: gro: add a per device gro flush timer
Date: Wed, 05 Nov 2014 18:39:36 -0800
Message-ID: <1415241576.13896.62.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1415235320.13896.51.camel@edumazet-glaptop2.roam.corp.google.com>
	 <545AD11B.5050603@hp.com>
	 <1415240055.13896.57.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Willem de Bruijn <willemb@google.com>
To: Rick Jones <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f171.google.com ([209.85.223.171]:47495 "EHLO
	mail-ie0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750915AbaKFCji (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Nov 2014 21:39:38 -0500
Received: by mail-ie0-f171.google.com with SMTP id x19so2107793ier.30
        for <netdev@vger.kernel.org>; Wed, 05 Nov 2014 18:39:37 -0800 (PST)
In-Reply-To: <1415240055.13896.57.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2014-11-05 at 18:14 -0800, Eric Dumazet wrote:
> On Wed, 2014-11-05 at 17:38 -0800, Rick Jones wrote:
> 
> > Speaking of QPS, what happens to 200 TCP_RR tests when the feature is 
> > enabled?

The possible reduction of QPS happens when you have a single flow like
TCP_RR  -- -r 40000,40000

(Because we have one single TCP packet with 40000 bytes of payload,
application is waked up once when Push flag is received)

So cpu effiency is way better, but application has to copy 40000 bytes
in one go _after_ Push flag, instead of being able to copy part of the
data _before_ receiving the Push flag.

lpaa5:~# echo 0 >/sys/class/net/eth0/gro_flush_timeout
lpaa6:~# echo 0 >/sys/class/net/eth0/gro_flush_timeout
lpaa5:~# ./netperf -H lpaa6 -t TCP_RR -l 20 -Cc -- -r 40000,40000
MIGRATED TCP REQUEST/RESPONSE TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to lpaa6.prod.google.com () port 0 AF_INET : first burst 0
Local /Remote
Socket Size   Request Resp.  Elapsed Trans.   CPU    CPU    S.dem   S.dem
Send   Recv   Size    Size   Time    Rate     local  remote local   remote
bytes  bytes  bytes   bytes  secs.   per sec  % S    % S    us/Tr   us/Tr

16384  87380  40000   40000  20.00   9023.86  2.02   1.70   107.513  90.561 
16384  87380 

lpaa5:~# echo 2000 >/sys/class/net/eth0/gro_flush_timeout
lpaa6:~# echo 2000 >/sys/class/net/eth0/gro_flush_timeout
lpaa5:~# ./netperf -H lpaa6 -t TCP_RR -l 20 -Cc -- -r 40000,40000
MIGRATED TCP REQUEST/RESPONSE TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to lpaa6.prod.google.com () port 0 AF_INET : first burst 0
Local /Remote
Socket Size   Request Resp.  Elapsed Trans.   CPU    CPU    S.dem   S.dem
Send   Recv   Size    Size   Time    Rate     local  remote local   remote
bytes  bytes  bytes   bytes  secs.   per sec  % S    % S    us/Tr   us/Tr

16384  87380  40000   40000  20.00   8651.26  0.66   1.02   36.502  56.710 
16384  87380 
