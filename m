From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] ipv6/tcp: Stop processing ICMPv6 redirect messages
Date: Sun, 07 Apr 2013 12:36:43 -0400 (EDT)
Message-ID: <20130407.123643.2080845809734438561.davem@davemloft.net>
References: <1365346395-18016-1-git-send-email-christoph.paasch@uclouvain.be>
	<1365346942.3887.6.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: christoph.paasch@uclouvain.be, netdev@vger.kernel.org,
	djduanjiong@gmail.com, steffen.klassert@secunet.com,
	ncardwell@google.com, hannes@stressinduktion.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56130 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934035Ab3DGQgp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 7 Apr 2013 12:36:45 -0400
In-Reply-To: <1365346942.3887.6.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Sun, 07 Apr 2013 08:02:22 -0700

> On Sun, 2013-04-07 at 16:53 +0200, Christoph Paasch wrote:
>> Tetja Rediske found that if the host receives an ICMPv6 redirect message
>> after sending a SYN+ACK, the connection will be reset.
>> 
>> He bisected it down to 093d04d (ipv6: Change skb->data before using
>> icmpv6_notify() to propagate redirect), but the origin of the bug comes
>> from ec18d9a26 (ipv6: Add redirect support to all protocol icmp error
>> handlers.). The bug simply did not trigger prior to 093d04d, because
>> skb->data did not point to the inner IP header and thus icmpv6_notify
>> did not call the correct err_handler.
>> 
>> This patch adds the missing "goto out;" in tcp_v6_err. After receiving
>> an ICMPv6 Redirect, we should not continue processing the ICMP in
>> tcp_v6_err, as this may trigger the removal of request-socks or setting
>> sk_err(_soft).
>> 
>> Reported-by: Tetja Rediske <tetja@tetja.de>
>> Signed-off-by: Christoph Paasch <christoph.paasch@uclouvain.be>
>> ---
>> v2: Removed code-cleanup from the patch and improved the commit-message upon 
>> suggestion from Eric Dumazet.
>> 
>>  net/ipv6/tcp_ipv6.c | 1 +
>>  1 file changed, 1 insertion(+)
>> 
>> diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
>> index 1033d2b..e51bd1a 100644
>> --- a/net/ipv6/tcp_ipv6.c
>> +++ b/net/ipv6/tcp_ipv6.c
>> @@ -386,6 +386,7 @@ static void tcp_v6_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
>>  
>>  		if (dst)
>>  			dst->ops->redirect(dst, sk, skb);
>> +		goto out;
>>  	}
>>  
>>  	if (type == ICMPV6_PKT_TOOBIG) {
> 
> 
> Thanks for sorting this out.
> 
> Acked-by: Eric Dumazet <edumazet@google.com>

Applied and queued up for -stable, thanks everyone!
