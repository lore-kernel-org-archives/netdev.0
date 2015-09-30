From: Michal Kubecek <mkubecek@suse.cz>
Subject: Re: List corruption on epoll_ctl(EPOLL_CTL_DEL) an AF_UNIX socket
Date: Wed, 30 Sep 2015 09:34:10 +0200
Message-ID: <20150930073410.GA7339@unicorn.suse.cz>
References: <20150913195354.GA12352@jig.fritz.box>
 <20150914023949.GA15012@dcvr.yhbt.net>
 <CA+rthh8smc0fxL5sEhMpKRQgzMi=BCVyxKc=O1JWesHGwYW8XA@mail.gmail.com>
 <560AE202.4020402@akamai.com>
 <CA+rthh9XU+5oN9Ua-+8XPF9Q0y03FZyxds53sxUjsvsJN2kaJA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jason Baron <jbaron@akamai.com>, netdev@vger.kernel.org,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Eric Wong <normalperson@yhbt.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Rainer Weikusat <rweikusat@mobileactivedefense.com>,
	Alexander Viro <viro@zeniv.linux.org.uk>,
	Davide Libenzi <davidel@xmailserver.org>,
	Davidlohr Bueso <dave@stgolabs.net>,
	Olivier Mauras <olivier@mauras.ch>,
	PaX Team <pageexec@freemail.hu>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	"peterz@infradead.org" <peterz@infradead.org>,
	"davem@davemloft.net" <davem@davemloft.net>
To: Mathias Krause <minipli@googlemail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CA+rthh9XU+5oN9Ua-+8XPF9Q0y03FZyxds53sxUjsvsJN2kaJA@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Sep 30, 2015 at 07:54:29AM +0200, Mathias Krause wrote:
> On 29 September 2015 at 21:09, Jason Baron <jbaron@akamai.com> wrote:
> > However, if we call connect on socket 's', to connect to a new socket 'o2', we
> > drop the reference on the original socket 'o'. Thus, we can now close socket
> > 'o' without unregistering from epoll. Then, when we either close the ep
> > or unregister 'o', we end up with this list corruption. Thus, this is not a
> > race per se, but can be triggered sequentially.
> 
> Sounds profound, but the reproducers calls connect only once per
> socket. So there is no "connect to a new socket", no?

I believe there is another scenario: 'o' becomes SOCK_DEAD while 's' is
still connected to it. This is detected by 's' in unix_dgram_sendmsg()
so that 's' releases its reference on 'o' and 'o' can be freed. If this
happens before 's' is unregistered, we get use-after-free as 'o' has
never been unregistered. And as the interval between freeing 'o' and
unregistering 's' can be quite long, there is a chance for the memory to
be reused. This is what one of our customers has seen:

    [exception RIP: _raw_spin_lock_irqsave+156]
    RIP: ffffffff8040f5bc  RSP: ffff8800e929de78  RFLAGS: 00010082
    RAX: 000000000000a32c  RBX: ffff88003954ab80  RCX: 0000000000001000
    RDX: 00000000f2320000  RSI: 000000000000f232  RDI: ffff88003954ab80
    RBP: 0000000000005220   R8: dead000000100100   R9: 0000000000000000
    R10: 00007fff1a284960  R11: 0000000000000246  R12: 0000000000000000
    R13: ffff8800e929de8c  R14: 000000000000000e  R15: 0000000000000000
    ORIG_RAX: ffffffffffffffff  CS: 10000e030  SS: e02b
 #8 [ffff8800e929de70] _raw_spin_lock_irqsave at ffffffff8040f5a9
 #9 [ffff8800e929deb0] remove_wait_queue at ffffffff8006ad09
#10 [ffff8800e929ded0] ep_unregister_pollwait at ffffffff80170043
#11 [ffff8800e929def0] ep_remove at ffffffff80170073
#12 [ffff8800e929df10] sys_epoll_ctl at ffffffff80171453
#13 [ffff8800e929df80] system_call_fastpath at ffffffff80417553

In this case, crash happened on unregistering 's' which had null peer
(i.e. not reconnected but rather disconnected) but there were still two
items in the list, the other pointing to an unallocated page which has
apparently been modified in between.

IMHO unix_dgram_disonnected() could be the place to handle this issue:
it is called from both places where we disconnect from a peer (dead peer
detection in unix_dgram_sendmsg() and reconnect in unix_dgram_connect())
just before the reference to peer is released. I'm not familiar with the
epoll implementation so I'm still trying to find what exactly needs to
be done to unregister the peer at this moment.

> That bug triggers since commit 3c73419c09 "af_unix: fix 'poll for
> write'/ connected DGRAM sockets". That's v2.6.26-rc7, as noted in the
> reproducer.

Sounds likely as this is the commit that introduced unix_dgram_poll()
with the code which adds the "asymmetric peer" to monitor its queue
state. More precisely, the asymmetricity check has been added by

  ec0d215f9420 ("af_unix: fix 'poll for write'/connected DGRAM sockets")

shortly after that.

                                                          Michal Kubecek
