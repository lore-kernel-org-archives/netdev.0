From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: Problem with patch "make nlmsg_end() and genlmsg_end() void"
Date: Wed, 08 Apr 2015 15:08:02 +0200
Message-ID: <1428498482.2809.10.camel@sipsolutions.net>
References: <E586D25A-9DAF-4535-A282-120F0C6EAE19@holtmann.org>
	 <CAE4R7bCWSM+SyDR830N1GmukyaMYE_DT0fd4L_x6Py5PEqMe_A@mail.gmail.com>
	 <01A82AB9-6ABD-4AD0-9CBC-628091569DB0@holtmann.org>
	 <20150118.233722.226468667930444145.davem@davemloft.net>
	 <1428494602.9010.11.camel@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, torvalds@linux-foundation.org,
	marcel@holtmann.org, sfeldma@gmail.com, netdev@vger.kernel.org,
	teg@jklm.no
To: David Woodhouse <dwmw2@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:44448 "EHLO sipsolutions.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751572AbbDHNIV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 8 Apr 2015 09:08:21 -0400
In-Reply-To: <1428494602.9010.11.camel@infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2015-04-08 at 13:03 +0100, David Woodhouse wrote:

> I'm not sure if this is entirely fixed. In Fedora 22 (4.0.0-rc5-git4)
> I'm occasionally seeing glibc deadlock in __check_pf() on a netlink
> recvmsg(), here:
> https://sourceware.org/git/?p=glibc.git;a=blob;f=sysdeps/unix/sysv/linux/check_pf.c;h=162606d7;hb=glibc-2.21#l166
> 
> As I understand it, this shouldn't happen. Even if messages are
> dropped (which surely shouldn't happen as often as I'm seeing this),
> glibc should get ENOBUFS from the recvmsg() call.
> 
> https://bugzilla.redhat.com/show_bug.cgi?id=1209433
> 
> I haven't bisected and proved that it *was* this commit which
> introduced the problem, as it only happens after a day or two of
> running Evolution and I haven't managed to trigger it more reliably.

I don't see the connection to this change.

The issue with my patch was that some code for NLM_F_DUMP would have
this pattern:

 int fill_function(...)
 {
    ...
    return nlmsg_end(...);
 }

 loop (...) {
   if (fill_function() <= 0)
     break; /* continue in next dump */
 }

and that all had to be converted to be just "< 0" now.

Additionally, the failure mode of this was the process running out of
memory due to receiving the same results over and over again - does that
happen for you? It seems it was stuck in recvmsg(), but that may just be
a side effect of happening to interrupt at that point?

johannes
