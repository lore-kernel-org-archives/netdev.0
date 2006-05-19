From: Sridhar Samudrala <sri@us.ibm.com>
Subject: [GIT PATCH] SCTP updates
Date: Fri, 19 May 2006 15:24:58 -0700
Message-ID: <1148077498.9764.3.camel@w-sridhar2.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, lksctp-developers@lists.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e1.ny.us.ibm.com ([32.97.182.141]:59070 "EHLO e1.ny.us.ibm.com")
	by vger.kernel.org with ESMTP id S1751300AbWESWZF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 May 2006 18:25:05 -0400
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e1.ny.us.ibm.com (8.12.11.20060308/8.12.11) with ESMTP id k4JMP44b029784
	for <netdev@vger.kernel.org>; Fri, 19 May 2006 18:25:04 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay04.pok.ibm.com (8.12.10/NCO/VER6.8) with ESMTP id k4JMP4sL196530
	for <netdev@vger.kernel.org>; Fri, 19 May 2006 18:25:04 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11/8.13.3) with ESMTP id k4JMP49N012483
	for <netdev@vger.kernel.org>; Fri, 19 May 2006 18:25:04 -0400
To: davem@davemloft.net
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Dave,

Please pull the following SCTP updates from
   master.kernel.org:/pub/scm/linux/kernel/git/sridhar/lksctp-2.6.git

Thanks
Sridhar

 include/net/sctp/command.h |    1 
 include/net/sctp/sctp.h    |    6 +-
 net/sctp/input.c           |  144 +++++++++++++++++++++++++-------------------
 net/sctp/sm_sideeffect.c   |   16 ++++-
 net/sctp/sm_statefuns.c    |   81 +++++++++++++++++--------
 net/sctp/socket.c          |   29 +++++----
 6 files changed, 168 insertions(+), 109 deletions(-)

commit b89498a1c2941c00889dd025f52dcb653a5083bc
Author: Vladislav Yasevich <vladislav.yasevich@hp.com>
Date:   Fri May 19 14:32:06 2006 -0700

    [SCTP]: Allow linger to abort 1-N style sockets.
    
    Enable SO_LINGER functionality for 1-N style sockets. The socket API
    draft will be clarfied to allow for this functionality. The linger
    settings will apply to all associations on a given socket.
    
    Signed-off-by: Vladislav Yasevich <vladislav.yasevich@hp.com>
    Signed-off-by: Sridhar Samudrala <sri@us.ibm.com>

commit a601266e4f3c479790f373c2e3122a766d123652
Author: Vladislav Yasevich <vladislav.yasevich@hp.com>
Date:   Fri May 19 14:25:53 2006 -0700

    [SCTP]: Validate the parameter length in HB-ACK chunk.
    
    If SCTP receives a badly formatted HB-ACK chunk, it is possible
    that we may access invalid memory and potentially have a buffer
    overflow.  We should really make sure that the chunk format is
    what we expect, before attempting to touch the data.
    
    Signed-off-by: Vlad Yasevich <vladislav.yasevich@hp.com>
    Signed-off-by: Sridhar Samudrala <sri@us.ibm.com>

commit dd2d1c6f2958d027e4591ca5d2a04dfe36ca6512
Author: Vladislav Yasevich <vladislav.yasevich@hp.com>
Date:   Fri May 19 11:52:20 2006 -0700

    [SCTP]: Respect the real chunk length when walking parameters.
    
    When performing bound checks during the parameter processing, we
    want to use the real chunk and paramter lengths for bounds instead
    of the rounded ones.  This prevents us from potentially walking of
    the end if the chunk length was miscalculated.  We still use rounded
    lengths when advancing the pointer. This was found during a
    conformance test that changed the chunk length without modifying
    parameters.
    
    Signed-off-by: Vlad Yasevich <vladislav.yasevich@hp.com>
    Signed-off-by: Sridhar Samudrala <sri@us.ibm.com>

commit 61c9fed41638249f8b6ca5345064eb1beb50179f
Author: Vladislav Yasevich <vladislav.yasevich@hp.com>
Date:   Fri May 19 11:01:18 2006 -0700

    [SCTP]: A better solution to fix the race between sctp_peeloff() and
    sctp_rcv().
    
    The goal is to hold the ref on the association/endpoint throughout the
    state-machine process.  We accomplish like this:
    
      /* ref on the assoc/ep is taken during lookup */
    
      if owned_by_user(sk)
     	sctp_add_backlog(skb, sk);
      else
     	inqueue_push(skb, sk);
    
      /* drop the ref on the assoc/ep */
    
    However, in sctp_add_backlog() we take the ref on assoc/ep and hold it
    while the skb is on the backlog queue.  This allows us to get rid of the
    sock_hold/sock_put in the lookup routines.
    
    Now sctp_backlog_rcv() needs to account for potential association move.
    In the unlikely event that association moved, we need to retest if the
    new socket is locked by user.  If we don't this, we may have two packets
    racing up the stack toward the same socket and we can't deal with it.
    If the new socket is still locked, we'll just add the skb to its backlog
    continuing to hold the ref on the association.  This get's rid of the
    need to move packets from one backlog to another and it also safe in
    case new packets arrive on the same backlog queue.
    
    The last step, is to lock the new socket when we are moving the
    association to it.  This is needed in case any new packets arrive on
    the association when it moved.  We want these to go to the backlog since
    we would like to avoid the race between this new packet and a packet
    that may be sitting on the backlog queue of the old socket toward the
    same association.
    
    Signed-off-by: Vladislav Yasevich <vladislav.yasevich@hp.com>
    Signed-off-by: Sridhar Samudrala <sri@us.ibm.com>

commit 8de8c8738086501bbe3057ed6f4b70dded657488
Author: Sridhar Samudrala <sri@us.ibm.com>
Date:   Fri May 19 10:58:12 2006 -0700

    [SCTP]: Set sk_err so that poll wakes up after a non-blocking connect failure.
    
    Also fix some other cases where sk_err is not set for 1-1 style sockets.
    
    Signed-off-by: Sridhar Samudrala <sri@us.ibm.com>



