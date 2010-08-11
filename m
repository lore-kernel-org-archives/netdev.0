From: "Sol Kavy" <skavy@ubicom.com>
Subject: Performance problem OpenWRT Routing
Date: Tue, 10 Aug 2010 18:59:48 -0700
Message-ID: <CB2DD11991B27C4F99935E6229450D3205DA0BCD@STORK.scenix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from server70.appriver.com ([69.20.119.203]:2185 "EHLO
	server70.appriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753932Ab0HKD7x convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Aug 2010 23:59:53 -0400
Received: from [216.112.109.98] (HELO stork.scenix.com)
  by server70.appriver.com (CommuniGate Pro SMTP 5.3.7)
  with ESMTP id 139514937 for netdev@vger.kernel.org; Tue, 10 Aug 2010 21:59:57 -0400
Content-class: urn:content-classes:message
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

To Netdev Developers:

Linux: 2.6.28 (untested but appears the similiar in 2.6.35).
Arch: Ubicom32 <not yet pushed>
Distro: OpenWRT

While=A0 working on a response time problem in OpenWRT when the router =
is fully flooded with packets,=A0 I found that do_softirq() was spendin=
g up to 56 milliseconds in execution.=A0=A0 This function is called fro=
m both irq_exit() and from ksoftirqd().=A0=A0 =20

do_softirq() is designed to drain the softirq_pending work.  It execute=
s in a loop up to=20
MAX_SOFTIRQ_RESTART (10) times.=A0 As long as one of the softirqs has p=
ending work, all of the softirqs will have a chance to run 10 times.

Inside of net/core/dev.c, net_rx_action() attempts to "limit" the amoun=
t of data that it processes in one "call".=A0 It tries to limit things =
to 1 or 2 jiffies worth of work with a budget of 300 packets.=A0 Readin=
g the code one is left with the feeling that the author believed that r=
eturning (would enable the rest of the system to continue).=A0 However,=
 this is not true if do_softirq() is going to call net_rx_action() 10 t=
imes before giving up.

The result of do_softirq() re-invoking net_rx_action() is that both pac=
ket budget and jiffies budget are reset. =A0=A0The current values resul=
t in a maximum of 10 x 300 or 3,000 packets processed in one do_softirq=
() sequence.=A0=A0=20

By setting the value to 30, the processing is reduced to the 10 millise=
cond range and most of the packet processing is moved to ksoftirqd.=A0 =
The value of this is that one can then prioritize ksoftirqd with other =
threads.=A0=A0 Irq_exit() cannot be prioritized since it is executing o=
n the back side of the interrupt.

Questions:
1) Is my analysis correct?
2) Are there any negative side effects of this change besides slowing t=
he work a bit since it is now moved to ksoftirqd?
3) Is there a better knob to tweak?
4) Should net_rx_action() use in_irq() and have different budget's base=
d on the calling context?

Thanks in advance for any feedback,

Sol Kavy

diff --git a/net/core/dev.c b/net/core/dev.c
index 144184c..9e4fb4f 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1905,7 +1905,7 @@ out:
=A0=A0 =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D*/

=A0int netdev_max_backlog __read_mostly =3D 1000;
-int netdev_budget __read_mostly =3D 300;
+int netdev_budget __read_mostly =3D 30;
int weight_p __read_mostly =3D 64;=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 /* =
old backlog weight */

=A0DEFINE_PER_CPU(struct netif_rx_stats, netdev_rx_stat) =3D { 0, };


