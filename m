From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Subject: Re: [PATCH net] sctp: fix race on protocol/netns initialization
Date: Thu, 10 Sep 2015 09:54:01 -0300
Message-ID: <55F17D69.2050404@gmail.com>
References: <27f20cc781cac28bc2ce7229719748a2f6824bd8.1441827818.git.marcelo.leitner@gmail.com>
 <20150909.171600.1487892650387164045.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, vyasevich@gmail.com, nhorman@tuxdriver.com,
	linux-sctp@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f46.google.com ([209.85.192.46]:33556 "EHLO
	mail-qg0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751263AbbIJMyK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Sep 2015 08:54:10 -0400
In-Reply-To: <20150909.171600.1487892650387164045.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Em 09-09-2015 21:16, David Miller escreveu:
> From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
> Date: Wed,  9 Sep 2015 17:03:01 -0300
>
>> So the fix then is to invert the initialization order inside
>> register_pernet_subsys() so that the control socket is created by last
>> and also block socket creation if netns initialization wasn't yet
>> performed.
>
> If we really need to we could make ->create() fail with -EAFNOSUPPORT
> if kern==1 until the protocol is fully setup.
>
> Or, instead of failing, we could make such ->create() calls block
> until the control sock init is complete or fails.

I guess I should have written that paragraph in another order, perhaps like:
So the fix then is to deny any sctp socket creation until netns 
initialization is sufficiently done. And due to that, we have to 
initialize the control socket as last step in netns initialization, as 
now it can't be created earlier anymore.

Is it clearer on the intention?

And my emphasis on userspace sockets was to highlight that a random user 
could trigger it, but yes both users are affected by the issue.

Strictly speaking, we would have to block ->create() not until the 
control socket init is done but until the protocol is fully loaded. Such 
condition, with this patch, is after net->sctp.auto_asconf_splist is 
initialized. But for blocking until instead of just denying, we would 
need some other mechanism.

It would be better from the (sctp) user point of view but then such 
solution may better belong to another layer instead and protect all 
protocols at once. (I checked and couldn't find other protocols at risk 
like sctp)

> We have actually several visibility issues wrt. control sockets on
> protocol init, in general.
>
> For example, such control sockets can briefly be hashed and visible
> to socket dumps and packet input.
>
> A lot of really tricky issues involved here.

Agreed, but does these still apply after explaining that paragraph/the 
solution? I had no intention on visiting these issues with this patch, 
they are left unchanged, but I can if a better solution for the original 
issue calls for it.

   Marcelo
