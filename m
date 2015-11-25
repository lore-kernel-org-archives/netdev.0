From: Rainer Weikusat <rweikusat@mobileactivedefense.com>
Subject: Re: use-after-free in sock_wake_async
Date: Wed, 25 Nov 2015 19:38:07 +0000
Message-ID: <87y4dl3m5c.fsf@doppelsaurus.mobileactivedefense.com>
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
	<1448476744.24696.25.camel@edumazet-glaptop2.roam.corp.google.com>
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
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1448476744.24696.25.camel@edumazet-glaptop2.roam.corp.google.com>
	(Eric Dumazet's message of "Wed, 25 Nov 2015 10:39:04 -0800")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Eric Dumazet <eric.dumazet@gmail.com> writes:
> On Wed, 2015-11-25 at 18:24 +0000, Rainer Weikusat wrote:
>> Eric Dumazet <eric.dumazet@gmail.com> writes:
>> > On Wed, 2015-11-25 at 17:30 +0000, Rainer Weikusat wrote:
>> >
>> >> In case this is wrong, it obviously implies that sk_sleep(sk) must not
>> >> be used anywhere as it accesses the same struck sock, hence, when that
>> >> can "suddenly" disappear despite locks are used in the way indicated
>> >> above, there is now safe way to invoke that, either, as it just does a
>> >> rcu_dereference_raw based on the assumption that the caller knows that
>> >> the i-node (and the corresponding wait queue) still exist.
>> >> 
>> >
>> > Oh well.
>> >
>> > sk_sleep() is not used if the return is NULL

[...]

>> 	finish_wait(sk_sleep(sk), &wait);
>> 	unix_state_unlock(sk);
>> 	return timeo;
>> }
>> 
>> Neither prepare_to_wait nor finish_wait check if the pointer is
>> null.

[...]

> You are looking at the wrong side.
>
> Of course, the thread 'owning' a socket has a reference on it, so it
> knows sk->sk_socket and sk->sk_ww is not NULL.

I could continue argueing about this but IMHO, it just leads away from
the actual issue. Taking a couple of steps back, therefore,

------------
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
 
-------------

I'm convinced this will work for the given problem (I don't claim that
it's technically superior to the larger change in any aspect except that
it's simpler and localized) because

1) The use-after-free occurred while accessing the struck sock allocated
   together with the socket inode.

2) This happened because a close was racing with a write.   

3) The socket inode, struct sock and struct socket_wq are freed by
   sock_destroy_inode.

4) sock_destroy_inode can only be called as consequence of the iput in
   sock_release.

5) sock_release invokes the per-protocol/ family release function before
   doing the iput.

6) unix_sock_release has to acquire the unix_state_lock on the socket
   referred to as other in the code above before it can do anything, in
   particular, before it calls sock_orphan which resets the struct sock and wq
   pointers and also sets the SOCK_DEAD flag.

7) the unix_stream_sendmsg code acquires the unix_state_lock on other
   and then checks the SOCK_DEAD flag. The code above only runs if it
   was not set, hence, the iput in sock_release can't have happened yet
   because a concurrent unix_sock_release must still be blocked on the
   unix_state_lock of other.

If there's an error in this reasoning, I'd very much like to know where
and what it is, not the least because the unix_dgram_peer_wake_relay
function I wrote also relies on it being correct (wrt to using the
result of sk_sleep outside of rcu_read_lock/ rcu_read_unlock).
