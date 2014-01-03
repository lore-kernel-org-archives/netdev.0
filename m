From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [Bug 68011] New: spin_unlock is missed in function
 (netpoll_send_skb_on_dev) in file (linux-3.12/net/core/netpoll.c)
Date: Fri, 3 Jan 2014 04:50:07 +0000 (UTC)
Message-ID: <slrnlccgcb.3uh.xiyou.wangcong@linux-6brj.site>
References: <20140101215231.50ea361e@nehalam.linuxnetplumber.net>
 <20140102.195116.2109511693723200480.davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from plane.gmane.org ([80.91.229.3]:49249 "EHLO plane.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750790AbaACEue (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 2 Jan 2014 23:50:34 -0500
Received: from list by plane.gmane.org with local (Exim 4.69)
	(envelope-from <linux-netdev-2@m.gmane.org>)
	id 1VywiN-00058g-RO
	for netdev@vger.kernel.org; Fri, 03 Jan 2014 05:50:31 +0100
Received: from c-67-170-205-66.hsd1.ca.comcast.net ([67.170.205.66])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Fri, 03 Jan 2014 05:50:31 +0100
Received: from xiyou.wangcong by c-67-170-205-66.hsd1.ca.comcast.net with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Fri, 03 Jan 2014 05:50:31 +0100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 03 Jan 2014 at 00:51 GMT, David Miller <davem@davemloft.net> wrote:
> From: Stephen Hemminger <stephen@networkplumber.org>
> Date: Wed, 1 Jan 2014 21:52:31 -0800
>
>> In function (netpoll_send_skb_on_dev) in file (linux-3.12/net/core/netpoll.c):
>> 
>> The structure (txq->_xmit_lock) gets successfully locked at line (383) by
>> (__netif_tx_trylock(txq)) and unlocked by (__netif_tx_unlock(txq)) at line
>> (398).
>> 
>> The problem occurs when the loop breaks at line (390) and the structure
>> (txq->_xmit_lock) still locked. In that case, the structure (txq->_xmit_lock)
>> never gets unlocked.
>> 
>> A possible solution is to call (__netif_tx_unlock(txq)) before the break at
>> line (390)
>
> This code path has another problem, if __vlan_put_tag() returns NULL then
> the function exit path is going to try and insert that NULL skb back onto
> the npinfo->txq, resulting in a crash.
>
> We effectively, therefore, don't have the packet any more and as
> things stand the one and only thing we could do is just unlock and
> return immediately.  But this means we won't retry sending later, and
> will thus lose the frame.
>
> netpoll should try to be as drop free as possible, that's why it has all
> of this retry logic.
>
> There really should be a version of __vlan_put_tag() that allows the caller
> to unwind and try again somehow.
>
> Here's what I'll apply and queue up for -stable, thanks.
>
>====================
> [PATCH] netpoll: Fix missing TXQ unlock and and OOPS.
>
> The VLAN tag handling code in netpoll_send_skb_on_dev() has two problems.
>
> 1) It exits without unlocking the TXQ.
>
> 2) It then tries to queue a NULL skb to npinfo->txq.
>
> Reported-by: Ahmed Tamrawi <atamrawi@iastate.edu>
> Signed-off-by: David S. Miller <davem@davemloft.net>

Reviewed-by: Cong Wang <xiyou.wangcong@gmail.com>

Thanks!
