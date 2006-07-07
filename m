From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: What is RDMA (was: RDMA will be reverted)
Date: Fri, 7 Jul 2006 18:11:31 +1000
Message-ID: <20060707081131.GA2991@gondor.apana.org.au>
References: <adaac7naj80.fsf@cisco.com> <20060705.200325.74731166.davem@davemloft.net> <1152163503.20248.98.camel@trinity.ogc.int> <20060706.235320.92562667.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: tom@opengridcomputing.com, rdreier@cisco.com,
	netdev@vger.kernel.org, akpm@osdl.org,
	Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:19474 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S932071AbWGGILz
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 7 Jul 2006 04:11:55 -0400
To: David Miller <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20060706.235320.92562667.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jul 07, 2006 at 06:53:20AM +0000, David Miller wrote:
> 
> What I am saying, however, is that we need to understand the
> technology and the hooks you guys want before we put any of it in.

Yes indeed.

Here is what I've understood so far so let's see if we can start building
a censensus.

1) RDMA over straight Infiniband is not contentious.  In this case no
   IP networking is involved.

2) RDMA over TCP/IP (or SCTP) can theoretically run on any network that
   supported IP, including Infiniband and Ethernet.

3) When RDMA over TCP is completely done in hardware, i.e., it has its
   own IP address, MAC address, and simply presents an RDMA interface
   (whatever that may be) to Linux, we're OK with it.

   This is similar to how some iSCSI adapters work.

4) When RDMA over TCP is done completely in the Linux networking stack,
   we don't have a problem because the existing TCP stack is still in
   charge.  However, this is pretty pointless.

5) RDMA over TCP on the receive side is offloaded into the NIC.  This
   allows the NIC to directly place data into the application's buffer.  

   We're starting to have a little bit of a problem because it means that
   part of the incoming IP traffic is now being directly processed by the
   NIC, with no input from the Linux TCP/IP stack.

   However, as long as the connection establishment/acks are still
   controlled/seen by Linux we can probably live with it.

6) RDMA over TCP on the transmit side is offloaded into the NIC.  This
   is starting to look very worrying.

   The reason is that we lose all control to crucial aspects of TCP like
   congestion control.  It is now completely up to the NIC to do that.
   For straight RDMA over Infiniband this isn't an issue because the
   traffic is not likely to travel across the Internet.

   However, for RDMA over TCP, one of their goals is to support sending
   traffic over the Internet so this is a concern.  Incidentally, this is
   why they need to know about things like MAC/route/MTU changing.

7) RDMA over TCP is completely offloaded into the NIC, however, they still
   use Linux's IP address, MAC address, and rely on us to tell it about
   events such as MTU updates or MAC changes.

   In addition to the problems we have in 5) and 6), we now have a portion
   of TCP port space which has suddenly become invisible to Linux.  What's
   more, we lose control (e.g., netfilter) over what connections may or
   may not be established.

So to my mind, RDMA over TCP is most problematic when it shares the same
IP/MAC address as the Linux host, and when the transmit side and/or the
connection establishment (case 6 and 7) is offloaded into the NIC.  This
also happens to be the only scenario where they need the notification
patch that started all this discussion.

BTW, this URL gives an interesting perspective on RDMA over TCP
(particularly Q14/Q15):

http://www.rdmaconsortium.org/home/FAQs_Apr25.htm

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
