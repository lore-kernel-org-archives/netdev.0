From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH] sock filter: fix copy of filter from userspace
Date: Sat, 13 Oct 2012 21:19:49 +0200
Message-ID: <20121013191949.GA16286@minipsycho.orion>
References: <20121013114032.2d1c1434@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jiri Pirko <jpirko@redhat.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f44.google.com ([74.125.82.44]:55347 "EHLO
	mail-wg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754014Ab2JMTT4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 13 Oct 2012 15:19:56 -0400
Received: by mail-wg0-f44.google.com with SMTP id dr13so3344389wgb.1
        for <netdev@vger.kernel.org>; Sat, 13 Oct 2012 12:19:55 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20121013114032.2d1c1434@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sat, Oct 13, 2012 at 08:40:32PM CEST, shemminger@vyatta.com wrote:
>The sk_unattached_filter_create function is passed a socket
>filter structure and the copies the contents of the filter from
>userspace. Sparse detected that this code was incorrectly using
>memcpy when it needed to use copy_from_user instead.

Hmm. fprog->filter is in this case allocated and filled in kernel.
So memcpy is good.

Not sure how to handle this correctly. Either we remove "__user" or we
redefine "struct sock_fprog" for sk_unattached_filter_create() use.

Any thoughts?

>
>The only use of sk_unattached_filter_create at present is in
>the team driver.
>
>Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
>
>
>--- a/net/core/filter.c	2012-10-09 10:35:03.183141638 -0700
>+++ b/net/core/filter.c	2012-10-13 11:33:05.955531440 -0700
>@@ -666,7 +666,9 @@ int sk_unattached_filter_create(struct s
> 	fp = kmalloc(fsize + sizeof(*fp), GFP_KERNEL);
> 	if (!fp)
> 		return -ENOMEM;
>-	memcpy(fp->insns, fprog->filter, fsize);
>+
>+	if (copy_from_user(fp->insns, fprog->filter, fsize))
>+		return -EFAULT;
> 
> 	atomic_set(&fp->refcnt, 1);
> 	fp->len = fprog->len;
>--
>To unsubscribe from this list: send the line "unsubscribe netdev" in
>the body of a message to majordomo@vger.kernel.org
>More majordomo info at  http://vger.kernel.org/majordomo-info.html
