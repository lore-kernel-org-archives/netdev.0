From: Stephane Chazelas <stephane.chazelas@gmail.com>
Subject: newline characters in unix socket names and /proc/net/unix
Date: Sat, 14 Mar 2015 22:33:42 +0000
Message-ID: <20150314223342.GA4146@chaz.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Werner Almesberger <Werner.Almesberger@epfl.ch>,
	Vic Abell <vabell@lsof.comcastbiz.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f54.google.com ([74.125.82.54]:33695 "EHLO
	mail-wg0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751059AbbCNWdq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 Mar 2015 18:33:46 -0400
Received: by wgbcc7 with SMTP id cc7so13095034wgb.0
        for <netdev@vger.kernel.org>; Sat, 14 Mar 2015 15:33:44 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

it seems the kernel doesn't escape newline characters in the
file names displayed in /proc/net/unix

That file has this format:

Num       RefCount Protocol Flags    Type St Inode Path
ffff8802441bcb40: 00000002 00000000 00000000 0002 01  9219 /run/systemd/shutdownd
ffff8800a0651780: 00000002 00000000 00010000 0001 01 37020 /tmp/.menu-cached-:0-stephane
[...]


and is used by things like fuser, lsof for instance to map Inode
to Path (and libgtop, systemd (to check which sockets are still
in use for cleanup) at least).

# fuser /run/systemd/shutdownd
/run/systemd/shutdownd:     1
# fuser /tmp/.menu-cached-:0-stephane
/tmp/.menu-cached-:0-stephane:  4263

Now, one can bind a socket like:

socket=$'/tmp/foo\nffff8802441bcb40: 00000002 00000000 00000000 0002 01  9219 /tmp/.menu-cached-:0-stephane'
mkdir -p "${socket%/*}"
nc -lU "$socket"

Now /proc/net/unix has

Num       RefCount Protocol Flags    Type St Inode Path
ffff8802441bcb40: 00000002 00000000 00000000 0002 01  9219 /run/systemd/shutdownd
ffff8800a0651780: 00000002 00000000 00010000 0001 01 37020 /tmp/.menu-cached-:0-stephane
ffff880104af9400: 00000002 00000000 00010000 0001 01 5918000 /tmp/foo
ffff8802441bcb40: 00000002 00000000 00000000 0002 01  9219 /tmp/.menu-cached-:0-stephane

And fuser gives:

# fuser /run/systemd/shutdownd
# fuser /tmp/.menu-cached-:0-stephane
/tmp/.menu-cached-:0-stephane:     1  4263

Which could be a problem if the output of fuser were used to
decide what process to kill (like with -k).

I think at least newline characters (and the escape character
itself) should be escaped in there, maybe do something similar
to what is currently done for the process name in
/proc/self/status

(fuser and lsof and the other tools would also need to be
updated to take the change into account, note that lsof already
chokes on space/tab/colon in there which I've already reported
to Vic).

Also note that /proc/net/unix doesn't change after a socket file
has been renamed, so even after that issue is fixed, fuser -k on
a socket may not be very reliable. Maybe it would help if the
filesystem device/inode for the socket file were added to
/proc/net/unix and/or if the path was updated like for the
symlink targets of /proc/self/fd/*.

-- 
Stephane
