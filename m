From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3] netpoll: Close race condition between poll_one_napi
 and napi_disable
Date: Wed, 23 Sep 2015 14:33:12 -0700 (PDT)
Message-ID: <20150923.143312.404914990603153762.davem@davemloft.net>
References: <20150922190154.GC31679@hmsreliant.think-freely.org>
	<1443034678-1475-1-git-send-email-nhorman@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: nhorman@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45718 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755787AbbIWVdN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Sep 2015 17:33:13 -0400
In-Reply-To: <1443034678-1475-1-git-send-email-nhorman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neil Horman <nhorman@redhat.com>
Date: Wed, 23 Sep 2015 14:57:58 -0400

> Drivers might call napi_disable while not holding the napi instance poll_lock.
> In those instances, its possible for a race condition to exist between
> poll_one_napi and napi_disable.  That is to say, poll_one_napi only tests the
> NAPI_STATE_SCHED bit to see if there is work to do during a poll, and as such
> the following may happen:
> 
> CPU0				CPU1
> ndo_tx_timeout			napi_poll_dev
>  napi_disable			 poll_one_napi
>   test_and_set_bit (ret 0)
> 				  test_bit (ret 1)
>    reset adapter		   napi_poll_routine
> 
> If the adapter gets a tx timeout without a napi instance scheduled, its possible
> for the adapter to think it has exclusive access to the hardware  (as the napi
> instance is now scheduled via the napi_disable call), while the netpoll code
> thinks there is simply work to do.  The result is parallel hardware access
> leading to corrupt data structures in the driver, and a crash.
> 
> Additionaly, there is another, more critical race between netpoll and
> napi_disable.  The disabled napi state is actually identical to the scheduled
> state for a given napi instance.  The implication being that, if a napi instance
> is disabled, a netconsole instance would see the napi state of the device as
> having been scheduled, and poll it, likely while the driver was dong something
> requiring exclusive access.  In the case above, its fairly clear that not having
> the rings in a state ready to be polled will cause any number of crashes.
> 
> The fix should be pretty easy.  netpoll uses its own bit to indicate that that
> the napi instance is in a state of being serviced by netpoll (NAPI_STATE_NPSVC).
> We can just gate disabling on that bit as well as the sched bit.  That should
> prevent netpoll from conducting a napi poll if we convert its set bit to a
> test_and_set_bit operation to provide mutual exclusion
> 
> Change notes:
> V2)
> 	Remove a trailing whtiespace
> 	Resubmit with proper subject prefix
> 
> V3)
> 	Clean up spacing nits
> 
> Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
> CC: "David S. Miller" <davem@davemloft.net>
> CC: jmaxwell@redhat.com
> Tested-by: jmaxwell@redhat.com

Applied, thanks Neil.
