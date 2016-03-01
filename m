From: "Michael Kerrisk (man-pages)" <mtk.manpages@gmail.com>
Subject: Re: [PATCH v2] socket.7: Document some BPF-related socket options
Date: Tue, 1 Mar 2016 11:03:45 +0100
Message-ID: <56D56901.5070307@gmail.com>
References: <1456767399-7533-1-git-send-email-kraigatgoog@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: mtk.manpages@gmail.com, linux-man@vger.kernel.org,
	netdev@vger.kernel.org, alexei.starovoitov@gmail.com,
	bernat@luffy.cx
To: Craig Gallek <kraigatgoog@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f52.google.com ([74.125.82.52]:36364 "EHLO
	mail-wm0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752966AbcCAKDv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Mar 2016 05:03:51 -0500
In-Reply-To: <1456767399-7533-1-git-send-email-kraigatgoog@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Craig,

On 02/29/2016 06:36 PM, Craig Gallek wrote:
> From: Craig Gallek <kraig@google.com>

Thanks for improvements. I've applied the patch and tweaked things 
somewhat, but I have a few comments and queries below. I'd be 
grateful if you'd check these, in case I have introduced any errors.
(The tweaked version of the page can be found in the Git repo.)

> Document the behavior and the first kernel version for each of the
> following socket options:
> SO_ATTACH_FILTER
> SO_ATTACH_BPF
> SO_ATTACH_REUSEPORT_CBPF
> SO_ATTACH_REUSEPORT_EBPF
> SO_DETACH_FILTER
> SO_DETACH_BPF
> SO_LOCK_FILTER
> 
> Signed-off-by: Craig Gallek <kraig@google.com>
> ---
> v2 changes:
> - Content suggestions from Michael Kerrisk <mtk.manpages@gmail.com>:
>   * Clarify socket filter return value semantics
>   * Clarify wording of minimal kernel versions
>   * Explain behavior of multiple calls using SO_ATTACH_[BPF|FILTER]
>   * Define 'reuseport groups' in SO_ATTACH_REUSEPORT_*
> - Include SO_LOCK_FILTER documentation mostly based off of the wording
>   in the commit message by Vincent Bernat <bernat@luffy.cx>
>   d59577b6ffd3 ("sk-filter: Add ability to lock a socket filter program")
> 
> ---
>  man7/socket.7 | 136 +++++++++++++++++++++++++++++++++++++++++++++++++---------
>  1 file changed, 115 insertions(+), 21 deletions(-)
> 
> diff --git a/man7/socket.7 b/man7/socket.7
> index db7cb8324dde..d22107cc47d7 100644
> --- a/man7/socket.7
> +++ b/man7/socket.7
> @@ -41,9 +41,6 @@
>  .\" 	SO_GET_FILTER (3.8)
>  .\"		commit a8fc92778080c845eaadc369a0ecf5699a03bef0
>  .\"		Author: Pavel Emelyanov <xemul@parallels.com>
> -.\"	SO_LOCK_FILTER (3.9)
> -.\"		commit d59577b6ffd313d0ab3be39cb1ab47e29bdc9182
> -.\"		Author: Vincent Bernat <bernat@luffy.cx>
>  .\"	SO_SELECT_ERR_QUEUE (3.10)
>  .\"             commit 7d4c04fc170087119727119074e72445f2bb192b
>  .\"		Author: Keller, Jacob E <jacob.e.keller@intel.com>
> @@ -53,13 +50,6 @@
>  .\"     SO_BPF_EXTENSIONS (3.14)
>  .\"             commit ea02f9411d9faa3553ed09ce0ec9f00ceae9885e
>  .\"		Author: Michal Sekletar <msekleta@redhat.com>
> -.\"     SO_ATTACH_BPF (3.19)
> -.\"             and SO_DETACH_BPF as synonym for SO_DETACH_FILTER
> -.\"             commit 89aa075832b0da4402acebd698d0411dcc82d03e
> -.\"		Author: Alexei Starovoitov <ast@plumgrid.com>
> -.\"	SO_ATTACH_REUSEPORT_CBPF, SO_ATTACH_REUSEPORT_EBPF (4.5)
> -.\"		commit 538950a1b7527a0a52ccd9337e3fcd304f027f13
> -.\"		Author: Craig Gallek <kraig@google.com>
>  .\"
>  .TH SOCKET 7 2015-05-07 Linux "Linux Programmer's Manual"
>  .SH NAME
> @@ -311,6 +301,90 @@ The value 0 indicates that this is not a listening socket,
>  the value 1 indicates that this is a listening socket.
>  This socket option is read-only.
>  .TP
> +.BR SO_ATTACH_FILTER " and " SO_ATTACH_BPF
> +Attach a classic or extended BPF program (respectively) to the socket
> +for use as a filter of incoming packets. A packet will be dropped if
> +the filter program returns zero.  If the filter program returns a
> +non-zero value which is less than the packet's data length, the packet
> +will be truncated to the length returned.  If the value returned by
> +the filter is greater than or equal to the packet's data length, the
> +packet is allowed to proceed unmodified.
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
> +system call and must refer to a program of type
> +.BR BPF_PROG_TYPE_SOCKET_FILTER.
> +These options may be set multiple times for a given socket, each time
> +replacing the previous filter program.  The classic and extended
> +versions may be called on the same socket, but the previous filter
> +will always be replaced such that a socket never has more than one
> +filter defined.
> +
> +.BR SO_ATTACH_FILTER
> +is available since Linux 2.2.
> +.BR SO_ATTACH_BPF
> +is available since Linux 3.19.  Both classic and extended BPF are
> +explained in the kernel source file
> +.I Documentation/networking/filter.txt
> +.TP
> +.BR SO_ATTACH_REUSEPORT_CBPF " and " SO_ATTACH_REUSEPORT_EBPF " (since Linux 4.5)"
> +For use with the
> +.BR SO_REUSEPORT
> +option, these options allow the user to set a classic or extended
> +BPF program (respectively) which defines how packets are assigned to
> +the sockets in the reuseport group (that is, all sockets which have
> +.BR SO_REUSEPORT
> +set and are using the same local address to receive packets).  The BPF
> +program must return an index between 0 and N-1 representing the socket
> +which should receive the packet (where N is the number of sockets in
> +the group). If the BPF program returns an invalid index, socket
> +selection will fall back to the plain
> +.BR SO_REUSEPORT
> +mechanism.
> +
> +Sockets are numbered in the order in which they are added to the group
> +(that is, the order of
> +.BR bind (2)
> +calls for UDP sockets or the order of
> +.BR listen (2)
> +calls for TCP sockets).  New sockets added to a reuseport group will
> +inherit the BPF program.  When a socket is removed from a reuseport
> +group (via
> +.BR close (2))
> +the last socket in the group will be moved into the closed socket's
> +position.
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
> +UDP support for this feature is available since Linux 4.5.
> +TCP support for this feature is available since Linux 4.6.
> +.TP
>  .B SO_BINDTODEVICE
>  Bind this socket to a particular device like \(lqeth0\(rq,
>  as specified in the passed interface name.
> @@ -368,6 +442,18 @@ Only allowed for processes with the
>  .B CAP_NET_ADMIN
>  capability or an effective user ID of 0.
>  .TP
> +.BR SO_DETACH_FILTER " and " SO_DETACH_BPF
> +These options may be used to remove the BPF program attached to the

Here, I added some wording to note that these two options are
synonyms.

> +socket with either
> +.BR SO_ATTACH_FILTER
> +or
> +.BR SO_ATTACH_BPF.
> +The option value is ignored.
> +.BR SO_DETACH_FILTER
> +is available since Linux 2.2.
> +.BR SO_DETACH_BPF
> +is available since Linux 3.19.
> +.TP
>  .BR SO_DOMAIN " (since Linux 2.6.32)"
>  Retrieves the socket domain as an integer, returning a value such as
>  .BR AF_INET6 .
> @@ -423,6 +509,25 @@ When the socket is closed as part of
>  .BR exit (2),
>  it always lingers in the background.
>  .TP
> +.B SO_LOCK_FILTER
> +When set, this option will prevent an unprivileged process from

Looks like a wording misstep here. It looks like SO_LOCK_FILTER
applies for any process (even root), as per the commit message for
this feature, and my reading of the code.

> +changing the filters associated with the socket.

s/filters/filter/ surely? (Since a socket can only have one 
filter installed, right?)
  
Also the process is prevented from *removing* the filter
or *disabling the SO_LOCK_FILTER* option. Right?

I reworded this piece to:

          Once   the   SO_LOCK_FILTER  option  has  been  enabled,
          attempts by an unprivileged process to change or  remove
          the  filter  attached  to  a  socket,  or to disable the
          SO_LOCK_FILTER option will fail with the error EPERM.

Okay?

> These filters
> +include any set using the socket options
> +.BR SO_ATTACH_FILTER,
> +.BR SO_ATTACH_BPF,
> +.BR SO_ATTACH_REUSEPORT_CBPF
> +or
> +.BR SO_ATTACH_REUSEPORT_EPBF.
> +The typical use case is for a privileged process to setup a socket with
> +restrictive filters, set
> +.BR SO_LOCK_FILTER
> +and then either drop its privileges or pass the socket file descriptor
> +to an unprivileged process.  Attempts to change a filter by an
> +unprivileged process while
> +.BR SO_LOCK_FILTER
> +is set will result in an error with value
> +.BR EPERM.
> +.TP
>  .BR SO_MARK " (since Linux 2.6.25)"
>  .\" commit 4a19ec5800fc3bb64e2d87c4d9fdd9e636086fe0
>  .\" and    914a9ab386a288d0f22252fc268ecbc048cdcbd5
> @@ -991,17 +1096,6 @@ where only the later program needs to set the
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

Thanks,

Michael


-- 
Michael Kerrisk
Linux man-pages maintainer; http://www.kernel.org/doc/man-pages/
Linux/UNIX System Programming Training: http://man7.org/training/
