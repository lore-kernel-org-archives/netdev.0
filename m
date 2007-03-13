From: John Heffner <jheffner@psc.edu>
Subject: Re: SWS for rcvbuf < MTU
Date: Tue, 13 Mar 2007 15:01:50 -0400
Message-ID: <45F6F51E.6090905@psc.edu>
References: <200703021521.58821.alexandre.sidorenko@hp.com> <20070302.133839.17868570.davem@davemloft.net> <45EA075C.5010406@psc.edu> <200703051152.27780.alexandre.sidorenko@hp.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------070502060706050303030208"
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Alex Sidorenko <alexandre.sidorenko@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailer2.psc.edu ([128.182.66.106]:51732 "EHLO mailer2.psc.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932966AbXCMTCN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 Mar 2007 15:02:13 -0400
In-Reply-To: <200703051152.27780.alexandre.sidorenko@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------070502060706050303030208
Content-Type: text/plain; charset=iso-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Alex Sidorenko wrote:
> Here are the values from live kernel (obtained with 'crash') when the host was 
> in SWS state:
> 
> full_space=708		full_space/2=354
> free_space=393
> window=76
> 
> In this case the test from my original fix, (window < full_space/2),  
> succeeds. But John's test
> 
> free_space > window + full_space/2
> 393          430
> 
> does not. So I suspect that the new fix will not always work. From tcpdump 
> traces we can see that both hosts exchange with 76-byte packets for a long 
> time. From customer's application log we see that it continues to read 
> 76-byte chunks per each read() call - even though more than that is available 
> in the receive buffer. Technically it's OK for read() to return even after 
> reading one byte, so if sk->receive_queue contains multiple 76-byte skbuffs 
> we may return after processing just one skbuff (but we we don't understand 
> the details of why this happens on customer's system).
> 
> Are there any particular reasons why you want to postpone window update until 
> free_space becomes > window + full_space/2 and not as soon as 
> free_space > full_space/2? As the only real-life occurance of SWS shows 
> free_space oscillating slightly above full_space/2, I created the fix 
> specifically to match this phenomena as seen on customer's host. We reach the 
> modified section only when (free_space > full_space/2) so it should be OK to 
> update the window at this point if mss==full_space. 
> 
> So yes, we can test John's fix on customer's host but I doubt it will work for 
> the reasons mentioned above, in brief:
> 
> 'window = free_space' instead of 'window=full_space/2' is OK,
> but the test 'free_space > window + full_space/2' is not for the specific 
> pattern customer sees on his hosts.


Sorry for the long delay in response, I've been on vacation.  I'm okay 
with your patch, and I can't think of any real problem with it, except 
that the behavior is non-standard.  Then again, Linux acking in general 
is non-standard, which has created the bug in the first place. :)  The 
only thing I can think where it might still ack too often is if 
free_space frequently drops just below full_space/2 for a bit then rises 
above full_space/2.

I've also attached a corrected version of my earlier patch that I think 
solves the problem you noted.

Thanks,
   -John

--------------070502060706050303030208
Content-Type: text/plain; x-mac-type="0"; x-mac-creator="0";
 name="rcv-sws.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="rcv-sws.patch"

Do full receiver-side SWS avoidance when rcvbuf < mss.

Signed-off-by: John Heffner <jheffner@psc.edu>

---
commit f4333661026621e15549fb75b37be785e4a1c443
tree 30d46b64ea19634875fdd4656d33f76db526a313
parent 562aa1d4c6a874373f9a48ac184f662fbbb06a04
author John Heffner <jheffner@psc.edu> Tue, 13 Mar 2007 14:17:03 -0400
committer John Heffner <jheffner@psc.edu> Tue, 13 Mar 2007 14:17:03 -0400

 net/ipv4/tcp_output.c |    9 ++++++++-
 1 files changed, 8 insertions(+), 1 deletions(-)

diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index dc15113..e621a63 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -1605,8 +1605,15 @@ u32 __tcp_select_window(struct sock *sk)
 		 * We also don't do any window rounding when the free space
 		 * is too small.
 		 */
-		if (window <= free_space - mss || window > free_space)
+		if (window <= free_space - mss || window > free_space) {
 			window = (free_space/mss)*mss;
+		} else if (mss == full_space) {
+			/* Do full receive-side SWS avoidance
+			 * when rcvbuf <= mss */
+			window = tcp_receive_window(tp);
+			if (free_space > window + full_space/2)
+				window = free_space;
+		}
 	}
 
 	return window;

--------------070502060706050303030208--
