From: Vadim Kochan <vadim4j@gmail.com>
Subject: [PATCH iproute2 v3 0/3] ss: Fix sockets filtering
Date: Sun,  4 Jan 2015 22:18:37 +0200
Message-ID: <1420402720-28767-1-git-send-email-vadim4j@gmail.com>
Cc: Vadim Kochan <vadim4j@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f54.google.com ([209.85.215.54]:52538 "EHLO
	mail-la0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752782AbbADU3B (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 4 Jan 2015 15:29:01 -0500
Received: by mail-la0-f54.google.com with SMTP id pv20so16863169lab.41
        for <netdev@vger.kernel.org>; Sun, 04 Jan 2015 12:29:00 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vadim Kochan <vadim4j@gmail.com>

v3:
    patch #2:
        Used correct types in pktstat struct
v2:
    patch #1
        1) Used bool and true/false

    patch #3:
        1) Added 'const' to 'filter' tables in patch #3
        3) Get rid of default_filter
        4) Changed a little bit merging of filtering options
        5) Now packet and netlink show funcs requires AF and SS_CLOSE to be set
 
This series contains refactoring & fixes related to sockets filtering.

1st 2 patches relates mostly to refactoring as they just
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
