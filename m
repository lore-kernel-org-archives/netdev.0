From: Dave Jones <davej@redhat.com>
Subject: Re: fix broken locking in x25 ioctl error paths
Date: Fri, 28 Jun 2013 11:36:08 -0400
Message-ID: <20130628153608.GA12488@redhat.com>
References: <20130628151453.GA29428@redhat.com>
 <1372432775.3301.285.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:11153 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751511Ab3F1PgR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 28 Jun 2013 11:36:17 -0400
Content-Disposition: inline
In-Reply-To: <1372432775.3301.285.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jun 28, 2013 at 08:19:35AM -0700, Eric Dumazet wrote:
 > On Fri, 2013-06-28 at 11:14 -0400, Dave Jones wrote:
 > > Two of the x25 ioctl cases have error paths that break out of the function without
 > > unlocking the socket, leading to this warning:
 > > 
 > > 
 > > ================================================
 > > [ BUG: lock held when returning to user space! ]
 > > 3.10.0-rc7+ #36 Not tainted
 > > ------------------------------------------------
 > > trinity-child2/31407 is leaving the kernel with locks still held!
 > > 1 lock held by trinity-child2/31407:
 > >  #0:  (sk_lock-AF_X25){+.+.+.}, at: [<ffffffffa024b6da>] x25_ioctl+0x8a/0x740 [x25]
 > > 
 > > Signed-off-by: Dave Jones <davej@redhat.com>
 > > 
 > > diff --git a/net/x25/af_x25.c b/net/x25/af_x25.c
 > > index 37ca969..2c1e633 100644
 > > --- a/net/x25/af_x25.c
 > > +++ b/net/x25/af_x25.c
 > > @@ -1584,10 +1584,11 @@ out_cud_release:
 > >  		rc = -EINVAL;
 > >  		lock_sock(sk);
 > >  		if (sk->sk_state != TCP_CLOSE)
 > > -			break;
 > > +			goto out_callaccpt_release;
 > >  		clear_bit(X25_ACCPT_APPRV_FLAG, &x25->flags);
 > > -		release_sock(sk);
 > >  		rc = 0;
 > > +out_callaccpt_release:
 > > +		release_sock(sk);
 > >  		break;
 > >  	}
 > 
 > Or :
 > 
 > lock_sock(sk);
 > if (sk->sk_state == TCP_CLOSE) {
 >     clear_bit(X25_ACCPT_APPRV_FLAG, &x25->flags);
 >     rc = 0;
 > }
 > release_sock(sk);
 > break;

I can do that if it's preferred. I just copied the same style
as the existing cases.

	Dave
