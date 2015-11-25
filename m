From: Rainer Weikusat <rweikusat@mobileactivedefense.com>
Subject: Re: use-after-free in sock_wake_async
Date: Wed, 25 Nov 2015 17:30:21 +0000
Message-ID: <87a8q23s2a.fsf@doppelsaurus.mobileactivedefense.com>
References: <CACT4Y+ZZQ0ooT9LekV35u_jUAtAHJfg5O5SD=xATfHUF5UdNBQ@mail.gmail.com>
	<CANn89i+Uw+YzhRbQVSyf=FAQBO06JfFoxQpSHxfmDpS5_iZBQw@mail.gmail.com>
	<87poyzj7j2.fsf@doppelsaurus.mobileactivedefense.com>
	<CANn89iKg0Lc7OVLhxUOzPRr4OhEGxA8L7V1jyaqFAS6+7kEXTA@mail.gmail.com>
	<87io4qevdp.fsf@doppelsaurus.mobileactivedefense.com>
	<CANn89iJgW+6giMUicU1m831+mkaNy9z1hQB-ixvRHBqZo-7Yig@mail.gmail.com>
	<87io4q3u8u.fsf@doppelsaurus.mobileactivedefense.com>
	<1448471494.24696.18.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Rainer Weikusat <rweikusat@mobileactivedefense.com>,
	Eric Dumazet <edumazet@google.com>,
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
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tiger.mobileactivedefense.com ([217.174.251.109]:37085 "EHLO
	tiger.mobileactivedefense.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752464AbbKYRaq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Nov 2015 12:30:46 -0500
In-Reply-To: <1448471494.24696.18.camel@edumazet-glaptop2.roam.corp.google.com>
	(Eric Dumazet's message of "Wed, 25 Nov 2015 09:11:34 -0800")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet <eric.dumazet@gmail.com> writes:
> On Wed, 2015-11-25 at 16:43 +0000, Rainer Weikusat wrote:
>> Eric Dumazet <edumazet@google.com> writes:
>> > On Tue, Nov 24, 2015 at 5:10 PM, Rainer Weikusat
>> > <rweikusat@mobileactivedefense.com> wrote:
>> 
>> [...]
>> 
>> >> It's also easy to verify: Swap the unix_state_lock and
>> >> other->sk_data_ready and see if the issue still occurs. Right now (this
>> >> may change after I had some sleep as it's pretty late for me), I don't
>> >> think there's another local fix: The ->sk_data_ready accesses a
>> >> pointer after the lock taken by the code which will clear and
>> >> then later free it was released.
>> >
>> > It seems that :
>> >
>> > int sock_wake_async(struct socket *sock, int how, int band)
>> >
>> > should really be changed to
>> >
>> > int sock_wake_async(struct socket_wq *wq, int how, int band)
>> >
>> > So that RCU rules (already present) apply safely.
>> >
>> > sk->sk_socket is inherently racy (that is : racy without using
>> > sk_callback_lock rwlock )
>> 
>> The comment above sock_wait_async states that
>> 
>> /* This function may be called only under socket lock or callback_lock or rcu_lock */
>> 
>> In this case, it's called via sk_wake_async (include/net/sock.h) which
>> is - in turn - called via sock_def_readable (the 'default' data ready
>> routine/ net/core/sock.c) which looks like this:
>> 
>> static void sock_def_readable(struct sock *sk)
>> {
>> 	struct socket_wq *wq;
>> 
>> 	rcu_read_lock();
>> 	wq = rcu_dereference(sk->sk_wq);
>> 	if (wq_has_sleeper(wq))
>> 		wake_up_interruptible_sync_poll(&wq->wait, POLLIN | POLLPRI |
>> 						POLLRDNORM | POLLRDBAND);
>> 	sk_wake_async(sk, SOCK_WAKE_WAITD, POLL_IN);
>> 	rcu_read_unlock();
>> }
>> 
>> and should thus satisfy the constraint documented by the comment (I
>> didn't verify if the comment is actually correct, though).
>> 
>> Further - sorry about that - I think changing code in "half of the
>> network stack" in order to avoid calling a certain routine which will
>> only ever do something in case someone's using signal-driven I/O with an
>> already acquired lock held is a terrifying idea. Because of this, I
>> propose the following alternate patch which should also solve the
>> problem by ensuring that the ->sk_data_ready activity happens before
>> unix_release_sock/ sock_release get a chance to clear or free anything
>> which will be needed.
>> 
>> In case this demonstrably causes other issues, a more complicated
>> alternate idea (still restricting itself to changes to the af_unix code)
>> would be to move the socket_wq structure to a dummy struct socket
>> allocated by unix_release_sock and freed by the destructor.
>> 
>> ---
>> diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
>> index 4e95bdf..5c87ea6 100644
>> --- a/net/unix/af_unix.c
>> +++ b/net/unix/af_unix.c
>> @@ -1754,8 +1754,8 @@ restart_locked:
>>         skb_queue_tail(&other->sk_receive_queue, skb);
>>         if (max_level > unix_sk(other)->recursion_level)
>>                 unix_sk(other)->recursion_level = max_level;
>> -       unix_state_unlock(other);
>>         other->sk_data_ready(other);
>> +       unix_state_unlock(other);
>>         sock_put(other);
>>         scm_destroy(&scm);
>>         return len;
>> @@ -1860,8 +1860,8 @@ static int unix_stream_sendmsg(struct socket *sock, struct msghdr *msg,
>>                 skb_queue_tail(&other->sk_receive_queue, skb);
>>                 if (max_level > unix_sk(other)->recursion_level)
>>                         unix_sk(other)->recursion_level = max_level;
>> -               unix_state_unlock(other);
>>                 other->sk_data_ready(other);
>> +               unix_state_unlock(other);
>>                 sent += size;
>>         }
>>  
>
>
> The issue is way more complex than that.
>
> We cannot prevent inode from disappearing.
> We can not safely dereference "(struct socket *)->flags"
>
> locking the 'struct sock' wont help at all.

The inode can't disappear unless it's freed which is done by
sock_release,

void sock_release(struct socket *sock)
{
	if (sock->ops) {
		struct module *owner = sock->ops->owner;

		sock->ops->release(sock);
		sock->ops = NULL;
		module_put(owner);
	}

	if (rcu_dereference_protected(sock->wq, 1)->fasync_list)
		pr_err("%s: fasync list not empty!\n", __func__);

	this_cpu_sub(sockets_in_use, 1);
	if (!sock->file) {
		iput(SOCK_INODE(sock));
		return;
	}
	sock->file = NULL;
}

after calling the 'protocol release routine' (unix_release_sock) and
unix_release_sock will either be blocked waiting for the
unix_state_lock of the socket that's to be closed or it will set
SOCK_DEAD while holding this lock which will then be detected by either
of the unix _sendmsg routine before executing any of the receive code
(including the call to sk_data_ready).

In case this is wrong, it obviously implies that sk_sleep(sk) must not
be used anywhere as it accesses the same struck sock, hence, when that
can "suddenly" disappear despite locks are used in the way indicated
above, there is now safe way to invoke that, either, as it just does a
rcu_dereference_raw based on the assumption that the caller knows that
the i-node (and the corresponding wait queue) still exist.

I may be wrong on this, however, this then affects way more than just
sock_wake_async, and an explanation how precisely the existing code gets
it wrong would be very helpful (at least for my understanding).
