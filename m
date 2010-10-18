From: Leandro Lucarella <luca@llucax.com.ar>
Subject: Linux 2.6.35/TIPC 2.0 ABI breaking changes [was: TIPC 2.0 and
 TIPC_SUB_SERVICE]
Date: Mon, 18 Oct 2010 12:04:22 -0300
Message-ID: <20101018150422.GV8781__17128.5392753363$1287417616$gmane$org@llucax.com.ar>
References: <20100927163823.GD2834@integratech.com.ar>
 <29C1DC0826876849BDD9F1C67ABA2943090B67EC@ala-mail09.corp.ad.wrs.com>
 <20100929153805.GG2834@integratech.com.ar>
 <29C1DC0826876849BDD9F1C67ABA29430914AC18@ala-mail09.corp.ad.wrs.com>
 <20101001150034.GS8781@llucax.com.ar>
 <0434463FDA60A94FA978ACA44617682DEE843EDD79@EUSAACMS0702.eamcs.ericsson.se>
 <20101001162346.GV8781@llucax.com.ar>
 <4CA69F18.7000005@amln.net>
 <0434463FDA60A94FA978ACA44617682DEE8446A03B@EUSAACMS0702.eamcs.ericsson.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Peter Litov <xpl@amln.net>,
	"tipc-discussion@lists.sourceforge.net"
	<tipc-discussion@lists.sourceforge.net>, davem@redhat.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Jon Maloy <jon.maloy@ericsson.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from alerce.vps.bitfolk.com ([212.13.194.134]:3725 "EHLO
	alerce.vps.bitfolk.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757193Ab0JRQAD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Oct 2010 12:00:03 -0400
Received: from host222.190-30-133.telecom.net.ar ([190.30.133.222] helo=burns.springfield.home)
	by alerce.vps.bitfolk.com with esmtpsa (TLS1.0:RSA_AES_256_CBC_SHA1:32)
	(Exim 4.69)
	(envelope-from <luca@llucax.com.ar>)
	id 1P7rn7-00020x-4x
	for netdev@vger.kernel.org; Mon, 18 Oct 2010 12:38:25 -0300
Received: from luca by burns.springfield.home with local (Exim 4.72)
	(envelope-from <luca@llucax.com.ar>)
	id 1P7rn2-0007fm-Ry
	for netdev@vger.kernel.org; Mon, 18 Oct 2010 12:38:20 -0300
Content-Disposition: inline
In-Reply-To: <0434463FDA60A94FA978ACA44617682DEE8446A03B@EUSAACMS0702.eamcs.ericsson.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jon Maloy, el  4 de octubre a las 11:08 me escribiste:
> Hi Peter,
> Adding the version as a sockopt is a very is a very good idea. 
> But actually, you can find out the version, and get around the two-binary problem aready now:
> 
> Check if TIPC_SUB_SERVICE is zero. If it is, the version is 2.0,
> otherwise it is pre-2.0, and you should use the TIPC_SUB_SERVICE with
> a value of 1.
> A little hackish, maybe, but it would solve your problem (which is
> temporary anyway) provided you can alter and recompile your code. 
> 
> And, since you are anyway altering the code, you should take the
> opportunity to add the necessary byte-order conversions, since
> TIPC-1.6/7 are forward compatible in that respect.
> 
> The only reason to introduce what Luca is suggesting, compatiblity
> code in the driver itself, is that you wouldn't need recompile your
> old apps.
> lf that is an absolute requirement we could do that, but our initial
> assessment was that most people recompile their code when moving to
> a new kernel. We may be wrong there, of course.

I thought the kernel usually went to great lengths to ensure old
userspace binaries work with newer kernels.

Since this, as you mention, is not hard to do, and does not impose
a penalty on new code, why not do it?

> It is also uncertain whether David M would accept such a change, or if
> he would see it as a way of sneaking back a functionality he already
> threw out.

By the way, this doesn't work at all for the "bindings" I've done to the
D programming language. D is ABI compatible with C, but not source
compatible, so to add TIPC support to D, I had to write all the constant
values again, in a D source file[1].

This means D can't be used to write code that uses TIPC if you target
kernels >= 2.6.35 (unless they write their own bindings, or at least use
a custom TIPC_SUB_SERVICE constant). I could change the TIPC_SUB_SERVICE
value, but then people using older kernels will be screwed. Another
option is to use the version statement (kind of like C's #ifdef):

	version (TIPC_2_0)
		const TIPC_SUB_SERVICE = 0x00;
	else
		const TIPC_SUB_SERVICE = 0x02;

But then, *users* (I mean *end-users* not developers) will need to use
a compiler switch to select for which kernel they would like to compile
their applications, which I find unacceptable.

I think is really very harsh too to force people to recompile their
applications if they want to switch to a newer/older kernel to try
something out.

What I expected is to have something like 2 port names assigned to the
topology services instead of one, TIPC_TOP_SRV which is compatible with
TIPC 1 and marked as deprecated, and TIPC_TOP_SRV2 which only accepts
the TIPC 2.0 standard. Then, nothing of this would have happened.

And I think breaking changes should be discussed (or at least announced)
in this list more thoughtfully before including them in a Linux kernel
release. Is really a shame to be at a point where no matter what is
done, at least a couple of kernel releases will be binary incompatible
with old TIPC applications.


[1] http://www.dsource.org/projects/phobos/browser/trunk/phobos/std/c/linux/tipc.d

PS: Since this is David Miller's call, I'm Cc-ing him (and other kernel
    mailing lists), as it makes no sense to speculate about what he
    thinks if we can just ask him.

-- 
Leandro Lucarella (AKA luca)                     http://llucax.com.ar/
----------------------------------------------------------------------
GPG Key: 5F5A8D05 (F8CD F9A7 BF00 5431 4145  104C 949E BFB6 5F5A 8D05)
----------------------------------------------------------------------
I'll take a quiet life,
a handshake of carbon monoxide,
with no alarms and no surprises,
no alarms and no surprises.
