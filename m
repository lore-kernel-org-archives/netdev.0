From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net-next] bpf: add missing rcu protection when releasing
 programs from prog_array
Date: Fri, 29 May 2015 11:10:52 +0200
Message-ID: <55682D1C.3070607@iogearbox.net>
References: <1432866362-8154-1-git-send-email-ast@plumgrid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Michael Holzheu <holzheu@linux.vnet.ibm.com>,
	Martin Schwidefsky <schwidefsky@de.ibm.com>,
	netdev@vger.kernel.org
To: Alexei Starovoitov <ast@plumgrid.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:37922 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755558AbbE2JLH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 May 2015 05:11:07 -0400
In-Reply-To: <1432866362-8154-1-git-send-email-ast@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/29/2015 04:26 AM, Alexei Starovoitov wrote:
> Normally the program attachment place (like sockets, qdiscs) takes
> care of rcu protection and calls bpf_prog_put() after a grace period.
> The programs stored inside prog_array may not be attached anywhere,
> so prog_array needs to take care of preserving rcu protection.
> Otherwise bpf_tail_call() will race with bpf_prog_put().
> To solve that introduce bpf_prog_put_rcu() helper function and use
> it in 3 places where unattached program can decrement refcnt:
> closing program fd, deleting/replacing program in prog_array.
>
> Fixes: 04fd61ab36ec ("bpf: allow bpf programs to tail-call other bpf programs")
> Reported-by: Martin Schwidefsky <schwidefsky@de.ibm.com>
> Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>

Fix looks correct, so:

Acked-by: Daniel Borkmann <daniel@iogearbox.net>

[...]
> diff --git a/kernel/bpf/syscall.c b/kernel/bpf/syscall.c
> index 98a69bd83069..a1b14d197a4f 100644
> --- a/kernel/bpf/syscall.c
> +++ b/kernel/bpf/syscall.c
> @@ -432,6 +432,23 @@ static void free_used_maps(struct bpf_prog_aux *aux)
>   	kfree(aux->used_maps);
>   }
>
> +static void __prog_put_rcu(struct rcu_head *rcu)
> +{
> +	struct bpf_prog_aux *aux = container_of(rcu, struct bpf_prog_aux, rcu);
> +
> +	free_used_maps(aux);
> +	bpf_prog_free(aux->prog);

Not sure if it's worth it to move these two into a common helper shared
with bpf_prog_put()? Probably only in case that code should get further
extended.

> +}
> +
> +/* version of bpf_prog_put() that is called after a grace period */

Note that this callback to complete could potentially also last longer
than a grace period. Probably depends on the reader how to interpret
the comment, but the code itself would have been already self-documenting. ;)

> +void bpf_prog_put_rcu(struct bpf_prog *prog)
> +{
> +	if (atomic_dec_and_test(&prog->aux->refcnt)) {
> +		prog->aux->prog = prog;
> +		call_rcu(&prog->aux->rcu, __prog_put_rcu);
> +	}
> +}
> +
>   void bpf_prog_put(struct bpf_prog *prog)
>   {
>   	if (atomic_dec_and_test(&prog->aux->refcnt)) {
> @@ -445,7 +462,7 @@ static int bpf_prog_release(struct inode *inode, struct file *filp)
>   {
