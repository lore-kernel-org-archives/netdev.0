From: Michael Kerrisk <mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: sendmmsg(2) draft man pages
Date: Thu, 15 Sep 2011 06:16:22 +0200
Message-ID: <CAKgNAkhQu7LdGDh5=CMpTwsnmS03QRqojBpwSpAcFO55WdYWqw@mail.gmail.com>
Reply-To: mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-man <linux-man-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Andi Kleen <andi-Vw/NltI1exuRpAAqCnN02g@public.gmane.org>,
	Stephan Mueller <stephan.mueller-fwYZOkdEjagAvxtiuMwx3w@public.gmane.org>,
	netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linux API <linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Michael Kerrisk <mtk.manpages-gM/Ye1E23mwN+BqQ9rBEUg@public.gmane.org>
To: Anton Blanchard <anton-eUNUBHrolfbYtjvyW6yDsg@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hello Anton,

Stephan Mueller made an initial shot at a manual page for the
sendmmsg() syscall that you recently added to the kernel. This
inspired me to come up with a more complete version, which I'd like to
get reviewed before including in man-pages. Could you take a look
("man -l <file>") at the version below and let me know any errors or
omissions.

Thanks

Michael Kerrisk

.\" Copyright (c) 2011 by Michael Kerrisk <mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
.\" with some material from a draft by
.\" Stephan Mueller <stephan.mueller-fwYZOkdEjagAvxtiuMwx3w@public.gmane.org>
.\" in turn based on Andi Kleen's recvmmsg.2 page.
.\"
.\" Permission is granted to make and distribute verbatim copies of this
.\" manual provided the copyright notice and this permission notice are
.\" preserved on all copies.
.\"
.\" Permission is granted to copy and distribute modified versions of this
.\" manual under the conditions for verbatim copying, provided that the
.\" entire resulting derived work is distributed under the terms of a
.\" permission notice identical to this one.
.\"
.\" Since the Linux kernel and libraries are constantly changing, this
.\" manual page may be incorrect or out-of-date.  The author(s) assume no
.\" responsibility for errors or omissions, or for damages resulting from
.\" the use of the information contained herein.  The author(s) may not
.\" have taken the same level of care in the production of this manual,
.\" which is licensed free of charge, as they might when working
.\" professionally.
.\"
.\" Formatted or processed versions of this manual, if unaccompanied by
.\" the source, must acknowledge the copyright and authors of this work.
.\"
.TH SENDMMSG 2 2011-09-09 "Linux" "Linux Programmer's Manual"
.SH NAME
sendmmsg \- send multiple messages on a socket
.SH SYNOPSIS
.nf
.B "#define _GNU_SOURCE"
.BI "#include <sys/socket.h>"

.BI "int sendmmsg(int " sockfd ", struct mmsghdr *" msgvec \
", unsigned int " vlen ","
.BI "             unsigned int " flags ");"
.fi
.SH DESCRIPTION
The
.BR sendmmsg ()
system call is an extension of
.BR sendmsg (2)
that allows the caller to transmit multiple messages on a socket
using a single system call.
(This has performance benefits for some applications.)
.\" See commit 228e548e602061b08ee8e8966f567c12aa079682

The
.I sockfd
argument is the file descriptor of the socket
on which data is to be transmitted.

The
.I msgvec
argument is a pointer to an array of
.I mmsghdr
structures.
The size of this array is specified in
.IR vlen .

The
.I mmsghdr
structure is defined in
.I <sys/socket.h>
as:

.in +4n
.nf
struct mmsghdr {
    struct msghdr msg_hdr;  /* Message header */
    unsigned int  msg_len;  /* Number of bytes transmitted */
};
.fi
.in
.PP
The
.I msg_hdr
field is a
.I msghdr
structure, as described in
.BR sendmsg (2).
The
.I msg_len
field is used to return the number of bytes sent from the message in
.IR msg_hdr
(i.e., the same as the return value from a single
.BR sendmsg (2)
call).

The
.I flags
argument contains flags ORed together.
The flags are the same as for
.BR sendmsg (2).

A blocking
.BR sendmmsg ()
call blocks until
.I vlen
messages have been sent.
A nonblocking call sends as many messages as possible
(up to the limit specified by
.IR vlen )
and returns immediately.

On return from
.BR sendmmsg (),
the
.I msg_len
fields of successive elements of
.IR msgvec
are updated to contain the number of bytes transmitted from the corresponding
.IR msg_hdr .
The return value of the call indicates the number of elements of
.I msgvec
that have been updated.
.SH RETURN VALUE
On success,
.BR sendmmsg ()
returns the number of messages sent from
.IR msgvec ;
if this is less than
.IR vlen ,
the caller can retry with a further
.BR sendmmsg ()
call to send the remaining messages.

On error, \-1 is returned, and
.I errno
is set to indicate the error.
.SH ERRORS
Errors are as for
.BR sendmsg (2).
An error is returned only if no datagrams could be sent.
.\" commit 728ffb86f10873aaf4abd26dde691ee40ae731fe
.\"     ... only return an error if no datagrams could be sent.
.\"     If less than the requested number of messages were sent, the application
.\"     must retry starting at the first failed one and if the problem is
.\"     persistent the error will be returned.
.\"
.\"     This matches the behaviour of other syscalls like read/write - it
.\"     is not an error if less than the requested number of elements are sent.
.SH VERSIONS
The
.BR sendmmsg ()
system call was added in Linux 3.0.
Support in glibc was added in version 2.14.
.SH CONFORMING TO
.BR sendmmsg ()
is Linux-specific.
.SH NOTES
The value specified in
.I vlen
is capped to
.B UIO_MAXIOV
(1024).
.\" commit 98382f419f32d2c12d021943b87dea555677144b
.\"     net: Cap number of elements for sendmmsg
.\"
.\"     To limit the amount of time we can spend in sendmmsg, cap the
.\"     number of elements to UIO_MAXIOV (currently 1024).
.\"
.\"     For error handling an application using sendmmsg needs to retry at
.\"     the first unsent message, so capping is simpler and requires less
.\"     application logic than returning EINVAL.
.SH SEE ALSO
.BR recvmmsg (2),
.BR sendmsg (2),
.BR socket (2),
.BR socket (7)

-- 
Michael Kerrisk
Linux man-pages maintainer; http://www.kernel.org/doc/man-pages/
Author of "The Linux Programming Interface"; http://man7.org/tlpi/
