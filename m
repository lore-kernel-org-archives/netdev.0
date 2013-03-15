From: =?UTF-8?Q?Maciej_=C5=BBenczykowski?= <maze@google.com>
Subject: bnx2x statistics occasionally wrong by near multiples of 4GB.
Date: Fri, 15 Mar 2013 14:03:05 -0700
Message-ID: <CANP3RGdWMHv-7TZ4fvASrmz7NXkO7B2g2RCZwV8ecExUsQTQ2w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux NetDev <netdev@vger.kernel.org>
To: Mintz Yuval <yuvalmin@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f54.google.com ([209.85.219.54]:60440 "EHLO
	mail-oa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932453Ab3COVDF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Mar 2013 17:03:05 -0400
Received: by mail-oa0-f54.google.com with SMTP id n12so3892969oag.27
        for <netdev@vger.kernel.org>; Fri, 15 Mar 2013 14:03:05 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

bnx2x_stats.h:

#define UPDATE_QSTAT(s, t) \
     do { \
              qstats->t##_hi = qstats_old->t##_hi + le32_to_cpu(s.hi); \
              qstats->t##_lo = qstats_old->t##_lo + le32_to_cpu(s.lo); \
      } while (0)

Looks wrong because it doesn't deal with overflow of _lo.

I'm not 100% sure if I tracked it down correctly, but I think this is
the root cause of us occasionally seeing stats (/proc/net/dev tx_bytes
in this case) jump back by roughly N*4GB and then go forward again.

In particular we saw successive reads of /proc/net/dev eth0 Transmit bytes show:

0x8F6 45356E60
0x8F4 4C8D72B9
0x8F6 5420D096

(which since this is a sum of 3 values (ucase/mcast/bcast) from all
queues, means we actually wrongly accounted for overflow twice...)

- Maciej
