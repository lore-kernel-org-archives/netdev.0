From: Tomas Hozza <thozza@redhat.com>
Subject: Re: SOCK_STREAM TCP: send() returns success even when other side
 responded with RST packet
Date: Tue, 19 Feb 2013 10:09:22 -0500 (EST)
Message-ID: <2084007858.1889873.1361286562542.JavaMail.root@redhat.com>
References: <1361285472.19353.126.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx4-phx2.redhat.com ([209.132.183.25]:43375 "EHLO
	mx4-phx2.redhat.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932551Ab3BSPJX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Feb 2013 10:09:23 -0500
In-Reply-To: <1361285472.19353.126.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

----- Original Message -----
> On Tue, 2013-02-19 at 02:02 -0500, Tomas Hozza wrote:
> > Hi.
> > 
> > I was advised to forward my networking Kernel related Bug here
> > so it can get fixed much faster. Here is the Bug description
> > copied from Red Hat Bugzilla
> > (https://bugzilla.redhat.com/show_bug.cgi?id=912382):
> > 
> > Description of problem:
> > I'm using SOCK_STREAM TCP sockets. Imagine server-client
> > application.
> > - Server will accept connection from client.
> > - Client sends some data to server -> server receives data.
> > - Client then half-closes the TCP connection using shutdown(fd,
> > SHUT_WR).
> > - Client waits for some data from the server.
> > - Server sends some data to client -> client receives data.
> > - Client exits and closes the socket.
> > - After some time server tries to send some data to the client.
> > - The first send() call returns success even the Client's response
> > is RST.
> > 
> > 
> > Version-Release number of selected component (if applicable):
> > 3.7.7-201.fc18.x86_64
> > 3.7.8-202.fc18.x86_64
> > 
> > 
> > How reproducible:
> > always
> > 
> > 
> > Steps to Reproduce:
> > 1. download attached client/server sources.
> > 2. compile server: # gcc tcp_server.c -o server
> > 3. compile client: # gcc tcp_client.c -o client
> > 4. run the server: # ./server
> > 5. run the client: # ./client
> > 
> > 
> > Actual results:
> > Server started...
> > Created SOCK_STREAM socket
> > Bound to localhost:6666
> > waiting for connection...
> > Client connected!
> > Waiting for some data from client
> > Received: "MSG from client"
> > Received EOF
> > Sending msg to client: "MSG from server"
> > sleep(5)
> > Sending 1 msg to client: "MSG from server"
> > try #1 send() result: (0) Success
> > Sending 2 msg to client: "MSG from server"
> > try #2 send() result: (32) Broken pipe
> > Server exiting...
> > 
> > 
> > Expected results:
> > Server should fail to send() data right after sleep().
> > 
> > Server started...
> > Created SOCK_STREAM socket
> > Bound to localhost:6666
> > waiting for connection...
> > Client connected!
> > Waiting for some data from client
> > Received: "MSG from client"
> > Received EOF
> > Sending msg to client: "MSG from server"
> > sleep(5)
> > Sending 1 msg to client: "MSG from server"
> > try #1 send() result: (32) Broken pipe
> > Server exiting...
> > 
> > 
> > Additional info:
> > RST answer means that data were NOT delivered. Therefore the very
> > first send() call after server sleep() should fail!
> > 
> > 
> > Regards,
> > 
> > Tomas Hozza
> 
> Hi Tomas
> 
> I read your bug report, but cant understand why you believe there is
> a bug.
> 
> send() is not synchronous.

OK, my bad. In man page there is: "Successful completion of a call to
send() does not guarantee delivery of the message."

> 
> It only queues bytes to be transmitted either right now, either later
> when its possible.
> 
> So a RST message can be received _after_ send() has accepted the
> request and copy data from user land to kernel socket write queue, but TCP
> stack did not yet delivered the data.

I'm using TCP because it should guarantee that my data were delivered or
let me know there was some problem. If this is not a bug, then it is at least
confusing for TCP.

> To make sure data is delivered, you need additional logic.

To be honest I didn't find any way how to get notified there was a RST packet
sent as a reply to my previously sent data.

Thank you for your reply.

Regards,
Tomas Hozza
