From: Eric Dumazet <edumazet@google.com>
Subject: Re: use-after-free in sock_wake_async
Date: Tue, 24 Nov 2015 14:03:06 -0800
Message-ID: <CANn89iK=whv2XgeECNyvqn56dt7Apqhc=Mk2UwF8KtSF_jOG1g@mail.gmail.com>
References: <CACT4Y+ZZQ0ooT9LekV35u_jUAtAHJfg5O5SD=xATfHUF5UdNBQ@mail.gmail.com>
	<CANn89i+Uw+YzhRbQVSyf=FAQBO06JfFoxQpSHxfmDpS5_iZBQw@mail.gmail.com>
	<5654D6D9.1050108@akamai.com>
	<20151124214512.GM27046@kvack.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Jason Baron <jbaron@akamai.com>,
	Dmitry Vyukov <dvyukov@google.com>,
	"David S. Miller" <davem@davemloft.net>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Al Viro <viro@zeniv.linux.org.uk>,
	David Howells <dhowells@redhat.com>,
	Ying Xue <ying.xue@windriver.com>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Rainer Weikusat <rweikusat@mobileactivedefense.com>,
	netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	syzkaller <syzkaller@googlegroups.com>,
	Kostya Serebryany <kcc@google.com>,
	Alexander Potapenko <glider@google.com>,
	Sasha Levin <sasha.levin@oracle.com>
To: Benjamin LaHaise <bcrl@kvack.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20151124214512.GM27046@kvack.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Nov 24, 2015 at 1:45 PM, Benjamin LaHaise <bcrl@kvack.org> wrote:
> On Tue, Nov 24, 2015 at 04:30:01PM -0500, Jason Baron wrote:
>> So looking at this trace I think its the other->sk_socket that gets
>> freed and then we call sk_wake_async() on it.
>>
>> We could I think grab the socket reference there with unix_state_lock(),
>> since that is held by unix_release_sock() before the final iput() is called.
>>
>> So something like below might work (compile tested only):
>
> That just adds the performance regression back in.  It should be possible
> to protect the other socket dereference using RCU.  I haven't had time to
> look at this yet today, but will try to find some time this evening to come
> up with a suggested patch.
>
>                 -ben
>
>> diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
>> index aaa0b58..2b014f1 100644
>> --- a/net/unix/af_unix.c
>> +++ b/net/unix/af_unix.c
>> @@ -196,6 +196,19 @@ static inline int unix_recvq_full(struct sock const
>> *sk)
>>       return skb_queue_len(&sk->sk_receive_queue) > sk->sk_max_ack_backlog;
>>  }
>>
>> +struct socket *unix_peer_get_socket(struct sock *s)
>> +{
>> +     struct socket *peer;
>> +
>> +     unix_state_lock(s);
>> +     peer = s->sk_socket;
>> +     if (peer)
>> +             __iget(SOCK_INODE(s->sk_socket));
>> +     unix_state_unlock(s);
>> +
>> +     return peer;
>> +}
>> +
>>  struct sock *unix_peer_get(struct sock *s)
>>  {
>>       struct sock *peer;
>> @@ -1639,6 +1652,7 @@ static int unix_stream_sendmsg(struct socket
>> *sock, struct msghdr *msg,
>>  {
>>       struct sock *sk = sock->sk;
>>       struct sock *other = NULL;
>> +     struct socket *other_socket = NULL;
>>       int err, size;
>>       struct sk_buff *skb;
>>       int sent = 0;
>> @@ -1662,7 +1676,10 @@ static int unix_stream_sendmsg(struct socket
>> *sock, struct msghdr *msg,
>>       } else {
>>               err = -ENOTCONN;
>>               other = unix_peer(sk);
>> -             if (!other)
>> +             if (other)
>> +                     other_socket = unix_peer_get_socket(other);
>> +
>> +             if (!other_socket)
>>                       goto out_err;
>>       }
>>
>> @@ -1721,6 +1738,9 @@ static int unix_stream_sendmsg(struct socket
>> *sock, struct msghdr *msg,
>>               sent += size;
>>       }
>>
>> +     if (other_socket)
>> +             iput(SOCK_INODE(other_socket));
>> +
>>       scm_destroy(&scm);
>>
>>       return sent;
>> @@ -1733,6 +1753,8 @@ pipe_err:
>>               send_sig(SIGPIPE, current, 0);
>>       err = -EPIPE;
>>  out_err:
>> +     if (other_socket)
>> +             iput(SOCK_INODE(other_socket));
>>       scm_destroy(&scm);
>>       return sent ? : err;
>>  }
>
> --
> "Thought is the essence of where you are now."


This might be a data race in sk_wake_async() if inlined by compiler
(see https://lkml.org/lkml/2015/11/24/680 for another example)

KASAN adds register pressure and compiler can then do 'stupid' things :(

diff --git a/include/net/sock.h b/include/net/sock.h
index 7f89e4ba18d1..2af6222ccc67 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -2008,7 +2008,7 @@ static inline unsigned long sock_wspace(struct sock *sk)
 static inline void sk_wake_async(struct sock *sk, int how, int band)
 {
        if (sock_flag(sk, SOCK_FASYNC))
-               sock_wake_async(sk->sk_socket, how, band);
+               sock_wake_async(READ_ONCE(sk->sk_socket), how, band);
 }

 /* Since sk_{r,w}mem_alloc sums skb->truesize, even a small frame might
