From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [PATCH] net: Limit socket I/O iovec total length to INT_MAX.
Date: Fri, 29 Oct 2010 08:28:38 -0700
Message-ID: <AANLkTikeaXncdUohUiGF2EkhujYETK5dtyOJASffz2qR@mail.gmail.com>
References: <20101028.112231.232747062.davem@davemloft.net>
 <AANLkTinAzvfrRHwW-w-Ppdu7LWd7nGTa4EWP=e6pKV2F@mail.gmail.com> <1288360820.2092.34.camel@dan>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	jon.maloy@ericsson.com, allan.stephens@windriver.com,
	Al Viro <viro@zeniv.linux.org.uk>
To: Dan Rosenberg <drosenberg@vsecurity.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:55118 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756541Ab0J2P3Z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Oct 2010 11:29:25 -0400
Received: from mail-iw0-f174.google.com (mail-iw0-f174.google.com [209.85.214.174])
	(authenticated bits=0)
	by smtp1.linux-foundation.org (8.14.2/8.13.5/Debian-3ubuntu1.1) with ESMTP id o9TFT4mO023900
	(version=TLSv1/SSLv3 cipher=RC4-MD5 bits=128 verify=FAIL)
	for <netdev@vger.kernel.org>; Fri, 29 Oct 2010 08:29:04 -0700
Received: by iwn10 with SMTP id 10so3836913iwn.19
        for <netdev@vger.kernel.org>; Fri, 29 Oct 2010 08:29:02 -0700 (PDT)
In-Reply-To: <1288360820.2092.34.camel@dan>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Oct 29, 2010 at 7:00 AM, Dan Rosenberg <drosenberg@vsecurity.com> wrote:
>
> While you guys are at it, you might consider preventing sendto(), etc.
> calls from requesting >= 2GB data in one go.

Indeed. David - I think we have to, because that thing converts its
arguments to an iovec and then does a sendmsg, but since it's already
in kernel space it doesn't go through the verify_iovec() path.

So sendto/recvfrom (and possibly others that build their own msg
struct in kernel space) should be limited to MAX_INT too, so that
there's no back way to create a big iovec..

In fs/read_write.c, do_sync_read/write() do that iovec thing too, but
at least for the regular vfs_read()/vfs_write cases they will have
gone through rw_verify_area() first, which does the size limiting for
them.

We do need to fix the readv/writev path, though. It does the
rw_verify_area(), but it doesn't seem to limit the size to the
returned length, but still uses the original one. Hmm.

I think I'll take care of the readv/writev thing, and send it by Al to verify.

                              Linus
