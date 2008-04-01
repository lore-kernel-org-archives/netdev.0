From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: Fix for the fundamental network/block layer race in sendfile().
Date: Tue, 1 Apr 2008 21:47:59 +0400
Message-ID: <20080401174759.GB28217@2ka.mipt.ru>
References: <20080328092036.GA11924@2ka.mipt.ru> <20080328.134053.122172549.davem@davemloft.net> <20080328205613.GA24812@2ka.mipt.ru> <20080328.140736.92315090.davem@davemloft.net> <20080328215131.GB24812@2ka.mipt.ru> <20080401164904.GA2382@2ka.mipt.ru> <47F26EAB.7040900@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, axboe@kernel.dk,
	netdev@vger.kernel.org
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:54982 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756549AbYDARsR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Apr 2008 13:48:17 -0400
Content-Disposition: inline
In-Reply-To: <47F26EAB.7040900@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi.

On Tue, Apr 01, 2008 at 07:19:39PM +0200, Eric Dumazet (dada1@cosmosbay.com) wrote:
> >@@ -762,6 +765,12 @@ static ssize_t do_sendfile(int out_fd, int in_fd, 
> >loff_t *ppos,
> > 		count = max - pos;
> > 	}
> > 
> >+	sock = out_file->private_data;
> >+	sk = sock->sk;
> >+
> >+	sk->sk_user_data = &skb_splice_destructor;
> >+	sk->sk_flags |= SO_PRIVATE_CALLBACK;
> 
> Ouch...
> 
> this seems very ugly (sorry).
> 
> 1) Is out_file garanted to be a socket ?

Yep.

> 2) SO_PRIVATE_CALLBACK is defined to be 37 later on your patch. Is ORing 37 
> to sk_flags really working ???

Kind of... Not as supposed to be, since sk_flags is a long.
Will put that flag into socket instead.

> 3) So, once a socket has been used for a sendfile(), all subsequent 
> sendmsg() will call skb_splice_destructor ? (I see no clearing of 
> SO_PRIVATE_CALLBACK)
>  This will probably crash.

Yep, need to clear.

> 4) god_blessed_us name ... Oh I got it, its April the first !!!!

But it still works :)

-- 
	Evgeniy Polyakov
