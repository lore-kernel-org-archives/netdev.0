From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH V2 1/2] net: socket: return EADDRNOTAVAIL when source
 address becomes nonlocal
Date: Thu, 07 Apr 2016 21:48:14 -0400 (EDT)
Message-ID: <20160407.214814.1682483805978131113.davem@davemloft.net>
References: <1459865986-18271-1-git-send-email-zlpnobody@163.com>
	<1459865986-18271-2-git-send-email-zlpnobody@163.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, liping.zhang@spreadtrum.com
To: zlpnobody@163.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57651 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751965AbcDHBsQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Apr 2016 21:48:16 -0400
In-Reply-To: <1459865986-18271-2-git-send-email-zlpnobody@163.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Liping Zhang <zlpnobody@163.com>
Date: Tue,  5 Apr 2016 22:19:45 +0800

> From: Liping Zhang <liping.zhang@spreadtrum.com>
> 
> A socket can use bind(directly) or connect(indirectly) to bind to a local
> ip address, and later if the network becomes down, that cause the source
> address becomes nonlocal, then send() call will fail and return EINVAL.
> But this error code is confusing, acctually we did not pass any invalid
> arguments. Furthermore, send() maybe return ok at first, it now returns
> fail just because of a temporary network problem, i.e. when the network
> recovery, send() call will become ok. Return EADDRNOTAVAIL instead of
> EINVAL in such situation is better.
> 
> Take the ping utility for example, we can use -I option to specify the
> source address (e.g ping -I 10.19.145.26 117.135.169.41), when network
> becomes down, error message will be printed out as follows:
>     64 bytes from  (117.135.169.41): icmp_seq=9 ttl=54 time=46.7 ms
>     ping: sendmsg: Invalid argument
>     ping: sendmsg: Invalid argument
> 
> Apply this patch, error message will become:
>     64 bytes from  (117.135.169.41): icmp_seq=5 ttl=54 time=47.5 ms
>     ping: sendmsg: Cannot assign requested address
>     ping: sendmsg: Cannot assign requested address
> 
> Signed-off-by: Liping Zhang <liping.zhang@spreadtrum.com>

Changing the behavior of such a core, and fundamental function, with
hundreds of direct and indirect call sites is extremely dangerous.

I was worried that someone might depend upon the -EINVAL return value,
and indeed I quickly found that the code in net/netfilter/ipvs/ip_vs_xmit.c
does want to see EINVAL in this case.

I refuse to audit the entire call chain of all users of this helper
function, as I said there are hundreds.  But there are potentially
many other call sites, either direct or indirect, that have this
problem as well.

And furthermore, USERSPACE itself might depend upon the error code
being -EINVAL since we've been returning it for several decades.

To be quite honest I think the value of this change is very low and
with the risk factors involved here I really would rather not make
this change at all.

Sorry.
