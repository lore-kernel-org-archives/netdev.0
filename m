From: "David S. Miller" <davem@redhat.com>
Subject: Re: [patch] abstract out socket lock.users access
Date: Mon, 07 Oct 2002 15:14:59 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20021007.151459.09774569.davem@redhat.com>
References: <20021007175551.B30693@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: bcrl@redhat.com
In-Reply-To: <20021007175551.B30693@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: Benjamin LaHaise <bcrl@redhat.com>
   Date: Mon, 7 Oct 2002 17:55:51 -0400

We define this:

   +#define sock_is_locked(sk)	(NULL != (sk)->lock.owner)

But call:

   +				(int)is_sock_locked(sk));
   +		if (!is_sock_locked(sk))
 ...
   -	if (sk->lock.users != 0) {
   +	if (is_sock_locked(sk)) {

And it's not a lock, it is a user ownership indication.
I'd therefore prefer "sock_owned_by_user" or similar.

Next:

   +#define async_lock_sock(iocb, __sk, list) \
   +({	int ret = 0; \
   +	spin_lock_bh(&((__sk)->lock.slock)); \
   +	if ((__sk)->lock.owner != NULL) \
   +		ret = __async_lock_sock((iocb), (__sk), (list)); \
   +	else \
   +		(__sk)->lock.owner = (iocb); \
   +	spin_unlock_bh(&((__sk)->lock.slock)); \
   +	ret; \
   +})
   +

How does this work?  Is there some protocol that treats (void *)1
specially inside of __async_lock_sock()?  Where are this semantics
defined?

Please clean up the {is_sock,sock_is}_locked() stuff and define
how async_lock_sock works wrt. the owner pointer.
