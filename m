From: Julian Anastasov <ja@ssi.bg>
Subject: Re: TCP_DEFER_ACCEPT is missing counter update
Date: Thu, 15 Oct 2009 11:47:51 +0300 (EEST)
Message-ID: <Pine.LNX.4.58.0910151120340.2879@u.domain.uli>
References: <20091014045226.GA15655@1wt.eu> <Pine.LNX.4.58.0910140912420.2714@u.domain.uli>
 <20091014201706.GA24298@1wt.eu> <20091014.154349.83940908.davem@davemloft.net>
 <20091015060834.GB29564@1wt.eu>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	eric.dumazet@gmail.com
To: Willy Tarreau <w@1wt.eu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([217.79.71.194]:55306 "EHLO u.domain.uli"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S932156AbZJOIrn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Oct 2009 04:47:43 -0400
In-Reply-To: <20091015060834.GB29564@1wt.eu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


	Hello,

On Thu, 15 Oct 2009, Willy Tarreau wrote:

> BTW, I found a use case I didn't think about where current behaviour
> causes trouble :
> 
>    https://bugs.launchpad.net/ubuntu/+source/apache2/+bug/134274
>    http://lkml.indiana.edu/hypermail/linux/kernel/0711.0/0461.html
> 
> In summary, when front proxies establish pools of connections to
> an apache server making use of TCP_DEFER_ACCEPT, the connection
> never establishes on the apache server but silently expires in
> SYN_RECV state. The front proxy sees lots of SYN/ACKs and sends
> many ACKs trying to complete this connection and finally believes
> it got it since the server eventually becomes silent. However,
> when trying to send data over such a socket, the server immediately
> returns an RST.

	Such proxies using open connections for insane long
time should be prepared to retry idempotent methods such as
GET and to send POST methods to fresh connections. They can
close idle connections, say, after 5 seconds. Even if
server runs with TCP_DEFER_ACCEPT=OFF there is possibility
server to send FIN while request is flying (servers are
configured with some period to wait for first request).

> Such a problem would not happen if we would only drop the first
> X packets (X >= 1 is already fine), because the front proxy would
> establish the connection, send a second ACK in response to the
> second SYN/ACK and the connection would then really be established
> and would not have to expire early in SYN_RECV state.
> 
> If we really want to behave as it does today, well, let's not fix
> it, but obviously, I fail to see what real world use it has, except
> causing random and hard to debug issues :-/

	The reason is that in SYN_RECV state the server
saves resources. Socket and FD are created on DATA and possibly
for the short time while response is sent. If server is lucky
such resources will live miliseconds. Short responses can
be sent together with FIN. OTOH, servers running
with TCP_DEFER_ACCEPT=OFF can live with some wakeups (epoll
is fast enough) but the problem is that they have sockets
for longer time (the difference between first ACK and first DATA).

> Reading the articles below clearly make it think it was designed
> to help with HTTP connections by skipping the first expected and
> useless ACK packet before waking up the task :
> 
>    http://httpd.apache.org/docs/1.3/misc/perf-bsd44.html
>    http://articles.techrepublic.com.com/5100-10878_11-1050771.html
> 
> and people still get caught :
> 
>    http://lkml.indiana.edu/hypermail/linux/kernel/0711.0/0416.html

	They wait for minutes because they do not configure
TCP_SYNCNT. TCP_DEFER_ACCEPT works as expected if configured
properly.

> Maybe it was a bit over-engineered, in the end causing it to fail
> to satisfy the primary goal ?

	If one changes TCP_DEFER_ACCEPT to create socket it
will save wakeups but not resources. I'm wondering if the
behavior should be changed at all. For me the options are two:

a) you want to save resources: use TCP_DEFER_ACCEPT. To help
proxies use large values for TCP_SYNCNT and TCP_DEFER_ACCEPT.

b) you can live with wakeups and many sockets: do not use
TCP_DEFER_ACCEPT. Suitable for servers using short timeouts
for first request.

> Regards,
> Willy

Regards

--
Julian Anastasov <ja@ssi.bg>
