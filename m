From: Vladislav Yasevich <vladislav.yasevich@hp.com>
Subject: Re: [PATCH] sctp: Enforce maximum retransmissions during shutdown
Date: Thu, 30 Jun 2011 10:08:40 -0400
Message-ID: <4E0C8368.5090502@hp.com>
References: <20110629135704.GB10085@canuck.infradead.org> <4E0B3491.1060603@hp.com> <20110629143649.GC10085@canuck.infradead.org> <4E0B3DA1.9060200@hp.com> <20110629154814.GD10085@canuck.infradead.org> <4E0B4F71.4020108@hp.com> <20110630084933.GA24074@canuck.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, davem@davemloft.net,
	Wei Yongjun <yjwei@cn.fujitsu.com>,
	Sridhar Samudrala <sri@us.ibm.com>, linux-sctp@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0026.austin.hp.com ([15.216.28.33]:5069 "EHLO
	g1t0026.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752014Ab1F3OIq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Jun 2011 10:08:46 -0400
In-Reply-To: <20110630084933.GA24074@canuck.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/30/2011 04:49 AM, Thomas Graf wrote:
> On Wed, Jun 29, 2011 at 12:14:41PM -0400, Vladislav Yasevich wrote:
>> Right.  The lack of ABORT from the receive of data is a bug.  I was trying to point out
>> that instead of modified the sender of data to send the ABORT, you modify the receiver
>> to send the ABORT when it is being closed while having data queued.
> 
> Agreed. This makes a good procedure if there is data is on
> sk_receive_queue and gets us in line with TCP although I don't see this
> in the spec at all :-)
> 
>> But we don't even get to sending the SHUTDOWN, so from the wire protocol, we
>> do not violated it.  We have bad behavior in that when both sender and receiver
>> are dead, the association is hung.
> 
> So how do we get out if ...
> 
> 1) there is nothing queued on sk_receive_queue but the window still
>    remains 0 forver?

sk_receive_queue isn't the only queue you have to check.  You'll need to check
the reassembly and ordering queues, as partial or out of order things might stuck
there.  That's would be an extremely rare condition since if we ever get here, the
first thing we do is reneg on those TSN and open the window to get the missing chunk
in and push complete packet up to sk_receive_queue.

>    
> 2) the receiver is an older Linux without the above fix or another stack
>    that does not ABORT?

crap....

How about this.  If we in SHUTDOWN_PENDING state, let the errors accumulate upto
max_retrans.  After that, start SHUTDOWN_GUARD timer to let the association live a
bit longer just on the off-chance the receive comes back.  When SHUTDOWN_GUARD
expires it will abort the association.

When we are in this state, SACK processing will have to reset SHUTDOWN_GUARD when
the SACK is actually acknowledging something.

> 
> I agree that using ABORT on the receiver is the ideal way whenver
> possible but we still need to fix this if the receiver does not do so.
> 
> What sideeffects are you worried about resulting from my proposal?
> 

There is a potential that the sender may abort prematurely.  The issue is that
the sender has no way of knowing if the remote process somehow terminated and
will never consume data, or if it is just extremely busy with something else and
will come back.  Since this is a reliable protocol, we given the receive the benefit
of the doubt and try our hardest to get the data across.

My suggestion above is still a bit of a hack that one could argue still violates the
protocol, but the time period tries to remove as much doubt from the sender as possible
the the receiver is really out-to-lunch.

-vlad
