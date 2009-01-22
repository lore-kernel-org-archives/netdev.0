From: Evgeniy Polyakov <zbr@ioremap.net>
Subject: Re: speed regression in udp_lib_lport_inuse()
Date: Fri, 23 Jan 2009 01:14:34 +0300
Message-ID: <20090122221434.GB1651@ioremap.net>
References: <m3sknbuqf9.wl%vmayatsk@redhat.com> <4978EE03.9040207@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Vitaly Mayatskikh <v.mayatskih@gmail.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tservice.net.ru ([195.178.208.66]:58048 "EHLO tservice.net.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752768AbZAVWOf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Jan 2009 17:14:35 -0500
Content-Disposition: inline
In-Reply-To: <4978EE03.9040207@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Eric.

On Thu, Jan 22, 2009 at 11:06:59PM +0100, Eric Dumazet (dada1@cosmosbay.com) wrote:
> Hello Vitaly, thanks for this excellent report.
> 
> Yes, current code is really not good when all ports are in use :
> 
> We now have to scan 28232 [1] times long chains of 220 sockets.
> Thats very long (but at least thread is preemptable)
> 
> In the past (before patches), only one thread was allowed to run in kernel while scanning
> udp port table (we had only one global lock udp_hash_lock protecting the whole udp table).
> This thread was faster because it was not slowed down by other threads.
> (But the rwlock we used was responsible for starvations of writers if many UDP frames
> were received)
 
I believe problem is in the port searching algorithm, when we
have exponentially grow of the number of ports to check after random
selection of the first one. This allows to have small chains but setup
time will be very long. Not sure if bind chais should be that small
actually. In the 64k patch, which allows to have more than 64k bound
sockets per system I store rough amount of bound sockets and when it
becomes larger than sysctl limit I just randomly select a bundle.
This works for the bind(0) for the sockets with reuse option though.
I posted a picture of the bind(0) time for the .28 kernel iirc.

Or is this a different issue?

-- 
	Evgeniy Polyakov
