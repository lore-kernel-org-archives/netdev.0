From: Lucas Nussbaum <lucas.nussbaum@loria.fr>
Subject: [PATCH] Make CUBIC Hystart more robust to RTT variations
Date: Tue, 8 Mar 2011 10:32:15 +0100
Message-ID: <20110308093215.GA23842@xanadu.blop.info>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Sangtae Ha <sha2@ncsu.edu>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from xanadu.blop.info ([178.79.145.134]:56511 "EHLO xanadu.blop.info"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751756Ab1CHJbY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Mar 2011 04:31:24 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

CUBIC Hystart uses two heuristics to exit slow start earlier, before
losses start to occur. Unfortunately, it tends to exit slow start far t=
oo
early, causing poor performance since convergence to the optimal cwnd i=
s
then very slow. This was reported in
http://permalink.gmane.org/gmane.linux.network/188169 and
https://partner-bugzilla.redhat.com/show_bug.cgi?id=3D616985

I am using an experimental testbed (http://www.grid5000.fr/) with two
machines connected using Gigabit ethernet to a dedicated 10-Gb backbone=
=2E
RTT between both machines is 11.3ms. Using TCP CUBIC without Hystart, c=
wnd
grows to ~2200.  With Hystart enabled, CUBIC exits slow start with cwnd
lower than 100, and often lower than 20, which leads to the poor
performance that I reported.

After instrumenting TCP CUBIC, I found out that the segment-to-ack RTT
tends to vary quite a lot even when the network is not congested, due t=
o
several factors including the fact that TCP sends packet in burst (so t=
he
packets are queued locally before being sent, increasing their RTT), an=
d
delayed ACKs on the destination host.

The patch below increases the thresholds used by the two Hystart
heuristics. First, the length of an ACK train needs to reach 2*minRTT.
Second, the max RTT of a group of packets also needs to reach 2*minRTT.
In my setup, this causes Hystart to exit slow start when cwnd is in the
1900-2000 range using the ACK train heuristics, and sometimes to exit i=
n the
700-900 range using the delay increase heuristic, dramatically improvin=
g
performance.

I've left commented out a printk that is useful for debugging the exit
point of Hystart. And I could provide access to my testbed if someone
wants to do further experiments.

Signed-off-by: Lucas Nussbaum <lucas.nussbaum@loria.fr>
--=20
| Lucas Nussbaum             MCF Universit=E9 Nancy 2 |
| lucas.nussbaum@loria.fr         LORIA / AlGorille |
| http://www.loria.fr/~lnussbau/  +33 3 54 95 86 19 |

diff --git a/net/ipv4/tcp_cubic.c b/net/ipv4/tcp_cubic.c
index 71d5f2f..a973a49 100644
--- a/net/ipv4/tcp_cubic.c
+++ b/net/ipv4/tcp_cubic.c
@@ -344,7 +344,7 @@ static void hystart_update(struct sock *sk, u32 del=
ay)
                /* first detection parameter - ack-train detection */
                if (curr_jiffies - ca->last_jiffies <=3D msecs_to_jiffi=
es(2)) {
                        ca->last_jiffies =3D curr_jiffies;
-                       if (curr_jiffies - ca->round_start >=3D ca->del=
ay_min>>4)
+                       if (curr_jiffies - ca->round_start >=3D ca->del=
ay_min>>2)
                                ca->found |=3D HYSTART_ACK_TRAIN;
                }
=20
@@ -355,8 +355,7 @@ static void hystart_update(struct sock *sk, u32 del=
ay)
=20
                        ca->sample_cnt++;
                } else {
-                       if (ca->curr_rtt > ca->delay_min +
-                           HYSTART_DELAY_THRESH(ca->delay_min>>4))
+                       if (ca->curr_rtt > ca->delay_min<<1)
                                ca->found |=3D HYSTART_DELAY;
                }
                /*
@@ -364,7 +363,10 @@ static void hystart_update(struct sock *sk, u32 de=
lay)
                 * we exit from slow start immediately.
                 */
                if (ca->found & hystart_detect)
+               {
+//                     printk("hystart_update: cwnd=3D%u found=3D%d de=
lay_min=3D%u cur_jif=3D%u round_start=3D%u curr_rtt=3D%u\n", tp->snd_cw=
nd, ca->found, ca
                        tp->snd_ssthresh =3D tp->snd_cwnd;
+               }
        }
 }
