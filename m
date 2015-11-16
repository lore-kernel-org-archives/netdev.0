From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] qlcnic: Fix mailbox completion handling during
 spurious interrupt
Date: Mon, 16 Nov 2015 15:30:53 -0500 (EST)
Message-ID: <20151116.153053.1012877822441474046.davem@davemloft.net>
References: <1447671527-28905-1-git-send-email-rajesh.borundia@qlogic.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Dept-HSGLinuxNICDev@qlogic.com
To: rajesh.borundia@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41050 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751041AbbKPUaz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Nov 2015 15:30:55 -0500
In-Reply-To: <1447671527-28905-1-git-send-email-rajesh.borundia@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rajesh Borundia <rajesh.borundia@qlogic.com>
Date: Mon, 16 Nov 2015 05:58:47 -0500

> +	} else {
> +		if (atomic_read(&mbx->rsp_status) != rsp_status)
> +			qlcnic_83xx_notify_mbx_response(mbx);

Here we go with more of some "We don't understand what atomic_t's
actually do"...

atomic_read() does _nothing_

It doesn't enforce ordering of the read of the variable wrt.  other
memory accesses or anything like that.  It doesn't make the read
"atomic".

All it does is convert an "atomic_t" into an "int", and such a
conversion is necessary if the implementation makes use of some of the
atomic_t value for implementing atomicity (such as putting a spinlock
in the upper byte of the value, etc.)

Therefore, if you are using an atomic_t to order stores and reads of
an integer value.  That's not what they do, and your usage is wrong.

If you are assuming that atomic_t's store a full 32-bit signed
integer, all 32-bits of which which are unmolested by the
implementation, then your usage is wrong.  The implementation may use
any number of bits of the atomic_t value for it's own usage.

As a result, these uses in the qlogic driver are completely wrong and
give a false impression as to what the atomic_read() function does and
what atomic_t variables are to be used for.

Please correct this, and then respin your patch on top of that.
