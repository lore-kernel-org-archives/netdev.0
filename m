From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Bug?  TCP shutdown behaviour when deleting local IP addresses
Date: Thu, 18 Oct 2012 08:05:48 +0200
Message-ID: <1350540348.26103.1015.camel@edumazet-glaptop>
References: <507F38D4.102@genband.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Patrick McHardy <kaber@trash.net>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
To: Chris Friesen <chris.friesen@genband.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:49662 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754250Ab2JRGFx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Oct 2012 02:05:53 -0400
Received: by mail-ee0-f46.google.com with SMTP id b15so4338432eek.19
        for <netdev@vger.kernel.org>; Wed, 17 Oct 2012 23:05:51 -0700 (PDT)
In-Reply-To: <507F38D4.102@genband.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-10-17 at 17:01 -0600, Chris Friesen wrote:
> Hi all,
> 
> I sent this to the list yesterday (from another address) but didn't get 
> any responses.  Accordingly I'm expanding the receiver list to the 
> listed maintainers for IPv4/IPv6.
> 
> I'm seeing some unexpected (to me, at least) behaviour with local TCP 
> connections.  The scenario goes as follows:
> 
> 1) create new IP address and assign to eth device
> 2) TCP server starts listening on that IP address
> 3) TCP client connects to server
> 4) remove new IP address
> 5) kill server with ctrl-C.  At this point it appears that because the 
> address was removed the shutdown message isn't processed properly. 
> netstat shows the server socket as FIN_WAIT1, but the client socket is 
> still ESTABLISHED.
> 6) client writes to the connected socket (this passes with no error)
> 7) client waits for response from server, and waits forever or until 
> keepalive expires
> 
> 
> 
> A few points:
> 
> This was originally seen on 2.6.27, but I've verified it on 2.6.35. I'll 
> see about trying it on current git.  I've got really simple 
> client/server code if anyone wants to try reproducing.
> 
> If we don't remove the address in step 4, then step 5 results in the 
> server socket going to FIN_WAIT2 and the client socket going to 
> CLOSE_WAIT and step 7 returns right away with zero bytes.
> 
> It seems like the waiting forever behaviour in step 7 might be 
> legitimate since the address was removed before shutting down the 
> server, but it also seems like we should be able to do better given that 
> everything is local.  In the "remove IP address" case maybe step 6 
> should cause some sort of error since the IP address no longer exists?
> 
> Incidentally, if we do this sort of scenario with the client and server 
> on different hosts then we get a "no route to host" error at step 6.
> 
> Curious how this is supposed to work...
> 
> Chris

I see no real problem here.

Its like you cut the cable somewhere in the path.

Only timeouts will apply.

And its not keeepalive timeouts in 7) but normal retransmits with
exponential backoff.

Extract of Documentation/networking/ip-sysctl.txt :

tcp_retries1 - INTEGER
        This value influences the time, after which TCP decides, that
        something is wrong due to unacknowledged RTO retransmissions,
        and reports this suspicion to the network layer.
        See tcp_retries2 for more details.

        RFC 1122 recommends at least 3 retransmissions, which is the
        default.

tcp_retries2 - INTEGER
        This value influences the timeout of an alive TCP connection,
        when RTO retransmissions remain unacknowledged.
        Given a value of N, a hypothetical TCP connection following
        exponential backoff with an initial RTO of TCP_RTO_MIN would
        retransmit N times before killing the connection at the (N+1)th
RTO.

        The default value of 15 yields a hypothetical timeout of 924.6
        seconds and is a lower bound for the effective timeout.
        TCP will effectively time out at the first RTO which exceeds the
        hypothetical timeout.

        RFC 1122 recommends at least 100 seconds for the timeout,
        which corresponds to a value of at least 8.
