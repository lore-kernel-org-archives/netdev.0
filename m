From: Rainer Weikusat <rweikusat@mobileactivedefense.com>
Subject: Re: use-after-free in sock_wake_async
Date: Wed, 25 Nov 2015 16:43:13 +0000
Message-ID: <87io4q3u8u.fsf@doppelsaurus.mobileactivedefense.com>
References: <CACT4Y+ZZQ0ooT9LekV35u_jUAtAHJfg5O5SD=xATfHUF5UdNBQ@mail.gmail.com>
	<CANn89i+Uw+YzhRbQVSyf=FAQBO06JfFoxQpSHxfmDpS5_iZBQw@mail.gmail.com>
	<87poyzj7j2.fsf@doppelsaurus.mobileactivedefense.com>
	<CANn89iKg0Lc7OVLhxUOzPRr4OhEGxA8L7V1jyaqFAS6+7kEXTA@mail.gmail.com>
	<87io4qevdp.fsf@doppelsaurus.mobileactivedefense.com>
	<CANn89iJgW+6giMUicU1m831+mkaNy9z1hQB-ixvRHBqZo-7Yig@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: rweikusat@mobileactivedefense.com,
	Dmitry Vyukov <dvyukov@google.com>,
	Benjamin LaHaise <bcrl@kvack.org>,
	"David S. Miller" <davem@davemloft.net>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Al Viro <viro@zeniv.linux.org.uk>,
	David Howells <dhowells@redhat.com>,
	Ying Xue <ying.xue@windriver.com>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	syzkaller <syzkaller@googlegroups.com>,
	Kostya Serebryany <kcc@google.com>,
	Alexander Potapenko <glider@google.com>,
	Sasha Levin <sasha.levin@oracle.com>
To: Eric Dumazet <edumazet@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tiger.mobileactivedefense.com ([217.174.251.109]:57892 "EHLO
	tiger.mobileactivedefense.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751704AbbKYQni (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Nov 2015 11:43:38 -0500
In-Reply-To: <CANn89iJgW+6giMUicU1m831+mkaNy9z1hQB-ixvRHBqZo-7Yig@mail.gmail.com>
	(Eric Dumazet's message of "Tue, 24 Nov 2015 17:18:27 -0800")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet <edumazet@google.com> writes:
> On Tue, Nov 24, 2015 at 5:10 PM, Rainer Weikusat
> <rweikusat@mobileactivedefense.com> wrote:

[...]

>> It's also easy to verify: Swap the unix_state_lock and
>> other->sk_data_ready and see if the issue still occurs. Right now (this
>> may change after I had some sleep as it's pretty late for me), I don't
>> think there's another local fix: The ->sk_data_ready accesses a
>> pointer after the lock taken by the code which will clear and
>> then later free it was released.
>
> It seems that :
>
> int sock_wake_async(struct socket *sock, int how, int band)
>
> should really be changed to
>
> int sock_wake_async(struct socket_wq *wq, int how, int band)
>
> So that RCU rules (already present) apply safely.
>
> sk->sk_socket is inherently racy (that is : racy without using
> sk_callback_lock rwlock )

The comment above sock_wait_async states that

/* This function may be called only under socket lock or callback_lock or rcu_lock */

In this case, it's called via sk_wake_async (include/net/sock.h) which
is - in turn - called via sock_def_readable (the 'default' data ready
routine/ net/core/sock.c) which looks like this:

static void sock_def_readable(struct sock *sk)
{
	struct socket_wq *wq;

	rcu_read_lock();
	wq = rcu_dereference(sk->sk_wq);
	if (wq_has_sleeper(wq))
		wake_up_interruptible_sync_poll(&wq->wait, POLLIN | POLLPRI |
						POLLRDNORM | POLLRDBAND);
	sk_wake_async(sk, SOCK_WAKE_WAITD, POLL_IN);
	rcu_read_unlock();
}

and should thus satisfy the constraint documented by the comment (I
didn't verify if the comment is actually correct, though).

Further - sorry about that - I think changing code in "half of the
network stack" in order to avoid calling a certain routine which will
only ever do something in case someone's using signal-driven I/O with an
already acquired lock held is a terrifying idea. Because of this, I
propose the following alternate patch which should also solve the
problem by ensuring that the ->sk_data_ready activity happens before
unix_release_sock/ sock_release get a chance to clear or free anything
which will be needed.

In case this demonstrably causes other issues, a more complicated
alternate idea (still restricting itself to changes to the af_unix code)
would be to move the socket_wq structure to a dummy struct socket
allocated by unix_release_sock and freed by the destructor.

---
diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
index 4e95bdf..5c87ea6 100644
--- a/net/unix/af_unix.c
+++ b/net/unix/af_unix.c
@@ -1754,8 +1754,8 @@ restart_locked:
        skb_queue_tail(&other->sk_receive_queue, skb);
        if (max_level > unix_sk(other)->recursion_level)
                unix_sk(other)->recursion_level = max_level;
-       unix_state_unlock(other);
        other->sk_data_ready(other);
+       unix_state_unlock(other);
        sock_put(other);
        scm_destroy(&scm);
        return len;
@@ -1860,8 +1860,8 @@ static int unix_stream_sendmsg(struct socket *sock, struct msghdr *msg,
                skb_queue_tail(&other->sk_receive_queue, skb);
                if (max_level > unix_sk(other)->recursion_level)
                        unix_sk(other)->recursion_level = max_level;
-               unix_state_unlock(other);
                other->sk_data_ready(other);
+               unix_state_unlock(other);
                sent += size;
        }
 
