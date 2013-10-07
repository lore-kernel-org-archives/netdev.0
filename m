From: Andy Lutomirski <luto@amacapital.net>
Subject: Re: bug in passing file descriptors
Date: Mon, 7 Oct 2013 11:44:49 -0700
Message-ID: <CALCETrXmmW-nRTr4-yWJnNr2GWW37KW-7B1m=kSRnmYjhMTajA@mail.gmail.com>
References: <5252FD2B.5040800@nec-labs.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Network Development <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Michael Kerrisk-manpages <mtk.manpages@gmail.com>,
	Eric Biederman <ebiederm@xmission.com>
To: Steve Rago <sar@nec-labs.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f173.google.com ([209.85.217.173]:40408 "EHLO
	mail-lb0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756321Ab3JGSpK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Oct 2013 14:45:10 -0400
Received: by mail-lb0-f173.google.com with SMTP id o14so6027158lbi.32
        for <netdev@vger.kernel.org>; Mon, 07 Oct 2013 11:45:09 -0700 (PDT)
In-Reply-To: <5252FD2B.5040800@nec-labs.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 7, 2013 at 11:27 AM, Steve Rago <sar@nec-labs.com> wrote:
> Sending this to a larger group at mtk's suggestion.
>
> I recently found a bug with passing file descriptors over Unix domain
> sockets.  The attached program illustrates the problem.  I believe the
> source of the problem is in net/core/scm.c.  In put_cmsg(), cmlen is
> calculated as CMSG_SPACE(len) for the purposes of setting msg_controllen,
> but it probably should be CMSG_LEN(len), at least in this particular case (I
> didn't investigate other use cases).  On a 32-bit platform, a long is a
> 4-byte quantity and the file descriptor is already aligned to a 4-byte
> quantity by placing it after the cmsghdr structure.  On a 64-byte platform,
> however, a long is an 8-byte quantity, and CMSG_SPACE() assumes that len is
> aligned on an 8-byte boundary, which isn't a requirement for passing file
> descriptors (which are 4-byte quantities; see scm_fp_copy() to verify).
> Anyway, the end result is that recvmsg(2) returns with msg_controllen 4
> bytes larger than it should be on a 64-bit platform.  The attached program
> prints out a warning message when this happens.
>
> I've tried this on kernels as old as 2.6.18, so it appears this bug has been
> around for a while.  I originally found it on a 3.2.0 kernel.  Michael
> verified it still exists on a 3.11 kernel.
>
> Let me know if you need any more information

ISTM that, in order for further cmsgs to be correctly decoded, all of
the relevant things need to match.

put_cmsg uses this layout: cmsghdr, padding, payload, padding.
CMSG_SPACE matches that calculation.

scm_detach_fds is the actual code path for SCM_RIGHTS.  It does the same thing.

CMSG_DATA also things that there's possible padding after cmsghdr.

So I think everything's okay.

--Andy
