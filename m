From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: net/unix: sk_socket can disappear when state is unlocked
Date: Fri, 22 May 2015 20:16:02 +0200
Message-ID: <1432318562.3430833.275929105.372EB77C@webmail.messagingengine.com>
References: <1432225541-28498-1-git-send-email-salyzyn@android.com>
 <1432288230.3364.23.camel@redhat.com> <555F4267.30704@android.com>
 <1432308915.28081.10.camel@redhat.com> <555F583B.1010309@android.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Al Viro <viro@zeniv.linux.org.uk>,
	David Howells <dhowells@redhat.com>,
	Ying Xue <ying.xue@windriver.com>,
	Christoph Hellwig <hch@lst.de>, netdev@vger.kernel.org
To: Mark Salyzyn <salyzyn@android.com>,
	Hannes Frederic Sowa <hannes@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <555F583B.1010309@android.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, May 22, 2015, at 18:24, Mark Salyzyn wrote:
> On 05/22/2015 08:35 AM, Hannes Frederic Sowa wrote:
> > I still wonder if we need to actually recheck the condition and not
> > simply break out of unix_stream_data_wait:
> >
> > We return to the unix_stream_recvmsg loop and recheck the
> > sk_receive_queue. At this point sk_receive_queue is not really protected
> > with unix_state_lock against concurrent modification with unix_release,
> > as such we could end up concurrently dequeueing packets if socket is
> > DEAD.
> sock destroy(sic) is called before sock_orphan which sets SOCK_DEAD, so 
> the receive queue has already been drained.

I am still afraid that there is a race:

When we break out in unix_stream_data_wait we most of the time hit the
continue statement in unix_stream_recvmsg. Albeit we acquired state lock
again, we could end up in a situation where the sk_receive_queue is not
completely drained. We would miss the recheck of the sk_shutdown mask,
because it is possible we dequeue a non-null skb from the receive queue.
This is because unix_release_sock acquires state lock, sets appropriate
flags but the draining of the receive queue does happen without locks,
state lock is unlocked before that. So theoretically both, release_sock
and recvmsg could dequeue skbs concurrently in nondeterministic
behavior.

The fix would be to recheck SOCK_DEAD or even better, sk_shutdown right
after we reacquired state_lock and break out of the loop altogether,
maybe with -ECONNRESET.

Thanks,
Hannes
