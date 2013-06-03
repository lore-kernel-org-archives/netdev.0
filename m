From: Ying Xue <ying.xue@windriver.com>
Subject: Re: [PATCH net-next 01/12] tipc: change socket buffer overflow control
 to respect sk_rcvbuf
Date: Mon, 3 Jun 2013 17:55:06 +0800
Message-ID: <51AC67FA.2040001@windriver.com>
References: <1369942577-39563-1-git-send-email-paul.gortmaker@windriver.com> <1369942577-39563-2-git-send-email-paul.gortmaker@windriver.com> <20130531133642.GA2727@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Paul Gortmaker <paul.gortmaker@windriver.com>,
	David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>,
	Jon Maloy <jon.maloy@ericsson.com>,
	Erik Hugne <erik.hugne@ericsson.com>
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.windriver.com ([147.11.146.13]:60728 "EHLO
	mail1.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753880Ab3FCJza (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Jun 2013 05:55:30 -0400
In-Reply-To: <20130531133642.GA2727@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/31/2013 09:36 PM, Neil Horman wrote:
> On Thu, May 30, 2013 at 03:36:06PM -0400, Paul Gortmaker wrote:
>> From: Jon Maloy <jon.maloy@ericsson.com>
>>
>> As per feedback from the netdev community, we change the buffer
>> overflow protection algorithm in receiving sockets so that it
>> always respects the nominal upper limit set in sk_rcvbuf.
>>
>> Instead of scaling up from a small sk_rcvbuf value, which leads to
>> violation of the configured sk_rcvbuf limit, we now calculate the
>> weighted per-message limit by scaling down from a much bigger value,
>> still in the same field, according to the importance priority of the
>> received message.
>>
>> Cc: Neil Horman <nhorman@tuxdriver.com>
>> Signed-off-by: Jon Maloy <jon.maloy@ericsson.com>
>> Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
>> ---
>>  net/tipc/socket.c | 13 +++++++------
>>  1 file changed, 7 insertions(+), 6 deletions(-)
>>
>> diff --git a/net/tipc/socket.c b/net/tipc/socket.c
>> index 515ce38..2dfabc7 100644
>> --- a/net/tipc/socket.c
>> +++ b/net/tipc/socket.c
>> @@ -1,7 +1,7 @@
>>  /*
>>   * net/tipc/socket.c: TIPC socket API
>>   *
>> - * Copyright (c) 2001-2007, 2012 Ericsson AB
>> + * Copyright (c) 2001-2007, 2012-2013, Ericsson AB
>>   * Copyright (c) 2004-2008, 2010-2012, Wind River Systems
>>   * All rights reserved.
>>   *
>> @@ -203,6 +203,7 @@ static int tipc_create(struct net *net, struct socket *sock, int protocol,
>>  
>>  	sock_init_data(sock, sk);
>>  	sk->sk_backlog_rcv = backlog_rcv;
>> +	sk->sk_rcvbuf = CONN_OVERLOAD_LIMIT;
> The last time Jon and I discussed this, I thought the consensus was to export
> sk_rcvbuf via its own sysctl, or tie it to sysctl_rmem (while requiring a
> protocol specific minimum on top of that), so administrators on memory
> constrained systems didn't wonder why their sysctl changes weren't being
> honored.

Yes, your suggestion is reasonable, and I prefer to involve
net.tipc.sysctl_rmem. But I have one question about it:

As you suggested as belows, the default value of sk->sk_rcvbuf is set to
sk->sk_rcvbuf >> 4 << msg_importance(TIPC_CRITICAL_IMPORTANCE), that is,
sk->sk_rcvbuf is about 32MB.

However, please see below code:

int sock_setsockopt()
{
...
	        case SO_RCVBUF:
                /* Don't error on this BSD doesn't and if you think
                 * about it this is right. Otherwise apps have to
                 * play 'guess the biggest size' games. RCVBUF/SNDBUF
                 * are treated in BSD as hints
                 */
                val = min_t(u32, val, sysctl_rmem_max);
set_rcvbuf:
                sk->sk_userlocks |= SOCK_RCVBUF_LOCK;
                /*
                 * We double it on the way in to account for
                 * "struct sk_buff" etc. overhead.   Applications
                 * assume that the SO_RCVBUF setting they make will
                 * allow that much actual data to be received on that
                 * socket.
                 *
                 * Applications are unaware that "struct sk_buff" and
                 * other overheads allocate from the receive buffer
                 * during socket buffer allocation.
                 *
                 * And after considering the possible alternatives,
                 * returning the value we actually used in getsockopt
                 * is the most desirable behavior.
                 */
                sk->sk_rcvbuf = max_t(u32, val * 2, SOCK_MIN_RCVBUF);
                break;
...
}

>From above logic of setting sk->sk_rcvbuf with SO_RCVBUF, it only
permits the maximum value of sk->sk_rcvbuf to sysctl_rmem_max * 2(ie,
about 400KB normally).

So, even if the default value of sk->sk_rcvbuf is set to 32MB with
net.tipc.sysctl_rmem, a bit smaller value than the default value can
never be set to sk->sk_rcvbuf successfully with SO_RCVBUF option.

How can we avoid the limit?

Regards,
Ying

> 
>>  	sk->sk_data_ready = tipc_data_ready;
>>  	sk->sk_write_space = tipc_write_space;
>>  	tipc_sk(sk)->p = tp_ptr;
>> @@ -1233,10 +1234,10 @@ static u32 filter_connect(struct tipc_sock *tsock, struct sk_buff **buf)
>>   * For all connectionless messages, by default new queue limits are
>>   * as belows:
>>   *
>> - * TIPC_LOW_IMPORTANCE       (5MB)
>> - * TIPC_MEDIUM_IMPORTANCE    (10MB)
>> - * TIPC_HIGH_IMPORTANCE      (20MB)
>> - * TIPC_CRITICAL_IMPORTANCE  (40MB)
>> + * TIPC_LOW_IMPORTANCE       (4 MB)
>> + * TIPC_MEDIUM_IMPORTANCE    (8 MB)
>> + * TIPC_HIGH_IMPORTANCE      (16 MB)
>> + * TIPC_CRITICAL_IMPORTANCE  (32 MB)
>>   *
>>   * Returns overload limit according to corresponding message importance
>>   */
>> @@ -1248,7 +1249,7 @@ static unsigned int rcvbuf_limit(struct sock *sk, struct sk_buff *buf)
>>  	if (msg_connected(msg))
>>  		limit = CONN_OVERLOAD_LIMIT;
>>  	else
>> -		limit = sk->sk_rcvbuf << (msg_importance(msg) + 5);
>> +		limit = sk->sk_rcvbuf >> 4 << msg_importance(msg);
> I still don't like this.  I would much prefer that the minimum sk_rcvbuf value
> were defaulted to a value such that:
> sk->sk_rcvbuf >> 4 << msg_importance(TIPC_CRITICAL_IMPORTANCE) = sk->sk_rcvbuf
> i.e. that the minimum sk_rcvbuf size allowed was equal to the size needed to
> hold the maximum number of critical messages TIPC required, and have less
> important messages be a fraction of that.  that, in conjunction with the above
> default setting would allow for administrative tunability, while still giving
> you the receive space you need I think.
> 
> This is much better than what you have there currently though.
> 
> Regards
> Neil
>>  	return limit;
>>  }
>>  
>> -- 
>> 1.8.1.2
>>
>>
> 
> 
