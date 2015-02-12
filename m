From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: xt_recent broken in kernel 3.19.0 + PATCH
Date: Wed, 11 Feb 2015 19:15:29 -0800
Message-ID: <CAM_iQpVmxw_XfzP7yaPWbhu8UBujebm1vjumgPPH1TUdHgs0rA@mail.gmail.com>
References: <20150211092834.65f8ae80@bother.homenet>
	<20150211183121.6688aec8@bother.homenet>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	netfilter-devel@vger.kernel.org,
	Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Chris Vine <chris@cvine.freeserve.co.uk>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20150211183121.6688aec8@bother.homenet>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

(Cc'ing netdev and netfilter-devel lists)

On Wed, Feb 11, 2015 at 10:31 AM, Chris Vine
<chris@cvine.freeserve.co.uk> wrote:
> On Wed, 11 Feb 2015 09:28:34 +0000
> Chris Vine <chris@cvine.freeserve.co.uk> wrote:
>> With kernel 3.19.0, the following iptables rule, where SSH_TRIES is
>> set to 4:
>>
>>   iptables -D SSH_CHAIN -m conntrack --ctstate NEW \
>>     -m recent --update --seconds $SSH_LOGIN_PERIOD --hitcount
>> $SSH_TRIES -j DROP
>>
>> generates this error message in syslog:
>>
>>   kernel: xt_recent: hitcount (4) is larger than packets to be
>>   remembered (4) for table DEFAULT
>>
>> and the rule fails to install in the table.  No error is generated
>> with kernel 3.18.6.
>
> The rule provoking this should of course have been the one appending
> the rule, which is:
>
>   iptables -A SSH_CHAIN -m conntrack --ctstate NEW \
>     -m recent --update --seconds $SSH_LOGIN_PERIOD --hitcount $SSH_TRIES -j DROP
>
> On looking at the code, the changes in the 3.19 kernel seem not to have
> been tested and there is an off-by-one error.  The patch below restores
> behaviour to be identical to that found in the 3.18 kernel.
>
> Chris
>
> --- linux-3.19.0/net/netfilter/xt_recent.c~     2015-02-10 09:18:44.657376355 +0000
> +++ linux-3.19.0/net/netfilter/xt_recent.c      2015-02-11 17:58:33.311608835 +0000
> @@ -378,7 +378,7 @@
>         mutex_lock(&recent_mutex);
>         t = recent_table_lookup(recent_net, info->name);
>         if (t != NULL) {
> -               if (info->hit_count > t->nstamps_max_mask) {
> +               if (info->hit_count > t->nstamps_max_mask + 1) {
>                         pr_info("hitcount (%u) is larger than packets to be remembered (%u) for table %s\n",
>                                 info->hit_count, t->nstamps_max_mask + 1,
>                                 info->name);
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
