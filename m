From: David Miller <davem@davemloft.net>
Subject: Re: [Bug 8013] New: select for write hangs on a socket after write
 returned ECONNRESET
Date: Wed, 21 Feb 2007 22:45:43 -0800 (PST)
Message-ID: <20070221.224543.95508003.davem@davemloft.net>
References: <20070216161045.GA2371@2ka.mipt.ru>
	<20070216102914.7d4b34f0@freekitty>
	<20070216183426.GA3138@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@linux-foundation.org, netdev@vger.kernel.org
To: johnpol@2ka.mipt.ru
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36391
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751429AbXBVGpo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Feb 2007 01:45:44 -0500
In-Reply-To: <20070216183426.GA3138@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Date: Fri, 16 Feb 2007 21:34:27 +0300

> Otherwise we can extend select output mask to include hungup too
> (getting into account that hungup is actually output event).

POLLHUP is non-maskable and this is very clearly defined in
just about every Unix definition of poll().

This non-maskability leads to all the strange semantics in this area.

There is simply no way for sockets to return HUP for someone who
is only waiting to write.  Definitions of POLLHUP include language
such as "This event and POLLOUT are mutually exclusive".

I reviewed the current code and the many (and I mean MANY) threads on
this topic that have occurred over the years going back to even 1999,
and what we're doing now is the best possible set of semantics we can
provide without breaking any existing applications.

How many others have gone into the archives and actually looked at
the discussions?   That appears to be going out of style :-/

Now, on the read side, for the epoll folks, we added a POLLRDHUP
to handle that case.  It's not relevant here, but I'm mentioning it
in passing since it's roughly related and it shows part of the devil
in dealing with POLLHUP semantics.

POLLHUP is a complete mess, because it means different things on
different kinds of fds.  And exactly, because it is not maskable,
this makes it totally useless for sockets.
