From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] rtnl: Simplify ASSERT_RTNL
Date: Sun, 30 Sep 2007 17:47:30 +0200
Message-ID: <46FFC512.9060101@trash.net>
References: <E1IbTz0-0000FK-00@gondolin.me.apana.org.au> <46FE7019.4030705@trash.net> <20070930002421.GA7502@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: "Eric W. Biederman" <ebiederm@xmission.com>, davem@davemloft.net,
	netdev@vger.kernel.org, oliver@neukum.name,
	linux-usb-devel@lists.sourceforge.net
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:42094 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757312AbXI3Prc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 30 Sep 2007 11:47:32 -0400
In-Reply-To: <20070930002421.GA7502@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Herbert Xu wrote:
> On Sat, Sep 29, 2007 at 05:32:41PM +0200, Patrick McHardy wrote:
> 
>>For unicast addresses its not strictly necessary since they may
>>only be changed under the RTNL anyway. The reason why it takes
>>the tx_lock is for consistency with multicast address handling,
>>which can't rely on the RTNL since IPv6 changes them from
>>BH context. The idea was that the ->set_rx_mode function should
>>handle both secondary unicast and multicast addresses for
>>simplicity.
> 
> 
> In any case, coming back to the original question, the RTNL
> assertion is simply wrong in this case because if we're being
> called from IPv6 then the RTNL won't even be held.
> 
> So I think we need to
> 
> 1) Move the assert into dev_set_promiscuity.
> 2) Take the TX lock in dev_set_promiscuity.


In the IPv6 case we're only changing the multicast list,
so we're never calling into __dev_set_promiscuity.

I actually even added a comment about this :)

        /* Unicast addresses changes may only happen under the rtnl,
         * therefore calling __dev_set_promiscuity here is safe.
         */

I would prefer to keep the ASSERT_RTNL in __dev_set_promiscuity
since it also covers the __dev_set_rx_mode path. How about
adding an ASSERT_RTNL_ATOMIC without the might_sleep or simply
open coding it?
