From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [PATCH net 1/3] sched: cls_bpf: fix panic on filter replace
Date: Fri, 17 Jul 2015 14:05:09 -0700
Message-ID: <55A96E05.2090002@gmail.com>
References: <cover.1437163466.git.daniel@iogearbox.net> <094e34b7e8d45a323c5cf18a366665654b3f3e45.1437163466.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: ast@plumgrid.com, jiri@resnulli.us, jhs@mojatatu.com,
	edumazet@google.com, netdev@vger.kernel.org
To: Daniel Borkmann <daniel@iogearbox.net>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f48.google.com ([209.85.218.48]:33270 "EHLO
	mail-oi0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751964AbbGQVEv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Jul 2015 17:04:51 -0400
Received: by oige126 with SMTP id e126so78109045oig.0
        for <netdev@vger.kernel.org>; Fri, 17 Jul 2015 14:04:51 -0700 (PDT)
In-Reply-To: <094e34b7e8d45a323c5cf18a366665654b3f3e45.1437163466.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 15-07-17 01:38 PM, Daniel Borkmann wrote:
> The following test case causes a NULL pointer dereference in cls_bpf:
> 
>   FOO="1,6 0 0 4294967295,"
>   tc filter add dev foo parent 1: bpf bytecode "$FOO" flowid 1:1 action ok
>   tc filter replace dev foo parent 1: pref 49152 handle 0x1 \
>             bpf bytecode "$FOO" flowid 1:1 action drop
> 
> The problem is that commit 1f947bf151e9 ("net: sched: rcu'ify cls_bpf")
> accidentally swapped the arguments of list_replace_rcu(), the old
> element needs to be the first argument and the new element the second.
> 
> Fixes: 1f947bf151e9 ("net: sched: rcu'ify cls_bpf")
> Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
> ---

Thanks Daniel. Apparently I got this right in cls_basic but botched it
here and in cls_flow.

FWIW,

Acked-by: John Fastabend <john.r.fastabend@intel.com>

>  net/sched/cls_bpf.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/net/sched/cls_bpf.c b/net/sched/cls_bpf.c
> index c79ecfd..e5168f8 100644
> --- a/net/sched/cls_bpf.c
> +++ b/net/sched/cls_bpf.c
> @@ -378,7 +378,7 @@ static int cls_bpf_change(struct net *net, struct sk_buff *in_skb,
>  		goto errout;
>  
>  	if (oldprog) {
> -		list_replace_rcu(&prog->link, &oldprog->link);
> +		list_replace_rcu(&oldprog->link, &prog->link);
>  		tcf_unbind_filter(tp, &oldprog->res);
>  		call_rcu(&oldprog->rcu, __cls_bpf_delete_prog);
>  	} else {
> 
