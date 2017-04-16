From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH net-next 1/1] net sched actions: add time filter for
 action dumping
Date: Sun, 16 Apr 2017 10:00:39 -0400
Message-ID: <d90c7796-cba2-cebb-3fef-93f56b534997@mojatatu.com>
References: <1492350973-6846-1-git-send-email-jhs@emojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, xiyou.wangcong@gmail.com,
        eric.dumazet@gmail.com, jiri@resnulli.us
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f67.google.com ([209.85.214.67]:33003 "EHLO
        mail-it0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755381AbdDPOAr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 16 Apr 2017 10:00:47 -0400
Received: by mail-it0-f67.google.com with SMTP id z67so2967535itb.0
        for <netdev@vger.kernel.org>; Sun, 16 Apr 2017 07:00:46 -0700 (PDT)
In-Reply-To: <1492350973-6846-1-git-send-email-jhs@emojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


I should say this is dependent on the earlier patch I posted.
Made them separate because I think this one in particular
may generate some discussions.

cheers,
jamal

On 17-04-16 09:56 AM, Jamal Hadi Salim wrote:
> From: Jamal Hadi Salim <jhs@mojatatu.com>
>
> This adds support for filtering based on time since last used.
> When we are dumping a large number of actions it is useful to
> have the option of filtering based on when the action was last
> used to reduce the amount of data crossing to user space.
>
> With this patch the user space app sets the FILTER_ACCESS_TIME flag
> (in the pad1 flags area) and the "time of interest since now" in seconds
> when the action was last used (in the pad2 area).  The kernel converts
> this to jiffies and does the filtering comparison matching entries that
> have seen activity since then and returns them to user space.
> Old kernels and old tc continue to work in legacy mode.
>
> Some example (we have 400 actions bound to 400 filters); at installation
> time using  hacked tc which sets the time of interest to 120 seconds:
>
> prompt$ hackedtc actions ls action gact | grep index | wc -l
> 400
>
> go get some coffee and  wait for > 120 seconds and try again:
>
> prompt$ hackedtc actions ls action gact | grep index | wc -l
> 0
>
> Lets see a filter bound to one of these actions:
> ..
> filter pref 10 u32
> filter pref 10 u32 fh 800: ht divisor 1
> filter pref 10 u32 fh 800::800 order 2048 key ht 800 bkt 0 flowid 1:10  (rule hit 2 success 1)
>   match 7f000002/ffffffff at 12 (success 1 )
> 	action order 1: gact action pass
> 	 random type none pass val 0
> 	 index 23 ref 2 bind 1 installed 1145 sec used 802 sec
>  	Action statistics:
> 	Sent 84 bytes 1 pkt (dropped 0, overlimits 0 requeues 0)
> 	backlog 0b 0p requeues 0
> ....
>
> Now lets ping -c 1 127.0.0.2, then run the actions again:
>
> prompt$ hackedtc actions ls action gact | grep index | wc -l
> 1
>
> More details please:
>
> prompt$ hackedtc -s actions ls action gact
> total acts 1 flags 0x3
>
> 	action order 0: gact action pass
> 	 random type none pass val 0
> 	 index 23 ref 2 bind 1 installed 1270 sec used 30 sec
>  	Action statistics:
> 	Sent 168 bytes 2 pkt (dropped 0, overlimits 0 requeues 0)
> 	backlog 0b 0p requeues 0
>
> And the filter?
>
> filter pref 10 u32
> filter pref 10 u32 fh 800: ht divisor 1
> filter pref 10 u32 fh 800::800 order 2048 key ht 800 bkt 0 flowid 1:10  (rule hit 4 success 2)
>   match 7f000002/ffffffff at 12 (success 2 )
> 	action order 1: gact action pass
> 	 random type none pass val 0
> 	 index 23 ref 2 bind 1 installed 1324 sec used 84 sec
>  	Action statistics:
> 	Sent 168 bytes 2 pkt (dropped 0, overlimits 0 requeues 0)
> 	backlog 0b 0p requeues 0
>
> Signed-off-by: Jamal Hadi Salim <jhs@mojatatu.com>
> ---
>  net/sched/act_api.c | 24 ++++++++++++++++++++++--
>  1 file changed, 22 insertions(+), 2 deletions(-)
>
> diff --git a/net/sched/act_api.c b/net/sched/act_api.c
> index 90cc774..4dd55f2 100644
> --- a/net/sched/act_api.c
> +++ b/net/sched/act_api.c
> @@ -84,11 +84,13 @@ static int tcf_dump_walker(struct tcf_hashinfo *hinfo, struct sk_buff *skb,
>  {
>  	int err = 0, index = -1, i = 0, s_i = 0, n_i = 0;
>  	unsigned short act_flags = cb->args[2];
> +	unsigned long jiffy_filter = cb->args[3];
> +
>  	struct nlattr *nest;
>
>  	spin_lock_bh(&hinfo->lock);
>
> -	s_i = cb->args[0];
> +	s_i = cb->args[4];
>
>  	for (i = 0; i < (hinfo->hmask + 1); i++) {
>  		struct hlist_head *head;
> @@ -101,6 +103,12 @@ static int tcf_dump_walker(struct tcf_hashinfo *hinfo, struct sk_buff *skb,
>  			if (index < s_i)
>  				continue;
>
> +			if (jiffy_filter &&
> +			    time_after(jiffy_filter,
> +				       (unsigned long)p->tcfa_tm.lastuse)) {
> +				continue;
> +			}
> +
>  			nest = nla_nest_start(skb, n_i);
>  			if (nest == NULL)
>  				goto nla_put_failure;
> @@ -118,6 +126,8 @@ static int tcf_dump_walker(struct tcf_hashinfo *hinfo, struct sk_buff *skb,
>  		}
>  	}
>  done:
> +	if (index > 0)
> +		cb->args[4] = index + 1;
>  	spin_unlock_bh(&hinfo->lock);
>  	if (n_i) {
>  		cb->args[0] += n_i;
> @@ -1086,8 +1096,10 @@ static int tc_dump_action(struct sk_buff *skb, struct netlink_callback *cb)
>  	struct tc_action_ops *a_o;
>  	int ret = 0;
>  	struct tcamsg *t = (struct tcamsg *) nlmsg_data(cb->nlh);
> -	unsigned char act_flags = t->tca__pad1;
>  	struct nlattr *kind = find_dump_kind(cb->nlh);
> +	unsigned char act_flags = t->tca__pad1;
> +	unsigned short secs = t->tca__pad2;
> +	unsigned long jiffy_wanted = 0;
>
>  	if (kind == NULL) {
>  		pr_info("tc_dump_action: action bad kind\n");
> @@ -1103,7 +1115,15 @@ static int tc_dump_action(struct sk_buff *skb, struct netlink_callback *cb)
>  	if (!nlh)
>  		goto out_module_put;
>
> +	if (act_flags & ACT_FILTER_TIME_ACCESS) {
> +		const unsigned int m = secs * 1000L;
> +		unsigned long jiffy_msecs = msecs_to_jiffies(m);
> +
> +		jiffy_wanted = jiffies - jiffy_msecs;
> +	}
> +
>  	cb->args[2] = act_flags;
> +	cb->args[3] = jiffy_wanted;
>
>  	t = nlmsg_data(nlh);
>  	t->tca_family = AF_UNSPEC;
>
