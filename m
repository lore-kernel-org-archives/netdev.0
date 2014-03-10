From: Matthew Leach <matthew.leach@arm.com>
Subject: Re: sys_sendmsg Fails Silently With Negative msg_namelen
Date: Mon, 10 Mar 2014 10:48:52 +0000
Message-ID: <87fvmqwcq3.fsf@e106496-lin.cambridge.arm.com>
References: <87vbvpx0fo.fsf@e106496-lin.cambridge.arm.com>
	<20140307212609.GQ4774@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset=WINDOWS-1252
Content-Transfer-Encoding: 8BIT
Cc: "netdev\@vger.kernel.org" <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Will Deacon <Will.Deacon@arm.com>
To: Dan Carpenter <dan.carpenter@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from service87.mimecast.com ([91.220.42.44]:56476 "EHLO
	service87.mimecast.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752191AbaCJKs5 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Mar 2014 06:48:57 -0400
In-Reply-To: <20140307212609.GQ4774@mwanda> (Dan Carpenter's message of "Fri,
	7 Mar 2014 21:26:09 +0000")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dan,

Dan Carpenter <dan.carpenter@oracle.com> writes:

[...]

> I think Ruby was using larger buffer sizes than necessary so we could
> add something like:
>
> 	if (kmsg->msg_namelen < 0)
> 		return -EINVAL;
> 	if (kmsg->msg_namelen > sizeof(struct sockaddr_storage))
>   		kmsg->msg_namelen = sizeof(struct sockaddr_storage);

I don't see how your patch does anything different?  If we don't clamp
the value and leave it as -1 the check for a negative buffer size
eventually happens in move_addr_to_kernel anyway, just before we copy
the buffer from userspace.  This check fails and returns EINVAL.

>
>
> Why are people passing -1 as the buffer size anyway?  

This was actually found with LTP.  The sendmsg01 test passes -1 as the
msg_namelen parameter and expects the syscall to fail.

> Your email suggests that people expect it to work, and it will work
> fine if you have a buffer size which is larger than sizeof(struct
> sockaddr_storage).  I'm nervous about changing something which works
> fine in case I break userspace.  A second time.  :P

Agreed, but IMHO passing -1 as a buffer size should cause a syscall to
fail, rather than assuming we can copy from the buffer.

-- 
Matt
