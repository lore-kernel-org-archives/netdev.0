From: Glauber Costa <glommer@parallels.com>
Subject: Re: [PATCH] memcg/tcp: fix warning caused b res->usage go to negative.
Date: Mon, 9 Apr 2012 23:51:14 -0300
Message-ID: <4F83A022.1000701@parallels.com>
References: <4F7408B7.9090706@jp.fujitsu.com> <4F740AEF.7090900@jp.fujitsu.com> <4F742983.1080402@parallels.com> <4F750FE8.2030800@jp.fujitsu.com> <4F7F1091.9040204@parallels.com> <4F839CF1.5050104@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, David Miller <davem@davemloft.net>,
	Andrew Morton <akpm@linux-foundation.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.parallels.com ([64.131.90.16]:45077 "EHLO mx2.parallels.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754091Ab2DJCwx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 9 Apr 2012 22:52:53 -0400
In-Reply-To: <4F839CF1.5050104@jp.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/09/2012 11:37 PM, KAMEZAWA Hiroyuki wrote:
> Hm. What happens in following sequence ?
> 
>    1. a memcg is created
>    2. put a task into the memcg, start tcp steam
>    3. set tcp memory limit
> 
> The resource used between 2 and 3 will cause the problem finally.

I don't get it. if a task is in memcg, but no limit is set,
that socket will be assigned null memcg, and will stay like that
forever. Only new sockets will have the new memcg pointer.

And previously, we could have the memcg pointer alive, but the jump
labels to be disabled. With the patch I posted, this can't happen
anymore, since the jump labels are guaranteed to live throughout the
whole socket life.

> Then, Dave's request
> ==
> You must either:
> 
> 1) Integrate the socket's existing usage when the limit is set.
> 
> 2) Avoid accounting completely for a socket that started before
>     the limit was set.
> ==
> are not satisfied. So, we need to have a state per sockets, it's accounted
> or not. I'll look into this problem again, today.
> 

Of course they are.

Every socket created before we set the limit is not accounted.
This is 2) that Dave mentioned, and it was *always* this way.

The problem here was the opposite: You could disable the jump labels
with sockets still in flight, because we were disabling it based on
the limit being set back to unlimited.

What this patch does, is defer that until the last socket limited dies.
