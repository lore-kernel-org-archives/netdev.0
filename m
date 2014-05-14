From: Jon Maloy <maloy@donjonn.com>
Subject: Re: [PATCH net-next v2 2/8] tipc: compensate for
 double accounting in socket rcv buffer
Date: Wed, 14 May 2014 15:00:44 -0400
Message-ID: <5373BD5C.9030703@donjonn.com>
References: <1400060355-26308-1-git-send-email-jon.maloy@ericsson.com>	
	<1400060355-26308-3-git-send-email-jon.maloy@ericsson.com>	
	<1400068021.7973.78.camel@edumazet-glaptop2.roam.corp.google.com>	
	<A2BAEFC30C8FD34388F02C9B3121859D1C25134A@eusaamb103.ericsson.se>
	<1400089542.7973.104.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Paul Gortmaker <paul.gortmaker@windriver.com>,
	"tipc-discussion@lists.sourceforge.net"
	<tipc-discussion@lists.sourceforge.net>,
	"davem@davemloft.net" <davem@davemloft.net>
To: Eric Dumazet <eric.dumazet@gmail.com>, Jon Maloy <jon.maloy@ericsson.com>
Return-path: <tipc-discussion-bounces@lists.sourceforge.net>
In-Reply-To: <1400089542.7973.104.camel@edumazet-glaptop2.roam.corp.google.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=tipc-discussion>
List-Post: <mailto:tipc-discussion@lists.sourceforge.net>
List-Help: <mailto:tipc-discussion-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=subscribe>
Errors-To: tipc-discussion-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On 05/14/2014 01:45 PM, Eric Dumazet wrote:
> On Wed, 2014-05-14 at 12:53 +0000, Jon Maloy wrote:
>
>> For us, the underlying problem is that sk_backlog.len does not
>> give correct information about the buffer situation.  There is a comment
>> in  _release_sock() trying to explain why.:
>>
>> /*
>>   * Doing the zeroing here guarantee we can not loop forever
>>   * while a wild producer attempts to flood us.
>>   */
>>
>> but I fail to understand how this scenario can happen even with TCP.
>> Yes, it can throw away packets, but not until the receive buffer is full,
>> and then sk_add_backlog() should start rejecting new messages anyway?
>> There is evidently something I have missed here.
> The following can happen :
>
> An innocent user thread does a socket system call.
> It owns the socket.
>
> Then a flood of incoming messages happen, constantly trying to push new
> packets for this socket. Note the packets can be spoofed ones.
>
> Softirq handler notices socket is owned by 'user', so queue packets into
> backlog, unless the sk_rcvbuf limit is hit.
>
> If we were releasing sk_backlog.len for every dequeued skb, we could
> have a deadlock for the innocent user thread, who could never exit from
> __release_sock()
>
> http://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/commit/?id=8eae939f1400326b06d0c9afe53d2a484a326871

This is where I don't get it.

sk_add_backlog(limit) is (via sk_rcvqueues_full) testing for

 (sk_backlog.len + sk_rmem_alloc) > limit

But, if the receiving user is slow, sk_rmem_alloc will run full eventually, even if we
reduce sk_backlog.len with truesize of each transferred buffer, and sk_add_backlog
should then start throwing away packets. Why doesn't this happen?

I understand that the receiving user will be kept too busy to be able to do
any useful work, but this shouldn't result in the whole system running out
of memory, as is stated in the link. I am still confused.

///jon

> So really you do not want to 'relax' this check.

I am ok with that as long as we can work around it.

Regards
///jon

>
> All you need to do is have a big enough sk_rcvbuf for the expected and
> reasonable amount of memory you allow to be stored in input queues for
> your socket.
>
>
>


------------------------------------------------------------------------------
"Accelerate Dev Cycles with Automated Cross-Browser Testing - For FREE
Instantly run your Selenium tests across 300+ browser/OS combos.
Get unparalleled scalability from the best Selenium testing platform available
Simple to use. Nothing to install. Get started now for free."
http://p.sf.net/sfu/SauceLabs
