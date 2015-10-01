From: Jason Baron <jbaron@akamai.com>
Subject: Re: List corruption on epoll_ctl(EPOLL_CTL_DEL) an AF_UNIX socket
Date: Wed, 30 Sep 2015 22:55:59 -0400
Message-ID: <560CA0BF.7090608@akamai.com>
References: <20150913195354.GA12352@jig.fritz.box> <20150914023949.GA15012@dcvr.yhbt.net> <CA+rthh8smc0fxL5sEhMpKRQgzMi=BCVyxKc=O1JWesHGwYW8XA@mail.gmail.com> <560AE202.4020402@akamai.com> <CA+rthh9XU+5oN9Ua-+8XPF9Q0y03FZyxds53sxUjsvsJN2kaJA@mail.gmail.com> <20150930073410.GA7339@unicorn.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
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
To: Michal Kubecek <mkubecek@suse.cz>,
	Mathias Krause <minipli@googlemail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a23-79-238-179.deploy.static.akamaitechnologies.com ([23.79.238.179]:12051
	"EHLO prod-mail-xrelay05.akamai.com" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755094AbbJAC4B (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Sep 2015 22:56:01 -0400
In-Reply-To: <20150930073410.GA7339@unicorn.suse.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/30/2015 03:34 AM, Michal Kubecek wrote:
> On Wed, Sep 30, 2015 at 07:54:29AM +0200, Mathias Krause wrote:
>> On 29 September 2015 at 21:09, Jason Baron <jbaron@akamai.com> wrote:
>>> However, if we call connect on socket 's', to connect to a new socket 'o2', we
>>> drop the reference on the original socket 'o'. Thus, we can now close socket
>>> 'o' without unregistering from epoll. Then, when we either close the ep
>>> or unregister 'o', we end up with this list corruption. Thus, this is not a
>>> race per se, but can be triggered sequentially.
>>
>> Sounds profound, but the reproducers calls connect only once per
>> socket. So there is no "connect to a new socket", no?
> 
> I believe there is another scenario: 'o' becomes SOCK_DEAD while 's' is
> still connected to it. This is detected by 's' in unix_dgram_sendmsg()
> so that 's' releases its reference on 'o' and 'o' can be freed. If this
> happens before 's' is unregistered, we get use-after-free as 'o' has
> never been unregistered. And as the interval between freeing 'o' and
> unregistering 's' can be quite long, there is a chance for the memory to
> be reused. This is what one of our customers has seen:
> 
>     [exception RIP: _raw_spin_lock_irqsave+156]
>     RIP: ffffffff8040f5bc  RSP: ffff8800e929de78  RFLAGS: 00010082
>     RAX: 000000000000a32c  RBX: ffff88003954ab80  RCX: 0000000000001000
>     RDX: 00000000f2320000  RSI: 000000000000f232  RDI: ffff88003954ab80
>     RBP: 0000000000005220   R8: dead000000100100   R9: 0000000000000000
>     R10: 00007fff1a284960  R11: 0000000000000246  R12: 0000000000000000
>     R13: ffff8800e929de8c  R14: 000000000000000e  R15: 0000000000000000
>     ORIG_RAX: ffffffffffffffff  CS: 10000e030  SS: e02b
>  #8 [ffff8800e929de70] _raw_spin_lock_irqsave at ffffffff8040f5a9
>  #9 [ffff8800e929deb0] remove_wait_queue at ffffffff8006ad09
> #10 [ffff8800e929ded0] ep_unregister_pollwait at ffffffff80170043
> #11 [ffff8800e929def0] ep_remove at ffffffff80170073
> #12 [ffff8800e929df10] sys_epoll_ctl at ffffffff80171453
> #13 [ffff8800e929df80] system_call_fastpath at ffffffff80417553
> 
> In this case, crash happened on unregistering 's' which had null peer
> (i.e. not reconnected but rather disconnected) but there were still two
> items in the list, the other pointing to an unallocated page which has
> apparently been modified in between.
> 
> IMHO unix_dgram_disonnected() could be the place to handle this issue:
> it is called from both places where we disconnect from a peer (dead peer
> detection in unix_dgram_sendmsg() and reconnect in unix_dgram_connect())
> just before the reference to peer is released. I'm not familiar with the
> epoll implementation so I'm still trying to find what exactly needs to
> be done to unregister the peer at this moment.
> 

Indeed that is a path as well. The patch I posted here deals with that
case as well. It does a remove_wait_queue() in that case.

unix_dgram_disconnected() gets called as you point out when we are removing
the remote peer, and I have a remove_wait_queue() in that case. The patch
I posted converts us back to a polling() against a single wait queue.

The wait structure that epoll()/select()/poll() adds to the peer wait
queue is really opaque to the unix code. The normal pattern is for
epoll()/select()/poll() to do the unregister, not the socket/fd that
we are waiting on. Further we could not just release all of the wait
queues in unix_dgram_disconnected() b/c there could be multiple waiters
there. So the POLLFREE thing really has to be done from the
unix_sock_destructor() path, since it going to free the entire queue.

In addition, I think that removing the the wait queue from
unix_dgram_disconnected() will still be broken, b/c we would need to
re-add to the remote peer via subsequent poll(), to get events if the
socket was re-connected to a new peer.

Thanks,

-Jason
