From: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Subject: Re: [PATCH] fix sk->sk_filter field access
Date: Thu, 31 Aug 2006 02:20:42 +0400
Message-ID: <20060830222042.GA21714@ms2.inr.ac.ru>
References: <200608301707.14250.dim@openvz.org> <20060830.143015.104035096.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: dim@openvz.org, netdev@vger.kernel.org, dev@sw.ru
Return-path: <netdev-owner@vger.kernel.org>
Received: from minus.inr.ac.ru ([194.67.69.97]:6359 "HELO ms2.inr.ac.ru")
	by vger.kernel.org with SMTP id S932192AbWH3WVC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Aug 2006 18:21:02 -0400
To: David Miller <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20060830.143015.104035096.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello!

> > Function sk_filter() is called from tcp_v{4,6}_rcv() functions with argue 
> > needlock = 0, while socket is not locked at that moment. In order to avoid 
> > this and similar issues in the future, use rcu for sk->sk_filter field read 
> > protection.
> > 
> > Patch is for net-2.6.19
> 
> What bug are you fixing?  The current code looks correct to me.
> 
> Why is it important to avoid the needlock stuff in the future?
> 
> This patch description is very incomplete, you should list the
> precise reason why you are doing something instead of using
> vague language.

Yes, explanation could be better.

Current code in tcp_v4_rcv() calls sk_filter() _before_ it takes socket lock.
This happened when LSM patches were applied. Apparently, LSM does not
want to see socket locked in security_sock_rcv_skb().

Obvious solution is to change the third argument of sk_filter "needlock" to 1.
Then we see that sk_filter() is not used with needlock=0 anymore, therefore
it can be completely eliminated. It was original fix.

I suggested to remove ugly misuse of bh_lock_sock() (introduced by me,
just because there was no better lock to use) and replace it with RCU, which
is logical and clean.

The patch looks decent. I had one doubt about misuse of rcu_read_lock_bh()
in sk_attach_filter(). Probably, it should be plain local_bh_disable(),
I do not know. But because rcu_read_lock_bh() actually is local_bh_disable(),
it seems to be not a serious issue.

Alexey
