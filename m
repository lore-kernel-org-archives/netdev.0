From: Vadim Kochan <vadim4j@gmail.com>
Subject: [PATCH iproute2 0/3] ss: Fix sockets filtering
Date: Sat,  3 Jan 2015 02:44:34 +0200
Message-ID: <1420245877-11763-1-git-send-email-vadim4j@gmail.com>
Cc: Vadim Kochan <vadim4j@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f178.google.com ([209.85.217.178]:50005 "EHLO
	mail-lb0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752377AbbACAy4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Jan 2015 19:54:56 -0500
Received: by mail-lb0-f178.google.com with SMTP id f15so17764957lbj.9
        for <netdev@vger.kernel.org>; Fri, 02 Jan 2015 16:54:54 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vadim Kochan <vadim4j@gmail.com>

This series contains refactoring & fixes related to
sockets filtering.

1st 2 patches are related mostly to refactoring as they just
allows to use one func to output UNIX & PACKET socket stats from both Netlink &
/proc.

The last one have a big change which related to the way how filtering options
are combined with each other. This change has also fixes for some filtering
combination options.

I did some basic testing *BUT* I cant guarantee that there is no bugs ...
Here is my some testing list with comparing to the 'master' version:

Some test results with comparing version in PATCH and version from master
-------------------------------------------------------------------------

this   - ss version sending in PATCH
master - ss version in master

Case #1: Show only IPv4 sockets
    $ ss -4

    RESULTS
        this    -  shows only IPv4 sockets with established states     [OK]
        master  -  shows IPv4 and UNIX sockets with established states [FAIL]

Case #2: Show only IPv4 sockets with all states
    $ ss -4 -a

    RESULTS
        this    -  shows only IPv4 sockets with all states [OK]
        master  -  shows ALL sockets kinds with all states [FAIL]

Case #3: Show only IPv4 sockets with listen states (closed or listening)
    $ ss -4 -l

    RESULTS
        this    -  shows only IPv4 sockets with listen states    [OK]
        master  -  shows ALL sockets kinds with LISTENING states [FAIL]

Case #4 Show only IPv4 UDP sockets
    $ ss -4 -u

    RESULTS
        this    -  shows only IPv4 UDP sockets                                 [OK]
        master  -  shows IPv4 UDP sockets but only if state 'closed' specified [FAIL]
    
    In 'this' version it is not needed to set 'closed' state additionally for UDP sockets as it it set
    automatically because we explicitly specified UDP sockets. 

Case #5: Show all UDP sockets
    $ ss -u

    RESULTS
        this    -  shows all UDP sockets for both IPv4/IPv6 protocol families  [OK]
        master  -  shows IPv4 UDP sockets but only if state 'closed' specified [FAIL]

Case #6: Show all UDP sockets for IPv6 only protocol
    $ ss -u -6

    RESULTS
        this    -  shows all IPv6 UDP sockets                                  [OK]
        master  -  shows IPv4 UDP sockets but only if state 'closed' specified [FAIL]


Case #7: Show UNIX sockets with matches "*X11*" as src
    $ ss src unix:*X11*

    RESULTS
        this    -  shows only UNIX sockets with established states with src matches "*X11*" [OK]
        master  -  shows all established UNIX sockets with "RTNETLINK" errors               [FAIL]


Case #8: Show UNIX sockets with matches "*X11*" as src but with LISTENING states only
    $ ss src unix:*X11* -l

    RESULTS
        this    -  shows only UNIX sockets with LISTENING states with src matches "*X11*" [OK]
        master  -  Segmentation error                                                     [FAIL]

Case #9: Show all RAW sockets
    $ ss -w

    RESULTS
        this    - shows all RAW sockets for IPv4/IPv6 families                                  [OK]
        master  - shows all RAW sockets for IPv4/IPv6 families only if state 'closed' specified [FAIL]

Case #10: Show all TCP/UDP sockets
    $ ss -t -u

    RESULTS
        this    - shows all established TCP and unconnected UDP sockets for IPv4/IPv6 protocols. [OK]
        master  - shows only TCP established sockets, shows UDP                                  [FAIL]

Vadim Kochan (3):
  ss: Unify unix stats output from netlink and proc
  ss: Unify packet stats output from netlink and proc
  ss: Filtering logic changing, with fixes

 misc/ss.c | 628 ++++++++++++++++++++++++++++++++++----------------------------
 1 file changed, 346 insertions(+), 282 deletions(-)

-- 
2.1.3
