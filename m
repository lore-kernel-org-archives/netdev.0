From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: Re: sys_sendmsg Fails Silently With Negative msg_namelen
Date: Sat, 8 Mar 2014 00:26:09 +0300
Message-ID: <20140307212609.GQ4774@mwanda>
References: <87vbvpx0fo.fsf@e106496-lin.cambridge.arm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Will Deacon <Will.Deacon@arm.com>
To: Matthew Leach <matthew.leach@arm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:33583 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751624AbaCGV0W (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Mar 2014 16:26:22 -0500
Content-Disposition: inline
In-Reply-To: <87vbvpx0fo.fsf@e106496-lin.cambridge.arm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 07, 2014 at 07:39:55PM +0000, Matthew Leach wrote:
> Hello,
> 
> Passing -1 in msg->msg_namelen to sys_sendmsg will cause the syscall
> to finish without error. This happens because of the following check
> in copy_msghdr_from_user:
> 
> if (kmsg->msg_namelen > sizeof(struct sockaddr_storage))
> 	 kmsg->msg_namelen = sizeof(struct sockaddr_storage);
> 
> This check passes due to a comparison between signed (msg_namelen =
> -1) and unsigned values (sizeof(struct sockaddr_storage) = 128). This
> was introduced with 1661bf36 ("net: heap overflow in
> __audit_sockaddr()").

The silent capping was actually introduced in commit db31c55a6fb2 ('net:
clamp ->msg_namelen instead of returning an error').  Just returning an
error code broke beta versions of Ruby and maybe something else?

> 
> Below is an ugly patch that fixes this. Are there any suggestions on a
> cleaner fix?

Your patch re-introduces the memory corruption bug that 1661bf36 ("net:
heap overflow in __audit_sockaddr()") was supposed to fix.

I think Ruby was using larger buffer sizes than necessary so we could
add something like:

	if (kmsg->msg_namelen < 0)
		return -EINVAL;
	if (kmsg->msg_namelen > sizeof(struct sockaddr_storage))
  		kmsg->msg_namelen = sizeof(struct sockaddr_storage);

Why are people passing -1 as the buffer size anyway?  Your email
suggests that people expect it to work, and it will work fine if you
have a buffer size which is larger than sizeof(struct sockaddr_storage).
I'm nervous about changing something which works fine in case I break
userspace.  A second time.  :P

regards,
dan carpenter
