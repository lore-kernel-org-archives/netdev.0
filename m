From: Eric Dumazet <edumazet@google.com>
Subject: Re: use-after-free in sock_wake_async
Date: Tue, 24 Nov 2015 17:18:27 -0800
Message-ID: <CANn89iJgW+6giMUicU1m831+mkaNy9z1hQB-ixvRHBqZo-7Yig@mail.gmail.com>
References: <CACT4Y+ZZQ0ooT9LekV35u_jUAtAHJfg5O5SD=xATfHUF5UdNBQ@mail.gmail.com>
	<CANn89i+Uw+YzhRbQVSyf=FAQBO06JfFoxQpSHxfmDpS5_iZBQw@mail.gmail.com>
	<87poyzj7j2.fsf@doppelsaurus.mobileactivedefense.com>
	<CANn89iKg0Lc7OVLhxUOzPRr4OhEGxA8L7V1jyaqFAS6+7kEXTA@mail.gmail.com>
	<87io4qevdp.fsf@doppelsaurus.mobileactivedefense.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Dmitry Vyukov <dvyukov@google.com>,
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
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f50.google.com ([74.125.82.50]:35620 "EHLO
	mail-wm0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754248AbbKYBS2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Nov 2015 20:18:28 -0500
Received: by wmuu63 with SMTP id u63so119006443wmu.0
        for <netdev@vger.kernel.org>; Tue, 24 Nov 2015 17:18:27 -0800 (PST)
In-Reply-To: <87io4qevdp.fsf@doppelsaurus.mobileactivedefense.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 24, 2015 at 5:10 PM, Rainer Weikusat
<rweikusat@mobileactivedefense.com> wrote:
>
> The af_unix part of this, yes, ie, what gets allocated in
> unix_create1. But neither the socket inode nor the struct sock
> originally passed to unix_create. Since these are part of the same
> umbrella structure, they'll both be freed as consequence of the
> sock_release iput. As far as I can tell (I don't claim that I'm
> necessarily right on this, this is just the result of spending ca 2h
> reading the code with the problem report in mind and looking for
> something which could cause it), doing a sock_hold on the unix peer of
> the socket in unix_stream_sendmsg is indeed not needed, however, there's
> no additional reference to the inode or the struct sock accompanying it,
> ie, both of these will be freed by unix_release_sock. This also affects
> unix_dgram_sendmsg.
>
> It's also easy to verify: Swap the unix_state_lock and
> other->sk_data_ready and see if the issue still occurs. Right now (this
> may change after I had some sleep as it's pretty late for me), I don't
> think there's another local fix: The ->sk_data_ready accesses a
> pointer after the lock taken by the code which will clear and
> then later free it was released.

It seems that :

int sock_wake_async(struct socket *sock, int how, int band)

should really be changed to

int sock_wake_async(struct socket_wq *wq, int how, int band)

So that RCU rules (already present) apply safely.

sk->sk_socket is inherently racy (that is : racy without using
sk_callback_lock rwlock )

Other possibility would be _not_ calling sock_orphan() from unix_release_sock()
