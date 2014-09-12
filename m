From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH net-next v4 2/9] net: filter: keep original BPF program
 around
Date: Fri, 12 Sep 2014 08:09:31 +0200
Message-ID: <54128E1B.7020407@redhat.com>
References: <1396029506-16776-1-git-send-email-dborkman@redhat.com>  <1396029506-16776-3-git-send-email-dborkman@redhat.com> <1410492457.7106.72.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, ast@plumgrid.com, netdev@vger.kernel.org,
	Pavel Emelyanov <xemul@parallels.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:34550 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751141AbaILGJo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 12 Sep 2014 02:09:44 -0400
In-Reply-To: <1410492457.7106.72.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/12/2014 05:27 AM, Eric Dumazet wrote:
> From: Eric Dumazet <edumazet@google.com>
>
> On Fri, 2014-03-28 at 18:58 +0100, Daniel Borkmann wrote:
>> In order to open up the possibility to internally transform a BPF program
>> into an alternative and possibly non-trivial reversible representation, we
>> need to keep the original BPF program around, so that it can be passed back
>> to user space w/o the need of a complex decoder.
>>
>> The reason for that use case resides in commit a8fc92778080 ("sk-filter:
>> Add ability to get socket filter program (v2)"), that is, the ability
>> to retrieve the currently attached BPF filter from a given socket used
>> mainly by the checkpoint-restore project, for example.
>>
>> Therefore, we add two helpers sk_{store,release}_orig_filter for taking
>> care of that. In the sk_unattached_filter_create() case, there's no such
>> possibility/requirement to retrieve a loaded BPF program. Therefore, we
>> can spare us the work in that case.
>>
>> This approach will simplify and slightly speed up both, sk_get_filter()
>> and sock_diag_put_filterinfo() handlers as we won't need to successively
>> decode filters anymore through sk_decode_filter(). As we still need
>> sk_decode_filter() later on, we're keeping it around.
>>
>> Joint work with Alexei Starovoitov.
>>
>> Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>
>> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
>> Cc: Pavel Emelyanov <xemul@parallels.com>
>> ---
>
> Note that this patch added a possible use after free.
>
> Following patch should be sent to stable trees only, as 3.17+
> incidentally fixed this with
> commit 278571baca2aecf5fb5cb5c8b002dbfa0a6c524c
>      net: filter: simplify socket charging
>
> [PATCH] net: filter: fix possible use after free
>
> If kmemdup() fails, we free fp->orig_prog and return -ENOMEM
>
> sk_attach_filter()
>   -> sk_filter_uncharge(sk, fp)
>    -> sk_filter_release(fp)
>     -> call_rcu(&fp->rcu, sk_filter_release_rcu)
>      -> sk_filter_release_rcu()
>       -> sk_release_orig_filter()
>          fprog = fp->orig_prog; // not NULL, but points to freed memory
> 	  kfree(fprog->filter); // use after free, potential corruption
>            kfree(fprog); // double free or corruption
>
> Note: This was fixed in 3.17+ with commit 278571baca2a
> ("net: filter: simplify socket charging")
>
> Found by AddressSanitizer
>
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Fixes: a3ea269b8bcdb ("net: filter: keep original BPF program around")

Thanks Eric!

Acked-by: Daniel Borkmann <dborkman@redhat.com>
