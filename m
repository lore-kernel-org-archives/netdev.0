From: Willy Tarreau <w@1wt.eu>
Subject: Re: TCP: orphans broken by RFC 2525 #2.17
Date: Mon, 27 Sep 2010 00:54:40 +0200
Message-ID: <20100926225440.GH12373@1wt.eu>
References: <20100926131717.GA13046@1wt.eu> <20100926.151346.112585478.davem@davemloft.net> <20100926223448.GF12373@1wt.eu> <20100926.153832.115943505.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 1wt.eu ([62.212.114.60]:45704 "EHLO 1wt.eu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932220Ab0IZWyo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 26 Sep 2010 18:54:44 -0400
Content-Disposition: inline
In-Reply-To: <20100926.153832.115943505.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Sep 26, 2010 at 03:38:32PM -0700, David Miller wrote:
> From: Willy Tarreau <w@1wt.eu>
> Date: Mon, 27 Sep 2010 00:34:48 +0200
> 
> > I don't see what is being violated nor what reliability has been
> > compromised.
> 
> The TCP protcol's obligation to reliably deliver data between
> two applications, that is what has been violated.

Once again, I don't see why, due to the orphans mechanism. Please
consider for a minute that the application-level close() is distinct
from the protocol-level close. The application-level close() just
instructs the lower layer to turn the connection into an orphan. Any
pending data is sent. Incoming data may accumulate until the receive
buffer is full, but at least the other end regularly acks what is
being sent. Then once the other end has acked the orphaned data, we
perform the protocol-level close, which consists in either switching
the connection to TIME_WAIT if there are no pending data, or to send
an RST if there are pending data.

> You don't have to like this, but you certainly must cope with it
> in your applications :-)

It's not a matter of liking it or not, but to use something reliable.
Orphans are supposed to be (as long as there aren't any memory shortage).
But they're not. And my concern is that the information that my app
could make use for a reliable close exists in the kernel but is not
usable from the application level.

In fact, the end result is that we're observing exactly the opposite
of what RFC2525 wanted to achieve : their goal was to perform early
resets on aborts in order not to have to transfer too many data, but
the way we have it makes it mandatory to read everything because some
information is lost between the kernel and the application.

Willy

