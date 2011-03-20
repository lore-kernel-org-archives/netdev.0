From: Hagen Paul Pfeifer <hagen@jauu.net>
Subject: Re: [PATCH 1/2] socket: increase default maximum listen queue
 length
Date: Mon, 21 Mar 2011 00:52:53 +0100
Message-ID: <20110320235253.GD3038@nuttenaction>
References: <20110320121414.GC3038@nuttenaction>
 <1300662282-24741-1-git-send-email-hagen@jauu.net>
 <20110320.160906.112595807.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from alternativer.internetendpunkt.de ([88.198.24.89]:53946 "EHLO
	geheimer.internetendpunkt.de" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751506Ab1CTXwz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Mar 2011 19:52:55 -0400
Content-Disposition: inline
In-Reply-To: <20110320.160906.112595807.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

* David Miller | 2011-03-20 16:09:06 [-0700]:

>Absolutely no context is provided for this number.
>
>What's the RTT?  How fast are the cpus?  etc.
>
>You must tell the whole story in order to justify these changes
>properly.

(you can skip the first paragraphs and read the last one ;)

The number is somewhat magically - like many other values. I greped
tglx/history.git but the comment (at that time tcp_ipv4.c) seems pre 2002 era.

Providing context is a little bit artificial: I can construct an scenario with
a RTT of 200ms and 1000 connection request per second and the table will
overflow. This can happen, sure. On the other hand there are scenarios with a
RTT of 20ms and 10 connection requests per second - no problem there.

Increasing the number _has_ one essential advantage: it is aligned on
sysctl_max_syn_backlog which in turn is determined by memory characteristics.


Without patch (sysctl not modified, BUT sysctl_max_syn_backlog depending on memory characteristic):

listen-queue-length = max(8, min(userspace_backlog, min(128, sysctl_max_syn_backlog))

Wit patch (sysctl not modified, BUT sysctl_max_syn_backlog depending on memory characteristic):

listen-queue-length = max(8, min(userspace_backlog, min(256, sysctl_max_syn_backlog))


The point is now: sysctl_max_syn_backlog is per default 256, 128 for small
systems and up to 1024 for larger systems. But sysctl_somaxconn (128) will
_always_ restrict the queue length to 128 and make therefore
sysctl_max_syn_backlog defacto unfeasible - it will always restrict the value
to 128. IMHO sysctl_somaxconn should be removed, the overhead of the
listen-queue size per listening socket is insignificant. Especially because
sysctl_max_syn_backlog already consider the memory characteristic. There are a
bunch more connected sockets as these <10 listening sockets, but performance
lack because of will always be noticeable:

netstat -s | grep overflowed
    2621 times the listen queue of a socket overflowed

Hagen
