From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] unix: avoid use-after-free in ep_remove_wait_queue
Date: Mon, 23 Nov 2015 12:30:33 -0500 (EST)
Message-ID: <20151123.123033.522701221384821229.davem@davemloft.net>
References: <87ziydvasn.fsf_-_@doppelsaurus.mobileactivedefense.com>
	<87d1v57dif.fsf@doppelsaurus.mobileactivedefense.com>
	<87vb8w2ulg.fsf_-_@doppelsaurus.mobileactivedefense.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jbaron@akamai.com, dvyukov@google.com, syzkaller@googlegroups.com,
	mkubecek@suse.cz, viro@zeniv.linux.org.uk,
	linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org,
	hannes@stressinduktion.org, dhowells@redhat.com,
	paul@paul-moore.com, salyzyn@android.com, sds@tycho.nsa.gov,
	ying.xue@windriver.com, netdev@vger.kernel.org, kcc@google.com,
	glider@google.com, andreyknvl@google.com, sasha.levin@oracle.com,
	jln@google.com, keescook@google.com, minipli@googlemail.com
To: rweikusat@mobileactivedefense.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54312 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754194AbbKWRah (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Nov 2015 12:30:37 -0500
In-Reply-To: <87vb8w2ulg.fsf_-_@doppelsaurus.mobileactivedefense.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rainer Weikusat <rweikusat@mobileactivedefense.com>
Date: Fri, 20 Nov 2015 22:07:23 +0000

> Rainer Weikusat <rweikusat@mobileactivedefense.com> writes:
> An AF_UNIX datagram socket being the client in an n:1 association with
> some server socket is only allowed to send messages to the server if the
> receive queue of this socket contains at most sk_max_ack_backlog
> datagrams. This implies that prospective writers might be forced to go
> to sleep despite none of the message presently enqueued on the server
> receive queue were sent by them. In order to ensure that these will be
> woken up once space becomes again available, the present unix_dgram_poll
> routine does a second sock_poll_wait call with the peer_wait wait queue
> of the server socket as queue argument (unix_dgram_recvmsg does a wake
> up on this queue after a datagram was received). This is inherently
> problematic because the server socket is only guaranteed to remain alive
> for as long as the client still holds a reference to it. In case the
> connection is dissolved via connect or by the dead peer detection logic
> in unix_dgram_sendmsg, the server socket may be freed despite "the
> polling mechanism" (in particular, epoll) still has a pointer to the
> corresponding peer_wait queue. There's no way to forcibly deregister a
> wait queue with epoll.
> 
> Based on an idea by Jason Baron, the patch below changes the code such
> that a wait_queue_t belonging to the client socket is enqueued on the
> peer_wait queue of the server whenever the peer receive queue full
> condition is detected by either a sendmsg or a poll. A wake up on the
> peer queue is then relayed to the ordinary wait queue of the client
> socket via wake function. The connection to the peer wait queue is again
> dissolved if either a wake up is about to be relayed or the client
> socket reconnects or a dead peer is detected or the client socket is
> itself closed. This enables removing the second sock_poll_wait from
> unix_dgram_poll, thus avoiding the use-after-free, while still ensuring
> that no blocked writer sleeps forever.
> 
> Signed-off-by: Rainer Weikusat <rweikusat@mobileactivedefense.com>
> Fixes: ec0d215f9420 ("af_unix: fix 'poll for write'/connected DGRAM sockets")

Applied and queued up for -stable, thanks to you and Jason for all of
your hard work on this fix.
