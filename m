From: Cong Wang <cwang@twopensource.com>
Subject: Re: [PATCH net] net: sched: fix call_rcu() race on classifier module unloads
Date: Wed, 20 May 2015 11:30:39 -0700
Message-ID: <CAHA+R7Nx3P4i8=EQ_6nGvi5MhEXxMUvY=nBYf0vuKcOxAud2kg@mail.gmail.com>
References: <9f44c4c5d2ad81e7d7ef828b9e60bd308fc7caf9.1432134471.git.daniel@iogearbox.net>
	<CAHA+R7PMC7Zi0gqAUFzfWfJ_CLTmNYqjSgAQH2kKVONEy_3gZQ@mail.gmail.com>
	<555CCE89.10503@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>, subramanian.vijay@gmail.com,
	netdev <netdev@vger.kernel.org>,
	John Fastabend <john.r.fastabend@intel.com>,
	Eric Dumazet <edumazet@google.com>,
	Thomas Graf <tgraf@suug.ch>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Alexei Starovoitov <ast@plumgrid.com>
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f169.google.com ([209.85.212.169]:36309 "EHLO
	mail-wi0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753783AbbETSak (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 May 2015 14:30:40 -0400
Received: by wizk4 with SMTP id k4so165028984wiz.1
        for <netdev@vger.kernel.org>; Wed, 20 May 2015 11:30:39 -0700 (PDT)
In-Reply-To: <555CCE89.10503@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, May 20, 2015 at 11:12 AM, Daniel Borkmann <daniel@iogearbox.net> wrote:
> On 05/20/2015 07:38 PM, Cong Wang wrote:
> ...
>>
>> Why synchronize_rcu() even matters here? It waits for
>> readers, not for RCU callbacks.
>
>
> Hm, I am mentioning it here as it was related to 78fd1d0ab072
> as explained in the commit message.


Move it to the right place or remove it, it is only confusing.


>
>>> Since we came here via unregister_tcf_proto_ops(), there
>>> are no users of a given classifier anymore. Further nested
>>> call_rcu()s pointing into the module space are not being
>>> done anywhere.
>>
>>
>> This doesn't look like the best way to fix it, since calling
>> call_rcu() is tc filter specific, so why not just move the
>> rcu_barrier() to each of the ->destroy() implementation?
>> Let each filter handle its own implementation bug.
>
>
> Effectively, every in-tree classifier (rsvp is the only exception)
> is making use of call_rcu(). Moreover, moving this into every
> ->destroy() handler would also be unnecessary overhead, imho, as
> this is only relevant when we actually _unload_ a module.

Well, ->destroy() is not a fast path, it holds rtnl lock, we don't want to
lose readability for little performance gain. The code is hard to
understand even with a comment there, move it to tcf_destroy() so
that we probably don't even need a comment there.
