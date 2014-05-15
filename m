From: Jon Maloy <maloy@donjonn.com>
Subject: Re: [PATCH net-next v2 2/8] tipc: compensate for
 double accounting in socket rcv buffer
Date: Thu, 15 May 2014 09:25:24 -0400
Message-ID: <5374C044.6040802@donjonn.com>
References: <1400060355-26308-1-git-send-email-jon.maloy@ericsson.com>		
	<1400060355-26308-3-git-send-email-jon.maloy@ericsson.com>		
	<1400068021.7973.78.camel@edumazet-glaptop2.roam.corp.google.com>		
	<A2BAEFC30C8FD34388F02C9B3121859D1C25134A@eusaamb103.ericsson.se>	
	<1400089542.7973.104.camel@edumazet-glaptop2.roam.corp.google.com>	
	<5373BD5C.9030703@donjonn.com>
	<1400096531.7973.123.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Jon Maloy <jon.maloy@ericsson.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Paul Gortmaker <paul.gortmaker@windriver.com>,
	"tipc-discussion@lists.sourceforge.net"
	<tipc-discussion@lists.sourceforge.net>,
	"davem@davemloft.net" <davem@davemloft.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <tipc-discussion-bounces@lists.sourceforge.net>
In-Reply-To: <1400096531.7973.123.camel@edumazet-glaptop2.roam.corp.google.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=tipc-discussion>
List-Post: <mailto:tipc-discussion@lists.sourceforge.net>
List-Help: <mailto:tipc-discussion-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=subscribe>
Errors-To: tipc-discussion-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On 05/14/2014 03:42 PM, Eric Dumazet wrote:
> On Wed, 2014-05-14 at 15:00 -0400, Jon Maloy wrote:
>
>> This is where I don't get it.
>>
>> sk_add_backlog(limit) is (via sk_rcvqueues_full) testing for
>>
>>  (sk_backlog.len + sk_rmem_alloc) > limit
>>
>> But, if the receiving user is slow, sk_rmem_alloc will run full eventually, even if we
>> reduce sk_backlog.len with truesize of each transferred buffer, and sk_add_backlog
>> should then start throwing away packets. Why doesn't this happen?
> It definitely can happen if sender tries to send small packets, that
> have a high truesize/len ratio.
>
> $ nstat -a | egrep "TcpExtTCPBacklogDrop|IpInReceives|TcpExtTCPRcvCoalesce"
> IpInReceives                    8357544624         0.0
> TcpExtTCPBacklogDrop            13                 0.0
> TcpExtTCPRcvCoalesce            437826621          0.0
>
> You claim that "that sk_backlog.len does not
> give correct information about the buffer situation.", but really it
> does.

                                 Backlog Q     Recv Q     Total:   Reported
                                 -------------     ---------     ------    -----------
bef. release_sock:        2 kB            0 kB        2 kB      2 kB
during rel_lock:           0 kB             2 kB        2 kB     4 kB
after rel_lock:              0 kB             2 kB       2 kB      2 kB

But I guess you understand this, so you must mean something else
when you say it gives a "correct information".
To me it looks wrong.

My perception of those queues is that they really are part of the
same logical queue, whose combined size must not exceed the
configured upper socket limit, otherwise we violate the rules we
are supposed to obey to regarding memory consumption per socket.


>
> Your problem seems that you do not use the appropriate 'limit',
> or assume very tight scheduling constraints (An incoming packet has to
> be immediately consumed by receiver, otherwise following packet might be
> dropped)

Relating to the above, the 'limit' we use in TIPC  is the same both for
sk_add_backlog() and in tipc_filter_rcv(), so we can have a somewhat
deterministic behavior. But, given that the 'reported' value (the
one used by sk_add_backlog() ) is not correct at all moments, we
end up with seeing messages unnecessarily rejected. (Note that I
consistently say 'messages' here. In TIPC the units arriving in a socket
are complete, reassembled messages, not packets.)

>
> If rcvbuf_limit(sk, buf) is the limit for normal packets (sk_rmem_alloc)
> in receive queue, then you need something bigger to allow bursts.
>
>
> diff --git a/net/tipc/socket.c b/net/tipc/socket.c
> index 3f9912f87d0d..fe4f37d8029a 100644
> --- a/net/tipc/socket.c
> +++ b/net/tipc/socket.c
> @@ -1457,7 +1457,7 @@ u32 tipc_sk_rcv(struct sock *sk, struct sk_buff *buf)
>  	if (!sock_owned_by_user(sk)) {
>  		res = filter_rcv(sk, buf);
>  	} else {
> -		if (sk_add_backlog(sk, buf, rcvbuf_limit(sk, buf)))
> +		if (sk_add_backlog(sk, buf, 2 * rcvbuf_limit(sk, buf)))

This would work, but is in reality just a cruder version of what I have done.
It would temporarily violate the configured memory constraint, while my
method doesn't.

I should also say that my first idea when I realized this problem was just
to do like this. But given that our (fix) socket buffer limit is already at a crazy
level, I ddn't find it a good idea to double it once more.

Now, since we are planning to post a patch series with byte-based flow control
control in a few months, I would like to avoid ending up in the same discussions
again, and maybe have to redo things. If you are are interested, I could give you
a more thorough background to the TIPC two-level flow control, and involve you
in our discussions. But I am not sure this mailing list is the right forum for that.
Should I  cc you when we start discussing this internally? Only if you have time
and are interested, of course.

Regards
///jon

>  			res = TIPC_ERR_OVERLOAD;
>  		else
>  			res = TIPC_OK;
>
>
>


------------------------------------------------------------------------------
"Accelerate Dev Cycles with Automated Cross-Browser Testing - For FREE
Instantly run your Selenium tests across 300+ browser/OS combos.
Get unparalleled scalability from the best Selenium testing platform available
Simple to use. Nothing to install. Get started now for free."
http://p.sf.net/sfu/SauceLabs
