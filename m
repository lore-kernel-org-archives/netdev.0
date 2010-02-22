From: jamal <hadi@cyberus.ca>
Subject: [net-next-2.6 PATCH 0/7] xfrm by MARK
Date: Mon, 22 Feb 2010 16:32:53 -0500
Message-ID: <1266874380-29593-1-git-send-email-hadi@cyberus.ca>
References: <xfrm-mark-v3>
Cc: timo.teras@iki.fi, kaber@trash.net, herbert@gondor.apana.org.au,
	netdev@vger.kernel.org, Jamal Hadi Salim <hadi@cyberus.ca>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f209.google.com ([209.85.218.209]:45423 "EHLO
	mail-bw0-f209.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754487Ab0BVVdP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Feb 2010 16:33:15 -0500
Received: by bwz1 with SMTP id 1so465221bwz.21
        for <netdev@vger.kernel.org>; Mon, 22 Feb 2010 13:33:14 -0800 (PST)
In-Reply-To: <xfrm-mark-v3>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jamal Hadi Salim <hadi@cyberus.ca>

Changes since last time:
----------------------
Patch 1/7: Feedback from David Miller; aggregate xfrm_*mark
and correct comment on the type of xfrm_mark

Changes since first time:
----------------------
Patch 1/7: Feedback from Patrick McHardy; We pass to user space any 
mark as long as it has non-zero mask.

This patchset implements manipulation of ipsec tables with the
"mark" tag. You can config the SAD and SPD from user space
with a specified mark. 

Example:
---
#ip xfrm state add src 192.168.2.100 dst 192.168.1.10 proto esp spi 0x00000301 mode tunnel mark 7 auth md5 0x96358c90783bbfa3d7b196ceabe0536b enc des3_ede 0xf6ddb555acfd9d77b03ea3843f2653255afe8eb5573965df

#ip xfrm state get mark 7 src 192.168.2.100 dst 192.168.1.10 proto esp spi 0x00000301
output:
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
output:
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
output:
RTNETLINK answers: No such file or directory
# ip xfrm pol get src 172.16.2.0/24 dst 172.16.1.0/24 dir fwd mark 7
output:
src 172.16.2.0/24 dst 172.16.1.0/24 
        dir fwd priority 0 ptype main 
        mark 7/0xffffffff
        tmpl src 192.168.2.100 dst 192.168.1.100
                proto esp reqid 0 mode tunnel
---

Jamal Hadi Salim (7):
  xfrm: introduce basic mark infrastructure
  xfrm: SA lookups signature with mark
  xfrm: SA lookups with mark
  xfrm: SP lookups signature with mark
  xfrm: SP lookups with mark
  xfrm: Allow user space config of SAD mark
  xfrm: Allow user space manipulation of SPD mark

 include/linux/xfrm.h   |   12 ++++-
 include/net/xfrm.h     |   50 ++++++++++++++++++++----
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
 15 files changed, 216 insertions(+), 75 deletions(-)

