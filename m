From: Jason Baron <jbaron@akamai.com>
Subject: Re: [PATCH] unix: avoid use-after-free in ep_remove_wait_queue
Date: Mon, 9 Nov 2015 17:44:32 -0500
Message-ID: <564121D0.2000305@akamai.com>
References: <CACT4Y+b3xsLsKVFCz2M7nqqfXnyuMHEVYtJS2wN4WHLWs9A5ng@mail.gmail.com>
 <20151012120249.GB16370@unicorn.suse.cz>
 <1444652071.27760.156.camel@edumazet-glaptop2.roam.corp.google.com>
 <CACT4Y+Z2H8xPg1Dq0Z=HC3WKm+Uw+ZjK6zOLvxhPwFd4D0CsZw@mail.gmail.com>
 <CACT4Y+Zu7J0n6dU1dSfiW3F9Q0Us3_DBVcD5Pi9NG9LER8MmRg@mail.gmail.com>
 <563CC002.5050307@akamai.com>
 <87ziyrcg67.fsf@doppelsaurus.mobileactivedefense.com>
 <87fv0fnslr.fsf_-_@doppelsaurus.mobileactivedefense.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: Dmitry Vyukov <dvyukov@google.com>,
	syzkaller <syzkaller@googlegroups.com>,
	Michal Kubecek <mkubecek@suse.cz>,
	Al Viro <viro@zeniv.linux.org.uk>,
	"linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	David Howells <dhowells@redhat.com>,
	Paul Moore <paul@paul-moore.com>, salyzyn@android.com,
	sds@tycho.nsa.gov, ying.xue@windriver.com,
	netdev <netdev@vger.kernel.org>,
	Kostya Serebryany <kcc@google.com>,
	Alexander Potapenko <glider@google.com>,
	Andrey Konovalov <andreyknvl@google.com>,
	Sasha Levin <sasha.levin@oracle.com>,
	Julien Tinnes <jln@google.com>,
	Kees Cook <keescook@google.com>,
	Mathias Krause <minipli@googlemail.com>
To: Rainer Weikusat <rweikusat@mobileactivedefense.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from prod-mail-xrelay05.akamai.com ([23.79.238.179]:63787 "EHLO
	prod-mail-xrelay05.akamai.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751781AbbKIWoe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Nov 2015 17:44:34 -0500
In-Reply-To: <87fv0fnslr.fsf_-_@doppelsaurus.mobileactivedefense.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/09/2015 09:40 AM, Rainer Weikusat wrote:
> An AF_UNIX datagram socket being the client in an n:1 association with
> some server socket is only allowed to send messages to the server if the
> receive queue of this socket contains at most sk_max_ack_backlog
> datagrams. This implies that prospective writers might be forced to go
> to sleep despite none of the message presently enqueued on the server
> receive queue were sent by them. In order to ensure that these will be
> woken up once space becomes again available, the present unix_dgram_poll
> routine does a second sock_poll_wait call with the peer_wait wait queue
> of the server socket as queue argument (unix_dgram_recvmsg does a wake
> up on this queue after a datagram was received). This is inherently
> problematic because the server socket is only guaranteed to remain alive
> for as long as the client still holds a reference to it. In case the
> connection is dissolved via connect or by the dead peer detection logic
> in unix_dgram_sendmsg, the server socket may be freed despite "the
> polling mechanism" (in particular, epoll) still has a pointer to the
> corresponding peer_wait queue. There's no way to forcibly deregister a
> wait queue with epoll.
> 
> Based on an idea by Jason Baron, the patch below changes the code such
> that a wait_queue_t belonging to the client socket is enqueued on the
> peer_wait queue of the server whenever the peer receive queue full
> condition is detected by either a sendmsg or a poll. A wake up on the
> peer queue is then relayed to the ordinary wait queue of the client
> socket via wake function. The connection to the peer wait queue is again
> dissolved if either a wake up is about to be relayed or the client
> socket reconnects or a dead peer is detected or the client socket is
> itself closed. This enables removing the second sock_poll_wait from
> unix_dgram_poll, thus avoiding the use-after-free, while still ensuring
> that no blocked writer sleeps forever.
> 
> Signed-off-by: Rainer Weikusuat <rweikusat@mobileactivedefense.com>

[...]

> @@ -1590,10 +1723,14 @@ restart:
>  			goto out_unlock;
>  	}
>  
> -	if (unix_peer(other) != sk && unix_recvq_full(other)) {
> +	if (!unix_dgram_peer_recv_ready(sk, other)) {
>  		if (!timeo) {
> -			err = -EAGAIN;
> -			goto out_unlock;
> +			if (unix_dgram_peer_wake_me(sk, other)) {
> +				err = -EAGAIN;
> +				goto out_unlock;
> +			}
> +
> +			goto restart;
>  		}


So this will cause 'unix_state_lock(other) to be called twice in a
row if we 'goto restart' (and hence will softlock the box). It just
needs a 'unix_state_unlock(other);' before the 'goto restart'.

I also tested this patch with a single unix server and 200 client
threads doing roughly epoll() followed by write() until -EAGAIN in a
loop. The throughput for the test was roughly the same as current
upstream, but the cpu usage was a lot higher. I think its b/c this patch
takes the server wait queue lock in the _poll() routine. This causes a
lot of contention. The previous patch you posted for this where you did
not clear the wait queue on every wakeup and thus didn't need the queue
lock in poll() (unless we were adding to it), performed much better.

However, the previous patch which tested better didn't add to the remote
queue when it was full on sendmsg() - so it wouldn't be correct for
epoll ET. Adding to the remote queue for every sendmsg() that fails does
seem undesirable, if we aren't even doing poll(). So I'm not sure if
just going back to the previous patch is a great option either....I'm
also not sure how realistic the test case I have is. It would be great
if we had some other workloads to test against.

Thanks,

-Jason
