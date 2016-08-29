From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH v3 4/6] net: filter: run cgroup eBPF ingress programs
Date: Tue, 30 Aug 2016 01:15:16 +0200
Message-ID: <57C4C204.1010603@iogearbox.net>
References: <1472241532-11682-1-git-send-email-daniel@zonque.org> <1472241532-11682-5-git-send-email-daniel@zonque.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, kafai@fb.com, fw@strlen.de,
        pablo@netfilter.org, harald@redhat.com, netdev@vger.kernel.org,
        sargun@sargun.me
To: Daniel Mack <daniel@zonque.org>, htejun@fb.com, ast@fb.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:59578 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753695AbcH2XP1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 29 Aug 2016 19:15:27 -0400
In-Reply-To: <1472241532-11682-5-git-send-email-daniel@zonque.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/26/2016 09:58 PM, Daniel Mack wrote:
> If the cgroup associated with the receiving socket has an eBPF
> programs installed, run them from sk_filter_trim_cap().
>
> eBPF programs used in this context are expected to either return 1 to
> let the packet pass, or != 1 to drop them. The programs have access to
> the full skb, including the MAC headers.
>
> Note that cgroup_bpf_run_filter() is stubbed out as static inline nop
> for !CONFIG_CGROUP_BPF, and is otherwise guarded by a static key if
> the feature is unused.
>
> Signed-off-by: Daniel Mack <daniel@zonque.org>
> ---
>   net/core/filter.c | 5 +++++
>   1 file changed, 5 insertions(+)
>
> diff --git a/net/core/filter.c b/net/core/filter.c
> index bc04e5c..163f75b 100644
> --- a/net/core/filter.c
> +++ b/net/core/filter.c
> @@ -78,6 +78,11 @@ int sk_filter_trim_cap(struct sock *sk, struct sk_buff *skb, unsigned int cap)
>   	if (skb_pfmemalloc(skb) && !sock_flag(sk, SOCK_MEMALLOC))
>   		return -ENOMEM;
>
> +	err = cgroup_bpf_run_filter(sk, skb,
> +				    BPF_ATTACH_TYPE_CGROUP_INET_INGRESS);

Maybe just BPF_CGROUP_INET_{IN,E}GRESS (seems less cluttered, and we know
these were set via bpf(2) as attach_type anyway)?

> +	if (err)
> +		return err;
> +
>   	err = security_sock_rcv_skb(sk, skb);
>   	if (err)
>   		return err;
>
