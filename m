From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [PATCH] Fix for IPsec leakage with SELinux enabled
Date: Mon, 2 Oct 2006 17:42:01 +0400
Message-ID: <20061002134200.GA20441@2ka.mipt.ru>
References: <20060925120519.GA19010@2ka.mipt.ru> <Pine.LNX.4.64.0609300037460.12011@d.namei> <Pine.LNX.4.64.0609300110190.12422@d.namei> <20060930111521.GA646@2ka.mipt.ru> <Pine.LNX.4.64.0609301035020.26766@d.namei> <20060930144018.GA16918@2ka.mipt.ru> <Pine.LNX.4.64.0609301044090.26813@d.namei> <Pine.LNX.4.64.0610010203440.8658@d.namei> <20061002112050.GA772@2ka.mipt.ru> <Pine.LNX.4.64.0610020919050.9400@d.namei>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: "David S. Miller" <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	netdev@vger.kernel.org, Stephen Smalley <sds@tycho.nsa.gov>,
	Venkat Yekkirala <vyekkirala@TrustedCS.com>,
	Paul Moore <paul.moore@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:45484 "EHLO 2ka.mipt.ru")
	by vger.kernel.org with ESMTP id S932328AbWJBNmc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Oct 2006 09:42:32 -0400
To: James Morris <jmorris@namei.org>
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0610020919050.9400@d.namei>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Oct 02, 2006 at 09:31:36AM -0400, James Morris (jmorris@namei.org) wrote:
> What kind of traffic was running over the system?  What is the IPsec and 
> SELinux configuration?

I had login through ssh, started racoon and setup keys.
SElinu is configured by default in FC5 system with enforcing mode.

I switched off to different window and after some time, not immediately,
remote system stopped to answer.

There were no heavy traffic definitely.
It looks like some timeout expired and someone tried to do xfrm_lookup.

> Can you run gdb on vmlinux, find the start of xfrm_lookup then list what's 
> at the EIP offset?
> 
> (gdb) p xfrm_lookup
> $1 = {int (struct dst_entry **, struct flowi *, struct sock *, int)} 
> 0xc02cc7e2 <xfrm_lookup>
> (gdb) l *(0xc02cc7e2 + 0x043d)

(gdb) p xfrm_lookup
$1 = {int (struct dst_entry **, struct flowi *, struct sock *, int)} 0xc0301326 <xfrm_lookup>
(gdb) l *(0xc0301326+0x043d)
0xc0301763 is in xfrm_lookup (include/asm/atomic.h:126).
121      */ 
122     static __inline__ int atomic_dec_and_test(atomic_t *v)
123     {
124             unsigned char c;
125
126             __asm__ __volatile__(
127                     LOCK_PREFIX "decl %0; sete %1"
128                     :"+m" (v->counter), "=qm" (c)
129                     : : "memory");
130             return c != 0;

Probably reference counter is inside freed object...

> -- 
> James Morris
> <jmorris@namei.org>

-- 
	Evgeniy Polyakov
