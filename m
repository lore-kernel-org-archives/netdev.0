From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 1/2] genl: Allow concurrent genl callbacks.
Date: Mon, 22 Apr 2013 16:18:12 -0400 (EDT)
Message-ID: <20130422.161812.1075030033926378895.davem@davemloft.net>
References: <1366320646-16903-1-git-send-email-pshelar@nicira.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dev@openvswitch.org, jesse@nicira.com
To: pshelar@nicira.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37900 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754895Ab3DVUSO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Apr 2013 16:18:14 -0400
In-Reply-To: <1366320646-16903-1-git-send-email-pshelar@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pravin B Shelar <pshelar@nicira.com>
Date: Thu, 18 Apr 2013 14:30:46 -0700

> All genl callbacks are serialized by genl-mutex. This can become
> bottleneck in multi threaded case.
> Following patch adds an parameter to genl_family so that a
> particular family can get concurrent netlink callback without
> genl_lock held.
> New rw-sem is used to protect genl callback from genl family unregister.
> in case of lockless genl-family read-lock is taken for callbacks and
> write lock is taken for register or unregistration for any family.
> In case of locked genl family semaphore and gel-mutex is locked for
> any openration.
> 
> Signed-off-by: Pravin B Shelar <pshelar@nicira.com>

I don't think you can do this.

Dumps happen in several passes, and the dumps keep track of where
we are in the dump by using a scratchpad in the SKB.  That means
we have state that must stay sane across several dump invocations.

This means we have to keep out set operations while the dump is
happening.

That means we have to hold a mutex over all configurations changes.

I do not like this change, and don't intend to apply it nor the
openvswitch stuff.

If you don't like my position, get one of the netlink experts to
chime in since none of them have reviewed this stuff yet.
