From: "Chad N. Tindel" <chad@tindel.net>
Subject: Wrong UIDs reported in /proc/net/tcp
Date: Tue, 9 Nov 2004 15:53:58 -0500
Message-ID: <20041109205358.GA64015@calma.pair.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-net@vger.kernel.org
Return-path: <linux-net-owner@vger.kernel.org>
To: netdev@oss.sgi.com
Content-Disposition: inline
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello-

In our testing we've found some occurrences of identd reporting back the
wrong username for the owner of a socket.  We added some instrumentation
to identd so that we can tell it what we expect the username to be, and when
what it discovers doesn't match what we expect, it logs a message.  Sometimes
non-root users appear as root, and sometimes the root user appears as a non-root
user.  Here's an example log message from our instrumented identd:

Nov  9 00:55:11 rock identd[4139]: ERROR: Expected username 'root' but got 'ident'. Proc line was ' 299: AFAF0D0F:CEE1 ACAF0D0F:14B6 01 00000000:00000000 00:00000000 00000000   100        0 880370 1 f22bb980 21 4 8 3 -1 '.  EUID was 100

As you can see, our client was running as root, but identd reported that
the username was "ident".  /proc/net/tcp reported that the EUID was 100.  
Clearly it isn't correct that the ident user is associated with a socket that
doesn't have port 113 as one of the endpoints.

Here's another example:

Nov  8 17:19:06 rock identd[4139]: ERROR: Expected username 'rba0001f' but got 'root'. Proc line was '  19: AFAF0D0F:8FFD AFAF0D0F:14B6 01 00000000:00000000 02:000AFC6F 00000000     0        0 0 2 f04ed980 '.  EUID was 0

The user rba0001f has a UID of 65535 on this system.

We have seen this problem on RH3u3 as well as SLES9, so our current thoughts
are that it is a generic kernel issue.  We're starting to dive down in the
code to look for possible problems, but I wanted to bring it up to the list
and see if anybody had any ideas.  

In our cursory analysis of the code, we've seen that the inode structure which
holds the user id comes out of a cache.  In the function sock_alloc(), the
UID gets assigned as:

inode->i_uid = current->fsuid;

Is it possible for this code to be invoked in a context where current doesn't
actually point to the right task structure?

Is it possible for the socket to get added to the established hash table
before the uid pointer gets initialized, thus causing /proc/net/tcp to report
the UID of whoever used this socket memory earlier?

We can reproduce this problem fairly easily here, so if anybody has any ideas
or suggestions on kernel instrumentation that would help track this down, I'm
all ears.

Regards,

Chad
