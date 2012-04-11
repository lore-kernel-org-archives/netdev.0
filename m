From: Glauber Costa <glommer@parallels.com>
Subject: Re: [PATCH] memcg/tcp: fix warning caused b res->usage go to negative.
Date: Tue, 10 Apr 2012 23:22:08 -0300
Message-ID: <4F84EAD0.7000608@parallels.com>
References: <4F7408B7.9090706@jp.fujitsu.com> <4F740AEF.7090900@jp.fujitsu.com> <4F742983.1080402@parallels.com> <4F750FE8.2030800@jp.fujitsu.com> <4F7F1091.9040204@parallels.com> <4F839CF1.5050104@jp.fujitsu.com> <4F83A022.1000701@parallels.com> <4F83A29D.1060402@parallels.com> <4F83B3FD.4010107@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, David Miller <davem@davemloft.net>,
	"Andrew Morton" <akpm@linux-foundation.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.parallels.com ([64.131.90.16]:36822 "EHLO mx2.parallels.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759977Ab2DKCXx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Apr 2012 22:23:53 -0400
In-Reply-To: <4F83B3FD.4010107@jp.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> 
> The problem is that jump_label updating is not atomic_ops.

That's indeed really bad.
You seem to be right about that... I wonder, however, if we should
prevent anything to run in any cpu during the jump_label update?
The update can be slow, sure, but it is not expected to be frequent...

> I'm _not_ sure the update order of the jump_label in sock_update_memcg()
> and other jump instructions inserted at accounting.

Any ordering assumptions here would be extremely fragile, even if we
could make one.

> For example, if the jump instruction in sock_update_memcg() is updated 1st
> and others are updated later, it's unclear whether sockets which has _valid_
> sock->sk_cgrp will be accounted or not because accounting jump instruction
> may not be updated yet.
> 
> Hopefully, label in sock_update_memcg should be updated last...
> 
> Hm. If I do, I'll add one more key as:
> 
> atomic_t	sock_should_memcg_aware;
> 
> And update 2 keys in following order.
> 
> At enable
> 	static_key_slow_inc(&memcg_socket_limit_enabled)
> 	atomic_inc(&sock_should_memcg_aware);
> 
> At disable
> 	atomic_dec(&sock_should_memcg_aware);
> 	static_key_slow_dec(&memcg_socket_limit_enabled)
> 
> And
> ==
> void sock_update_memcg(struct sock *sk)
> {
>          if (atomic_read(&sock_should_memcg_aware)) {
> 
> ==

Problem here is that having an atomic variable here defeats a bit the
purpose of the jump labels.

If it is just in the update path, it is not *that* bad.

But unless we go fix the jump labels to prevent such thing from
happening, maybe it would be better to have two jump labels here?

One for the writer, that is updated last, and one from the readers.
This way we can force the ordering the way we want.
