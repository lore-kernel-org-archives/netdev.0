From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: /proc/net/sockstat invalid memory accounting or memory leak in
 latest kernels?
Date: Thu, 17 Jul 2014 13:51:58 +0200
Message-ID: <1405597918.10255.76.camel@edumazet-glaptop2.roam.corp.google.com>
References: <40bc2b5fcda47d790f1fd247bc409041@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kaber@trash.net, davem@davemloft.net
To: Denys Fedoryshchenko <nuclearcat@nuclearcat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f170.google.com ([74.125.82.170]:48411 "EHLO
	mail-we0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756330AbaGQLwC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Jul 2014 07:52:02 -0400
Received: by mail-we0-f170.google.com with SMTP id w62so2575056wes.15
        for <netdev@vger.kernel.org>; Thu, 17 Jul 2014 04:52:01 -0700 (PDT)
In-Reply-To: <40bc2b5fcda47d790f1fd247bc409041@visp.net.lb>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2014-07-17 at 13:52 +0300, Denys Fedoryshchenko wrote:
> Hi
> 
> I noticed TCP transfer rate slowdown after few days of operation on 
> kernel 3.15.3, after some digging found out this:

What was previous version you were using without this problem ?

> 
> balancer-backup ~ # cat /proc/net/sockstat
> sockets: used 118236
> TCP: inuse 122958 orphan 4986 tw 108010 alloc 123179 mem 1955339
> UDP: inuse 1 mem 0
> UDPLITE: inuse 0
> RAW: inuse 0
> FRAG: inuse 1 memory 2
> 
> after shutting down program
> balancer-backup ~ # cat /proc/net/sockstat
> sockets: used 47
> TCP: inuse 10552 orphan 10547 tw 142645 alloc 10552 mem 1877061
> UDP: inuse 0 mem 0
> UDPLITE: inuse 0
> RAW: inuse 0
> FRAG: inuse 0 memory 0
> 
> sysctl settings:
> net.ipv4.tcp_mem = 1767103      2045612 3068412
> 
> I restarted recently process, and mem value didnt changed (while because 
> it is sockets should release all memory), also it looks incorrect, 
> because at same time:
> balancer-backup ~ # cat /proc/meminfo
> MemTotal:       32939492 kB
> MemFree:        29876564 kB
> 
> While 1955339 * 4096 should be around 8GB.
> Probably it is just accounting issue or is it real memory leak?
> What other info i can provide to troubleshoot this info more properly?
> I will upgrade to 3.15.5 also now, to see if issue persist there.

I see nothing really wrong in your report.

It looks like you have a lot of sockets around after shutdown of the
program. Each FIN-WAIT socket might consume a lot of buffers in its
write queue, unless you use/force SO_LINGER or something.

If you try the following command, you might see how many sockets have
outstanding data.

ss -amn
