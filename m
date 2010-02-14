From: jamal <hadi@cyberus.ca>
Subject: [net-next-2.6 PATCH 0/7] xfrm by MARK
Date: Sun, 14 Feb 2010 10:18:45 -0500
Message-ID: <1266160732-946-1-git-send-email-hadi@cyberus.ca>
References: <xfrm-mark-net-next>
Cc: netdev@vger.kernel.org, Jamal Hadi Salim <hadi@cyberus.ca>
To: timo.teras@iki.fi, kaber@trash.net, herbert@gondor.apana.org.au,
	davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qw-out-2122.google.com ([74.125.92.26]:54675 "EHLO
	qw-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751088Ab0BNPTE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 14 Feb 2010 10:19:04 -0500
Received: by qw-out-2122.google.com with SMTP id 5so313013qwi.37
        for <netdev@vger.kernel.org>; Sun, 14 Feb 2010 07:19:02 -0800 (PST)
In-Reply-To: <xfrm-mark-net-next>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jamal Hadi Salim <hadi@cyberus.ca>

This patchset implements manipulation of ipsec tables with the
"mark" tag. You can config the SAD and SPD from user space
with a specified mark. 

Example:
---
#ip xfrm state add src 192.168.2.100 dst 192.168.1.10 proto esp spi 0x00000301 mode tunnel mark 7 auth md5 0x96358c90783bbfa3d7b196ceabe0536b enc des3_ede 0xf6ddb555acfd9d77b03ea3843f2653255afe8eb5573965df

#ip xfrm state get mark 7 src 192.168.2.100 dst 192.168.1.10 proto esp spi 0x00000301
src 192.168.2.100 dst 192.168.1.10
        proto esp spi 0x00000301 reqid 0 mode tunnel
        replay-window 0 
        mark 7/0xffffffff
        auth hmac(md5) 0x96358c90783bbfa3d7b196ceabe0536b
        enc cbc(des3_ede) 0xf6ddb555acfd9d77b03ea3843f2653255afe8eb5573965df
        sel src 0.0.0.0/0 dst 0.0.0.0/0 
#
#
#ip xfrm policy add src 172.16.2.0/24 dst 172.16.1.0/24 \
        dir fwd ptype main \
        tmpl src 192.168.2.100 dst 192.168.1.100 \
        proto esp mode tunnel mark 7 mask 0xffffffff
#
#ip xfrm policy ls
src 172.16.2.0/24 dst 172.16.1.0/24 
        dir fwd priority 0 ptype main 
        mark 7/0xffffffff
        tmpl src 192.168.2.100 dst 192.168.1.100
                proto esp reqid 0 mode tunnel
-----

A mark-configured SAD/SPD entry will use the mark as part of the 
lookup key (both in data and control path).
Example:

---
# ip xfrm pol get src 172.16.2.0/24 dst 172.16.1.0/24 dir fwd
RTNETLINK answers: No such file or directory
# ip xfrm pol get src 172.16.2.0/24 dst 172.16.1.0/24 dir fwd mark 7
src 172.16.2.0/24 dst 172.16.1.0/24 
        dir fwd priority 0 ptype main 
        mark 7/0xffffffff
        tmpl src 192.168.2.100 dst 192.168.1.100
                proto esp reqid 0 mode tunnel
---
I could probably have broken down the last two patches into more
than one, but it was easier to do it this way. If there is strong
feeling to do that let me know.
Oh, and this is an attempt to use git-send-mail - so i would appreciate
any feedback on what i can do better next time..

Jamal Hadi Salim (7):
  xfrm: introduce basic mark infrastructure
  xfrm: SA lookups signature with mark
  xfrm: SA lookups with mark
  xfrm: SP lookups signature with mark
  xfrm: SP lookups with mark
  xfrm: Allow user space config of SAD mark
  xfrm: Allow user space manipulation of SPD mark

 include/linux/xfrm.h   |   12 ++++-
 include/net/xfrm.h     |   56 +++++++++++++++++++++++----
 net/core/pktgen.c      |    3 +-
 net/ipv4/ah4.c         |    2 +-
 net/ipv4/esp4.c        |    2 +-
 net/ipv4/ipcomp.c      |    6 ++-
 net/ipv6/ah6.c         |    2 +-
 net/ipv6/esp6.c        |    2 +-
 net/ipv6/ipcomp6.c     |    6 ++-
 net/ipv6/xfrm6_input.c |    2 +-
 net/key/af_key.c       |   16 ++++---
 net/xfrm/xfrm_input.c  |    2 +-
 net/xfrm/xfrm_policy.c |   20 +++++++--
 net/xfrm/xfrm_state.c  |   70 +++++++++++++++++++++++------------
 net/xfrm/xfrm_user.c   |   96 ++++++++++++++++++++++++++++++++++++++++--------
 15 files changed, 222 insertions(+), 75 deletions(-)

