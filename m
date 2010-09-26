From: Willy Tarreau <w@1wt.eu>
Subject: Re: TCP: orphans broken by RFC 2525 #2.17
Date: Mon, 27 Sep 2010 00:34:48 +0200
Message-ID: <20100926223448.GF12373@1wt.eu>
References: <20100926131717.GA13046@1wt.eu> <20100926.151346.112585478.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 1wt.eu ([62.212.114.60]:45701 "EHLO 1wt.eu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932202Ab0IZWew (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 26 Sep 2010 18:34:52 -0400
Content-Disposition: inline
In-Reply-To: <20100926.151346.112585478.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

On Sun, Sep 26, 2010 at 03:13:46PM -0700, David Miller wrote:
> From: Willy Tarreau <w@1wt.eu>
> Date: Sun, 26 Sep 2010 15:17:17 +0200
> 
> > I've read RFC 2525 #2.17 and it shows quite interesting examples of what
> > it wanted to protect against. However, the recommendation did not consider
> > the fact that there could be some unacked pending data in the outgoing
> > buffers.
> 
> It doesn't matter if there is any pending data still outgoing when
> we received this data after close().
> 
> The issue is that the reliable transport nature of TCP has been
> violated, and as such the entire connection's reliability has
> been compromised.

I don't see what is being violated nor what reliability has been
compromised. Some data has reliably been delivered to the kernel,
a shutdown() has reliably been performed, followed by a close()
which then makes use of the orphans mechanism to deliver the data
to the other side.

> The only appropriate response is a full reset.

I'm not against the full reset, I really want it, but I don't want
it to be sent before the previous data. The reset here is being sent
out of order and kills the data that were previously going to be
delivered. It's all about a timing issue BTW. If the other side sends
its data slightly later, it reliably receives its response followed by
a reset it understands and respects. So this is a valid working
mechanism. I'm just trying to ensure that the reset does not break
ordering and is delivered after the pending data.

> As Eric said, your only option is to fully sync the data coming
> from the peer.

The why are we keeping the orphans feature and not get rid of it then ?
It becomes completely useless, and we can as well disable all the
lingering options which have no use beyond that.

The lingering controls how long unacked data remains in an orphaned
socket, which precisely is my case. If the application has no way to
know whether it can close, all this becomes useless.

I can easily admit I'm doing something wrong, but here we have a
feature that I think I'm correctly using and it does not always
work, and I can't know when I can use it, so I should not use it.
Obviously, either I'm missing something or there's something wrong.
And that's what I'd like to find out.

Thanks,
Willy

