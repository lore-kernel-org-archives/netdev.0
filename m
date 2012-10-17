From: Chris Friesen <chris.friesen@genband.com>
Subject: Bug?  TCP shutdown behaviour when deleting local IP addresses
Date: Wed, 17 Oct 2012 17:01:40 -0600
Message-ID: <507F38D4.102@genband.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Patrick McHardy <kaber@trash.net>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exprod7og108.obsmtp.com ([64.18.2.169]:44278 "EHLO
	exprod7og108.obsmtp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752562Ab2JQXHi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Oct 2012 19:07:38 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,

I sent this to the list yesterday (from another address) but didn't get 
any responses.  Accordingly I'm expanding the receiver list to the 
listed maintainers for IPv4/IPv6.

I'm seeing some unexpected (to me, at least) behaviour with local TCP 
connections.  The scenario goes as follows:

1) create new IP address and assign to eth device
2) TCP server starts listening on that IP address
3) TCP client connects to server
4) remove new IP address
5) kill server with ctrl-C.  At this point it appears that because the 
address was removed the shutdown message isn't processed properly. 
netstat shows the server socket as FIN_WAIT1, but the client socket is 
still ESTABLISHED.
6) client writes to the connected socket (this passes with no error)
7) client waits for response from server, and waits forever or until 
keepalive expires



A few points:

This was originally seen on 2.6.27, but I've verified it on 2.6.35. I'll 
see about trying it on current git.  I've got really simple 
client/server code if anyone wants to try reproducing.

If we don't remove the address in step 4, then step 5 results in the 
server socket going to FIN_WAIT2 and the client socket going to 
CLOSE_WAIT and step 7 returns right away with zero bytes.

It seems like the waiting forever behaviour in step 7 might be 
legitimate since the address was removed before shutting down the 
server, but it also seems like we should be able to do better given that 
everything is local.  In the "remove IP address" case maybe step 6 
should cause some sort of error since the IP address no longer exists?

Incidentally, if we do this sort of scenario with the client and server 
on different hosts then we get a "no route to host" error at step 6.

Curious how this is supposed to work...

Chris



-- 

Chris Friesen
Software Designer
GENBAND
www.genband.com
