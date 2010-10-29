From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [PATCH] net: Limit socket I/O iovec total length to INT_MAX.
Date: Fri, 29 Oct 2010 11:59:48 -0700
Message-ID: <AANLkTinCD-A18cCV4FH1Q4oiOvfdsCTgLr6EXd17Rggi@mail.gmail.com>
References: <20101028.112231.232747062.davem@davemloft.net>
 <AANLkTinAzvfrRHwW-w-Ppdu7LWd7nGTa4EWP=e6pKV2F@mail.gmail.com>
 <1288360820.2092.34.camel@dan> <AANLkTikeaXncdUohUiGF2EkhujYETK5dtyOJASffz2qR@mail.gmail.com>
 <4CCB17B7.1010908@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Dan Rosenberg <drosenberg@vsecurity.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	jon.maloy@ericsson.com, allan.stephens@windriver.com,
	Al Viro <viro@zeniv.linux.org.uk>
To: Rick Jones <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:50135 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753553Ab0J2TAg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Oct 2010 15:00:36 -0400
Received: from mail-gw0-f46.google.com (mail-gw0-f46.google.com [74.125.83.46])
	(authenticated bits=0)
	by smtp1.linux-foundation.org (8.14.2/8.13.5/Debian-3ubuntu1.1) with ESMTP id o9TJ0HpW012466
	(version=TLSv1/SSLv3 cipher=RC4-MD5 bits=128 verify=FAIL)
	for <netdev@vger.kernel.org>; Fri, 29 Oct 2010 12:00:17 -0700
Received: by gwj21 with SMTP id 21so2196083gwj.19
        for <netdev@vger.kernel.org>; Fri, 29 Oct 2010 12:00:09 -0700 (PDT)
In-Reply-To: <4CCB17B7.1010908@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Oct 29, 2010 at 11:51 AM, Rick Jones <rick.jones2@hp.com> wrote:
> It may be but a paint splatter on the bikeshed, or considered a case of
> "Doctor! Doctor! It hurts when I do this" "Then don't do that!" but
> elsewhere (not in the context of Linux) I've seen mention made of ISV
> software posting some particularly large receives and such - one case I saw
> was over 1GB, where that was tied to the size of a log buffer the creation
> of which I believe was not limited to ~INT_MAX by the application software.

Sure. And that is why I very much don't think it's a good idea to
disallow large reads or writes. Returning an error would be bad,
because it's not entirely unreasonable for some user to just have a
really big object (presumably for unrelated reasons), and do IO on it
in one go.

But expecting anybody to _fill_ that really big object in one go is
unreasonable. Even for regular files, anybody who has ever worked with
NFS and interruptible mounts knows that they have to be able to handle
partial IO. And with non-files you obviously have that all the time.

So I think it's perfectly fine to do a terabyte read() or write(). The
fact that the kernel will then internally limit it, and won't ever
actually then write more than 2GB-1 at a time ends up being just an
"implementation issue" that happens to protect the kernel against
subsystems that happen to have issues.

And an application that cannot handle partial reads or writes, yet
works with gigabyte+ data sets is _not_ an application that I consider
reasonable. That's a user space bug, pure and simple, and no amount of
"but but ..." makes any difference what-so-ever.

                        Linus
