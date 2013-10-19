From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net: unix: inherit SOCK_PASS{CRED,SEC} flags from
 socket to fix race
Date: Sat, 19 Oct 2013 18:50:57 -0400 (EDT)
Message-ID: <20131019.185057.1209480553711126452.davem@davemloft.net>
References: <cover.1382042286.git.dborkman@redhat.com>
	<5c4eda258a6d7397a180ca72562b0ce5d87beda1.1382042286.git.dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, edumazet@google.com, ebiederm@xmission.com
To: dborkman@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40296 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750769Ab3JSWu6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 19 Oct 2013 18:50:58 -0400
In-Reply-To: <5c4eda258a6d7397a180ca72562b0ce5d87beda1.1382042286.git.dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <dborkman@redhat.com>
Date: Thu, 17 Oct 2013 22:51:31 +0200

> In the case of credentials passing in unix stream sockets (dgram
> sockets seem not affected), we get a rather sparse race after
> commit 16e5726 ("af_unix: dont send SCM_CREDENTIALS by default").
> 
> We have a stream server on receiver side that requests credential
> passing from senders (e.g. nc -U). Since we need to set SO_PASSCRED
> on each spawned/accepted socket on server side to 1 first (as it's
> not inherited), it can happen that in the time between accept() and
> setsockopt() we get interrupted, the sender is being scheduled and
> continues with passing data to our receiver. At that time SO_PASSCRED
> is neither set on sender nor receiver side, hence in cmsg's
> SCM_CREDENTIALS we get eventually pid:0, uid:65534, gid:65534
> (== overflow{u,g}id) instead of what we actually would like to see.
> 
> On the sender side, here nc -U, the tests in maybe_add_creds()
> invoked through unix_stream_sendmsg() would fail, as at that exact
> time, as mentioned, the sender has neither SO_PASSCRED on his side
> nor sees it on the server side, and we have a valid 'other' socket
> in place. Thus, sender believes it would just look like a normal
> connection, not needing/requesting SO_PASSCRED at that time.
> 
> As reverting 16e5726 would not be an option due to the significant
> performance regression reported when having creds always passed,
> one way/trade-off to prevent that would be to set SO_PASSCRED on
> the listener socket and allow inheriting these flags to the spawned
> socket on server side in accept(). It seems also logical to do so
> if we'd tell the listener socket to pass those flags onwards, and
> would fix the race.
> 
> Before, strace:
> 
> recvmsg(4, {msg_name(0)=NULL, msg_iov(1)=[{"blub\n", 4096}],
>         msg_controllen=32, {cmsg_len=28, cmsg_level=SOL_SOCKET,
>         cmsg_type=SCM_CREDENTIALS{pid=0, uid=65534, gid=65534}},
>         msg_flags=0}, 0) = 5
> 
> After, strace:
> 
> recvmsg(4, {msg_name(0)=NULL, msg_iov(1)=[{"blub\n", 4096}],
>         msg_controllen=32, {cmsg_len=28, cmsg_level=SOL_SOCKET,
>         cmsg_type=SCM_CREDENTIALS{pid=11580, uid=1000, gid=1000}},
>         msg_flags=0}, 0) = 5
> 
> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>

Applied and queued up for -stable, thanks Daniel.
