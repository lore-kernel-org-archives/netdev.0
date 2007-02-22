From: David Miller <davem@davemloft.net>
Subject: Re: [Bug 8013] New: select for write hangs on a socket after write
 returned ECONNRESET
Date: Thu, 22 Feb 2007 06:08:05 -0800 (PST)
Message-ID: <20070222.060805.59465933.davem@davemloft.net>
References: <20070222121427.GA29455@2ka.mipt.ru>
	<20070222.053138.74748069.davem@davemloft.net>
	<20070222134620.GC5208@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@linux-foundation.org, netdev@vger.kernel.org
To: johnpol@2ka.mipt.ru
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49359
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S932078AbXBVOIH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Feb 2007 09:08:07 -0500
In-Reply-To: <20070222134620.GC5208@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Date: Thu, 22 Feb 2007 16:46:21 +0300

> On Thu, Feb 22, 2007 at 05:31:38AM -0800, David Miller (davem@davemloft.net) wrote:
> > TCP_CLOSE is where we end up on a non-error close too, this has
> > the same kind of bug as your previous attempt to set POLLERR
> > here.
> > 
> > One side gets TCP_TIMEWAIT the other goes straight to TCP_CLOSE.
> > 
> > It really is not possible to change current semantics, they are the
> > best possible unfortunately.
> 
> AS a last attempt - we can have a sockt flag set when sk-err is
> installed in tcp_reset(), and tcp_poll() will set POLLERR if that flag
> exist (just like it checks for sk_err, which is cleared in tcp_sendmsg()
> when error is being returned).

Oh is that the problem?  Someone sees a fatal connection error from
write() then attempts to poll() the socket?

That is illegal.

Socket is dead, you cannot do anything reasonable with it and you know
the socket is errored so there is nothing you can possibly try to
poll() on it for.

One should close() the file descriptor at this point.  Even
getpeername() cannot work at this point, since socket is closed and
has lost identity.

Socket errors are delivered as unique events, once error is delivered
the socket is not in error state any more, it is instead closed.
That's why we clear sk->sk_err after error delivery.

BTW, there was a query about this back in Feb. 2006 on linux-kernel,
nobody replied, he reposted to linux-net in September 2006 and this
is likely where this kernel bugzilla comes from :-)

This is not a kernel bug, let's close this and move on.
