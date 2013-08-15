From: Fan Du <fan.du@windriver.com>
Subject: [PATCHv3 net-next 0/3] xfrm: Refactor xfrm_state timer management
Date: Thu, 15 Aug 2013 15:50:40 +0800
Message-ID: <1376553043-19007-1-git-send-email-fan.du@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <herbert@gondor.hengli.com.au>, <dborkman@redhat.com>,
	<netdev@vger.kernel.org>
To: <tglx@linutronix.de>, <davem@davemloft.net>,
	<steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:40372 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751382Ab3HOHvL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Aug 2013 03:51:11 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The first version of "refactor xfrm_state timer management" has been
flushed into toilet since nobody but only me like it.

Anyway new approach here is updating SAs lifetime timeout whenever
clock_was_set is called, iow, system clock changed or host resume from
suspend state. Rule is simple, force soft expire for any SAs which has
not reach their soft expire limit and hard expire for those has experienced
soft expire timeout but wait for hard expire timeout to come.

Locking issue:
 - holding rtnl_lock when iterate on all net namespace.
 - holding xfrm_state_lock when iterate all xfrm_state in this net.
 - holding state->lock when changing xfrm_state.

Any comments would be wellcome! harsh or gentle :)

Thanks!

v3:
  - Fixing locking issue clock_change_callback reported by LOCKDEP.
  - Beautify notifier in clock_was_set as suggested by Daniel Borkmann.

v2: 
  - Instead of getting rid of original xfrm_state timer code almost completely,
    new approach is updating SA lifetime when clock_was_set is called.

v1:
  - The initiative of v1 is making xfrm_state timer independent of wall clock
    changing which could result in sudden SA termination or extremely long SA
    lifetime. So no need to read wall clock in timer handler and also
    unnecessary to turn on the timer for just 1 second as the original
    implementation. Simply start the timer right after SA is create for soft
    timeout, and after soft timeout happened, reload timer for hard timeout.


Fan Du (3):
  hrtimer: Add notifer when clock_was_set was called
  xfrm: Update xfrm_state lifetime expire after clock_was_set
  xfrm: Revert "Fix unexpected SA hard expiration after changing date"

 include/linux/hrtimer.h |    3 +++
 include/net/xfrm.h      |    4 ---
 kernel/hrtimer.c        |   19 ++++++++++++++
 net/xfrm/xfrm_state.c   |   65 ++++++++++++++++++++++++++++++++++-------------
 4 files changed, 70 insertions(+), 21 deletions(-)

-- 
1.7.9.5
