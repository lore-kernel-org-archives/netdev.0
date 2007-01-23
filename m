From: dean gaudet <dean@arctic.org>
Subject: Re: why would EPIPE cause socket port to change?
Date: Tue, 23 Jan 2007 12:11:01 -0800 (PST)
Message-ID: <Pine.LNX.4.64.0701231140320.21464@twinlark.arctic.org>
References: <E1H9ES2-0006uJ-00@gondolin.me.apana.org.au> <45B65271.1040709@hp.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Herbert Xu <herbert@gondor.apana.org.au>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from twinlark.arctic.org ([207.29.250.54]:46702 "EHLO
	twinlark.arctic.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965486AbXAWULD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Jan 2007 15:11:03 -0500
To: Rick Jones <rick.jones2@hp.com>
In-Reply-To: <45B65271.1040709@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 23 Jan 2007, Rick Jones wrote:

> Herbert Xu wrote:
> > Prior to the last write, the socket entered the CLOSED state meaning
> > that the old port is no longer allocated to it.  As a result, the
> > last write operates on an unconnected socket which causes a new local
> > port to be allocated as an autobind.  It then fails because the socket
> > is still not connected.
> > 
> > So any attempt to run getsockname after an error on the socket is
> > simply buggy.
> 
> But falls within the principle of least surprise doesn't it?  Unless the
> application has called close() or bind(), it does seem like a reasonable
> expectation that the port assignments are not changed.

i sampled a few other OSes...

netbsd returns EINVAL after close
freebsd returns ECONNRESET after close
OSX retains the same port number
solaris 10 returns port 0

actually any of those behaviours seems more appropriate than randomly 
assigning a new port :)  but i like the ENOTCONN suggestion from Michael 
Tokarev the best... it matches the ENOTCONN from getpeername.


> > (fwiw this is one of two reasons i've found for libnss-ldap to leak
> > sockets... causing nscd to crash.)
> 
> Of course, that seems rather odd too - why does libnss-ldap check the socket
> name on a socket after an EPIPE anyway?

libnss-ldap has some code which attempts to determine if its private 
socket has been trampled on in between calls to the library... and to do 
this it caches getsockname/getpeername results and compares them every 
time the library is re-entered... and when there's a mismatch it leaks a 
socket (eventually crashing nscd if you're using that).  i've been trying 
to band-aid over the problem:

http://bugzilla.padl.com/show_bug.cgi?id=304
http://bugzilla.padl.com/show_bug.cgi?id=305

but i'm probably going to need to approach it from another direction -- 
make libnss-ldap monitor the ldap library results so it knows when there's 
been a read/write error so that it stops doing this 
getsockname/getpeername thing after the error has occured.

-dean
