From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: linux-next: zillions of lockdep whinges in
 include/net/sock.h:1408
Date: Thu, 21 Apr 2016 20:10:36 +0200
Message-ID: <5719179C.7020208@stressinduktion.org>
References: <66816.1461198639@turing-police.cc.vt.edu>
 <1461224532.4101068.585250481.7A43E285@webmail.messagingengine.com>
 <43037.1461229555@turing-police.cc.vt.edu>
 <1461245496.7627.17.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>, Valdis.Kletnieks@vt.edu
Return-path: <netdev-owner@vger.kernel.org>
Received: from out2-smtp.messagingengine.com ([66.111.4.26]:36826 "EHLO
	out2-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752074AbcDUSKl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Apr 2016 14:10:41 -0400
Received: from compute3.internal (compute3.nyi.internal [10.202.2.43])
	by mailout.nyi.internal (Postfix) with ESMTP id 2254520A8D
	for <netdev@vger.kernel.org>; Thu, 21 Apr 2016 14:10:40 -0400 (EDT)
In-Reply-To: <1461245496.7627.17.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 21.04.2016 15:31, Eric Dumazet wrote:
> On Thu, 2016-04-21 at 05:05 -0400, Valdis.Kletnieks@vt.edu wrote:
>> On Thu, 21 Apr 2016 09:42:12 +0200, Hannes Frederic Sowa said:
>>> Hi,
>>>
>>> On Thu, Apr 21, 2016, at 02:30, Valdis Kletnieks wrote:
>>>> linux-next 20160420 is whining at an incredible rate - in 20 minutes of
>>>> uptime, I piled up some 41,000 hits from all over the place (cleaned up
>>>> to skip the CPU and PID so the list isn't quite so long):
>>>
>>> Thanks for the report. Can you give me some more details:
>>>
>>> Is this an nfs socket? Do you by accident know if this socket went
>>> through xs_reclassify_socket at any point? We do hold the appropriate
>>> locks at that point but I fear that the lockdep reinitialization
>>> confused lockdep.
>>
>> It wasn't an NFS socket, as NFS wasn't even active at the time.  I'm reasonably
>> sure that multiple sockets were in play, given that tcp_v6_rcv and
>> udpv6_queue_rcv_skb were both implicated.  I strongly suspect that pretty much
>> any IPv6 traffic could do it - the frequency dropped off quite a bit when I
>> closed firefox, which is usually a heavy network hitter on my laptop.
> 
> 
> Looks like the following patch is needed, can you try it please ?
> 
> Thanks !
> 
> diff --git a/include/net/sock.h b/include/net/sock.h
> index d997ec13a643..db8301c76d50 100644
> --- a/include/net/sock.h
> +++ b/include/net/sock.h
> @@ -1350,7 +1350,8 @@ static inline bool lockdep_sock_is_held(const struct sock *csk)
>  {
>  	struct sock *sk = (struct sock *)csk;
>  
> -	return lockdep_is_held(&sk->sk_lock) ||
> +	return !debug_locks ||
> +	       lockdep_is_held(&sk->sk_lock) ||
>  	       lockdep_is_held(&sk->sk_lock.slock);
>  }
>  #endif

I am a little bit lost because I cannot reproduce this bug. I thought
maybe it has something to do with single cpu spin_locks which don't
update the lockdep_maps but I couldn't reproduce it. If debug_locks get
flipped you should see something in dmesg, too. Maybe you have this
handy? Was there another lockdep splat before the networking ones? Also
the config would be helpful.

Thanks,
Hannes
