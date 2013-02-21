From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH net-next 2/3] tipc: byte-based overload control on socket
 receive queue
Date: Thu, 21 Feb 2013 16:35:28 -0500
Message-ID: <20130221213528.GA32764@hmsreliant.think-freely.org>
References: <20130219142629.GA31871@hmsreliant.think-freely.org>
 <5123BC46.40909@ericsson.com>
 <20130219191833.GB31871@hmsreliant.think-freely.org>
 <5123DDA8.5090202@ericsson.com>
 <20130219214439.GC31871@hmsreliant.think-freely.org>
 <5125F5D3.1000509@ericsson.com>
 <20130221150746.GA2730@shamino.rdu.redhat.com>
 <51265134.5080001@ericsson.com>
 <20130221181656.GC2730@shamino.rdu.redhat.com>
 <51268C21.8050602@donjonn.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jon Maloy <jon.maloy@ericsson.com>,
	Paul Gortmaker <paul.gortmaker@windriver.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Ying Xue <ying.xue@windriver.com>
To: Jon Maloy <maloy@donjonn.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:36877 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751698Ab3BUVfq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Feb 2013 16:35:46 -0500
Content-Disposition: inline
In-Reply-To: <51268C21.8050602@donjonn.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Feb 21, 2013 at 10:05:37PM +0100, Jon Maloy wrote:
> On 02/21/2013 07:16 PM, Neil Horman wrote:
> > On Thu, Feb 21, 2013 at 05:54:12PM +0100, Jon Maloy wrote:
> >> On 02/21/2013 04:07 PM, Neil Horman wrote:
> >>> On Thu, Feb 21, 2013 at 11:24:19AM +0100, Jon Maloy wrote:
> >>>> On 02/19/2013 10:44 PM, Neil Horman wrote:
> >>>>> On Tue, Feb 19, 2013 at 09:16:40PM +0100, Jon Maloy wrote:
> >>>>>> On 02/19/2013 08:18 PM, Neil Horman wrote:
> >>>>>>> On Tue, Feb 19, 2013 at 06:54:14PM +0100, Jon Maloy wrote:
> >>>>>>>> On 02/19/2013 03:26 PM, Neil Horman wrote:
> >>>>>>>>> On Tue, Feb 19, 2013 at 09:07:54AM +0100, Jon Maloy wrote:
> >>>>>>>>>> On 02/18/2013 09:47 AM, Neil Horman wrote:
> >>>>>>>>>>> On Fri, Feb 15, 2013 at 05:57:46PM -0500, Paul Gortmaker wrote:
> >>>>>>>>>>>> From: Ying Xue <ying.xue@windriver.com>
> >>>>>> <snip>
> >> I wouldn't call it a bug, because it doesn't cause deadlock in the current code,
> >> but it is clearly a design that can be improved.
> > I don't understand this - Above you said you could demonstrate how my proposal
> > (which was to drop packets when they surpassed the sk_rcvbuf limit), would cause
> > deadlock - if that happens, you have a locking bug.  If the only reason this
> > does not happen currently is because you allow for a large overrun of your
> > set sk_rcvbuf, then ostensibly a lockup can still be triggered if you have a
> > misbehaving sender that is willing to send frames past its congestion window.
> > So I think the root question here is: Does the code currently deadlock if you
> > drop frames in the receive path? 
> No. We can drop as as many as we want, the retransmission protocol will
> take hand of that, and that part is pretty robust by now.
> But it *would* deadlock if we tried to read fields in the sock structure, with
> the necessary grabbing of locks that involves, from within the scope of
> tipc_recv_msg, which is at a completely different level in the stack.
> 
> Since we don't do that in the current code, there is no deadlock problem.
> 
Theres tons of protocols that read socket structures that low in the receive
path, in fact (with the exception of TIPC) they all do, specifically for the
purpose of being able to check, among other things, the socket buffer recieve
limit.  See sctp_rcv, tcp_v4_rcv, tcp_v6_rcv, _udp4_lib_rcv, etc for examples.
Looking at tipc_recv_msg, it looks to me like you need to grab the
tipc_port_lock for a short critical section to get the tipc_port struct, from
which (as we previously discussed, you can get the socket).  Presuming you've
done appropriate reference counting on your socket, thats it.  One lock, that
you take and release in several other places in the same call path.

Neil

> ///jon
> 
> [...]
> >
> >>>>
> >>
> 
> 
