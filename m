From: Michael Tokarev <mjt@tls.msk.ru>
Subject: Re: [PATCH] net: Fix security_socket_sendmsg() bypass problem.
Date: Sat, 23 Jul 2011 11:04:19 +0400
Message-ID: <4E2A7273.7030504@msgid.tls.msk.ru>
References: <201107222041.FGG51092.OOQFFLOtMVFJHS@I-love.SAKURA.ne.jp>	<201107222127.GBG51007.FStQFVOHOFOLJM@I-love.SAKURA.ne.jp>	<201107230012.HED65612.JFVSFOOOMHtFLQ@I-love.SAKURA.ne.jp> <20110722.082224.688620059032914637.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: penguin-kernel@I-love.SAKURA.ne.jp, casey@schaufler-ca.com,
	anton@samba.org, netdev@vger.kernel.org,
	linux-security-module@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <20110722.082224.688620059032914637.davem@davemloft.net>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

22.07.2011 19:22, David Miller wrote:
> From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> Date: Sat, 23 Jul 2011 00:12:53 +0900
> 
>> I think the regression for SMACK can be fixed with below patch.
>>
>> Should I pass nosec flags down to "struct security_operations"->sendmsg()
>> so that SELinux checks sock_has_perm() for only once when multiple different
>> destination's addresses are passed to sendmmsg()?
>>
>> static int selinux_socket_sendmsg(struct socket *sock, struct msghdr *msg,
>> 				  int size, int nosec)
>> {
>> 	return nosec ? 0 : sock_has_perm(current, sock->sk, SOCKET__WRITE);
>> }
> 
> Ugh, this takes away a non-trivial part of the performance gain of
> sendmmsg().
> 
> I would instead rather that you check ahead of time whether this
> actually is a send to different addresses.  If they are all the
> same, keep the nosec code path.

Why to optimize for this case when destination addresses are the
same?  How common this usage case is, or even where it _can_
happen alot (I noticed samba.org address in the Cc list).

When I saw recvmmsg()/sendmmsg() here, my first thought was an
authoritative DNS server which can read several requests at a
time and answer them all at once too - this way it all will go
to different addresses.

I understand the initial change takes away good portion of
performance improvement, but I think the optimisation should
be performed in a different place than for a not-so-common
cenario.

Thanks,

/mjt
