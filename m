From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH net-next 2/3] tipc: byte-based overload control on socket
 receive queue
Date: Fri, 22 Feb 2013 07:08:11 -0500
Message-ID: <20130222120811.GA8680@hmsreliant.think-freely.org>
References: <20130219191833.GB31871@hmsreliant.think-freely.org>
 <5123DDA8.5090202@ericsson.com>
 <20130219214439.GC31871@hmsreliant.think-freely.org>
 <5125F5D3.1000509@ericsson.com>
 <20130221150746.GA2730@shamino.rdu.redhat.com>
 <51265134.5080001@ericsson.com>
 <20130221181656.GC2730@shamino.rdu.redhat.com>
 <51268C21.8050602@donjonn.com>
 <20130221213528.GA32764@hmsreliant.think-freely.org>
 <5127541C.9070306@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jon Maloy <maloy@donjonn.com>,
	Paul Gortmaker <paul.gortmaker@windriver.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Ying Xue <ying.xue@windriver.com>
To: Jon Maloy <jon.maloy@ericsson.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:44081 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754337Ab3BVMI1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Feb 2013 07:08:27 -0500
Content-Disposition: inline
In-Reply-To: <5127541C.9070306@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Feb 22, 2013 at 12:18:52PM +0100, Jon Maloy wrote:
> On 02/21/2013 10:35 PM, Neil Horman wrote:
> > On Thu, Feb 21, 2013 at 10:05:37PM +0100, Jon Maloy wrote:
> >> On 02/21/2013 07:16 PM, Neil Horman wrote:
> >>> On Thu, Feb 21, 2013 at 05:54:12PM +0100, Jon Maloy wrote:
> >>>> On 02/21/2013 04:07 PM, Neil Horman wrote:
> >>>>> On Thu, Feb 21, 2013 at 11:24:19AM +0100, Jon Maloy wrote:
> >>>>>> On 02/19/2013 10:44 PM, Neil Horman wrote:
> >>>>>>> On Tue, Feb 19, 2013 at 09:16:40PM +0100, Jon Maloy wrote:
> >>>>>>>> On 02/19/2013 08:18 PM, Neil Horman wrote:
> >>>>>>>>> On Tue, Feb 19, 2013 at 06:54:14PM +0100, Jon Maloy wrote:
> >>>>>>>>>> On 02/19/2013 03:26 PM, Neil Horman wrote:
> >>>>>>>>>>> On Tue, Feb 19, 2013 at 09:07:54AM +0100, Jon Maloy wrote:
> >>>>>>>>>>>> On 02/18/2013 09:47 AM, Neil Horman wrote:
> >>>>>>>>>>>>> On Fri, Feb 15, 2013 at 05:57:46PM -0500, Paul Gortmaker wrote:
> >>>>>>>>>>>>>> From: Ying Xue <ying.xue@windriver.com>
> >>>>>>>> <snip>
><snip>
> 
> grab net lock (read mode)
>    <do some packet sanity check>
>    grab node lock
> -->   grab port lock
>         grab socket lock
>            <check sk_rcvbuf>
>         release socket lock
> -->   release port lock
>       <perform link level protocol check>
>     release node lock
> release net lock
> grab port lock
>   grab socket lock
>      <check sk_rcvbuf>
>      <deliver or reject>
>   release socket lock
> release port lock
>  
> I.e., deadlock would occur almost immediately.
> 
> 
> Now, having slept on it, I see we could also do:
> -----------------------------------------------
> 
> grab port lock
>    grab socket lock
>        check sk_rcvbuf>
>    release socket lock
> release port lock
> grab net lock (read mode)
>      <do some packet sanity check>
>      grab node lock
>         <perform link level protocol check>
>      release node lock'
> release net lock'
> grab port lock
>   grab socket lock
>      <check sk_rcvbuf>
>      <deliver or reject>
>   release socket lock
> release port lock
> 
> If this is what you meant, then you are right.
Yes, this is one of the options I had meant.  Another one would be to pass a
reference of b_ptr up to the dispatch function (as everthing else is discernable
from the message buffer), and send the ack from there.

> It would work, although it would severely impact performance.
> 
> But the fact that it works technically doesn't mean it is the 
> right thing to do, because of the way it would mess up the 
> overall packet flow. 
> This is not a good solution! 
> 
How many times have we gone over this?
A) Impacting performance isn't an excuse for being able to overwhelm a system by
flooding it with traffic

B) I'm not advocating that you lower you receive buffer limit by default, only
that if someone chooses to, they be able to do so (and accept the performance
consequences thereof).

> And I think there are better ways...
> If we really want to improve the solution we agreed on
> yesterday we should rather go for a scheme adding back-pressure
> to the sender socket, even for connectionless datagram messages, 
As long as you drop frames when you supercede the limits set by the user on your
socket buffer, sure.

> not only connections as we do now. We have some ideas there, and 
> you are welcome to participate in the discussions. 
> Maybe another thread at tipc-discussion?
> 
Sure

> Regards
> ///jon
> 
> 
> 
> 
> > 
> > Neil
> > 
> >> ///jon
> >>
> >> [...]
> >>>
> >>>>>>
> >>>>
> >>
> >>
> 
> 
