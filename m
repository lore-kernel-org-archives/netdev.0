From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv4: do not cache local route when using
 SO_BINDTODEVICE
Date: Thu, 25 Feb 2016 14:31:06 -0500 (EST)
Message-ID: <20160225.143106.1173673610254814867.davem@davemloft.net>
References: <87si0knghn.fsf@pingu.sky.yk.fujitsu.co.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: kouya@jp.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44881 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933583AbcBYTbJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Feb 2016 14:31:09 -0500
In-Reply-To: <87si0knghn.fsf@pingu.sky.yk.fujitsu.co.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kouya Shimura <kouya@jp.fujitsu.com>
Date: Tue, 23 Feb 2016 14:27:32 +0900

> After v3.6, output routes are cached, however, the 'rt_iif' field of
> struct rtable can not be shared by various traffics using SO_BINDTODEVICE.
> It causes that traffic can not reach the local receiver which also uses 
> SO_BINDTODEVICE after another traffic creates a local route cache. 
> 
>   /* sender and receiver are running on same host. */
>   sender:
>     - socket(SOCK_DGRAM)
>     - setsockopt(SO_BINDTODEVICE, "eth0")
>     - connect(INADDR_ANY)
>     - send("message") ------>[loopback]------+
>                                              |
>   receiver:                                  |
>     - socket(SOCK_DGRAM)                     |
>     - setsockopt(SO_BINDTODEVICE, "eth0")    |
>     - bind(INADDR_ANY)                       |
>     - recv()  <------------------------------+
>       /* sometimes reach, sometimes not reach!!! */
> 
> Before v3.6, above traffics always reached. It seems to be a
> regression. Actually the 'dhcp_release' command relies on it.
> 
> Commit 7bd86cc282a458b66c41e3f6 ("ipv4: Cache local output routes")
> originated this issue. Revert it conditionally.
> 
> Signed-off-by: Kouya Shimura <kouya@jp.fujitsu.com>

I strongly fear that this will cause a performance regression for some important
cases.  If you elide the cache, it means that every route lookup has to allocate,
create, and destroy the cache object.  This is really expensive.

There has to be a better way to do so, so I'm not applying this patch, sorry.
