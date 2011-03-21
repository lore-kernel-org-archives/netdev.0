From: Wei Yongjun <yjwei@cn.fujitsu.com>
Subject: Re: xfrm: Fix initialize repl field of struct xfrm_state
Date: Mon, 21 Mar 2011 17:10:31 +0800
Message-ID: <4D871607.6090508@cn.fujitsu.com>
References: <4D86E603.8080704@cn.fujitsu.com> <20110320.225542.71119753.davem@davemloft.net> <4D86F1FD.3080009@cn.fujitsu.com> <20110320.234606.183056322.davem@davemloft.net> <20110321082512.GB27581@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:55369 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751792Ab1CUJKE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 21 Mar 2011 05:10:04 -0400
In-Reply-To: <20110321082512.GB27581@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> On Sun, Mar 20, 2011 at 11:46:06PM -0700, David Miller wrote:
>> Ok, thanks for the explanation.
>>
>> I think there is a simple way out of this:
>>
>> 1) Rename current xfrm_init_state to __xfrm_init_state, add
>>    "bool init_replay" argument.  Add the xfrm_init_replay()
>>    call, as in your patch, but conditionalized on this boolean.
>>
>> 2) Implement xfrm_init_state as inline, which calls
>>    __xfrm_init_state(..., true)
>>
>> 3) Replace xfrm_init_state() call in xfrm_user.c with
>>    __xfrm_init_state(..., false)
>>
>> This seems to avoid all the problems.  We don't need to touch every
>> caller, and we avoid initializing the replay state twice in xfrm_user
>>
> Btw, looking a bit closer to this. I think it would look a bit cleaner
> if we would add the xfrm_init_replay() call to xfrm_init_state() and
> to move the xfrm_init_state() call in xfrm_state_construct() behind
> the assign of the replay settings.

The xfrm_init_replay() should be call after the call to
  xfrm_update_ae_params(x, attrs);
since xfrm_update_ae_params() may update the replay_esn.

So we need move the xfrm_init_state()  call just before return x.

The other issue:
static void xfrm_update_ae_params()
{
        ...
        memcpy(x->replay_esn, replay_esn,
                       xfrm_replay_state_esn_len(replay_esn));
       ...
}

the memcpy() may cause memory overlap if we build a special
nl_data, we should free it and then do kmemdup()?

> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
