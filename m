From: Mark Salyzyn <salyzyn@android.com>
Subject: Re: net/unix: sk_socket can disappear when state is unlocked
Date: Fri, 22 May 2015 12:59:26 -0700
Message-ID: <555F8A9E.3050809@android.com>
References: <1432225541-28498-1-git-send-email-salyzyn@android.com> <1432288230.3364.23.camel@redhat.com> <555F4267.30704@android.com> <1432308915.28081.10.camel@redhat.com> <555F583B.1010309@android.com> <1432318562.3430833.275929105.372EB77C@webmail.messagingengine.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Al Viro <viro@zeniv.linux.org.uk>,
	David Howells <dhowells@redhat.com>,
	Ying Xue <ying.xue@windriver.com>,
	Christoph Hellwig <hch@lst.de>, netdev@vger.kernel.org
To: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Hannes Frederic Sowa <hannes@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1432318562.3430833.275929105.372EB77C@webmail.messagingengine.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 05/22/2015 11:16 AM, Hannes Frederic Sowa wrote:
> On Fri, May 22, 2015, at 18:24, Mark Salyzyn wrote:
>> On 05/22/2015 08:35 AM, Hannes Frederic Sowa wrote:
>>> I still wonder if we need to actually recheck the condition and not
>>> simply break out of unix_stream_data_wait:
>>>
>>> We return to the unix_stream_recvmsg loop and recheck the
>>> sk_receive_queue. At this point sk_receive_queue is not really protected
>>> with unix_state_lock against concurrent modification with unix_release,
>>> as such we could end up concurrently dequeueing packets if socket is
>>> DEAD.
>> sock destroy(sic) is called before sock_orphan which sets SOCK_DEAD, so
>> the receive queue has already been drained.
> I am still afraid that there is a race:
>
> When we break out in unix_stream_data_wait we most of the time hit the
> continue statement in unix_stream_recvmsg. Albeit we acquired state lock
> again, we could end up in a situation where the sk_receive_queue is not
> completely drained. We would miss the recheck of the sk_shutdown mask,
> because it is possible we dequeue a non-null skb from the receive queue.
> This is because unix_release_sock acquires state lock, sets appropriate
> flags but the draining of the receive queue does happen without locks,
> state lock is unlocked before that. So theoretically both, release_sock
> and recvmsg could dequeue skbs concurrently in nondeterministic
> behavior.
>
> The fix would be to recheck SOCK_DEAD or even better, sk_shutdown right
> after we reacquired state_lock and break out of the loop altogether,
> maybe with -ECONNRESET.
>
> Thanks,
> Hannes
I am trying to figure out _how_ to appease your worries.

Keep in mind what I hit was rare already, and resulted in a panic. 
Nondeterministic packet delivery during shutdown is a given, but if I 
buy that one can receive another frame after packet flush and 
RCV_SHUTDOWN, and SOCK_DEAD is set under lock then returning to the 
thread in wait, would you be more comfortable with:

         do {
                 int chunk;
                 struct sk_buff *skb, *last;

                 unix_state_lock(sk);
                 last = skb = skb_peek(&sk->sk_receive_queue);
  again:
-               if (skb == NULL) {
+               if (!skb || sock_flag(sk, SOCK_DEAD)) {
                         unix_sk(sk)->recursion_level = 0;
                         if (copied >= target)
                                 goto unlock;

- or -

+               skb = NULL;
+               if (!sock_flag(sk, SOCK_DEAD))   // check after loop, 
but not in again loop?
+                       skb = skb_peek(&sk->sk_receive_queue
+               last = skb;

I know this does not give you -ECONNRESET (but we will we get 
sock_error(sk) disposition, another check for sock_flag if err == 0 
could fix that)

Too far to deal with nondeterministic packet flow? getting a last packet 
or not does not seem worth the cycles of CPU trouble?

Sincerely -- Mark Salyzyn
