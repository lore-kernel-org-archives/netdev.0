From: Jon Maloy <jon.maloy@ericsson.com>
Subject: Re: [PATCH net-next 2/3] tipc: byte-based overload control on socket
 receive queue
Date: Tue, 19 Feb 2013 09:07:54 +0100
Message-ID: <512332DA.5040508@ericsson.com>
References: <1360969067-29956-1-git-send-email-paul.gortmaker@windriver.com> <1360969067-29956-3-git-send-email-paul.gortmaker@windriver.com> <20130218144757.GA26199@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Paul Gortmaker <paul.gortmaker@windriver.com>,
	David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>,
	Ying Xue <ying.xue@windriver.com>
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from usevmg21.ericsson.net ([198.24.6.65]:56853 "EHLO
	usevmg21.ericsson.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932288Ab3BSIW6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Feb 2013 03:22:58 -0500
In-Reply-To: <20130218144757.GA26199@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/18/2013 09:47 AM, Neil Horman wrote:
> On Fri, Feb 15, 2013 at 05:57:46PM -0500, Paul Gortmaker wrote:
>> From: Ying Xue <ying.xue@windriver.com>
>>
>> Change overload control to be purely byte-based, using
>> sk->sk_rmem_alloc as byte counter, and compare it to a calculated
>> upper limit for the socket receive queue.

[...]

>> + *
>> + * For all connectionless messages, by default new queue limits are
>> + * as belows:
>> + *
>> + * TIPC_LOW_IMPORTANCE       (5MB)
>> + * TIPC_MEDIUM_IMPORTANCE    (10MB)
>> + * TIPC_HIGH_IMPORTANCE      (20MB)
>> + * TIPC_CRITICAL_IMPORTANCE  (40MB)
>> + *
>> + * Returns overload limit according to corresponding message importance
>> + */
>> +static unsigned int rcvbuf_limit(struct sock *sk, struct sk_buff *buf)
>> +{
>> +	struct tipc_msg *msg = buf_msg(buf);
>> +	unsigned int limit;
>> +
>> +	if (msg_connected(msg))
>> +		limit = CONN_OVERLOAD_LIMIT;
> This still strikes me as a bit wierd.  If you really can't tolerate the default
> rmem settings in proc, have you considered separating the rmem and wmem values
> out into their own sysctls?  

Initially we tried to set this value as default for sk_rcvbuf, and then use
fractions of it as limits, as you suggest below. The problem we found was that
if we want to change this via setsockopt(SOL_SOCKET, SO_RCVBUF) the value range
we can use is very limited, and doesn't fit our purposes.

We did consider to introduce a separate setsockopt at TIPC level for this,
but thought it had a value in itself to use the mechanism that is already there. 
Hence the "re-interpretation" of sk_rcvbuf as we do below.
Considering the weird doubling of this parameter that is done elsewhere in the
code we thought that having our own interpretation might be acceptable.
We did of course see the potential issue with this, that is why we cc-ed
you for comments.
Now I see that David already pulled the series, so I am a little uncertain 
about how to proceed. 
Any comments from David on this?

///jon

Decnet is an example of a protocol that does this
> IIRC.  If you did that, then you wouldn't be mysteriously violating the
> sk_rcvbuf value that gets set on all new sockets (and you could make this
> legitimately tunable).
> 
>> +	else
>> +		limit = sk->sk_rcvbuf << (msg_importance(msg) + 5);
> Same here.  You're using sk_rcvbuf as a base value, rather than a maximum value.
> It seems to me, sk_rcvbuf should be the maximum backlog at which you will store
> incomming messages.  You can discard lower importance messages at fractions of
> sk_rcvbuf if you need to.  If you create separate rmem and wmem sysctls you can
> still make the queue limits you document above work, and you won't violate the
> receive buffer value set in the socket.

> 
> You might also consider looking into adding support for memory accounting, so
> that you can play a little more fast and loose with memory limits on an
> individual socket when the system as a whole isn't under pressure (tcp and sctp
> aer good examples of this).
> 
> Neil
> 
