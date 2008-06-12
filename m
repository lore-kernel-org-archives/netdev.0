From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: re-formated /Re: Hi!Couldn't you take a look at kernel stack's
   trace? (ip_route_input+0x91a/0xcc9)/
Date: Thu, 12 Jun 2008 21:36:45 +0200
Message-ID: <48517ACD.4020209@gmail.com>
References: <43d009740806100736y343bad9bt3a8b365292cced49@mail.gmail.com>	 <4851116A.6040805@trash.net> <43d009740806120524g78d066d2x95640fc8e01be625@mail.gmail.com> <485115EE.1040204@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: for.poige+linux@gmail.com, netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.173]:55020 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753952AbYFLThe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Jun 2008 15:37:34 -0400
Received: by ug-out-1314.google.com with SMTP id h2so414426ugf.16
        for <netdev@vger.kernel.org>; Thu, 12 Jun 2008 12:37:33 -0700 (PDT)
In-Reply-To: <485115EE.1040204@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Patrick McHardy wrote, On 06/12/2008 02:26 PM:

> Igor Podlesny wrote:
>> 2008/6/12 Patrick McHardy <kaber@trash.net>:
>>>> Igor Podlesny wrote:
>>>>>>  Pid: 8, comm: sirq-net-rx/0 Not tainted (2.6.25.4-rt4aa-gcc43 #1)
>>                                             ^^^^^^^^^^^^^^^^^^^^^^^^^
>>
>> 	(2.6.25.4-rt4aa-gcc43)
>> 	
>> 	-RT is real-time: http://rt.wiki.kernel.org/index.php/Main_Page

Hi,

Maybe I got something wrong but it seems to be this place:

static int ip_route_input_slow(struct sk_buff *skb, __be32 daddr, __be32 saddr,
                               u8 tos, struct net_device *dev)
...
        if (!IN_DEV_FORWARD(in_dev))
                goto e_hostunreach;
        if (res.type != RTN_UNICAST)
                goto martian_destination;

        err = ip_mkroute_input(skb, &res, &fl, in_dev, daddr, saddr, tos);
done:
        in_dev_put(in_dev);
        if (free_res)
                fib_res_put(&res);	<------------
out:    return err;
=====
static inline void fib_res_put(struct fib_result *res)
{
        if (res->fi)
                fib_info_put(res->fi);	<------------
#ifdef CONFIG_IP_MULTIPLE_TABLES
        if (res->r)
                fib_rule_put(res->r);
#endif
}
=====
static inline void fib_info_put(struct fib_info *fi)
{
        if (atomic_dec_and_test(&fi->fib_clntref))	<---------
                free_fib_info(fi);
}

Looks like EDX: 00000001 is fi, and fi + 0x18 is for fib_clntref,
but I didn't track it further.

Igor, probably for this list it's more interesting if it's reproducible
with unpatched kernels, and if you tried other than 2.6.25 versions
for this?

Thanks,
Jarek P.
