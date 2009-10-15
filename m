From: Willy Tarreau <w@1wt.eu>
Subject: Re: TCP_DEFER_ACCEPT is missing counter update
Date: Thu, 15 Oct 2009 08:08:34 +0200
Message-ID: <20091015060834.GB29564@1wt.eu>
References: <20091014045226.GA15655@1wt.eu> <Pine.LNX.4.58.0910140912420.2714@u.domain.uli> <20091014201706.GA24298@1wt.eu> <20091014.154349.83940908.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: ja@ssi.bg, netdev@vger.kernel.org, eric.dumazet@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 1wt.eu ([62.212.114.60]:50248 "EHLO 1wt.eu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934644AbZJOGJW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Oct 2009 02:09:22 -0400
Content-Disposition: inline
In-Reply-To: <20091014.154349.83940908.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 14, 2009 at 03:43:49PM -0700, David Miller wrote:
> For now I'm pushing Willy's change into Linus's tree.
> 
> After more discussion we can revert if necessary.
> 
> I won't submit this to -stable until the discussion is fully resolved.

Makes sense, thanks David.

BTW, I found a use case I didn't think about where current behaviour
causes trouble :

   https://bugs.launchpad.net/ubuntu/+source/apache2/+bug/134274
   http://lkml.indiana.edu/hypermail/linux/kernel/0711.0/0461.html

In summary, when front proxies establish pools of connections to
an apache server making use of TCP_DEFER_ACCEPT, the connection
never establishes on the apache server but silently expires in
SYN_RECV state. The front proxy sees lots of SYN/ACKs and sends
many ACKs trying to complete this connection and finally believes
it got it since the server eventually becomes silent. However,
when trying to send data over such a socket, the server immediately
returns an RST.

Such a problem would not happen if we would only drop the first
X packets (X >= 1 is already fine), because the front proxy would
establish the connection, send a second ACK in response to the
second SYN/ACK and the connection would then really be established
and would not have to expire early in SYN_RECV state.

If we really want to behave as it does today, well, let's not fix
it, but obviously, I fail to see what real world use it has, except
causing random and hard to debug issues :-/

Reading the articles below clearly make it think it was designed
to help with HTTP connections by skipping the first expected and
useless ACK packet before waking up the task :

   http://httpd.apache.org/docs/1.3/misc/perf-bsd44.html
   http://articles.techrepublic.com.com/5100-10878_11-1050771.html

and people still get caught :

   http://lkml.indiana.edu/hypermail/linux/kernel/0711.0/0416.html

Maybe it was a bit over-engineered, in the end causing it to fail
to satisfy the primary goal ?

Regards,
Willy

