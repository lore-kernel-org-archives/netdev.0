From: Jon Maloy <jon.maloy@ericsson.com>
Subject: Re: [PATCH net-next 03/10] tipc: sk_recv_queue size check only for
 connectionless sockets
Date: Fri, 7 Dec 2012 17:30:11 -0500
Message-ID: <50C26DF3.90409@ericsson.com>
References: <1354890498-6448-1-git-send-email-paul.gortmaker@windriver.com> <1354890498-6448-4-git-send-email-paul.gortmaker@windriver.com> <20121207192030.GA30339@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Paul Gortmaker <paul.gortmaker@windriver.com>,
	David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>,
	Ying Xue <ying.xue@windriver.com>
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from imr4.ericy.com ([198.24.6.9]:42169 "EHLO imr4.ericy.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755486Ab2LGWlt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 7 Dec 2012 17:41:49 -0500
In-Reply-To: <20121207192030.GA30339@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/07/2012 02:20 PM, Neil Horman wrote:
> On Fri, Dec 07, 2012 at 09:28:11AM -0500, Paul Gortmaker wrote:
>> From: Ying Xue <ying.xue@windriver.com>
>>
>> The sk_receive_queue limit control is currently performed for
>> all arriving messages, disregarding socket and message type.
>> But for connected sockets this check is redundant, since the protocol
>> flow control already makes queue overflow impossible.
>>
> Can you explain where that occurs?  

It happens in the functions port_dispatcher_sigh() and tipc_send(), 
among other places. Both are to be found in the file port.c, which 
was supposed to contain the 'generic' (i.e., API independent) part 
of the send/receive code.
Now that we have only one API left, the socket API, we are 
planning to merge the code in socket.c and port.c, and get rid of 
some code overhead.

The flow control in TIPC is message based, where the sender
requires to receive an explicit acknowledge message for each 
512 message the receiver reads to user space.
If the sender has more than 1024 messages outstanding without having
received an acknowledge he will be suspended or receive EAGAIN until 
he does.
The plan going forward is to replace this mechanism with a more 
standard looking byte based flow control, while maintaining 
backwards compatibility.


> I see where the tipc dispatch function calls
> sk_add_backlog, which checks the per socket recieve queue (regardless of weather
> the receiving socket is connection oriented or connectionless), but if the
> receiver doesn't call receive very often, This just adds a check against your
> global limit, doing nothing for your per-socket limits. 

OVERLOAD_LIMIT_BASE is tested against a per-socket message counter, so it _is_
our per-socket limit. In fact, TIPC connectionless overflow control currently 
is a kind of a hybrid, based on a message counter when the socket is not locked, 
and based on sk_rcv_queue's byte limit when a message has to be added to the 
backlog.
We are planning to fix this inconsistency too.

 In fact it seems to
> repeat the same check twice, as in the worst case of the incomming message being
> TIPC_LOW_IMPORTANCE, its just going to check that the global limit is exactly
> OVERLOAD_LIMIT_BASE/2 again.

Yes, you are right. The intention is that only the first test, 
if (unlikely(recv_q_len >= (OVERLOAD_LIMIT_BASE / 2)){..}
will be run for the vast majority of messages, since we must assume
that there is no overload most of the time.
An inelegant optimization, perhaps, but not logically wrong.

///jon

> 
> Neil
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
