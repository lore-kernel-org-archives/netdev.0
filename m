From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: 2.6.27 seems to break something with DSL (fwd)
Date: Mon, 20 Oct 2008 13:57:38 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0810201319590.7072@wrl-59.cs.helsinki.fi>
References: <Pine.LNX.4.64.0810171611100.2939@olon.olon.net> <48FA50E9.4080105@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: olon@verizon.net, Netdev <netdev@vger.kernel.org>
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:60692 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751028AbYJTK5l (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Oct 2008 06:57:41 -0400
In-Reply-To: <48FA50E9.4080105@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 18 Oct 2008, Jarek Poplawski wrote:

> Olon wrote, On 10/17/2008 10:11 PM:
> 
> > I can confirm this issue.
> > I'm using a westell dsl modem, and going from 2.6.26.5 to .27.  I found that I 
> > couldn't connect to most websites either.
> > This modem is in passthrough mode and not nat.
> 
> Could you try this?:
> echo 0 > /proc/sys/net/ipv4/tcp_sack
> 
> It looks like it helped in a similar problem here:
> http://bugzilla.kernel.org/show_bug.cgi?id=11721

In this case there are some other things as well... as connections get 
successfully established...

Analysis of the case from tcp side:

gnu.org)
- Established ok, request (at least 2422 bytes) is sent and acked, 
response never arrives (or tcpdump didn't get them)... Is this our
fault at all?

kernel.org)

2421 request sent and acked, then long delay and at :54.621879 we close 
the socket (or the app exits), the response to fin indicates that ~2896 
bytes were sent by the kernel.org but they never arrived (or for some 
reason tcpdump didn't catch them). Is this our fault?

www.news.com)

Connection to 216.239.122.102 successful, working as expected (a quick 
look only, no in depth check per field :-)).

Connection to 216.239.122.178, well, it's miserable... We send 2424 and 
it gets acked. They send some with funny fragmentation (and 1:1461 
missing anyway):

14:30:24.262465 IP (tos 0x0, ttl 245, id 22541, offset 0, 
flags [+], proto: TCP (6), length: 764) 216.239.122.178.80 >
96.246.106.2.36303: P 1461:2185(724) ack 2424 win 27588
14:30:24.270508 IP (tos 0x0, ttl 245, id 22541, offset 744, flags [none], 
proto: TCP (6), length: 756) 216.239.122.178 > ...

...which we'll respond (and probably queue that too into ofo queue) and 
we ack 1 which is the right thing to do. ...and tcpdump is too short to 
see retransmission of 1:1461 if they ever would come. Afaict we did 
nothing wrong here...


Olon, please don't wrap lines next time if you include tcpdumps... :-)

-- 
 i.
