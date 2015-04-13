From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net] tcp/dccp: do not block bh too long in
 inet_twdr_twkill_work()
Date: Sun, 12 Apr 2015 18:52:37 -0700
Message-ID: <1428889957.25985.377.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1428664747.25985.298.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20150412.210456.227234180754411318.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f172.google.com ([209.85.213.172]:34918 "EHLO
	mail-ig0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752502AbbDMBwj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 12 Apr 2015 21:52:39 -0400
Received: by iggg4 with SMTP id g4so34552776igg.0
        for <netdev@vger.kernel.org>; Sun, 12 Apr 2015 18:52:39 -0700 (PDT)
In-Reply-To: <20150412.210456.227234180754411318.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2015-04-12 at 21:04 -0400, David Miller wrote:
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Fri, 10 Apr 2015 04:19:07 -0700
> 
> > From: Eric Dumazet <edumazet@google.com>
> > 
> > I have seen inet_twdr_twkill_work() blocking softirq for
> > periods up to 1.5 seconds, depending on number of timewait sockets.
> > 
> > This is an unacceptable source of latency.
> > 
> > Note that inet_twdr_do_twkill_work() releases death_lock spinlock
> > for every tw handled, but does not take care of bh enabling.
> > 
> > Signed-off-by: Eric Dumazet <edumazet@google.com>
> 
> I think it makes sense to use local_softirq_pending() here rather
> than flip the lock unconditionally.

I thought about that, but this meant having to test 2 conditions.

Not sure we need this patch anyway, if we merge the 'tcp/dccp: get rid
of central timewait timer' in 4.1 

Its not like it is a new bug ...

diff --git a/net/ipv4/inet_timewait_sock.c b/net/ipv4/inet_timewait_sock.c
index 6d592f8555fb..942b582d044e 100644
--- a/net/ipv4/inet_timewait_sock.c
+++ b/net/ipv4/inet_timewait_sock.c
@@ -303,9 +303,10 @@ void inet_twdr_twkill_work(struct work_struct *work)
 				continue;
 
 			while (inet_twdr_do_twkill_work(twdr, i) != 0) {
-				if (need_resched()) {
+				if (local_softirq_pending() ||
+				    need_resched()) {
 					spin_unlock_bh(&twdr->death_lock);
-					schedule();
+					cond_resched();
 					spin_lock_bh(&twdr->death_lock);
 				}
 			}
