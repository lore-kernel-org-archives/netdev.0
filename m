From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] Move inetdev/ifa over to RCU
Date: Sun, 15 Aug 2004 19:08:23 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040815190823.654bf2d5.davem@redhat.com>
References: <20040812165954.00429e65.davem@redhat.com>
	<20040813090314.448c971d@dell_ss3.pdx.osdl.net>
	<20040813093838.6961c0d4.davem@redhat.com>
	<20040813215602.GA15870@gondor.apana.org.au>
	<20040813151923.3311b4f0.davem@redhat.com>
	<20040814003428.GA17760@gondor.apana.org.au>
	<20040813173924.6d05be15.davem@redhat.com>
	<20040814005411.GA18350@gondor.apana.org.au>
	<20040814012513.GA721@gondor.apana.org.au>
	<20040814013030.GA2042@gondor.apana.org.au>
	<20040814050848.GA11874@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: shemminger@osdl.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20040814050848.GA11874@gondor.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, 14 Aug 2004 15:08:48 +1000
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> I'm just going through all the __in_dev_get() callers and the one
> in ip_route_output_slow() looks fishy.  It appears to be checking
> whether the subsequent inet_select_addr() calls will succeed or not.
> 
> But this is not reliable since the addresses can always disappear
> between the check and the actual call.
> 
> Do we really care about the zero return value of inet_select_addr()
> here? What about the other calls to inet_select_addr()?

It won't return zero, typically it will return loopback's IP
(with preference to any non-loopback addresses assigned to
 the loopback device).  This is being used for source address
selection.

Also, when device ipv4 addresses are deleted, NETDEV_DOWN messages
are broadcast to all the subsystems.  One of the subsystems is FIB,
which will disable IP on that interface if this is the last ipv4
address and it will also flush the routing cache immediately.
However you are right that we may need to synchronize this more
tightly.

Hmmm....
