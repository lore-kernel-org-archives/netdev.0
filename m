From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH net-next] net: filter: cleanup invocation of internal
 BPF
Date: Tue, 20 May 2014 10:57:13 +0200
Message-ID: <537B18E9.8040002@redhat.com>
References: <1400536574-4485-1-git-send-email-ast@plumgrid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Kees Cook <keescook@chromium.org>, netdev@vger.kernel.org
To: Alexei Starovoitov <ast@plumgrid.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:59631 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750706AbaETI5U (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 May 2014 04:57:20 -0400
In-Reply-To: <1400536574-4485-1-git-send-email-ast@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/19/2014 11:56 PM, Alexei Starovoitov wrote:
> Kernel API for classic BPF socket filters is:
>
> sk_unattached_filter_create() - validate classic BPF, convert, JIT
> SK_RUN_FILTER() - run it
> sk_unattached_filter_destroy() - destroy socket filter
>
> Cleanup internal BPF kernel API as following:
>
> sk_filter_select_runtime() - final step of internal BPF creation.
>    Try to JIT internal BPF program, if JIT is not available select interpreter
> SK_RUN_FILTER() - run it
> sk_filter_free() - free internal BPF program
>
> Disallow direct calls to BPF interpreter. Execution of the BPF program should
> be done with SK_RUN_FILTER() macro.
>
> Example of internal BPF create, run, destroy:
>
>    struct sk_filter *fp;
>
>    fp = kzalloc(sk_filter_size(prog_len), GFP_KERNEL);
>    memcpy(fp->insni, prog, prog_len * sizeof(fp->insni[0]));
>    fp->len = prog_len;
>
>    sk_filter_select_runtime(fp);
>
>    SK_RUN_FILTER(fp, ctx);
>
>    sk_filter_free(fp);
>
> Sockets, seccomp, testsuite, tracing are using different ways to populate
> sk_filter, so first steps of program creation are not common.
>
> Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>

I think it makes sense and we can avoid directly exposing the symbol
__sk_run_filter() resp. its aliases.

Acked-by: Daniel Borkmann <dborkman@redhat.com>
