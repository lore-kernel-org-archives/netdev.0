From: William Allen Simpson <william.allen.simpson@gmail.com>
Subject: Re: [PATCH] TCPCT+1: initial SYN exchange with SYNACK data
Date: Mon, 05 Oct 2009 13:42:54 -0400
Message-ID: <4ACA301E.3040806@gmail.com>
References: <20091005.002719.146534039.davem@davemloft.net>	<4AC9A714.7060903@gmail.com>	<4AC9AA3E.2090001@gmail.com> <20091005.014558.48061546.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f217.google.com ([209.85.219.217]:63901 "EHLO
	mail-ew0-f217.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752443AbZJERnh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Oct 2009 13:43:37 -0400
Received: by ewy17 with SMTP id 17so3053789ewy.39
        for <netdev@vger.kernel.org>; Mon, 05 Oct 2009 10:42:59 -0700 (PDT)
In-Reply-To: <20091005.014558.48061546.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> Then we'll eat an atomic operation every connect() or something
> like that?
> 
Yes, on the client side.  On the server side, I was trying to avoid any
until after a 3-way handshake (the reason that I removed the kref'd struct
in Adam's request sock).

Adam:
+	struct tcp_sadata_payload	*sadata_payload;
+	u8				sadata_nonce[4]; /* generated nonce */
+	u8				sadata_ok:1;   /* send sadata?    */


Mine:
+	u8				*cookie_copy;	/* temporary pointer */
+	u8				cookie_size;	/* bytes in copy */
+	u8				s_data_in:1,
+					s_data_out:1,
+					cookie_in_always:1,
+					cookie_out_never:1;

Mine makes the code more tricky, though.  I'm depending on the various
locks and hashes to keep things kosher, whereas Adam kept more kref'd
pointer instances lying around for a longer time.  Tradeoffs....

But I *was* patting myself on the back for saving 3 bytes here.  ;-)


> That's bad too.  We're trying desperately to remove as many
> atomic operations as possible from the socket paths.
> 
And Adam had done a good job, too.  The state has to go somewhere!

After all, I've plenty of experience with small TCP implementations, as
*all* implementations were constrained back in the day.  At least one of
my tiny TCP/IP/PPP stack implementations is in hundreds of millions of
cell phones (originally on 186s with only a few K of RAM).


> Compress your state, really compress it, don't just externalize
> it somewhere else in exchange for a different cost.
> 
Cookies are pseudo-random nonces, not compressible by definition.

I think I'll be able to join everything into a single kref'd block, with
some modification/reuse of various function md5sig parameters to pass
pointers....  Cookie nonces are redundant to the authenticator option(s),
so they're never around at the same time.

That will whittle the tcp_sock size down some more, although it could
increase the overall memory footprint, as there will be wasted space for
the case where there are cookies without SYN data.  By keeping the sizes
and flags in the sock itself, both Adam and I were optimizing performance.

It's just tradeoffs, always and forever tradeoffs.
