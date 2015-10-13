From: Denys Fedoryshchenko <nuclearcat@nuclearcat.com>
Subject: Re: [PATCH net] ppp: don't override =?UTF-8?Q?sk-=3Esk=5Fstate=20?=
 =?UTF-8?Q?in=20pppoe=5Fflush=5Fdev=28=29?=
Date: Tue, 13 Oct 2015 05:13:54 +0300
Message-ID: <85baa6ab4293c475d0b4b26192694239@visp.net.lb>
References: <b7fbf103cd589741e3938550e7cf0f3684d8951c.1443605079.git.g.nault@alphalink.fr>
 <7045c1dad4647944f61c958511d45fcd@visp.net.lb>
 <20151002175426.GE2911@alphalink.fr>
 <356ca8b8094bb2460c0182c00e120378@visp.net.lb>
 <20151005120844.GF2911@alphalink.fr> <20151007121232.GF2882@alphalink.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII;
 format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Paul Mackerras <paulus@samba.org>,
	Oleksii Berezhniak <core@irc.lg.ua>,
	Matt Bennett <Matt.Bennett@alliedtelesis.co.nz>
To: Guillaume Nault <g.nault@alphalink.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hosting.visp.net.lb ([194.146.153.11]:48724 "EHLO
	hosting.visp.net.lb" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932118AbbJMCN6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Oct 2015 22:13:58 -0400
Received: from hosting.visp.net.lb (localhost [127.0.0.1])
	by hosting.visp.net.lb (Postfix) with ESMTP id 3A1374843B1
	for <netdev@vger.kernel.org>; Tue, 13 Oct 2015 05:13:55 +0300 (EEST)
In-Reply-To: <20151007121232.GF2882@alphalink.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2015-10-07 15:12, Guillaume Nault wrote:
> On Mon, Oct 05, 2015 at 02:08:44PM +0200, Guillaume Nault wrote:
>>  	if (po) {
>>  		struct sock *sk = sk_pppox(po);
>> 
>> -		bh_lock_sock(sk);
>> -
>> -		/* If the user has locked the socket, just ignore
>> -		 * the packet.  With the way two rcv protocols hook into
>> -		 * one socket family type, we cannot (easily) distinguish
>> -		 * what kind of SKB it is during backlog rcv.
>> -		 */
>> -		if (sock_owned_by_user(sk) == 0) {
>> -			/* We're no longer connect at the PPPOE layer,
>> -			 * and must wait for ppp channel to disconnect us.
>> -			 */
>> -			sk->sk_state = PPPOX_ZOMBIE;
>> -		}
>> -
>> -		bh_unlock_sock(sk);
>>  		if (!schedule_work(&po->proto.pppoe.padt_work))
>>  			sock_put(sk);
>>  	}
>> 
> Finally, I think I'll keep this approach for net-next, to completely
> remove PPPOX_ZOMBIE.
> For now, let's just avoid any assumption about the relationship between
> the PPPOX_ZOMBIE state and the value of po->pppoe_dev, as suggested by
> Matt.
> 
> Denys, can you let me know if your issue goes away with the following
> patch?
> ---
> diff --git a/drivers/net/ppp/pppoe.c b/drivers/net/ppp/pppoe.c
> index 2ed7506..5e0b432 100644
> --- a/drivers/net/ppp/pppoe.c
> +++ b/drivers/net/ppp/pppoe.c
> @@ -589,7 +589,7 @@ static int pppoe_release(struct socket *sock)
> 
>  	po = pppox_sk(sk);
> 
> -	if (sk->sk_state & (PPPOX_CONNECTED | PPPOX_BOUND | PPPOX_ZOMBIE)) {
> +	if (po->pppoe_dev) {
>  		dev_put(po->pppoe_dev);
>  		po->pppoe_dev = NULL;
>  	}
I just got OK to upgrade server yesterday, for now around 12 hours 
working fine. I need 1-2 more days, and maybe will upgrade few more 
servers to say for sure, if it is ok or not.
Sorry for delay, just it is production servers and at current situation 
they cannot tolerate significant downtime.
