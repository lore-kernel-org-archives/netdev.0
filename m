From: Wei Yongjun <yjwei@cn.fujitsu.com>
Subject: Re: xfrm: Fix initialize repl field of struct xfrm_state
Date: Tue, 22 Mar 2011 09:04:38 +0800
Message-ID: <4D87F5A6.90704@cn.fujitsu.com>
References: <4D86E603.8080704@cn.fujitsu.com> <20110320.225542.71119753.davem@davemloft.net> <4D86F1FD.3080009@cn.fujitsu.com> <20110320.234606.183056322.davem@davemloft.net> <20110321082512.GB27581@secunet.com> <4D871607.6090508@cn.fujitsu.com> <4D8717DA.2010901@cn.fujitsu.com> <20110321120635.GA1290@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:51044 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1756240Ab1CVBST (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 21 Mar 2011 21:18:19 -0400
In-Reply-To: <20110321120635.GA1290@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> On Mon, Mar 21, 2011 at 05:18:18PM +0800, Wei Yongjun wrote:
>>>> Btw, looking a bit closer to this. I think it would look a bit cleaner
>>>> if we would add the xfrm_init_replay() call to xfrm_init_state() and
>>>> to move the xfrm_init_state() call in xfrm_state_construct() behind
>>>> the assign of the replay settings.
>>> The xfrm_init_replay() should be call after the call to
>>>   xfrm_update_ae_params(x, attrs);
>>> since xfrm_update_ae_params() may update the replay_esn.
>>>
>>> So we need move the xfrm_init_state()  call just before return x.
>>
>> Oh, sorry, the memcpy looks like dup code since we used
>> kmemdup. It is the same attr XFRMA_REPLAY_ESN_VAL.
>>
> Indeed, we don't need the memcpy here because we do a kmemdup when we
> allocate repay_esn/preplay_esn. But we need to memcpy if we call
> xfrm_update_ae_params() from xfrm_new_ae().
>
> So we could just replace the kmemdup by kmalloc when we allocate
> repay_esn/preplay_esn and move xfrm_init_state() at the end of the
> function, as you suggested. xfrm_update_ae_params() would initialize
> x->replay_esn and x->preplay_esn properly then.

BTW, looking into more about this, another path, XFRM_MSG_NEWAE,
can overwrite the x->replay_esn with the nla_data length, which
may larger then the size we malloc.

>>> The other issue:
>>> static void xfrm_update_ae_params()
>>> {
>>>         ...
>>>         memcpy(x->replay_esn, replay_esn,
>>>                        xfrm_replay_state_esn_len(replay_esn));
>>>        ...
>>> }
>>>
>>> the memcpy() may cause memory overlap if we build a special
>>> nl_data, we should free it and then do kmemdup()?
>>>
