From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: ax25 rose Re: kernel panic linux-2.6.27-rc7
Date: Fri, 3 Oct 2008 07:34:18 +0000
Message-ID: <20081003073418.GA5235@ff.dom.local>
References: <20081002194845.GB2664@ami.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	Ralf Baechle DL5RB <ralf@linux-mips.org>
To: "Bernard, f6bvp" <f6bvp@free.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ik-out-1112.google.com ([66.249.90.178]:15109 "EHLO
	ik-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753474AbYJCHe1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Oct 2008 03:34:27 -0400
Received: by ik-out-1112.google.com with SMTP id c30so964027ika.5
        for <netdev@vger.kernel.org>; Fri, 03 Oct 2008 00:34:25 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20081002194845.GB2664@ami.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02-10-2008 21:48, Jarek Poplawski wrote:
> On Thu, Oct 02, 2008 at 08:20:18PM +0200, Bernard, f6bvp wrote:
...
>> Although I did not change anything, and contrarily to my previous
>> observation, the system instability as shown above occurs
>> systematically.
>> There was no problem with Kernel 2.6.25-10 I was using before (with
>> patches for AX25 and ROSE that are now included in 2.6.27-rc7).

Then it could be useful to try our luck with reverting some other
"suspicious" changes added in the meantime. My first candidate is
attached below. (So you could test this with vanilla 2.6.27-rc7 or
later, with or without any of the patches in this thread, and the
patch below reverted.)

>> I did not try 2.6.26 on this machine, thus I cannot tell if the bug was
>> already present.
>> Would it be worth to test 2.6.26 ?   
> 
> Yes, but only if you think you can do it safely.

This is still valid (it can wait).

Jarek P.

-------->

commit 30902dc3cb0ea1cfc7ac2b17bcf478ff98420d74
Author: David S. Miller <davem@davemloft.net>
Date:   Tue Jun 17 21:26:37 2008 -0700

    ax25: Fix std timer socket destroy handling.
    
    Tihomir Heidelberg - 9a4gl, reports:
    
    --------------------
    I would like to direct you attention to one problem existing in ax.25
    kernel since 2.4. If listening socket is closed and its SKB queue is
    released but those sockets get weird. Those "unAccepted()" sockets
    should be destroyed in ax25_std_heartbeat_expiry, but it will not
    happen. And there is also a note about that in ax25_std_timer.c:
    /* Magic here: If we listen() and a new link dies before it
    is accepted() it isn't 'dead' so doesn't get removed. */
    
    This issue cause ax25d to stop accepting new connections and I had to
    restarted ax25d approximately each day and my services were unavailable.
    Also netstat -n -l shows invalid source and device for those listening
    sockets. It is strange why ax25d's listening socket get weird because of
    this issue, but definitely when I solved this bug I do not have problems
    with ax25d anymore and my ax25d can run for months without problems.
    --------------------
    
    Actually as far as I can see, this problem is even in releases
    as far back as 2.2.x as well.
    
    It seems senseless to special case this test on TCP_LISTEN state.
    Anything still stuck in state 0 has no external references and
    we can just simply kill it off directly.
    
    Signed-off-by: David S. Miller <davem@davemloft.net>

diff --git a/net/ax25/ax25_std_timer.c b/net/ax25/ax25_std_timer.c
index 96e4b92..cdc7e75 100644
--- a/net/ax25/ax25_std_timer.c
+++ b/net/ax25/ax25_std_timer.c
@@ -39,11 +39,9 @@ void ax25_std_heartbeat_expiry(ax25_cb *ax25)
 
 	switch (ax25->state) {
 	case AX25_STATE_0:
-		/* Magic here: If we listen() and a new link dies before it
-		   is accepted() it isn't 'dead' so doesn't get removed. */
-		if (!sk || sock_flag(sk, SOCK_DESTROY) ||
-		    (sk->sk_state == TCP_LISTEN &&
-		     sock_flag(sk, SOCK_DEAD))) {
+		if (!sk ||
+		    sock_flag(sk, SOCK_DESTROY) ||
+		    sock_flag(sk, SOCK_DEAD)) {
 			if (sk) {
 				sock_hold(sk);
 				ax25_destroy_socket(ax25);
