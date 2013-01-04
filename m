From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: UDP multi-core performance on a single socket and SO_REUSEPORT
Date: Fri, 04 Jan 2013 11:37:18 -0800
Message-ID: <1357328238.1678.2189.camel@edumazet-glaptop>
References: <50DD6DF1.7080304@markandruth.co.uk>
	 <50E72493.4050406@markandruth.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Mark Zealey <netdev@markandruth.co.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f42.google.com ([209.85.160.42]:60781 "EHLO
	mail-pb0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754436Ab3ADThW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Jan 2013 14:37:22 -0500
Received: by mail-pb0-f42.google.com with SMTP id rp2so9365845pbb.15
        for <netdev@vger.kernel.org>; Fri, 04 Jan 2013 11:37:22 -0800 (PST)
In-Reply-To: <50E72493.4050406@markandruth.co.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-01-04 at 18:50 +0000, Mark Zealey wrote:
> I have written two small test scripts now which can be found at 
> http://mark.zealey.org/uploads/ - one launches 16 listening threads for 
> a single UDP socket, the other needs to be run as
> 
> for i in `seq 16`; do ./udp_test_client & done
> 
> On my test server (32-core), stock kernel 3.7.1, 90% of the time is 
> spent in the kernel waiting on spinlocks. Perf output:

Mark

We know the scalability issue of using a single socket and many threads.

The send path was somehow fixed to not require socket lock.

But the receive path uses a single receive_queue, protected by a
spinlock.

SO_REUSEPORT would be nice, but had known issues.

af_packet fanout implementation was nicer.
You could try :

1) Use af_packet FANOUT instead of UDP sockets

2) rewrite SO_REUSEPORT to use a FANOUT like implementation

3) Extend UDP sockets to be able to use a configurable number of receive
queues instead of a single one.
