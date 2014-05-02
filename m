From: Sharat Masetty <sharat04@gmail.com>
Subject: ebtables issue in compat mode
Date: Fri, 2 May 2014 13:05:07 -0600
Message-ID: <CAJzFV34kA1-oCO-LCQXuoB2WfYOowUL9DZW2-050KN+qWhhtSA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: Linux Netdev List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f173.google.com ([74.125.82.173]:44034 "EHLO
	mail-we0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752004AbaEBTFJ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 May 2014 15:05:09 -0400
Received: by mail-we0-f173.google.com with SMTP id w61so5022836wes.32
        for <netdev@vger.kernel.org>; Fri, 02 May 2014 12:05:08 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I am seeing a problem when running ebtables in 32bit userspace and 64
bit kernel space mode.

The command I am trying to run is
ebtables -t broute -A BROUTING -p IPv4 -j DROP

Here is the log message I am seeing in userspace

The message (http://sourceforge.net/p/ebtables/code/ci/master/tree/user=
space/ebtables2/communication.c
Line 243) in userspace is

        ebt_print_error("Unable to update the kernel. Two possible caus=
es:\n"

                       "1. Multiple ebtables programs were executing
simultaneously. The ebtables\n"

                       "   userspace tool doesn't by default support
multiple ebtables programs running\n"

                       "   concurrently. The ebtables option
--concurrent or a tool like flock can be\n"

                       "   used to support concurrent scripts that
update the ebtables kernel tables.\n"

                       "2. The kernel doesn't support a certain
ebtables extension, consider\n"

                       "   recompiling your kernel or insmod the extens=
ion.\n");

I noticed that setsockopt() is failing . The message is also printed
in kernel =E2=80=93 Standard target size too big . This occurs because =
there
is a mismatch in the size of the structures ebt_standard_target which
is 48 bytes in kernel and 40 bytes in userspace.
We are using a 3.10.0 kernel version which has CONFIG_COMPAT enabled.
The ebtables version is 2.0.10-4.  This is arm 63/32 not x86.


Here is where it is failing exactly, in check_chainloops() function in
ebtables.c in the kernel

if (e->target_offset + sizeof(struct ebt_standard_target) >
e->next_offset) {
BUGPRINT("Standard target size too big\n");
return -1;
}


Thanks
Sharat
