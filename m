From: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Subject: Re: [PATCH] LSM: Add security_socket_post_accept() and security_socket_post_recv_datagram().
Date: Wed, 22 Apr 2009 09:55:26 +0900
Message-ID: <200904220055.n3M0tQ6T048840@www262.sakura.ne.jp>
References: <200904212126.AJD95821.HFMOFtQJOVFLOS@I-love.SAKURA.ne.jp> <20090421.053701.234331700.davem@davemloft.net> <200904212152.FHH51019.MHOFVtOFSJFQOL@I-love.SAKURA.ne.jp> <20090421.060404.146628527.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Cc: paul.moore@hp.com, linux-security-module@vger.kernel.org,
	netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www262.sakura.ne.jp ([202.181.97.72]:54205 "EHLO
	www262.sakura.ne.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751874AbZDVAzg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Apr 2009 20:55:36 -0400
In-Reply-To: <20090421.060404.146628527.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> If poll() says to a listening socket that connections are
> available, we MUST return a connection from accept() unless
> there is a hard error.

No application is permitted to assume that accept() returns a connection if
poll() says that connections are available even if there is an assumption that
none of sock->ops->accept(), newsock->ops->getname(), move_addr_to_user()
fails, for there is security_socket_accept() hook which can interrupt between
"poll()" and "accept()".

There is a possibility that LSM module's policy changes from "allow picking
the connection up from the listening socket" to "deny picking the connection
up from the listening socket" after poll() said "connections are available".
We allow this policy change and we tolerate breakage of the application
expected semantics.

> If we tell the application, via poll() or similar, that connections
> are available and no other thread can get in there to steal the
> connection, we must deliver a connection to the listening socket when
> it calls accept() except in very unusual circumstances (out of file
> descriptors, memory allocation failure, etc.)!

If you think policy changes between poll() and security_socket_accept() is
one of unusual circumstances, I think policy changes between
security_socket_accept() and security_socket_post_accept()
(the old policy before poll() said "connections are available" was "allow
picking the connection up from any client" while the new policy after
poll() said "connections are available" is "allow picking the connection
up from only 127.0.0.1") is also one of unusual circumstances.
The only difference between security_socket_accept() and
security_socket_post_accept() is that whether the connection remains in the
listening socket's queue or not. We cannot avoid breakage of the application
expected semantics from the beginning.
