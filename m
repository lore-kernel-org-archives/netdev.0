From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH] memcg/tcp: fix warning caused b res->usage go to negative.
Date: Tue, 10 Apr 2012 11:37:37 +0900
Message-ID: <4F839CF1.5050104@jp.fujitsu.com>
References: <4F7408B7.9090706@jp.fujitsu.com> <4F740AEF.7090900@jp.fujitsu.com> <4F742983.1080402@parallels.com> <4F750FE8.2030800@jp.fujitsu.com> <4F7F1091.9040204@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	Andrew Morton <akpm@linux-foundation.org>
To: Glauber Costa <glommer@parallels.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fgwmail5.fujitsu.co.jp ([192.51.44.35]:34110 "EHLO
	fgwmail5.fujitsu.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754695Ab2DJCjz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Apr 2012 22:39:55 -0400
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 57DA43EE0C5
	for <netdev@vger.kernel.org>; Tue, 10 Apr 2012 11:39:53 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id E1A9B45DE52
	for <netdev@vger.kernel.org>; Tue, 10 Apr 2012 11:39:52 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id C764945DE54
	for <netdev@vger.kernel.org>; Tue, 10 Apr 2012 11:39:52 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id B826A1DB8038
	for <netdev@vger.kernel.org>; Tue, 10 Apr 2012 11:39:52 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.240.81.145])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 151001DB802C
	for <netdev@vger.kernel.org>; Tue, 10 Apr 2012 11:39:52 +0900 (JST)
In-Reply-To: <4F7F1091.9040204@parallels.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

(2012/04/07 0:49), Glauber Costa wrote:

> On 03/30/2012 05:44 AM, KAMEZAWA Hiroyuki wrote:
>> Maybe what we can do before lsf/mm summit will be this (avoid warning.)
>> This patch is onto linus's git tree. Patch description is updated.
>>
>> Thanks.
>> -Kame
>> ==
>>  From 4ab80f84bbcb02a790342426c1de84aeb17fcbe9 Mon Sep 17 00:00:00 2001
>> From: KAMEZAWA Hiroyuki<kamezawa.hiroyu@jp.fujitsu.com>
>> Date: Thu, 29 Mar 2012 14:59:04 +0900
>> Subject: [PATCH] memcg/tcp: fix warning caused b res->usage go to negative.
>>
>> tcp memcontrol starts accouting after res->limit is set. So, if a sockets
>> starts before setting res->limit, there are already used resource.
>> At setting res->limit, accounting starts. The resource will be uncharged
>> and make res_counter below 0 because they are not charged.
>> This causes warning.
>>
> 
> Kame,
> 
> Please test the following patch and see if it fixes your problems (I
> tested locally, and it triggers me no warnings running the test script
> you provided + an inbound scp -r copy of an iso directory from a remote
> machine)
> 
> When you are reviewing, keep in mind that we're likely to have the same
> problems with slab jump labels - since the slab pages will outlive the
> cgroup as well, and it might be worthy to keep this in mind, and provide
> a central point for the jump labels to be set of on cgroup destruction.
> 


Hm. What happens in following sequence ?

  1. a memcg is created
  2. put a task into the memcg, start tcp steam
  3. set tcp memory limit

The resource used between 2 and 3 will cause the problem finally.

Then, Dave's request
==
You must either:

1) Integrate the socket's existing usage when the limit is set.

2) Avoid accounting completely for a socket that started before
   the limit was set.
==
are not satisfied. So, we need to have a state per sockets, it's accounted
or not. I'll look into this problem again, today.


Thanks,
-Kame
