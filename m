From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH net-next 2/3] tipc: byte-based overload control on socket
 receive queue
Date: Tue, 19 Feb 2013 09:26:29 -0500
Message-ID: <20130219142629.GA31871@hmsreliant.think-freely.org>
References: <1360969067-29956-1-git-send-email-paul.gortmaker@windriver.com>
 <1360969067-29956-3-git-send-email-paul.gortmaker@windriver.com>
 <20130218144757.GA26199@hmsreliant.think-freely.org>
 <512332DA.5040508@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Paul Gortmaker <paul.gortmaker@windriver.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Ying Xue <ying.xue@windriver.com>
To: Jon Maloy <jon.maloy@ericsson.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:55658 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932906Ab3BSO0k (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Feb 2013 09:26:40 -0500
Content-Disposition: inline
In-Reply-To: <512332DA.5040508@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Feb 19, 2013 at 09:07:54AM +0100, Jon Maloy wrote:
> On 02/18/2013 09:47 AM, Neil Horman wrote:
> > On Fri, Feb 15, 2013 at 05:57:46PM -0500, Paul Gortmaker wrote:
> >> From: Ying Xue <ying.xue@windriver.com>
> >>
> >> Change overload control to be purely byte-based, using
> >> sk->sk_rmem_alloc as byte counter, and compare it to a calculated
> >> upper limit for the socket receive queue.
> 
> [...]
> 
> >> + *
> >> + * For all connectionless messages, by default new queue limits are
> >> + * as belows:
> >> + *
> >> + * TIPC_LOW_IMPORTANCE       (5MB)
> >> + * TIPC_MEDIUM_IMPORTANCE    (10MB)
> >> + * TIPC_HIGH_IMPORTANCE      (20MB)
> >> + * TIPC_CRITICAL_IMPORTANCE  (40MB)
> >> + *
> >> + * Returns overload limit according to corresponding message importance
> >> + */
> >> +static unsigned int rcvbuf_limit(struct sock *sk, struct sk_buff *buf)
> >> +{
> >> +	struct tipc_msg *msg = buf_msg(buf);
> >> +	unsigned int limit;
> >> +
> >> +	if (msg_connected(msg))
> >> +		limit = CONN_OVERLOAD_LIMIT;
> > This still strikes me as a bit wierd.  If you really can't tolerate the default
> > rmem settings in proc, have you considered separating the rmem and wmem values
> > out into their own sysctls?  
> 
> Initially we tried to set this value as default for sk_rcvbuf, and then use
> fractions of it as limits, as you suggest below. The problem we found was that
> if we want to change this via setsockopt(SOL_SOCKET, SO_RCVBUF) the value range
> we can use is very limited, and doesn't fit our purposes.
> 
Can you elaborate on this please?  The above doesn't really explain why you
can't do what I suggested.  Not asserting that what you say is untrue, mind you,
I'm just trying to understand what it is about TIPC that requires such a
specific reception buffer envelope, and how enforcing queue limits here is so
important when packets could just as easily be dropped at the ip layer (with
ostensibly no fatal failure).

> We did consider to introduce a separate setsockopt at TIPC level for this,
> but thought it had a value in itself to use the mechanism that is already there. 
> Hence the "re-interpretation" of sk_rcvbuf as we do below.
> Considering the weird doubling of this parameter that is done elsewhere in the
> code we thought that having our own interpretation might be acceptable.
Thats quite different IMHO.  The comments in sock_setsockopt make it pretty
clear that the doubling of the rcvbuf value is done to account for the sk_buff
overhead of packet reception, and thats documented in the socket(7) man page.
What you have here is the ability to set sk_rcvbuf, and then have that setting
be ignored, but only to within several different limits, depending on various
conditions, all of which are not visible to user space.

> We did of course see the potential issue with this, that is why we cc-ed
> you for comments.
I appreciate that.

> Now I see that David already pulled the series, so I am a little uncertain 
> about how to proceed. 
I saw that too, and asked him about this.  A follow-on patch (if we wind up
deciding one is warranted) is the way to go here.

Regards
Neil
