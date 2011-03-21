From: Wei Yongjun <yjwei@cn.fujitsu.com>
Subject: Re: xfrm: Fix initialize repl field of struct xfrm_state
Date: Mon, 21 Mar 2011 14:36:45 +0800
Message-ID: <4D86F1FD.3080009@cn.fujitsu.com>
References: <4D86E603.8080704@cn.fujitsu.com> <20110320.225542.71119753.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, steffen.klassert@secunet.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:54616 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751734Ab1CUGgQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 21 Mar 2011 02:36:16 -0400
In-Reply-To: <20110320.225542.71119753.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> From: Wei Yongjun <yjwei@cn.fujitsu.com>
> Date: Mon, 21 Mar 2011 13:45:39 +0800
>
>> Commit 'xfrm: Move IPsec replay detection functions to a separate file'
>>   (9fdc4883d92d20842c5acea77a4a21bb1574b495)
>> introduce repl field to struct xfrm_state, and only initialize it
>> under SA's netlink create path, the other path, such as pf_key, the
>> repl field remaining uninitialize. So if the SA is created by pf_key,
>> any input packet with SA's encryption algorithm will cause panic.
> Please, either add an xfrm_init_replay() call to the appropriate spot
> in net/key/af_key.c or, if possible, only have the one call in
> xfrm_init_state().  Don't leave two calls, one in xfrm_user.c and one
> in xfrm_state.c
>
> Anyways, I don't think just making one call from xfrm_init_state() is
> possible, because the replay settings need to be assigned before we
> can properly call xfrm_init_replay().
>
> Therefore, please fix this by adding the necessary call to af_key.c
Sorry for not said clearly, at the first time I want to do like this. 
But when I grep 'xfrm_init_state', it be used in many place, not
any pf_key, but also XFRM MIGRATE, ipcomp, ipcomp6. So I did this ugly
patch by add this to xfrm_init_state() to avoid dup code.

Not sure whether the other case like ipcomp/ipcomp6 etc can cause panic, if
it panic, maybe we can fix by introduce new xfrm_init_replay() function
like to assign the default reply function.
  int xfrm_init_replay(struct xfrm_state *x)
  {
  	x->repl = &xfrm_replay_legacy;
  	return 0;
  }
and change the orig xfrm_init_replay to xfrm_update_replay()? 
Or dup those code to all used place?

If I was wrong, I will fix this by adding the necessary call to af_key.c.

Thanks.


> Thanks.
>
