From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Subject: Re: [PATCH] net: Fix security_socket_sendmsg() bypass problem.
Date: Tue, 2 Aug 2011 20:52:05 +0900
Message-ID: <201108022052.FBE56208.FLQHFtMOVOSOJF@I-love.SAKURA.ne.jp>
References: <20110801.230731.1942061135621106602.davem@davemloft.net>
	<201108020928.p729Sekl091800@www262.sakura.ne.jp>
	<20110802.041857.1325765319466840715.davem@davemloft.net>
	<20110802.042641.2122529993066553943.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: eparis@parisplace.org, anton@samba.org, casey@schaufler-ca.com,
	mjt@tls.msk.ru, netdev@vger.kernel.org,
	linux-security-module@vger.kernel.org
To: davem@davemloft.net
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <20110802.042641.2122529993066553943.davem@davemloft.net>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller wrote:
> Actually, I change my mind. :-)
> 
> I think sendmmsg() needs to unconditionally not report an error if any
> datagrams were sent successfully.

What about adding

 #ifdef CONFIG_SECURITY_NETWORK
 static inline bool security_socket_may_send_multiple_address(void)
 {
	return security_ops->socket_may_send_multiple_address;
 }
 #else
 static inline bool security_socket_may_send_multiple_address(void)
 {
	return true;
 }
 #endif

and letting SMACK and TOMOYO return false and others return true?

The check will look like

  if (sendmmsg) {
    Record destination address of first datagram if first datagram,
    compare with recorded address and subsequent datagram otherwise.
    If same address, continue. Otherwise, call
    security_socket_may_send_multiple_address() and break if it returns false.
  }

. The side effect is that sendmmsg() will be allowed to send to single
destination if underlying  LSM module does not permit sending to multiple
address, to multiple destination otherwise. As long as sendmmsg() is used for
sending to single destination, there will be no performance loss.

It will be kmalloc()-free, fast and simple. Also, makes LSM stacking easier.
