From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: use-after-free in sock_wake_async
Date: Wed, 25 Nov 2015 23:52:30 +0100
Message-ID: <1448491950.1848115.450243417.726E2DCB@webmail.messagingengine.com>
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
 <87y4dl3m5c.fsf@doppelsaurus.mobileactivedefense.com>
 <1448481002.24696.30.camel@edumazet-glaptop2.roam.corp.google.com>
 <1448483017.24696.33.camel@edumazet-glaptop2.roam.corp.google.com>
 <87two93ig8.fsf@doppelsaurus.mobileactivedefense.com>
 <1448489350.24696.47.camel@edumazet-glaptop2.roam.corp.google.com>
 <1448490732.1842763.450231537.5358AF37@webmail.messagingengine.com>
 <1448491414.24696.60.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Rainer Weikusat <rweikusat@mobileactivedefense.com>,
	Eric Dumazet <edumazet@google.com>,
	Dmitry Vyukov <dvyukov@google.com>,
	Benjamin LaHaise <bcrl@kvack.org>,
	"David S. Miller" <davem@davemloft.net>,
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
In-Reply-To: <1448491414.24696.60.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Nov 25, 2015, at 23:43, Eric Dumazet wrote:
> On Wed, 2015-11-25 at 23:32 +0100, Hannes Frederic Sowa wrote:
> > On Wed, Nov 25, 2015, at 23:09, Eric Dumazet wrote:
> > > On Wed, 2015-11-25 at 20:57 +0000, Rainer Weikusat wrote:
> > > 
> > > > I do agree that keeping the ->sk_data_ready outside of the lock will
> > > > very likely have performance advantages. That's just something I
> > > > wouldn't have undertaken because I'd be reluctant to make a fairly
> > > > complicated change to a lot of code.
> > > 
> > > All I am saying is that we can keep current performance.
> > > 
> > > We already have the core infrastructure, we only need to properly use
> > > it.
> > > 
> > > I will split my changes in two parts.
> > > 
> > > One part doing a very boring change of
> > > 
> > > rename SOCK_ASYNC_NOSPACE and SOCK_ASYNC_WAITDATA
> > > for X in SOCK_ASYNC_NOSPACE SOCK_ASYNC_WAITDATA 
> > > 
> > >  set_bit(X, &sk->sk_socket->flags) -> sk_set_bit(X, sk)
> > >  clear_bit(X, &sk->sk_socket->flags) -> sk_clear_bit(X, sk)
> > 
> > sk_set_bit and sk_clear_bit will forward the set_bit and clear_bit into
> > the socket_wq like you explained above?
> 
> In the first patch (no functional change), the helpers will look like
> 
> static void inline sk_set_bit(int nr, struct sock *sk)
> {
> 	set_bit(nr, &sk->sk_socket->flags);
> }
> 
> 
> Then the second patch will change the helper to :
> 
> static void inline sk_set_bit(int nr, struct sock *sk)
> {
> 	set_bit(nr, &sk->sk_wq_raw->flags);
> }

Yep, that looks sensible.

> > > The rename will help backports to catch code that might have been
> > > removed in recent kernels.
> > > 
> > > Then the second patch will do the actual changes, and they will look
> > > very sensible for people wanting to review them, and or familiar with
> > > the stack, do not worry ;)
> > 
> > Do you see a chance to inline socket_wq into struct socket and discard
> > struct socket_alloc in one go by rcu in socket_destroy_inode?
> 
> ???
> 
> I guess you missed the whole point to have socket_wq allocated outside
> of the inode :(

Yep, sure, so inode could be torn down while wq is freed by rcu
callback.

> inodes are not rcu protected (yet). I certainly don't want to mess with
> VFS, we have enough problems in net/ directory already.

I have seen filesystems already doing so in .destroy_inode, that's why I
am asking. The allocation happens the same way as we do with sock_alloc,
e.g. shmem. I actually thought that struct inode already provides an
rcu_head for exactly that reason.

Bye,
Hannes
