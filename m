From: Paul Moore <paul.moore@hp.com>
Subject: Re: [TOMOYO 15/15] LSM expansion for TOMOYO Linux.
Date: Thu, 6 Sep 2007 11:25:39 -0400
Message-ID: <200709061125.39815.paul.moore@hp.com>
References: <46CED214.6050505@gmail.com> <200709051006.28429.paul.moore@hp.com> <200709062204.DFH97819.JLOHVOOSFMtFQF@I-love.SAKURA.ne.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: linux-kernel@vger.kernel.org,
	linux-security-module@vger.kernel.org, chrisw@sous-sol.org,
	netdev@vger.kernel.org
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlrel6.hp.com ([156.153.255.205]:57487 "EHLO atlrel6.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755421AbXIFP0V convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Sep 2007 11:26:21 -0400
In-Reply-To: <200709062204.DFH97819.JLOHVOOSFMtFQF@I-love.SAKURA.ne.jp>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thursday, September 6 2007 9:04:01 am Tetsuo Handa wrote:
> (1) It uses userspace intervention to allow/reject
>     connections and/or packets based on the application's domain.
>     Since existent hooks can't be used for this purpose,
>     I inserted a new hook post_recv_datagram() at skb_recv_datagram()
>     and I modified socket_post_accept() to return error so that
>     I can drop/disconnect based on the application's domain.
>
>     I think skb_recv_datagram() is the only place that can remove
>     a message picked up with MSG_PEEK flags from the receive queue.
>     To remove a message picked up with MSG_PEEK flags, I noticed that
>     I have to do skb_kill_datagram()-like operation so that
>     "the head message that must not be delivered to the caller" won't
> prevent picking up of "the non-head message that should be delivered to the
> caller" when the caller repeats only recv(MSG_PEEK) requests.
>     Since skb_recv_datagram() can be called from interrupt context,
>     I have to use spin_lock_irqsave() instead for spin_lock_bh(), am I
> right?

There are almost certainly better people to answer locking questions, but here 
is my take on it ... If you are accessing data both in a bottom half and 
elsewhere you need to make sure you disable bottom halfs from running before 
you access the data outside the bottom half (spin_lock_bh()).  If you are 
accessing data both in an interrupt handler and elsewhere you need to make 
sure you disable interrupts when accessing data outside the irq handler 
(spin_lock_irqsave()).

>     By the way, why can't socket_post_accept() fail?
>     Someone may wish to do memory allocation at socket_post_accept().
>     socket_accept() is too early for memory allocation because
>     there is no chance to free allocated memory
>     when sock->ops->accept() failed.
>     I think socket_post_accept() should be able to fail.

>From my experience the community disapproves of approaches which go through 
the entire TCP handshake and then terminate the connection, which is what 
allowing security_socket_post_accept() to fail would do.

-- 
paul moore
linux security @ hp
