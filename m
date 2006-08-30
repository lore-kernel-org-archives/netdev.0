From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: high latency with TCP connections
Date: Wed, 30 Aug 2006 10:27:27 -0700
Message-ID: <20060830102727.11e11453@localhost.localdomain>
References: <20060830100734.GA22235@isil.ipib.msu.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:63459 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1751173AbWH3R1d (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Aug 2006 13:27:33 -0400
To: Alexander Vodomerov <alex@sectorb.msk.ru>
In-Reply-To: <20060830100734.GA22235@isil.ipib.msu.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 30 Aug 2006 14:07:34 +0400
Alexander Vodomerov <alex@sectorb.msk.ru> wrote:

> Hello!
> 
> I'm writing an application that is working over TCP. Total traffic is
> very low (~ 10 kb/sec), but performance is very bad. I've tried to
> investigate problem with tcpdump and strace, and it shows that
> application does multiple writes, but TCP buffers them and send after
> some delay (about 40 msec). Due to nature of my application, it is
> essential to send any available data ASAP (decreased bandwidth is not
> important). I've set TCP_NODELAY option on socket, but it doesn't help.

Linux TCP implements "Appropriate Byte Count" (ABC) and this penalizes
applications that do small sends. The problem is that the other side
may be delaying acknowledgments.  If receiver doesn't acknowledge the
sender will limit itself to the congestion window. If the flow is light,
then you will be limited to 4 packets.

> We've written a simple program to reproduce the effect. It sends 10
> small packets, then sleeps for 0.1 sec. Another node tries to receive
> data. Strace shows that 2 packets are sent immediately and other 8 are
> grouped together and delayed by 40 msec.
> 
> It is interesting that this effect can be seen not only on Ethernet
> links, but on loopback also (with the same magic constant of 40 msec).
> 
> Here is a test run:
>   server (should be run first):
> $ ./a.out 1 5000
> Server: begin send_all
> Server: total time 14.216441
>   client:
> $ ./a.out 2 5000 localhost
> Client: connected to localhost:5000
> Client: begin receive_all
> Client: total time 14.223265
> 
> Expected time is 10.0 sec (instead of 14.0 sec).
> If packets are received more often (DELIM constant is set to 1 or 2)
> then effect disappear.
> 
> Is this a desired behaviour? How can I specify that packets should be
> sent really immediately after write?
> 
> Some people reported that this program runs in 9.997 sec when run on
> FreeBSD.
> 
> Please cc me on replies, as I'm not subscribed to mailing list.
> 
> With best regards, 
>    Alexander.
> 

> 
> void send_all(unsigned long delay)
> {
> 	int i;
> 	char buf[1024];
> 	printf("Server: begin send_all\n");
> 	for (i = 1; i < TOTAL_SENDS; ++i) {
>                 write(sock, buf, 1);

Expecting any performance with one byte write's is silly.
