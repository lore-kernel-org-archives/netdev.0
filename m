From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: [PATCH 3/3]: tg3: Manage TX backlog in-driver.
Date: Sat, 21 Jun 2008 10:02:03 -0700
Message-ID: <C27F8246C663564A84BB7AB343977242019B6FEC8F@IRVEXCHCCR01.corp.ad.broadcom.com>
References: <20080620.161710.223267437.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: "vinay@linux.vnet.ibm.com" <vinay@linux.vnet.ibm.com>,
	"krkumar2@in.ibm.com" <krkumar2@in.ibm.com>
To: "'David Miller'" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:2203 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751598AbYFURCq convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Jun 2008 13:02:46 -0400
In-Reply-To: <20080620.161710.223267437.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:

> +       /* This is a deadlock breaker.  tg3_tx() updates the consumer
> +        * index, then checks the tx_backlog for emptiness.  It also
> +        * tries to mitigate work by only flushing the backlog when at
> +        * least a certain percentage of space is available.  Those
> +        * tests in tg3_tx() run lockless.
> +        *
> +        * Here, we make the two primary memory operations in the
> +        * reverse order.  The idea is to make sure that one of these
> +        * two code paths will process the backlog no matter what the
> +        * order of their relative execution might be.
> +        *
> +        * In short:
> +        *
> +        * tg3_tx() --> tp->tx_cons = foo; test skb_queue_empty()
> +        * tg3_start_xmit() --> __skb_queue_tail(); test tp->tx_cons
> +        */
> +       if (tg3_tx_avail(tp) > TG3_TX_WAKEUP_THRESH(tp))
> +               __tg3_xmit_backlog(tp);
> +}
>

I'm thinking that we should use a different wakeup threshold here
than the one in tg3_tx().  If the 2 threads test for the same
threshold, it increases the likelihood that they will find the
condition to be true at the same time.  This contention will
cause tg3_tx() to spin longer for the tx_lock, because
tg3_start_xmit() will call __tg3_xmit_backlog() and keep the
tx_lock longer.

Since 99% of the wakeup should be done in tg3_tx(), we should
increase the threshold here to perhaps 3/4 of the ring.

