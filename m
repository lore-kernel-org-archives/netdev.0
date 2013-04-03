From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH -next] sctp: fix error return code in __sctp_connect()
Date: Wed, 3 Apr 2013 10:59:09 -0400
Message-ID: <20130403145909.GB32276@hmsreliant.think-freely.org>
References: <CAPgLHd-X5Qw64BnaSMr2ny6==jXGpRAYC7_1MGhP2v_GcVeApQ@mail.gmail.com>
 <20130403135126.GA32276@hmsreliant.think-freely.org>
 <515C4220.6030802@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Wei Yongjun <weiyj.lk@gmail.com>, davem@davemloft.net,
	yongjun_wei@trendmicro.com.cn, linux-sctp@vger.kernel.org,
	netdev@vger.kernel.org
To: Vlad Yasevich <vyasevich@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:36022 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759624Ab3DCO70 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Apr 2013 10:59:26 -0400
Content-Disposition: inline
In-Reply-To: <515C4220.6030802@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 03, 2013 at 10:52:16AM -0400, Vlad Yasevich wrote:
> On 04/03/2013 09:51 AM, Neil Horman wrote:
> >On Wed, Apr 03, 2013 at 09:02:28PM +0800, Wei Yongjun wrote:
> >>From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
> >>
> >>Fix to return a negative error code from the error handling
> >>case instead of 0, as returned elsewhere in this function.
> >>
> >>Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
> >>---
> >>  net/sctp/socket.c | 5 +++--
> >>  1 file changed, 3 insertions(+), 2 deletions(-)
> >>
> >>diff --git a/net/sctp/socket.c b/net/sctp/socket.c
> >>index dd21ae3..f631c5f 100644
> >>--- a/net/sctp/socket.c
> >>+++ b/net/sctp/socket.c
> >>@@ -1119,9 +1119,10 @@ static int __sctp_connect(struct sock* sk,
> >>  		/* Make sure the destination port is correctly set
> >>  		 * in all addresses.
> >>  		 */
> >>-		if (asoc && asoc->peer.port && asoc->peer.port != port)
> >>+		if (asoc && asoc->peer.port && asoc->peer.port != port) {
> >>+			err = -EINVAL;
> >>  			goto out_free;
> >>-
> >>+		}
> >>
> >>  		/* Check if there already is a matching association on the
> >>  		 * endpoint (other than the one created here).
> >>
> >>--
> >>To unsubscribe from this list: send the line "unsubscribe linux-sctp" in
> >>the body of a message to majordomo@vger.kernel.org
> >>More majordomo info at  http://vger.kernel.org/majordomo-info.html
> >>
> >Actually, I think you can remove that entire if statement (as well as some
> >checks further down).  Looking at the net-next trees __sctp_connect, it appears
> >that asoc is set to NULL at the top of the function, and not assigned to
> >anything else until the call to sctp_association_new much farther down (line
> >1201).  That means the above if statement, as well as this:
> >  if (asoc2 && asoc2 != asoc) {
> >and this:
> >if (!asoc) {
> >will always be false, false, and true, respectively.
> 
> No, I don't think you can.  Consider a case of sctp_connectx() where
> each address specified in connectx has a different destination port.
> 
> First time through the loop, we'll create the association and set
> the peer.port.  The second time through the loop, we'll compare the
> that port to the port specified in the second address.  If the ports
> do not match, we need to stop.
> 
> -vlad
Ah, you're right, I missed the while loop, apologies

Acked-by: Neil Horman <nhorman@tuxdriver.com>

> >
> >Regards
> >Neil
> >
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-sctp" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
