From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] fix sk->sk_filter field access
Date: Wed, 30 Aug 2006 15:32:59 -0700 (PDT)
Message-ID: <20060830.153259.59653494.davem@davemloft.net>
References: <200608301707.14250.dim@openvz.org>
	<20060830.143015.104035096.davem@davemloft.net>
	<20060830222042.GA21714@ms2.inr.ac.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dim@openvz.org, netdev@vger.kernel.org, dev@sw.ru
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:5858
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S932211AbWH3Wc7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 Aug 2006 18:32:59 -0400
To: kuznet@ms2.inr.ac.ru
In-Reply-To: <20060830222042.GA21714@ms2.inr.ac.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Date: Thu, 31 Aug 2006 02:20:42 +0400

> Current code in tcp_v4_rcv() calls sk_filter() _before_ it takes socket lock.
> This happened when LSM patches were applied. Apparently, LSM does not
> want to see socket locked in security_sock_rcv_skb().

Ok.

> Obvious solution is to change the third argument of sk_filter
> "needlock" to 1.  Then we see that sk_filter() is not used with
> needlock=0 anymore, therefore it can be completely eliminated. It
> was original fix.

Really?

It is used with needlock=0 by DCCP ipv6, for example.  This case seems
correct too.  What about sk_receive_skb()?  dn_queue_skb()?  In fact,
there seems to be numerous uses still with needlock=0, all legitimate.

> I suggested to remove ugly misuse of bh_lock_sock() (introduced by
> me, just because there was no better lock to use) and replace it
> with RCU, which is logical and clean.
>
> The patch looks decent. I had one doubt about misuse of
> rcu_read_lock_bh() in sk_attach_filter(). Probably, it should be
> plain local_bh_disable(), I do not know. But because
> rcu_read_lock_bh() actually is local_bh_disable(), it seems to be
> not a serious issue.

Let us to fix bugs first, and then consider rewriting the locking.
:-)
