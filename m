From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Subject: Re: [PATCH] LSM: Add post recvmsg() hook.
Date: Fri, 23 Jul 2010 16:21:38 +0900
Message-ID: <201007230721.o6N7Lc2L048186@www262.sakura.ne.jp>
References: <20100722.102251.165153819.davem@davemloft.net> <20100722.102637.201684445.davem@davemloft.net> <201007230022.o6N0MKLt053955@www262.sakura.ne.jp> <20100722.224450.04662931.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, pekkas@netcore.fi, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net, paul.moore@hp.com,
	netdev@vger.kernel.org, linux-security-module@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www262.sakura.ne.jp ([202.181.97.72]:52785 "EHLO
	www262.sakura.ne.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751386Ab0GWHVm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Jul 2010 03:21:42 -0400
In-Reply-To: <20100722.224450.04662931.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: Tetsuo Handa
> Date: Fri, 23 Jul 2010 09:22:20 +0900
> 
> > David Miller wrote:
> >> The fact is going to remain that you will be unable to return data
> >> from recvmsg() to a blocking socket when ->poll() returns true even
> >> though data is in fact there in the socket receive queue.
> >> 
> >> This is something that the existing LSM hooks do not do.
> > 
> > This is something that the existing security_socket_recvmsg() hook does do.
> > SELinux is unable to return data from recvmsg() to a blocking socket when
> > ->poll() returns true even though data is in fact there in the socket receive
> > queue.
> > We agreed below situation, didn't we?
> 
> Existing LSM hook returns an error early, as if the user passed in
> incorrect parameters or similar.
> 
> It's completely stateless and dependent upon purely the labels
> associated with state visible on recvmsg() entry, and independent
> of other things such as attributes in the packets contained in
> the socket's receive queue.

Users calling recvmsg() after select() said "read operation will return with
available data without blocking as long as you pass correct parameters" will
get error code even if they passed correct parameters.

If they passed incorrect parameters, they must accept the error code.
But they passed correct parameters, and they expected that recvmsg() returns
success with available data. From the point of view of select()->recvmsg()
users, they don't care whether internal implementation is stateful and/or
dependent of other things or not, they care what the specification says.

My understanding was that the specification requires

  If select() said "read operation will return with available data without
  blocking", recvmsg() must return available data. No access control mechanism
  in recvmsg() path is allowed to reject the request.

and security_socket_recvmsg() conflicts with this understanding.
I'd like to see the specification which states disclaimers like below.

  (i) Even if select() said "read operation will return with available data
      without blocking", recvmsg() is allowed to return error code rather than
      available data when an access control mechanism in recvmsg() path
      rejected the request.

  (ii) The access control mechanism in recvmsg() path may use attribute of
       the socket.

  (iii) The access control mechanism in recvmsg() path must not use the
        packets contained in the socket's receive queue.

We agreed on (i) and I don't mind (ii).
Would you please show me URLs to the specification which states (iii)?
