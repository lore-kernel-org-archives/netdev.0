From: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
Subject: Re: Fw: [Bug 70071] New: Sending netconsole messages over a bridged
 network interface doesn't work anymore
Date: Thu, 06 Feb 2014 14:44:44 +0900
Message-ID: <52F3214C.4060308@lab.ntt.co.jp>
References: <20140205141539.450095fa@samsung-9>	<52F30863.7000206@lab.ntt.co.jp> <CAHA+R7Pf1q7+xyqpwmGPToa0fTGn6dmukLvyncWwYAP-F_JvLg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	netdev <netdev@vger.kernel.org>
To: Cong Wang <cwang@twopensource.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tama500.ecl.ntt.co.jp ([129.60.39.148]:57076 "EHLO
	tama500.ecl.ntt.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752166AbaBFFpD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Feb 2014 00:45:03 -0500
In-Reply-To: <CAHA+R7Pf1q7+xyqpwmGPToa0fTGn6dmukLvyncWwYAP-F_JvLg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

(2014/02/06 14:05), Cong Wang wrote:
> On Wed, Feb 5, 2014 at 7:58 PM, Toshiaki Makita
> <makita.toshiaki@lab.ntt.co.jp> wrote:
>> (2014/02/06 6:15), Stephen Hemminger wrote:
>>>
>>>
>>> Begin forwarded message:
>>>
>>> Date: Wed, 5 Feb 2014 04:36:03 -0800
>>> From: "bugzilla-daemon@bugzilla.kernel.org" <bugzilla-daemon@bugzilla.kernel.org>
>>> To: "stephen@networkplumber.org" <stephen@networkplumber.org>
>>> Subject: [Bug 70071] New: Sending netconsole messages over a bridged network interface doesn't work anymore
>>
>> Reverting this commit seems to fix the problem.
>> 93d8bf9fb8f3 ("bridge: cleanup netpoll code")
>>
>> In the following code path, p->br->dev->npinfo is NULL at
>> br_netpoll_enable() because __netpoll_setup() assigns ndev->npinfo after
>> calling ndo_netpoll_setup().
>>
>>   __netpoll_setup() -> br_netpoll_setup() -> br_netpoll_enable()
> 
> Yeah, looks like we can just remove that incorrect 'if'.
> Please test the following patch.
> 
> diff --git a/net/bridge/br_device.c b/net/bridge/br_device.c
> index e4401a5..bb2b706 100644
> --- a/net/bridge/br_device.c
> +++ b/net/bridge/br_device.c
> @@ -254,9 +254,6 @@ int br_netpoll_enable(struct net_bridge_port *p, gfp_t gfp)
>         struct netpoll *np;
>         int err;
> 
> -       if (!p->br->dev->npinfo)
> -               return 0;
> -
>         np = kzalloc(sizeof(*p->np), gfp);
>         if (!np)
>                 return -ENOMEM;

Tested this patch with latest net-tree and netconsole works with it.
But I thinks it is better to move that "if" to br_add_if() because if we
don't have npinfo, we don't have to alloc p->np in br_add_if(), right?

Thanks,
Toshiaki Makita
