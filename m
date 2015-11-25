From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: use-after-free in sock_wake_async
Date: Wed, 25 Nov 2015 10:39:04 -0800
Message-ID: <1448476744.24696.25.camel@edumazet-glaptop2.roam.corp.google.com>
References: <CACT4Y+ZZQ0ooT9LekV35u_jUAtAHJfg5O5SD=xATfHUF5UdNBQ@mail.gmail.com>
	 <CANn89i+Uw+YzhRbQVSyf=FAQBO06JfFoxQpSHxfmDpS5_iZBQw@mail.gmail.com>
	 <87poyzj7j2.fsf@doppelsaurus.mobileactivedefense.com>
	 <CANn89iKg0Lc7OVLhxUOzPRr4OhEGxA8L7V1jyaqFAS6+7kEXTA@mail.gmail.com>
	 <87io4qevdp.fsf@doppelsaurus.mobileactivedefense.com>
	 <CANn89iJgW+6giMUicU1m831+mkaNy9z1hQB-ixvRHBqZo-7Yig@mail.gmail.com>
	 <87io4q3u8u.fsf@doppelsaurus.mobileactivedefense.com>
	 <1448471494.24696.18.camel@edumazet-glaptop2.roam.corp.google.com>
	 <87a8q23s2a.fsf@doppelsaurus.mobileactivedefense.com>
	 <1448473891.24696.21.camel@edumazet-glaptop2.roam.corp.google.com>
	 <87610q3pjg.fsf@doppelsaurus.mobileactivedefense.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <edumazet@google.com>,
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
To: Rainer Weikusat <rweikusat@mobileactivedefense.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <87610q3pjg.fsf@doppelsaurus.mobileactivedefense.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2015-11-25 at 18:24 +0000, Rainer Weikusat wrote:
> Eric Dumazet <eric.dumazet@gmail.com> writes:
> > On Wed, 2015-11-25 at 17:30 +0000, Rainer Weikusat wrote:
> >
> >> In case this is wrong, it obviously implies that sk_sleep(sk) must not
> >> be used anywhere as it accesses the same struck sock, hence, when that
> >> can "suddenly" disappear despite locks are used in the way indicated
> >> above, there is now safe way to invoke that, either, as it just does a
> >> rcu_dereference_raw based on the assumption that the caller knows that
> >> the i-node (and the corresponding wait queue) still exist.
> >> 
> >
> > Oh well.
> >
> > sk_sleep() is not used if the return is NULL
> 
> static long unix_stream_data_wait(struct sock *sk, long timeo,
> 				  struct sk_buff *last, unsigned int last_len)
> {
> 	struct sk_buff *tail;
> 	DEFINE_WAIT(wait);
> 
> 	unix_state_lock(sk);
> 
> 	for (;;) {
> 		prepare_to_wait(sk_sleep(sk), &wait, TASK_INTERRUPTIBLE);
> 
> 		tail = skb_peek_tail(&sk->sk_receive_queue);
> 		if (tail != last ||
> 		    (tail && tail->len != last_len) ||
> 		    sk->sk_err ||
> 		    (sk->sk_shutdown & RCV_SHUTDOWN) ||
> 		    signal_pending(current) ||
> 		    !timeo)
> 			break;
> 
> 		set_bit(SOCK_ASYNC_WAITDATA, &sk->sk_socket->flags);
> 		unix_state_unlock(sk);
> 		timeo = freezable_schedule_timeout(timeo);
> 		unix_state_lock(sk);
> 
> 		if (sock_flag(sk, SOCK_DEAD))
> 			break;
> 
> 		clear_bit(SOCK_ASYNC_WAITDATA, &sk->sk_socket->flags);
> 	}
> 
> 	finish_wait(sk_sleep(sk), &wait);
> 	unix_state_unlock(sk);
> 	return timeo;
> }
> 
> Neither prepare_to_wait nor finish_wait check if the pointer is
> null. For the finish_wait case, it shouldn't be null because if
> SOCK_DEAD is not found to be set after the unix_state_lock was acquired,
> unix_release_sock didn't execute the corresponding code yet, hence,
> inode etc will remain available until after the corresponding unlock.


> 
> But this isn't true anymore if the inode can go away despite
> sock_release couldn't complete yet.


You are looking at the wrong side.

Of course, the thread 'owning' a socket has a reference on it, so it
knows sk->sk_socket and sk->sk_ww is not NULL.

The problem is that at the time a wakeup is done, it can be done by a
process or softirq having no ref on the 'struct socket', as
sk->sk_socket can become NULL at anytime.

This is why we have sk_wq , and RCU protection, so that we do not have
to use expensive atomic operations in this fast path.
