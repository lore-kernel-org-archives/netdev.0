From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] ipv4: Avoid crashing in ip_error
Date: Fri, 22 May 2015 14:24:47 -0400 (EDT)
Message-ID: <20150522.142447.1048811620866120127.davem@davemloft.net>
References: <ff82713d6862786de9784bd3c9c06bfa@vittgam.net>
	<20150522040453.GC8530@1wt.eu>
	<87zj4x6iiz.fsf_-_@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linuxbugs@vittgam.net, security@kernel.org,
	greg@kroah.com, luto@amacapital.net, w@1wt.eu
To: ebiederm@xmission.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49453 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756692AbbEVSYu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 May 2015 14:24:50 -0400
In-Reply-To: <87zj4x6iiz.fsf_-_@x220.int.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: ebiederm@xmission.com (Eric W. Biederman)
Date: Fri, 22 May 2015 04:58:12 -0500

> ip_error does not check if in_dev is NULL before dereferencing it.
> 
> IThe following sequence of calls is possible:
> CPU A                          CPU B
> ip_rcv_finish
>     ip_route_input_noref()
>         ip_route_input_slow()
>                                inetdev_destroy()
>     dst_input()
> 
> With the result that a network device can be destroyed while processing
> an input packet.
> 
> A crash was triggered with only unicast packets in flight, and
> forwarding enabled on the only network device.   The error condition
> was created by the removal of the network device.
> 
> As such it is likely the that error code was -EHOSTUNREACH, and the
> action taken by ip_error (if in_dev had been accessible) would have
> been to not increment any counters and to have tried and likely failed
> to send an icmp error as the network device is going away.
> 
> Therefore handle this weird case by just dropping the packet if
> !in_dev.  It will result in dropping the packet sooner, and will not
> result in an actual change of behavior.
> 
> Fixes: 251da4130115b ("ipv4: Cache ip_error() routes even when not forwarding.")
> Reported-by: "Vittorio G (VittGam)" <linuxbugs@vittgam.net>
> Tested-by: "Vittorio G (VittGam)" <linuxbugs@vittgam.net>
> Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>

Looks good, applied and queued up for -stable, thanks!
