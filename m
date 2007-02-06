From: John Heffner <jheffner@psc.edu>
Subject: Re: [PATCH] apply cwnd rules to FIN packets with data
Date: Mon, 05 Feb 2007 19:11:09 -0500
Message-ID: <45C7C79D.1070707@psc.edu>
References: <45C7A87A.5050200@psc.edu>	<20070205.145615.92339659.davem@davemloft.net>	<45C7B77B.9060506@psc.edu> <20070205.150815.112291591.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------060600000500080900040808"
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailer2.psc.edu ([128.182.66.106]:58370 "EHLO mailer2.psc.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965134AbXBFALO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 Feb 2007 19:11:14 -0500
In-Reply-To: <20070205.150815.112291591.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------060600000500080900040808
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

David Miller wrote:
>> However, I can't think of any reason why the cwnd test should not 
>> apply.
> 
> Care to elaborate here?  You can view the FIN special case as an off
> by one error in the CWND test, it's not going to melt the internet.
> :-)

True, it's not going to melt the internet, but why stop at one when two 
would finish the connection even faster?  Not sure I buy this argument. 
  Was there some benchmarking data that was a justification for this in 
the first place?

My first patch was broken anyway (should not have pulled the test from 
tso_should_defer), and the change is not needed to the nagle test since 
it's implicit.  This patch just restores the old behavior from before 
TSO, sending the FIN when it's the last true segment.  We can debate the 
merits of applying congestion control to the FIN separately. :)

   -John

--------------060600000500080900040808
Content-Type: text/plain; x-mac-type="0"; x-mac-creator="0";
 name="fin_cwnd1.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="fin_cwnd1.patch"

Don't apply FIN exception to full TSO segments.

Signed-off-by: John Heffner <jheffner@psc.edu>

---
commit 89de0d8cb75958b0315c076b31a597143e30f7a4
tree 7e9c321e62729c6ef76e3886fe9edf2ac78a680c
parent c0d4d573feed199b16094c072e7cb07afb01c598
author John Heffner <jheffner@psc.edu> Mon, 05 Feb 2007 18:42:31 -0500
committer John Heffner <jheffner@psc.edu> Mon, 05 Feb 2007 18:42:31 -0500

 net/ipv4/tcp_output.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 975f447..58b7111 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -965,7 +965,8 @@ static inline unsigned int tcp_cwnd_test
 	u32 in_flight, cwnd;
 
 	/* Don't be strict about the congestion window for the final FIN.  */
-	if (TCP_SKB_CB(skb)->flags & TCPCB_FLAG_FIN)
+	if ((TCP_SKB_CB(skb)->flags & TCPCB_FLAG_FIN) &&
+	    tcp_skb_pcount(skb) == 1)
 		return 1;
 
 	in_flight = tcp_packets_in_flight(tp);

--------------060600000500080900040808--
