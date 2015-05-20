From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net] net: sched: fix call_rcu() race on classifier module
 unloads
Date: Wed, 20 May 2015 20:12:25 +0200
Message-ID: <555CCE89.10503@iogearbox.net>
References: <9f44c4c5d2ad81e7d7ef828b9e60bd308fc7caf9.1432134471.git.daniel@iogearbox.net> <CAHA+R7PMC7Zi0gqAUFzfWfJ_CLTmNYqjSgAQH2kKVONEy_3gZQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, subramanian.vijay@gmail.com,
	netdev <netdev@vger.kernel.org>,
	John Fastabend <john.r.fastabend@intel.com>,
	Eric Dumazet <edumazet@google.com>,
	Thomas Graf <tgraf@suug.ch>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Alexei Starovoitov <ast@plumgrid.com>
To: Cong Wang <cwang@twopensource.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:54352 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754168AbbETSMa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 May 2015 14:12:30 -0400
In-Reply-To: <CAHA+R7PMC7Zi0gqAUFzfWfJ_CLTmNYqjSgAQH2kKVONEy_3gZQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/20/2015 07:38 PM, Cong Wang wrote:
...
> Why synchronize_rcu() even matters here? It waits for
> readers, not for RCU callbacks.

Hm, I am mentioning it here as it was related to 78fd1d0ab072
as explained in the commit message.

>> Since we came here via unregister_tcf_proto_ops(), there
>> are no users of a given classifier anymore. Further nested
>> call_rcu()s pointing into the module space are not being
>> done anywhere.
>
> This doesn't look like the best way to fix it, since calling
> call_rcu() is tc filter specific, so why not just move the
> rcu_barrier() to each of the ->destroy() implementation?
> Let each filter handle its own implementation bug.

Effectively, every in-tree classifier (rsvp is the only exception)
is making use of call_rcu(). Moreover, moving this into every
->destroy() handler would also be unnecessary overhead, imho, as
this is only relevant when we actually _unload_ a module.
