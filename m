From: Marcelo Ricardo Leitner <mleitner@redhat.com>
Subject: Re: [PATCH net] Fix race condition between vxlan_sock_add and vxlan_sock_release
Date: Wed, 10 Dec 2014 16:34:51 -0200
Message-ID: <5488924B.5070502@redhat.com>
References: <e76bb0b4377c56583148323ada9b479e4628e35e.1418135271.git.mleitner@redhat.com> <20141210.131133.729833991671277249.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:41451 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932479AbaLJSey (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 10 Dec 2014 13:34:54 -0500
In-Reply-To: <20141210.131133.729833991671277249.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10-12-2014 16:11, David Miller wrote:
> From: Marcelo Ricardo Leitner <mleitner@redhat.com>
> Date: Tue,  9 Dec 2014 12:28:28 -0200
>
>> Currently, when trying to reuse a socket, vxlan_sock_add will grab
>> vn->sock_lock, locate a reusable socket, inc refcount and release
>> vn->sock_lock.
>>
>> But vxlan_sock_release() will first decrement refcount, and then grab
>> that lock. refcnt operations are atomic but as currently we have
>> deferred works which hold vs->refcnt each, this might happen, leading to
>> a use after free (specially after vxlan_igmp_leave):
>>
>>    CPU 1                            CPU 2
>>
>> deferred work                    vxlan_sock_add
>
> Just make vxlan_sock_add() do atomic_add_unless(x, 1, 0), that way
> if vxlan_sock_add() sees the count at zero it can just act as if
> no such reusable socket exists.

Interesting, I had thought of this, but it seemed a bit messy.
But okay, I see the pros on it, will go that way. Thanks!

   Marcelo
