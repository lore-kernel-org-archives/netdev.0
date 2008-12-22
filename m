From: Ben Mansell <ben@zeus.com>
Subject: Re: Mysterious network delays when using splice()
Date: Mon, 22 Dec 2008 16:30:44 +0000
Message-ID: <494FC0B4.3000502@zeus.com>
References: <49466A0E.7040406@zeus.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailin.zeus.com ([212.44.21.7]:4470 "EHLO mailin.zeus.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751248AbYLVQat (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 22 Dec 2008 11:30:49 -0500
In-Reply-To: <49466A0E.7040406@zeus.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ben Mansell wrote:
> (Originally posted to linux-net, but apparently this is the more
> appropriate list. Sorry if it is the wrong place!)
> 
> I've been investigating using splice() to proxy data from one  TCP
> socket to another. I know that splice() can't directly handle data
> between two sockets, so I'm using pipes in-between:
> 
> clientsock -> pipe1 -> serversock
> serversock -> pipe2 -> clientsock
> 
> All data transfer is done using splice() between the sockets and pipes.
> 
> However, while this does work, I get mysterious delays between some of
> the splices, which just aren't present if I use read() and write() in
> their place. I've put together a simple program that demonstrates the 
> issue.
 >
 > [...]

Mystery solved - replying to myself here, just in case anyone else runs 
into this 'problem' and finds these messages.

The problem I hit was when splice()ing from my pipe buffers to the 
client/server socket. My test program was always calling:

splice( srcfd, NULL, dstfd, NULL, BLOCK_SIZE, flags )

where BLOCK_SIZE was defined as 4096. This is fine when splice()ing from 
a network socket -> pipe, but when splice()ing from a pipe -> socket, 
Linux is using this as a hint that there are 4096 bytes to come. So if 
your pipe only contained (say) 1234 bytes, then 1234 bytes will get 
copied to the network socket's buffers, but they won't get immediately 
pushed onto the wire because the kernel believes that there is more data 
to come. Just like a normal write() to a socket.

The solution is simply to count bytes in & out of the pipe, so that when 
splice()ing from a pipe, you know exactly how many bytes are there for 
the taking. Linux is doing the right thing here, my test program was 
just a bit too dumb!
