From: Yotam Gigi <yotamg@mellanox.com>
Subject: Re: [PATCH net] net/sched: cls_matchall: fix crash when used with
 classful qdisc
Date: Sun, 17 Sep 2017 10:03:59 +0300
Message-ID: <0fe61e2a-24d1-5412-382f-2777ce219166@mellanox.com>
References: <b930159de5531a4d216a1cd2c2ef03aa41f421f9.1505562794.git.dcaratti@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Davide Caratti <dcaratti@redhat.com>,
        Jiri Pirko <jiri@resnulli.us>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        Jiri Benc <jbenc@redhat.com>,
        "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-db5eur01on0085.outbound.protection.outlook.com ([104.47.2.85]:36640
        "EHLO EUR01-DB5-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1750749AbdIQHEI (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 17 Sep 2017 03:04:08 -0400
In-Reply-To: <b930159de5531a4d216a1cd2c2ef03aa41f421f9.1505562794.git.dcaratti@redhat.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/16/2017 03:02 PM, Davide Caratti wrote:
> this script, edited from Linux Advanced Routing and Traffic Control guide
>
> tc q a dev en0 root handle 1: htb default a
> tc c a dev en0 parent 1:  classid 1:1 htb rate 6mbit burst 15k
> tc c a dev en0 parent 1:1 classid 1:a htb rate 5mbit ceil 6mbit burst 15k
> tc c a dev en0 parent 1:1 classid 1:b htb rate 1mbit ceil 6mbit burst 15k
> tc f a dev en0 parent 1:0 prio 1 $clsname $clsargs classid 1:b
> ping $address -c1
> tc -s c s dev en0
>
> classifies traffic to 1:b or 1:a, depending on whether the packet matches
> or not the pattern $clsargs of filter $clsname. However, when $clsname is
> 'matchall', a systematic crash can be observed in htb_classify(). HTB and
> classful qdiscs don't assign initial value to struct tcf_result, but then
> they expect it to contain valid values after filters have been run. Thus,
> current 'matchall' ignores the TCA_MATCHALL_CLASSID attribute, configured
> by user, and makes HTB (and classful qdiscs) dereference random pointers.
>
> By assigning head->res to *res in mall_classify(), before the actions are
> invoked, we fix this crash and enable TCA_MATCHALL_CLASSID functionality,
> that had no effect on 'matchall' classifier since its first introduction.
>
> BugLink: https://emea01.safelinks.protection.outlook.com/?url=https%3A%2F%2Fbugzilla.redhat.com%2Fshow_bug.cgi%3Fid%3D1460213&data=02%7C01%7Cyotamg%40mellanox.com%7C399f6ff50cb148cbd0d408d4fcfad4c7%7Ca652971c7d2e4d9ba6a4d149256f461b%7C0%7C0%7C636411601630363571&sdata=PSkkBrWNXkTxsvXrTmK6Dx9iKZMq61MAKlTcdVcPj8w%3D&reserved=0
> Reported-by: Jiri Benc <jbenc@redhat.com>
> Fixes: b87f7936a932 ("net/sched: introduce Match-all classifier")
> Signed-off-by: Davide Caratti <dcaratti@redhat.com>
> ---
>  net/sched/cls_matchall.c | 1 +
>  1 file changed, 1 insertion(+)
>
> diff --git a/net/sched/cls_matchall.c b/net/sched/cls_matchall.c
> index 21cc45caf842..eeac606c95ab 100644
> --- a/net/sched/cls_matchall.c
> +++ b/net/sched/cls_matchall.c
> @@ -32,6 +32,7 @@ static int mall_classify(struct sk_buff *skb, const struct tcf_proto *tp,
>  	if (tc_skip_sw(head->flags))
>  		return -1;
>  
> +	*res = head->res;
>  	return tcf_exts_exec(skb, &head->exts, res);
>  }
>  

Acked-by: Yotam Gigi <yotamg@mellanox.com>
