From: John Heffner <jheffner@psc.edu>
Subject: Re: [PATCH 0/9 Rev3] Implement batching skb API and support in IPoIB
Date: Sun, 26 Aug 2007 21:32:26 -0400
Message-ID: <46D229AA.6020900@psc.edu>
References: <OFC19F468C.48FB78EE-ON6525733F.0016047F-6525733F.00170F48@in.ibm.com>	<20070821.212229.82050253.davem@davemloft.net>	<46CC6DD1.5020105@hp.com>	<20070822.132145.90824527.davem@davemloft.net>	<1187906650.4279.16.camel@localhost>	<1187907903.4279.28.camel@localhost>	<46CE0BA1.60206@hp.com>	<20070823231820.2ae52cc0.billfink@mindspring.com>	<46CF7B13.3020701@psc.edu> <20070826044134.eabd18cf.billfink@mindspring.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Rick Jones <rick.jones2@hp.com>, hadi@cyberus.ca,
	David Miller <davem@davemloft.net>, krkumar2@in.ibm.com,
	gaagaan@gmail.com, general@lists.openfabrics.org,
	herbert@gondor.apana.org.au, jagana@us.ibm.com, jeff@garzik.org,
	johnpol@2ka.mipt.ru, kaber@trash.net, mcarlson@broadcom.com,
	mchan@broadcom.com, netdev@vger.kernel.org,
	peter.p.waskiewicz.jr@intel.com, rdreier@cisco.com,
	Robert.Olsson@data.slu.se, shemminger@linux-foundation.org,
	sri@us.ibm.com, tgraf@suug.ch, xma@us.ibm.com
To: Bill Fink <billfink@mindspring.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailer1.psc.edu ([128.182.58.100]:55019 "EHLO mailer1.psc.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753248AbXH0Bck (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 26 Aug 2007 21:32:40 -0400
In-Reply-To: <20070826044134.eabd18cf.billfink@mindspring.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Bill Fink wrote:
> Here's the beforeafter delta of the receiver's "netstat -s"
> statistics for the TSO enabled case:
> 
> Ip:
>     3659898 total packets received
>     3659898 incoming packets delivered
>     80050 requests sent out
> Tcp:
>     2 passive connection openings
>     3659897 segments received
>     80050 segments send out
> TcpExt:
>     33 packets directly queued to recvmsg prequeue.
>     104956 packets directly received from backlog
>     705528 packets directly received from prequeue
>     3654842 packets header predicted
>     193 packets header predicted and directly queued to user
>     4 acknowledgments not containing data received
>     6 predicted acknowledgments
> 
> And here it is for the TSO disabled case (GSO also disabled):
> 
> Ip:
>     4107083 total packets received
>     4107083 incoming packets delivered
>     1401376 requests sent out
> Tcp:
>     2 passive connection openings
>     4107083 segments received
>     1401376 segments send out
> TcpExt:
>     2 TCP sockets finished time wait in fast timer
>     48486 packets directly queued to recvmsg prequeue.
>     1056111048 packets directly received from backlog
>     2273357712 packets directly received from prequeue
>     1819317 packets header predicted
>     2287497 packets header predicted and directly queued to user
>     4 acknowledgments not containing data received
>     10 predicted acknowledgments
> 
> For the TSO disabled case, there are a huge amount more TCP segments
> sent out (1401376 versus 80050), which I assume are ACKs, and which
> could possibly contribute to the higher throughput for the TSO disabled
> case due to faster feedback, but not explain the lower CPU utilization.
> There are many more packets directly queued to recvmsg prequeue
> (48486 versus 33).  The numbers for packets directly received from
> backlog and prequeue in the TCP disabled case seem bogus to me so
> I don't know how to interpret that.  There are only about half as
> many packets header predicted (1819317 versus 3654842), but there
> are many more packets header predicted and directly queued to user
> (2287497 versus 193).  I'll leave the analysis of all this to those
> who might actually know what it all means.

There are a few interesting things here.  For one, the bursts caused by 
TSO seem to be causing the receiver to do stretch acks.  This may have a 
negative impact on flow performance, but it's hard to say for sure how 
much.  Interestingly, it will even further reduce the CPU load on the 
sender, since it has to process fewer acks.

As I suspected, in the non-TSO case the receiver gets lots of packets 
directly queued to user.  This should result in somewhat lower CPU 
utilization on the receiver.  I don't know if it can account for all the 
difference you see.

The backlog and prequeue values are probably correct, but netstat's 
description is wrong.  A quick look at the code reveals these values are 
in units of bytes, not packets.

   -John
