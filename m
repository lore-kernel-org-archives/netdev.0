From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Question about synchronize_net() in AF_PACKET close()
Date: Wed, 17 Sep 2014 10:52:51 -0700
Message-ID: <1410976371.7106.243.camel@edumazet-glaptop2.roam.corp.google.com>
References: <CAN8CM3zo3bMxZV_UvywCPNjJrMwMA2-+POfY8cR429iodHRc+A@mail.gmail.com>
	 <20140909.150000.1647602729214485795.davem@davemloft.net>
	 <CAN8CM3xEnQXVgrLpV0rfAJoZ75v6Xv64pAGJ-9SAPACAT8WJ_w@mail.gmail.com>
	 <54199AC7.1040502@martingkelly.com>
	 <1410965690.7106.233.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CAN8CM3wpZ236h3Okfi0AS+9+0P05fd1JVwfUOXfbp_LV2PqLLQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Paul McKenney <paulmck@linux.vnet.ibm.com>,
	Stephen Hemminger <stephen@networkplumber.org>
To: Martin Kelly <martin@martingkelly.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:58972 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756121AbaIQRwx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Sep 2014 13:52:53 -0400
Received: by mail-pa0-f47.google.com with SMTP id ey11so2659208pad.6
        for <netdev@vger.kernel.org>; Wed, 17 Sep 2014 10:52:53 -0700 (PDT)
In-Reply-To: <CAN8CM3wpZ236h3Okfi0AS+9+0P05fd1JVwfUOXfbp_LV2PqLLQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2014-09-17 at 10:04 -0700, Martin Kelly wrote:

> Does my analysis sound correct to you? If so, can you think of a more
> natural way to improve raw socket close() performance? I agree that
> optimally, userspace should not put close() in a critical path, but it
> still seems like a bug for close() to take 300 ms to complete.

I have a plan to remove the nulls support for UDP stack, because we
would like to be able to use million of connected UDP sockets, and we
would like to get rid of the atomic_inc()/atomic_dec() on socket
refcount for every incoming message ;)

My plan was to add a way for a socket to be freed after one rcu grace
period.

It would be an opt-in for protocols needing this. TCP stack would
continue to use SLAB_DESTROY_BY_RCU.

af_packet could immediately use this, and not have to use
synchronize_net() at all.
