From: Jim Keniston <jkenisto@us.ibm.com>
Subject: [PATCH - RFC] 2.6 must-fix list - kernel error reporting
Date: Tue, 08 Jul 2003 12:59:40 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3F0B22AC.1D600F98@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev <netdev@oss.sgi.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

I posted this today on LKML.  I intended to post to netdev as well, but botched
the address.  For the actual patches, see the LKML thread, or the indicated links.
*Sigh.*

Jim Keniston
IBM Linux Technology Center
-----
Andrew Morton's 2.6 must-fix list includes the following item:
> o We need a kernel side API for reporting error events to userspace (could
>   be async to 2.6 itself)
>
>   (Prototype core based on netlink exists)

The enclosed patches provide a mechanism for reporting error events
to user-mode applications via netlink.  This mechanism supplements
the text-oriented printk mechanism, providing a way to log binary
data or a mixture of text+binary.

Patch #1, closely based on a prototype by Dave Miller, implements the
NETLINK_KERROR protocol for AF_NETLINK sockets.  It provides two
functions for broadcasting data packets to user-mode applications:
in one, the caller provides a single data buffer, and in the other,
the caller provides an iovec[].

Patch #2 (see accompanying post) provides an API built on patch #1's
infrastructure.  Patch #2's functions capture context about the error
(e.g., driver/module, severity level, in interrupt or not, pid/uid/gid,
CPU ID), pack this information into a header, add the error-specific
data, and send the resulting packet via netlink.  The two principal
functions are:

- evl_write(), which accepts an arbitrarily defined buffer of
error-specific data; and

- evl_printf(), which accepts a format string plus args, printk-style.
Rather than combining the format and args, evl_printf() keeps them
separate, as various developers have suggested.  Thus the receiving
application can easily determine both the type of error (as indicated
by the raw format string) and the args' values, without parsing the
message string.

Applications that respond to kernel errors can establish
AF_NETLINK/NETLINK_KERROR sockets and receive the error packets
directly; or they can register with an event subsystem (e.g., see
evlog.sourceforge.net), which will deliver events that match specific
criteria.

These patches are posted on evlog.sourceforge.net.  (Click on "Latest
Release"; then scroll down to "evlog-2.5_kernel/evlog + netlink".  Or
just follow the links posted below.)  Also posted there is a tar file,
kerrord.tar.gz, which contains:
- a sample module that logs errors using evl_write() and evl_printf();
and
- a sample daemon that reads such errors from netlink and logs them.

Jim Keniston
IBM Linux Technology Center

http://prdownloads.sourceforge.net/evlog/kerror-2.5.74.patch?download
http://prdownloads.sourceforge.net/evlog/evlog-2.5.74.patch?download
http://prdownloads.sourceforge.net/evlog/kerrord.tar.gz?download
