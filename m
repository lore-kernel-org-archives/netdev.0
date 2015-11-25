From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: use-after-free in sock_wake_async
Date: Wed, 25 Nov 2015 09:51:31 -0800
Message-ID: <1448473891.24696.21.camel@edumazet-glaptop2.roam.corp.google.com>
References: <CACT4Y+ZZQ0ooT9LekV35u_jUAtAHJfg5O5SD=xATfHUF5UdNBQ@mail.gmail.com>
	 <CANn89i+Uw+YzhRbQVSyf=FAQBO06JfFoxQpSHxfmDpS5_iZBQw@mail.gmail.com>
	 <87poyzj7j2.fsf@doppelsaurus.mobileactivedefense.com>
	 <CANn89iKg0Lc7OVLhxUOzPRr4OhEGxA8L7V1jyaqFAS6+7kEXTA@mail.gmail.com>
	 <87io4qevdp.fsf@doppelsaurus.mobileactivedefense.com>
	 <CANn89iJgW+6giMUicU1m831+mkaNy9z1hQB-ixvRHBqZo-7Yig@mail.gmail.com>
	 <87io4q3u8u.fsf@doppelsaurus.mobileactivedefense.com>
	 <1448471494.24696.18.camel@edumazet-glaptop2.roam.corp.google.com>
	 <87a8q23s2a.fsf@doppelsaurus.mobileactivedefense.com>
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
In-Reply-To: <87a8q23s2a.fsf@doppelsaurus.mobileactivedefense.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2015-11-25 at 17:30 +0000, Rainer Weikusat wrote:

> In case this is wrong, it obviously implies that sk_sleep(sk) must not
> be used anywhere as it accesses the same struck sock, hence, when that
> can "suddenly" disappear despite locks are used in the way indicated
> above, there is now safe way to invoke that, either, as it just does a
> rcu_dereference_raw based on the assumption that the caller knows that
> the i-node (and the corresponding wait queue) still exist.
> 

Oh well.

sk_sleep() is not used if the return is NULL

This is exactly why we have such code in critical functions :

wqueue = sk_sleep(sk);
if (wqueue && waitqueue_active(wqueue))
	wake_up_interruptible_poll(wqueue, 
				   POLLOUT | POLLWRNORM | POLLWRBAND);


We already took care of this problem years ago, but missed the ASYNC
case (that almost nobody really uses these days)
