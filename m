From: "Michael Kerrisk (man-pages)" <mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH] socket.7: Document some BPF-related socket options
Date: Sun, 28 Feb 2016 20:41:53 +0100
Message-ID: <56D34D81.50408@gmail.com>
References: <1456432065-3362-1-git-send-email-kraigatgoog@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, linux-man-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, alexei.starovoitov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
To: Craig Gallek <kraigatgoog-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-man-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1456432065-3362-1-git-send-email-kraigatgoog-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: linux-man-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hello Craig,

Thanks for putting this together. I have a few comments.
Would you please amend your patch and resend? (And include Alexei
in a "Reviewed-by" tag.)

On 02/25/2016 09:27 PM, Craig Gallek wrote:
> From: Craig Gallek <kraig-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
> 
> Document the behavior and the first kernel version for each of the
> following socket options:
> SO_ATTACH_FILTER
> SO_ATTACH_BPF
> SO_ATTACH_REUSEPORT_CBPF
> SO_ATTACH_REUSEPORT_EBPF
> SO_DETACH_FILTER
> SO_DETACH_BPF
> 
> Signed-off-by: Craig Gallek <kraig-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
> ---
>  man7/socket.7 | 104 ++++++++++++++++++++++++++++++++++++++++++++++++----------
>  1 file changed, 86 insertions(+), 18 deletions(-)
> 
> diff --git a/man7/socket.7 b/man7/socket.7
> index db7cb8324dde..79b4f3158541 100644
> --- a/man7/socket.7
> +++ b/man7/socket.7
> @@ -53,13 +53,6 @@
>  .\"     SO_BPF_EXTENSIONS (3.14)
>  .\"             commit ea02f9411d9faa3553ed09ce0ec9f00ceae9885e
>  .\"		Author: Michal Sekletar <msekleta-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
> -.\"     SO_ATTACH_BPF (3.19)
> -.\"             and SO_DETACH_BPF as synonym for SO_DETACH_FILTER
> -.\"             commit 89aa075832b0da4402acebd698d0411dcc82d03e
> -.\"		Author: Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>
> -.\"	SO_ATTACH_REUSEPORT_CBPF, SO_ATTACH_REUSEPORT_EBPF (4.5)
> -.\"		commit 538950a1b7527a0a52ccd9337e3fcd304f027f13
> -.\"		Author: Craig Gallek <kraig-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
>  .\"
>  .TH SOCKET 7 2015-05-07 Linux "Linux Programmer's Manual"
>  .SH NAME
> @@ -311,6 +304,80 @@ The value 0 indicates that this is not a listening socket,
>  the value 1 indicates that this is a listening socket.
>  This socket option is read-only.
>  .TP
> +.BR SO_ATTACH_FILTER " and " SO_ATTACH_BPF
> +Attach a classic or extended BPF program (respectively) to the socket
> +for use as a filter of incoming packets.  A packet will be dropped if
> +the filter returns zero or have its data truncated to the non-zero
> +length returned.  

I find that last sentence hard to parse. How about something like:

A packet will be dropped if the filter program returns zero or will 
have its data truncated to the non-zero length returned [returned by 
what? The filter? Make this clearer please.]

>                    If the value returned is greater or equal to the
> +packet's data length, the packet is allowed to proceed unmodified.
> +
> +The argument for
> +.BR SO_ATTACH_FILTER
> +is a
> +.I sock_fprog
> +structure in
> +.B <linux/filter.h>.
> +.sp
> +.in +4n
> +.nf
> +struct sock_fprog {
> +    unsigned short      len;
> +    struct sock_filter *filter;
> +};
> +.fi
> +.in
> +.IP
> +The argument for
> +.BR SO_ATTACH_BPF
> +is a file descriptor returned by the
> +.BR bpf (2)
> +system call and must represent a program of type

s/represent/refer to/

> +.BR BPF_PROG_TYPE_SOCKET_FILTER.
> +
> +.BR SO_ATTACH_FILTER
> +is available in Linux 2.2.

s/in/since/

> +.BR SO_ATTACH_BPF
> +is available in Linux 3.19.  Both classic and extended BPF are

s/in/since/

> +explained in the kernel source file
> +.I Documentation/networking/filter.txt

Presumably, it is not possible to attach multiple filters to a socket.
This should be stated explicitly somewhere here, as well as an
explanation of what happens if you try to add a filter to a socket
that already has one. Does it replace the existing filter, or does
an error result.

Seems like SOCK_FILTER_LOCKED also needs documenting here somewhere...

> +.TP
> +.BR SO_ATTACH_REUSEPORT_CBPF " and " SO_ATTACH_REUSEPORT_EBPF " (since Linux 4.5)"
> +For use with the
> +.BR SO_REUSEPORT
> +option, these options allow the user to define a classic or extended
> +BPF program (respectively) which defines how packets are assigned to
> +the sockets in the reuseport group.  The program must return an index

Is there some documentation on "reuseport groups" that we can refer
to here? If yes, please add a reference.

s/program/BPF program/

> +between 0 and N-1 representing the socket which should receive the
> +packet (where N is the number of sockets in the group). If the BPF
> +program returns an invalid index, socket selection will fall back to
> +the plain
> +.BR SO_REUSEPORT
> +mechanism.
> +
> +Sockets are numbered in the order in which they are added to the group
> +(that is, the order of
> +.BR bind (2)
> +calls for UDP sockets or the order of
> +.BR listen (2)
> +calls for TCP sockets).  New sockets added to the group will inherit
> +the program.  When a socket is removed from the group (via

s/program/BPF program/

s/the group/a reuseport group/

> +.BR close (2))
> +the last socket in the group will be moved into the closed socket's
> +position.

Wow! That's interesting behavior that seems like it could easily 
trip up users!

> +
> +These options may be set repeatedly at any time on any single socket
> +in the group to replace the current BPF program used by all sockets in
> +the group.
> +.BR SO_ATTACH_REUSEPORT_CBPF
> +takes the same socket argument type as
> +.BR SO_ATTACH_FILTER
> +and
> +.BR SO_ATTACH_REUSEPORT_EBPF
> +takes the same socket argument type as
> +.BR SO_ATTACH_BPF.
> +UDP support for this feature is available in Linux 4.5.

s/in/since/

> +TCP support for this feature is available in Linux 4.6.

s/in/since/

> +.TP
>  .B SO_BINDTODEVICE
>  Bind this socket to a particular device like \(lqeth0\(rq,
>  as specified in the passed interface name.
> @@ -368,6 +435,18 @@ Only allowed for processes with the
>  .B CAP_NET_ADMIN
>  capability or an effective user ID of 0.
>  .TP
> +.BR SO_DETACH_FILTER " and " SO_DETACH_BPF
> +These options may be used to remove the BPF program attached to the
> +socket with either
> +.BR SO_ATTACH_FILTER
> +or
> +.BR SO_ATTACH_BPF.
> +The option value is ignored.
> +.BR SO_DETACH_FILTER
> +is available in Linux 2.2.

s/in/since/

> +.BR SO_DETACH_BPF
> +is available in Linux 3.19.

s/in/since/

> +.TP
>  .BR SO_DOMAIN " (since Linux 2.6.32)"
>  Retrieves the socket domain as an integer, returning a value such as
>  .BR AF_INET6 .
> @@ -991,17 +1070,6 @@ where only the later program needs to set the
>  option.
>  Typically this difference is invisible, since, for example, a server
>  program is designed to always set this option.
> -.SH BUGS
> -The
> -.B CONFIG_FILTER
> -socket options
> -.B SO_ATTACH_FILTER
> -and
> -.B SO_DETACH_FILTER
> -.\" FIXME Document SO_ATTACH_FILTER and SO_DETACH_FILTER
> -are not documented.
> -The suggested interface to use them is via the libpcap
> -library.
>  .\" .SH AUTHORS
>  .\" This man page was written by Andi Kleen.
>  .SH SEE ALSO

Cheers,

Michael


-- 
Michael Kerrisk
Linux man-pages maintainer; http://www.kernel.org/doc/man-pages/
Linux/UNIX System Programming Training: http://man7.org/training/
--
To unsubscribe from this list: send the line "unsubscribe linux-man" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
