From: Denys Fedoryshchenko <nuclearcat@nuclearcat.com>
Subject: Re: 4.1.0, kernel panic, =?UTF-8?Q?pppoe=5Frelease?=
Date: Tue, 22 Sep 2015 04:47:48 +0300
Message-ID: <9392178bf13d2814e19b1756cd204d73@visp.net.lb>
References: <677da51dbac367fcb7a456de2789334b@visp.net.lb>
 <c6e2cb4002bf11ad7a25be8eeded2dc1@visp.net.lb>
 <1437147400.5437.4.camel@redhat.com>
 <de4b28603ef7bcaea7aeca73dab80079@visp.net.lb>
 <20150910155657.GC3661@alphalink.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII;
 format=flowed
Content-Transfer-Encoding: 7bit
Cc: Dan Williams <dcbw@redhat.com>, Netdev <netdev@vger.kernel.org>,
	ebiederm@xmission.com, davem@davemloft.net, simon@farnz.org.uk,
	develop@kristov.de
To: Guillaume Nault <g.nault@alphalink.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hosting.visp.net.lb ([194.146.153.11]:33904 "EHLO
	hosting.visp.net.lb" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932198AbbIVBx2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Sep 2015 21:53:28 -0400
Received: from hosting.visp.net.lb (localhost [127.0.0.1])
	by hosting.visp.net.lb (Postfix) with ESMTP id D3C6248020B
	for <netdev@vger.kernel.org>; Tue, 22 Sep 2015 04:47:48 +0300 (EEST)
In-Reply-To: <20150910155657.GC3661@alphalink.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,
Sorry for late reply, was not able to push new kernel on pppoes without 
permissions (it's production servers), just got OK.

I am testing patch on another pppoe server with 9k users, for ~3 days, 
seems fine. I will test today
also on server that was experiencing crashes within 1 day.

On 2015-09-10 18:56, Guillaume Nault wrote:
> On Fri, Jul 17, 2015 at 09:16:14PM +0300, Denys Fedoryshchenko wrote:
>> Probably my knowledge of kernel is not sufficient, but i will try few
>> approaches.
>> One of them to add to pppoe_unbind_sock_work:
>> 
>>         pppox_unbind_sock(sk);
>>         +/* Signal the death of the socket. */
>>         +sk->sk_state = PPPOX_DEAD;
>> 
> I don't believe this will fix anything. pppox_unbind_sock() already
> sets sk->sk_state when necessary.
> 
>> I will wait first, to make sure this patch was causing kernel panic 
>> (it
>> needs 24h testing cycle), then i will try this fix.
>> 
> I suspect the problem goes with actions performed on the underlying
> interface (MAC address, MTU or link state update). This triggers
> pppoe_flush_dev(), which cleans up the device without announcing it
> in sk->sk_state.
> 
> Can you pleas try the following patch?
> 
> ---
> diff --git a/drivers/net/ppp/pppoe.c b/drivers/net/ppp/pppoe.c
> index 3837ae3..2ed7506 100644
> --- a/drivers/net/ppp/pppoe.c
> +++ b/drivers/net/ppp/pppoe.c
> @@ -313,7 +313,6 @@ static void pppoe_flush_dev(struct net_device *dev)
>  			if (po->pppoe_dev == dev &&
>  			    sk->sk_state & (PPPOX_CONNECTED | PPPOX_BOUND | PPPOX_ZOMBIE)) 
> {
>  				pppox_unbind_sock(sk);
> -				sk->sk_state = PPPOX_ZOMBIE;
>  				sk->sk_state_change(sk);
>  				po->pppoe_dev = NULL;
>  				dev_put(dev);
