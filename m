From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: use-after-free in sock_wake_async
Date: Thu, 26 Nov 2015 07:51:30 -0800
Message-ID: <1448553090.24696.71.camel@edumazet-glaptop2.roam.corp.google.com>
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
	 <1448491950.1848115.450243417.726E2DCB@webmail.messagingengine.com>
	 <87r3jcx4w7.fsf@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
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
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <87r3jcx4w7.fsf@stressinduktion.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2015-11-26 at 14:32 +0100, Hannes Frederic Sowa wrote:
> Hannes Frederic Sowa <hannes@stressinduktion.org> writes:
> 
> 
> > I have seen filesystems already doing so in .destroy_inode, that's why I
> > am asking. The allocation happens the same way as we do with sock_alloc,
> > e.g. shmem. I actually thought that struct inode already provides an
> > rcu_head for exactly that reason.
> 
> E.g.:

> +static void sock_destroy_inode(struct inode *inode)
> +{
> +	call_rcu(&inode->i_rcu, sock_cache_free_rcu);
> +}

I guess you missed few years back why we had to implement
SLAB_DESTROY_BY_RCU for TCP sockets to not destroy performance.

By adding RCU grace period before reuse of this inode (about 640 bytes
today), you are asking the CPU to evict from its cache precious content,
and slow down some workloads, adding lot of ram pressure, as the cpu
allocating a TCP socket will have to populate its cache for a cold
inode.

The reason we put in a small object the RCU protected fields should be
pretty clear.

Do not copy code that people wrote in other layers without understanding
the performance implications.

Thanks.
