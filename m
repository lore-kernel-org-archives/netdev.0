From: Zhu Yi <yi.zhu@intel.com>
Subject: Re: [RFC PATCH] accounting for socket backlog
Date: Fri, 26 Feb 2010 10:44:13 +0800
Message-ID: <1267152253.16986.1655.camel@debian>
References: <1267067593.16986.1583.camel@debian>
	 <20100225.003124.183011848.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Shi, Alex" <alex.shi@intel.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:9870 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934998Ab0BZCms (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 25 Feb 2010 21:42:48 -0500
In-Reply-To: <20100225.003124.183011848.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2010-02-25 at 16:31 +0800, David Miller wrote:
> > @@ -1372,8 +1372,13 @@ int udp_queue_rcv_skb(struct sock *sk, struct
> sk_buff *skb)
> >       bh_lock_sock(sk);
> >       if (!sock_owned_by_user(sk))
> >               rc = __udp_queue_rcv_skb(sk, skb);
> > -     else
> > +     else {
> > +             if (atomic_read(&sk->sk_backlog.len) >= sk->sk_rcvbuf)
> {
> > +                     bh_unlock_sock(sk);
> > +                     goto drop;
> > +             }
> >               sk_add_backlog(sk, skb);
> > +     }
> 
> We have to address this issue, of course, but I bet this method of
> handling it negatively impacts performance in normal cases.

Eric mentioned atomic is not required here. I don't think performance
will be impacted any more with the above if clause. Right?

> Right now we can queue up a lot and still get it to the application
> if it is slow getting scheduled onto a cpu, but if you put this
> limit here it could result in lots of drops. 

Or we can replace the sk->sk_rcvbuf limit with a backlog own limit. We
can queue "a lot", but not endless. We have to have a limit anyway.

Thanks,
-yi

