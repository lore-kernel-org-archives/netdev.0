From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Fw: [Bug 194723] connect() to localhost stalls after 4.9 -> 4.10
 upgrade
Date: Wed, 15 Mar 2017 13:36:19 -0700
Message-ID: <20170315133619.64a31120@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f181.google.com ([209.85.192.181]:35659 "EHLO
        mail-pf0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751416AbdCOUgr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 15 Mar 2017 16:36:47 -0400
Received: by mail-pf0-f181.google.com with SMTP id x63so8379366pfx.2
        for <netdev@vger.kernel.org>; Wed, 15 Mar 2017 13:36:27 -0700 (PDT)
Received: from xeon-e3 (204-195-18-65.wavecable.com. [204.195.18.65])
        by smtp.gmail.com with ESMTPSA id 15sm5992298pgh.21.2017.03.15.13.36.26
        for <netdev@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 15 Mar 2017 13:36:26 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Begin forwarded message:

Date: Wed, 15 Mar 2017 19:41:59 +0000
From: bugzilla-daemon@bugzilla.kernel.org
To: stephen@networkplumber.org
Subject: [Bug 194723] connect() to localhost stalls after 4.9 -> 4.10 upgrade


https://bugzilla.kernel.org/show_bug.cgi?id=194723

--- Comment #15 from Lutz Vieweg (lvml@5t9.de) ---
At last, bisecting converged:

git bisect start
# bad: [c470abd4fde40ea6a0846a2beab642a578c0b8cd] Linux 4.10
git bisect bad c470abd4fde40ea6a0846a2beab642a578c0b8cd
# good: [69973b830859bc6529a7a0468ba0d80ee5117826] Linux 4.9
git bisect good 69973b830859bc6529a7a0468ba0d80ee5117826
# bad: [f4000cd99750065d5177555c0a805c97174d1b9f] Merge tag 'arm64-upstream' of
git://git.kernel.org/pub/scm/linux/kernel/git/arm64/linux
git bisect bad f4000cd99750065d5177555c0a805c97174d1b9f
# bad: [7079efc9d3e7f1f7cdd34082ec58209026315057] Merge tag 'fbdev-4.10' of
git://git.kernel.org/pub/scm/linux/kernel/git/tomba/linux
git bisect bad 7079efc9d3e7f1f7cdd34082ec58209026315057
# bad: [669bb4c58c3091cd54650e37c5f4e345dd12c564] Merge branch 'for-linus' of
git://git.kernel.org/pub/scm/linux/kernel/git/egtvedt/linux-avr32
git bisect bad 669bb4c58c3091cd54650e37c5f4e345dd12c564
# good: [7a8bca043cf1bb0433aa43d008b6c4de6c07d6a2] Merge branch 'sfc-tso-v2'
git bisect good 7a8bca043cf1bb0433aa43d008b6c4de6c07d6a2
# bad: [4f4f907a6729ae9e132810711c3a05e48311a948] Merge branch 'mvneta-64bit'
git bisect bad 4f4f907a6729ae9e132810711c3a05e48311a948
# good: [33f8a0458b2ce4546b681c5fae04427e3077a543] Merge tag
'wireless-drivers-next-for-davem-2016-11-25' of
git://git.kernel.org/pub/scm/linux/kernel/git/kvalo/wireless-drivers-next
git bisect good 33f8a0458b2ce4546b681c5fae04427e3077a543
# good: [80439a1704e811697ee01fd09dd95dd10790bc93] qede: Remove 'num_tc'.
git bisect good 80439a1704e811697ee01fd09dd95dd10790bc93
# good: [5067b6020770ef7c8102f47079c9e577d175ef2c] net/mlx5e: Remove flow encap
entry in the correct place
git bisect good 5067b6020770ef7c8102f47079c9e577d175ef2c
# bad: [7091d8c7055d7310339435ae3af2fb490a92524d] net/sched: cls_flower: Add
offload support using egress Hardware device
git bisect bad 7091d8c7055d7310339435ae3af2fb490a92524d
# good: [b14945ac3efdf5217182a344b037f96d6b0afae1] net: atarilance: use %8ph
for printing hex string
git bisect good b14945ac3efdf5217182a344b037f96d6b0afae1
# bad: [25429d7b7dca01dc4f17205de023a30ca09390d0] tcp: allow to turn tcp
timestamp randomization off
git bisect bad 25429d7b7dca01dc4f17205de023a30ca09390d0
# good: [1d6cff4fca4366d0529dbce170e0f33cfe213790] qed: Add iSCSI out of order
packet handling.
git bisect good 1d6cff4fca4366d0529dbce170e0f33cfe213790
# bad: [95a22caee396cef0bb2ca8fafdd82966a49367bb] tcp: randomize tcp timestamp
offsets for each connection
git bisect bad 95a22caee396cef0bb2ca8fafdd82966a49367bb


So the culprit seems to be this change: 
https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=95a22caee396cef0bb2ca8fafdd82966a49367bb

"tcp: randomize tcp timestamp offsets for each connection
jiffies based timestamps allow for easy inference of number of devices
behind NAT translators and also makes tracking of hosts simpler.

commit ceaa1fef65a7c2e ("tcp: adding a per-socket timestamp offset")
added the main infrastructure that is needed for per-connection ts
randomization, in particular writing/reading the on-wire tcp header
format takes the offset into account so rest of stack can use normal
tcp_time_stamp (jiffies).

So only two items are left:
 - add a tsoffset for request sockets
 - extend the tcp isn generator to also return another 32bit number
   in addition to the ISN.

Re-use of ISN generator also means timestamps are still monotonically
increasing for same connection quadruple, i.e. PAWS will still work.

Includes fixes from Eric Dumazet.

Signed-off-by: Florian Westphal <fw@strlen.de>
Acked-by: Eric Dumazet <edumazet@google.com>
Acked-by: Yuchung Cheng <ycheng@google.com>
Signed-off-by: David S. Miller <davem@davemloft.net>
"

I will try to attract some attention from above mentioned people.

-- 
You are receiving this mail because:
You are the assignee for the bug.
