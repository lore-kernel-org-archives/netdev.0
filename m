From: "David Laight" <David.Laight@ACULAB.COM>
Subject: RE: [PATCH] rebalance locks by converting write_lock_bh towrite_lock+local_bh_disable
Date: Mon, 25 Nov 2013 09:40:08 -0000
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B7441@saturn3.aculab.com>
References: <20131121235402.GA11774@opentech.at> <20131123.143929.975712910203893827.davem@davemloft.net> <20131123235823.GA23670@opentech.at>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: <kuznet@ms2.inr.ac.ru>, <eric.dumazet@gmail.com>,
	<roque@di.fc.ul.pt>, <peterz@infradead.org>,
	<netdev@vger.kernel.org>
To: "Nicholas Mc Guire" <der.herr@hofr.at>,
	"David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:60087 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1750811Ab3KYJlu convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Nov 2013 04:41:50 -0500
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 27061-10 for <netdev@vger.kernel.org>;
 Mon, 25 Nov 2013 09:41:47 +0000 (GMT)
Content-class: urn:content-classes:message
In-Reply-To: <20131123235823.GA23670@opentech.at>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> in one of the cases I do not understand the intent behind the split:
> in net/core/sock.c:lock_sock_fast
> 
> 	spin_lock_bh(&sk->sk_lock.slock);
> 	...
>         spin_unlock(&sk->sk_lock.slock);
>         /*
>          * The sk_lock has mutex_lock() semantics here:
>          */
>         mutex_acquire(&sk->sk_lock.dep_map, 0, 0, _RET_IP_);
>         local_bh_enable();
> 
>  I think that
> 
> 	spin_lock_bh(&sk->sk_lock.slock);
> 	...
>         /*
>          * The sk_lock has mutex_lock() semantics here:
>          */
>         mutex_acquire(&sk->sk_lock.dep_map, 0, 0, _RET_IP_);
>         spin_unlock_bh(&sk->sk_lock.slock);
> 
>  should be equivalent ?

You've added a lock ordering that wasn't there before.
Also I suspect that mutex_acquire() might be allowed to sleep,
whereas you shouldn't sleep with a spin lock held.

	David
