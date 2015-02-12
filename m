From: Catalin Marinas <catalin.marinas@arm.com>
Subject: Re: [PATCH] net: compat: Ignore MSG_CMSG_COMPAT in
 compat_sys_{send,recv}msg
Date: Thu, 12 Feb 2015 17:32:18 +0000
Message-ID: <20150212173218.GC25491@e104818-lin.cambridge.arm.com>
References: <1423744087-21317-1-git-send-email-catalin.marinas@arm.com>
 <20150212.084124.1966135201655814270.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Will Deacon <Will.Deacon@arm.com>,
	"luto@amacapital.net" <luto@amacapital.net>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20150212.084124.1966135201655814270.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Feb 12, 2015 at 04:41:24PM +0000, David Miller wrote:
> From: Catalin Marinas <catalin.marinas@arm.com>
> Date: Thu, 12 Feb 2015 12:28:07 +0000
> 
> > With commit a7526eb5d06b (net: Unbreak compat_sys_{send,recv}msg), the
> > MSG_CMSG_COMPAT flag is blocked at the compat syscall entry points,
> > changing the kernel compat behaviour from the one before the commit it
> > was trying to fix (1be374a0518a, net: Block MSG_CMSG_COMPAT in
> > send(m)msg and recv(m)msg).
> > 
> > On 32-bit kernels (!CONFIG_COMPAT), MSG_CMSG_COMPAT is 0 and the native
> > 32-bit sys_sendmsg() allows flag 0x80000000 to be set (it is ignored by
> > the kernel). However, on a 64-bit kernel, the compat ABI is different
> > with commit a7526eb5d06b.
> > 
> > This patch changes the compat_sys_{send,recv}msg behaviour to the one
> > prior to commit 1be374a0518a.
> > 
> > The problem was found running 32-bit LTP (sendmsg01) binary on an arm64
> > kernel. Arguably, LTP should not pass 0xffffffff as flags to sendmsg()
> > but the general rule is not to break user ABI (even when the user
> > behaviour is not entirely sane).
> > 
> > Fixes: a7526eb5d06b (net: Unbreak compat_sys_{send,recv}msg)
> > Cc: Andy Lutomirski <luto@amacapital.net>
> > Cc: David S. Miller <davem@davemloft.net>
> > Signed-off-by: Catalin Marinas <catalin.marinas@arm.com>
> 
> I think this is a very poor LTP test.

That I agree.

> Setting MSG_* bits that aren't supported by the protocol in any way
> gives undefined semantics.  You may get an error, it may be silently
> ignored, etc.

>From the sendmsg(2) man page, if some bit in the flags is inappropriate
for the socket type, it should return -EOPNOTSUPP. But I can't tell
whether it refers only to bits which are defined (for other socket
types) or just any bit. The test itself checks for -EOPNOTSUPP but it
gets -EINVAL instead, hence the failure being reported.

> I'm not applying this, sorry.

What I'm after is consistency between the native 32-bit kernel and the
compat layer on 64-bit. On the former, bit 31 is silently ignored, on
the latter it reports -EINVAL.

We could as well do something like below but we end up with unnecessary
flags check on 32-bit. The question is whether such change would be
considered a 32-bit user ABI breakage.

diff --git a/include/linux/socket.h b/include/linux/socket.h
index 6e49a14365dc..0b283397ca0a 100644
--- a/include/linux/socket.h
+++ b/include/linux/socket.h
@@ -272,11 +272,7 @@ struct ucred {
 #define MSG_CMSG_CLOEXEC 0x40000000	/* Set close_on_exec for file
 					   descriptor received through
 					   SCM_RIGHTS */
-#if defined(CONFIG_COMPAT)
 #define MSG_CMSG_COMPAT	0x80000000	/* This message needs 32 bit fixups */
-#else
-#define MSG_CMSG_COMPAT	0		/* We never have 32 bit fixups */
-#endif
 
 
 /* Setsockoptions(2) level. Thanks to BSD these must match IPPROTO_xxx */

-- 
Catalin
