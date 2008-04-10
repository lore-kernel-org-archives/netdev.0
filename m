From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/6] socket: sk_filter deinline
Date: Thu, 10 Apr 2008 01:49:38 -0700 (PDT)
Message-ID: <20080410.014938.247220159.davem@davemloft.net>
References: <20080401004708.009204033@vyatta.com>
	<20080401004724.528304251@vyatta.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55468
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752265AbYDJIth (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Apr 2008 04:49:37 -0400
In-Reply-To: <20080401004724.528304251@vyatta.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Mon, 31 Mar 2008 17:47:10 -0700

> The sk_filter function is too big to be inlined. This saves 2296 bytes
> of text on allyesconfig.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

Because of the bloat I'll apply this to net-2.6.26

But I think we can do better in many of the callsites.

Most of them are in the packet receive path, have BH's disabled, and a
lot of the variables already laid out in registers.

I would like to see a new inline created that caters to these cases,
which does something like:

	if (rcu_dereference(sk->sk_filter))
		return sk_filter(sk, skb);
	else
		return 0;

The security check muddles things here, but that should be inlined in
such situations too I think.

It's all of that "pkt_len = this; pskb_trim(that);" that makes for
most of the bloat.  And that can stay in the un-inlined sk_filter() we
have now.

Having a socket filter enabled on a TCP socket is so rare, but
now everyone pays for the function call unconditionally.
