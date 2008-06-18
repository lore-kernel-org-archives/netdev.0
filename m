From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH]: Consolidate ax25 socket grafting.
Date: Tue, 17 Jun 2008 21:27:43 -0700 (PDT)
Message-ID: <20080617.212743.05103991.davem@davemloft.net>
References: <20080617.023201.14122891.davem@davemloft.net>
	<4857A9F8.7040208@hamradio.hr>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-hams@vger.kernel.org, netdev@vger.kernel.org,
	ralf@linux-mips.org
To: 9a4gl@hamradio.hr
Return-path: <linux-hams-owner@vger.kernel.org>
In-Reply-To: <4857A9F8.7040208@hamradio.hr>
Sender: linux-hams-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Tihomir Heidelberg - 9a4gl <9a4gl@hamradio.hr>
Date: Tue, 17 Jun 2008 14:11:36 +0200

> I would like to direct you attention to one problem existing in ax.25 
> kernel since 2.4. If listening socket is closed and its SKB queue is 
> released but those sockets get weird. Those "unAccepted()" sockets 
> should be destroyed in ax25_std_heartbeat_expiry, but it will not 
> happen. And there is also a note about that in ax25_std_timer.c:
> /* Magic here: If we listen() and a new link dies before it
> is accepted() it isn't 'dead' so doesn't get removed. */
> 
> This issue cause ax25d to stop accepting new connections and I had to 
> restarted ax25d approximately each day and my services were unavailable. 
> Also netstat -n -l shows invalid source and device for those listening 
> sockets. It is strange why ax25d's listening socket get weird because of 
> this issue, but definitely when I solved this bug I do not have problems 
> with ax25d anymore and my ax25d can run for months without problems.

Thanks for the report.  I just committed the following patch
which should fix the bug:

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
---
 net/ax25/ax25_std_timer.c |    8 +++-----
 1 files changed, 3 insertions(+), 5 deletions(-)

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
-- 
1.5.5.1.308.g1fbb5

