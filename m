From: Rainer Weikusat <rweikusat@mobileactivedefense.com>
Subject: Re: use-after-free in sock_wake_async
Date: Wed, 25 Nov 2015 01:10:58 +0000
Message-ID: <87io4qevdp.fsf@doppelsaurus.mobileactivedefense.com>
References: <CACT4Y+ZZQ0ooT9LekV35u_jUAtAHJfg5O5SD=xATfHUF5UdNBQ@mail.gmail.com>
	<CANn89i+Uw+YzhRbQVSyf=FAQBO06JfFoxQpSHxfmDpS5_iZBQw@mail.gmail.com>
	<87poyzj7j2.fsf@doppelsaurus.mobileactivedefense.com>
	<CANn89iKg0Lc7OVLhxUOzPRr4OhEGxA8L7V1jyaqFAS6+7kEXTA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Rainer Weikusat <rweikusat@mobileactivedefense.com>,
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
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CANn89iKg0Lc7OVLhxUOzPRr4OhEGxA8L7V1jyaqFAS6+7kEXTA@mail.gmail.com>
	(Eric Dumazet's message of "Tue, 24 Nov 2015 15:43:48 -0800")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Eric Dumazet <edumazet@google.com> writes:
> On Tue, Nov 24, 2015 at 3:34 PM, Rainer Weikusat
> <rweikusat@mobileactivedefense.com> wrote:
>> Eric Dumazet <edumazet@google.com> writes:
>>> On Tue, Nov 24, 2015 at 6:18 AM, Dmitry Vyukov <dvyukov@google.com> wrote:
>>>> Hello,
>>>>
>>>> The following program triggers use-after-free in sock_wake_async:
>>
>> [...]
>>
>>>> void *thr1(void *arg)
>>>> {
>>>>         syscall(SYS_close, r2, 0, 0, 0, 0, 0);
>>>>         return 0;
>>>> }
>>>>
>>>> void *thr2(void *arg)
>>>> {
>>>>         syscall(SYS_write, r3, 0x20003000ul, 0xe7ul, 0, 0, 0);
>>>>         return 0;
>>>> }
>>
>> [...]
>>
>>>>         pthread_t th[3];
>>>>         pthread_create(&th[0], 0, thr0, 0);
>>>>         pthread_create(&th[1], 0, thr1, 0);
>>>>         pthread_create(&th[2], 0, thr2, 0);
>>>>         pthread_join(th[0], 0);
>>>>         pthread_join(th[1], 0);
>>>>         pthread_join(th[2], 0);
>>>>         return 0;
>>>> }
>>
>> [...]
>>
>>> Looks like commit 830a1e5c212fb3fdc83b66359c780c3b3a294897 should be reverted ?
>>>
>>> commit 830a1e5c212fb3fdc83b66359c780c3b3a294897
>>> Author: Benjamin LaHaise <benjamin.c.lahaise@intel.com>
>>> Date:   Tue Dec 13 23:22:32 2005 -0800
>>>
>>>     [AF_UNIX]: Remove superfluous reference counting in unix_stream_sendmsg
>>>
>>>     AF_UNIX stream socket performance on P4 CPUs tends to suffer due to a
>>>     lot of pipeline flushes from atomic operations.  The patch below
>>>     removes the sock_hold() and sock_put() in unix_stream_sendmsg().  This
>>>     should be safe as the socket still holds a reference to its peer which
>>>     is only released after the file descriptor's final user invokes
>>>     unix_release_sock().  The only consideration is that we must add a
>>>     memory barrier before setting the peer initially.
>>>
>>>     Signed-off-by: Benjamin LaHaise <benjamin.c.lahaise@intel.com>
>>>     Signed-off-by: David S. Miller <davem@davemloft.net>
>>
>> JFTR: This seems to be unrelated. (As far as I understand this), the
>> problem is that sk_wake_async accesses sk->sk_socket. That's invoked via
>> the
>>
>> other->sk_data_ready(other)
>>
>> in unix_stream_sendmsg after an
>>
>> unix_state_unlock(other);
>>
>> because of this, it can race with the code in unix_release_sock clearing
>> this pointer (via sock_orphan). The structure this pointer points to is
>> freed via iput in sock_release (net/socket.c) after the af_unix release
>> routine returned (it's really one part of a "twin structure" with the
>> socket inode being the other).
>>
>> A quick way to test if this was true would be to swap the
>>
>> unix_state_unlock(other);
>> other->sk_data_ready(other);
>>
>> in unix_stream_sendmsg and in case it is, a very 'hacky' fix could be to
>> put a pointer to the socket inode into the struct unix_sock, do an iget
>> on that in unix_create1 and a corresponding iput in
>> unix_sock_destructor.
>
> This is interesting, but is not the problem or/and the fix.
>
> We are supposed to own a reference on the 'other' socket or make sure
> it cannot disappear under us.

The af_unix part of this, yes, ie, what gets allocated in
unix_create1. But neither the socket inode nor the struct sock
originally passed to unix_create. Since these are part of the same
umbrella structure, they'll both be freed as consequence of the
sock_release iput. As far as I can tell (I don't claim that I'm
necessarily right on this, this is just the result of spending ca 2h
reading the code with the problem report in mind and looking for
something which could cause it), doing a sock_hold on the unix peer of
the socket in unix_stream_sendmsg is indeed not needed, however, there's
no additional reference to the inode or the struct sock accompanying it,
ie, both of these will be freed by unix_release_sock. This also affects
unix_dgram_sendmsg.

It's also easy to verify: Swap the unix_state_lock and
other->sk_data_ready and see if the issue still occurs. Right now (this
may change after I had some sleep as it's pretty late for me), I don't
think there's another local fix: The ->sk_data_ready accesses a
pointer after the lock taken by the code which will clear and
then later free it was released.
