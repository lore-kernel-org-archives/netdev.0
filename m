From: Mark Huth <mhuth@mvista.com>
Subject: Re: [PATCH][af_key]pfkey_add: Optimize SA adds and algorithm probes
Date: Fri, 18 May 2007 10:16:59 -0700
Message-ID: <464DDF8B.6090402@mvista.com>
References: <E1HouAO-0003i5-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from h155.mvista.com ([63.81.120.158]:49032 "EHLO
	gateway-1237.mvista.com" rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org
	with ESMTP id S1756342AbXERRRL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 May 2007 13:17:11 -0400
In-Reply-To: <E1HouAO-0003i5-00@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Herbert Xu wrote:
> Mark Huth <mhuth@mvista.com> wrote:
>   
>> This patch provides a performance optimization in the pfkey_add path.
>> Prior versions have a serious performance problem when adding a large
>> number of SAs to a node.  For example, if a backup node needs to be
>> loaded with the SAs previously held by a failed active node, thousands
>> of SAs may need to be added as rapidly as possible.  Tests show that
>> without this patch, such additions may take several minutes.  The
>> cause is that the available algorithm modules are probed each time
>> instead of only when needed.  This patch changes the unconditional
>> call to xfrm_probe_algs() to only be done when it may be needed.
>>     
>
> Thanks for the patch!
>  
>   
>>  static int pfkey_add(struct sock *sk, struct sk_buff *skb, struct 
>> sadb_msg *hdr, void **ext_hdrs)
>>  {
>>        struct xfrm_state *x;
>> -       int err;
>> +       int err, probe_done = 0;
>>        struct km_event c;
>>
>> -       xfrm_probe_algs();
>> -
>>        x = pfkey_msg2xfrm_state(hdr, ext_hdrs);
>>        if (IS_ERR(x))
>>                return PTR_ERR(x);
>>     
>
> I don't think it works when then algorithm isn't loaded though :)
> If the algorithm isn't present pfkey_msg2xfrm_state will return
> -ENOSYS so we need to do the probe here.
>   
Okay.  I tested with the algorithms not loaded, and they were all loaded 
after the test, but I'm sure you understand this much better than I do.
> Actually, I think we should just probe for the specific algorithm
> requested rather than everything.  See patch below.
>
> [IPSEC] pfkey: Load specific algorithm in pfkey_add rather than all
>
> This is a natural extension of the changeset
>
>     [XFRM]: Probe selected algorithm only.
>
> which only removed the probe call for xfrm_user.  This patch does exactly
> the same thing for af_key.  In other words, we load the algorithm requested
> by the user rather than everything when adding xfrm states in af_key.
>
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
>
> Cheers,
>   
Thanks for the patch.  I'll try it later today and confirm that it fixes 
our problem.

Mark Huth
