From: Chris Friesen <cbf123@mail.usask.ca>
Subject: unexpected TCP behaviour when deleting local IP addresses
Date: Tue, 16 Oct 2012 15:12:13 -0600
Message-ID: <507DCDAD.7030209@mail.usask.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from idcmail-mo2no.shaw.ca ([64.59.134.9]:20775 "EHLO
	idcmail-mo2no.shaw.ca" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753890Ab2JPVVv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Oct 2012 17:21:51 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


I'm seeing some strange behaviour with local TCP connections.  The 
scenario goes as follows:

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

This was originally seen on 2.6.27, but I've verified it on 2.6.35. 
I'll see about trying it on current git.

Is the waiting forever in step 7 a bug, or is this legitimate TCP 
behaviour since the server was basically shut down uncleanly?

If we don't remove the address in step 4, then step 5 results in the 
server socket going to FIN_WAIT2 and the client socket going to 
CLOSE_WAIT and step 7 returns right away with zero bytes.

In the "remove IP address" case I would expect step 6 to cause some sort 
of error since the IP address no longer exists.

The interesting thing is that if you do this sort of scenario with the 
client and server on different hosts then you get a "no route to host" 
error at step 6.

Curious how this is supposed to work...

Chris
