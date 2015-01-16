From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: ipv4: Fix incorrect free in ICMP receive
Date: Fri, 16 Jan 2015 13:48:12 -0800
Message-ID: <1421444892.11734.148.camel@edumazet-glaptop2.roam.corp.google.com>
References: <05e337f44c7a71ac317194cfa3dcdf62.squirrel@www.codeaurora.org>
	 <1421412775.11734.117.camel@edumazet-glaptop2.roam.corp.google.com>
	 <ff3aa93b48dfedd7721d7fcc8ee7624b.squirrel@www.codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: subashab@codeaurora.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f181.google.com ([209.85.223.181]:47924 "EHLO
	mail-ie0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751314AbbAPVsO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Jan 2015 16:48:14 -0500
Received: by mail-ie0-f181.google.com with SMTP id vy18so889826iec.12
        for <netdev@vger.kernel.org>; Fri, 16 Jan 2015 13:48:14 -0800 (PST)
In-Reply-To: <ff3aa93b48dfedd7721d7fcc8ee7624b.squirrel@www.codeaurora.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2015-01-16 at 20:59 +0000, subashab@codeaurora.org wrote:
> >skb_queue_purge() is also calling skb_orphan() on all skb
> From my reading, it looked like skb_queue_purge() is dequeuing and calling
> kfree_skb() which will release a reference. I did not see skb_orphan()
> being called directly. Am I missing something?
> I think that if it had really orphaned the skb, then this crash would not
> be seen in the first place.

Well, I never said you had no crash.

I said your 'fix' made no sense.

Sure, we automatically call skb_orphan() when skb are freed, as a in
kfree_skb()

Thats whole point having skb->destructor


> >And no, sock_put() does not free the socket.
> >We release a refcount that was acquired when we did the socket lookup.
> I agree that the refcount is released, but it looked to me like inside
> sock_put() the reference count reached 0 hence the socket was freed.
> 
> Here is why I say this
> (from dmesg)
> WARN stack trace @       WARN_ON(atomic_read(&sk->sk_rmem_alloc));
> dump_backtrace+0x0/0x248
> show_stack+0x10/0x1c
> dump_stack+0x1c/0x28
> warn_slowpath_common+0x74/0x9c
> warn_slowpath_null+0x14/0x20
> inet_sock_destruct+0x130/0x1a0
> __sk_free+0x1c/0x168
> sk_free+0x24/0x30            [sock_put() inlined hence not seen in the
> stack trace I believe]
> ping_rcv+0xf4/0x124
> icmp_rcv+0x224/0x2c4
> ip_local_deliver_finish+0x108/0x214
> 
> and here is stack at the time of the exception
> -007|sk_mem_uncharge   [trying to access freed sk structure]
> -007|sock_rfree
> -008|skb_release_head_state
> -009|skb_release_all
> -009|__kfree_skb
> -010|kfree_skb
> -011|icmp_rcv
> -012|ip_local_deliver_finish
> 
> I am not sure why the ref reached zero and if that is even the right trail
> of thought. Could the userspace have released the sock reference also and
> this is race condition? Any thoughts?

Normally it is not possible. By definition, ping_lookup() does a
sock_hold() on a socket that is still alive (since it was found in hash
table). Hash table is protected by ping_table.lock rwlock.

> 
> Note that we are using the 3.10 kernel version and does not have Rick
> Jones patch in this area e3e3217029a35c579bf100998b43976d0b1cb8d7
> "icmp: Remove some spurious dropped packet profile hits from the ICMP",
> although it looks to me that this patch would not solve this problem
> either.


Seriously guys.

Do not post upstream patches if you cannot reproduce the issue on
current kernel.

Thanks
