From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [Patch net] act_mirred: avoid calling tcf_hash_release() when
 binding
Date: Fri, 31 Jul 2015 12:06:48 +0200
Message-ID: <55BB48B8.6060201@iogearbox.net>
References: <1438301541-26192-1-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, Jamal Hadi Salim <jhs@mojatatu.com>,
	Cong Wang <cwang@twopensource.com>
To: Cong Wang <xiyou.wangcong@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:46709 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750970AbbGaKGw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 Jul 2015 06:06:52 -0400
In-Reply-To: <1438301541-26192-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/31/2015 02:12 AM, Cong Wang wrote:
> When we share an action within a filter, the bind refcnt
> should increase, therefore we should not call tcf_hash_release().
>
> Cc: Jamal Hadi Salim <jhs@mojatatu.com>
> Cc: Daniel Borkmann <daniel@iogearbox.net>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
> Signed-off-by: Cong Wang <cwang@twopensource.com>
> ---
>   net/sched/act_mirred.c | 2 ++
>   1 file changed, 2 insertions(+)
>
> diff --git a/net/sched/act_mirred.c b/net/sched/act_mirred.c
> index a42a3b2..2685450 100644
> --- a/net/sched/act_mirred.c
> +++ b/net/sched/act_mirred.c
> @@ -98,6 +98,8 @@ static int tcf_mirred_init(struct net *net, struct nlattr *nla,
>   			return ret;
>   		ret = ACT_P_CREATED;
>   	} else {
> +		if (bind)
> +			return 0;
>   		if (!ovr) {
>   			tcf_hash_release(a, bind);
>   			return -EEXIST;
>

Did you test all variants on this?

I.e. what happens when you replace an existing one, I think the
refcnt should also be dropped here. It looks like we only drop
it, in case we tried to add an action to an already existing index ...

	[...]
	} else {
		if (bind)
			return 0;
		tcf_hash_release(a, bind);
		if (!ovr)
			return -EEXIST;
	}
	[...]

Thanks,
Daniel
