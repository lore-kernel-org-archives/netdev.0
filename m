From: David Miller <davem@davemloft.net>
Subject: Re: TCP kernel tables overflowing after sustained 1000 new
 connections per second
Date: Wed, 09 Sep 2009 17:08:24 -0700 (PDT)
Message-ID: <20090909.170824.141343404.davem@davemloft.net>
References: <c67e3dc60909091146j4aeaf422v4e0543eff87c7f9a@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, roque@di.fc.ul.pt,
	netdev@vger.kernel.org
To: paulsheer@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59978
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752630AbZIJAII (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Sep 2009 20:08:08 -0400
In-Reply-To: <c67e3dc60909091146j4aeaf422v4e0543eff87c7f9a@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Paul Sheer <paulsheer@gmail.com>
Date: Wed, 9 Sep 2009 20:46:07 +0200

Can you please send networking reports and questions at least
CC:'d to netdev@vger.kernel.org, which is where the networking
developers are subscribed?  I've added it to the CC:

> I am developing a high-performance application, and testing against Apache.
> It makes 1000 new connections to Apache per second.
> 
> After 16 seconds the test grinds to a halt. A Linux kernel problem. There are
> several hurdles to overcome when trying to sustain such through-put. Some
> are configuration issues, others I believe are real problems with the kernel
> internals. I'll discuss these all below.
> 
> Configuration:
> 
> These are the relavent kernel configuration parameters:
> 
>  /proc/sys/net/ipv4/tcp_tw_recycle
>  /proc/sys/net/ipv4/tcp_tw_reuse
>  /proc/sys/net/ipv4/tcp_max_tw_buckets
>  /proc/sys/net/ipv4/ip_local_port_range
>  /proc/sys/net/ipv4/tcp_timestamps
>  /proc/sys/net/ipv4/tcp_fin_timeout
>  /proc/sys/net/ipv4/tcp_orphan_retries
>  /proc/sys/net/ipv4/tcp_rfc1337
>  /proc/sys/net/ipv4/tcp_max_orphans
>  /proc/sys/net/ipv4/tcp_max_syn_backlog
>  /proc/sys/net/ipv4/tcp_mem
> 
> On a gigabit local LAN I can set the timeouts very low to encourage
> port reuse. A well known configuration issue with all OS's - just search
> for MyOS+TIMED_WAIT on google. No problems here.
> 
> 
> The second problem is the ip_conntrack module.
> 
> If you don't know that your distribution has enabled this module
> by default, it not easy to work out that it has internal tables
> that max out at 16384.  So this explains why my system
> stops accepting connections after exactly 16 seconds.
> If you stop the application, give it a few minutes, try again,
> then you can do another 16 seconds of flat out load for it
> grinds to a halt again. Doing an rm on the module ko and
> rebooting fixed *this* problem.
> 
> The third problem seems to be connected to /proc/net/tcp6
> 
> look at the output of the script
> 
> while true ; do echo "`date`: `cat /proc/net/tcp6 | wc -l`  vs  `cat
> /proc/net/tcp | wc -l`" ; sleep 1 ; done
> 
> while I run my load test:
> 
> 
>  Wed Sep  9 20:39:26 SAST 2009: 5  vs  20
>  Wed Sep  9 20:39:27 SAST 2009: 5  vs  20
>  Wed Sep  9 20:39:28 SAST 2009: 5  vs  20
>  Wed Sep  9 20:39:29 SAST 2009: 5  vs  20
>  Wed Sep  9 20:39:31 SAST 2009: 1233  vs  20
>  Wed Sep  9 20:39:32 SAST 2009: 2640  vs  21
>  Wed Sep  9 20:39:33 SAST 2009: 4190  vs  20
>  Wed Sep  9 20:39:34 SAST 2009: 5813  vs  20
>  Wed Sep  9 20:39:35 SAST 2009: 7527  vs  20
>  Wed Sep  9 20:39:37 SAST 2009: 9568  vs  44
>  Wed Sep  9 20:39:38 SAST 2009: 11819  vs  21
>  Wed Sep  9 20:39:40 SAST 2009: 14510  vs  21
>  Wed Sep  9 20:39:42 SAST 2009: 16971  vs  20
>  Wed Sep  9 20:39:44 SAST 2009: 16971  vs  20
>  Wed Sep  9 20:39:46 SAST 2009: 17013  vs  20
>  Wed Sep  9 20:39:48 SAST 2009: 17013  vs  20
>  Wed Sep  9 20:39:50 SAST 2009: 17013  vs  20
> 
> So it is clear "something" is filling up in tcp_ipv6.c
> 
> any ideas Pedro?
> anyone?
> 
> Many thanks.
> 
> -paul
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
