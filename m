From: "Michael T Kerrisk" <mtk-lists@gmx.net>
Subject: Assassination of TIME_WAIT state
Date: Thu, 22 Apr 2004 15:05:13 +0200 (MEST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <18236.1082639113@www15.gmx.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Gidday,

In the scenario below, one achieves assassination of the 
TIME_WAIT state on Linux 2.6.5 and 2.4.x.  From a conversation 
I had a while ago with Andi Kleen (see below), it appears 
that this is expected behavior.  I have two (closely linked) 
questions:

-- what is the rationale for this behavior (i.e., why assassinate 
   in this scenario)?

-- why does Linux behave differently from FreeBSD and Solaris 
   in this scenario?

Assume in the following scenario that SO_RESUSEADDR is set on 
the server socket(s):

Server                           Client

1. Create listening socket 
   bound to INADDR_ANY/port=9999
2. Accept a connection on
   the listening socket
                                 3. Create a socket bound 
                                    to INADDR_ANY/port=50000
                                 4. Connect to server socket
                                    (on port 9999)
5. Close listening and 
   connected sockets
                                 6. Close the socket

At this point, there is TCP on the server side in the TIME_WAIT 
state: { local=localhost:9999, peer=XXX:50000 }

(re-run server)
7. Create listening socket 
   bound to INADDR_ANY/port=9999
8. Accept a connection on
   the listening socket
                                 (re-run client while TIME_WAIT 
                                 TCP still exists)
                                 9. Create a socket bound 
                                    to INADDR_ANY/port=50000
                                 10.Connect to server socket
                                    (on port 9999)

On Linux the connect() in step 10 succeeds; the reason that it 
does is that the TIME_WAIT TCP is immediately assassinated.  

A while back I asked Andi Kleen about this scenario, and he 
commented that this behavious was:

> a (dubious) BSD extension, also implemented
> in linux (after all sockets is about being bug to bug coompatible).
> the kernel sees the TIME-WAIT and choses a sequence number with
> a large offset to avoid conflicts. When you don't have PAWS
> but still had a big window it is rather risky though.

However, when I try the above on FreeBSD 5.1 and Solaris 8, we see 
different behavior: the TIME_WAIT TCP is NOT assassinated and the 
connect() at step 10 fails with EADDRINUSE (which makes sense 
because we can't create a duplicate 4-tuple...).

Cheers,

Michael

-- 
Michael Kerrisk
mtk-lists@gmx.net

"Sie haben neue Mails!" - Die GMX Toolbar informiert Sie beim Surfen!
Jetzt aktivieren unter http://www.gmx.net/info
