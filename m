From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCH 8/9] [TCP]: Enable SACK enhanced FRTO (RFC4138) by default
Date: Thu, 20 Sep 2007 15:17:51 +0300
Message-ID: <11902906723907-git-send-email-ilpo.jarvinen@helsinki.fi>
References: <11902906724088-git-send-email-ilpo.jarvinen@helsinki.fi> <11902906721846-git-send-email-ilpo.jarvinen@helsinki.fi> <11902906723619-git-send-email-ilpo.jarvinen@helsinki.fi> <11902906723822-git-send-email-ilpo.jarvinen@helsinki.fi> <1190290672770-git-send-email-ilpo.jarvinen@helsinki.fi> <11902906721671-git-send-email-ilpo.jarvinen@helsinki.fi> <11902906723159-git-send-email-ilpo.jarvinen@helsinki.fi> <1190290672980-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:39950 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752042AbXITMR4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Sep 2007 08:17:56 -0400
In-Reply-To: <1190290672980-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Most of the description that follows comes from my mail to
netdev (some editing done):

Main obstacle to FRTO use is its deployment as it has to be on
the sender side where as wireless link is often the receiver's
access link. Take initiative on behalf of unlucky receivers and
enable it by default in future Linux TCP senders. Also IETF
seems to interested in advancing FRTO from experimental [1].

How does FRTO help?
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D

=46RTO detects spurious RTOs and avoids a number of unnecessary
retransmissions and a couple of other problems that can arise
due to incorrect guess made at RTO (i.e., that segments were
lost when they actually got delayed which is likely to occur
e.g. in wireless environments with link-layer retransmission).
Though FRTO cannot prevent the first (potentially unnecessary)
retransmission at RTO, I suspect that it won't cost that much
even if you have to pay for each bit (won't be that high
percentage out of all packets after all :-)). However, usually
when you have a spurious RTO, not only the first segment
unnecessarily retransmitted but the *whole window*. It goes like
this: all cumulative ACKs got delayed due to in-order delivery,
then TCP will actually send 1.5*original cwnd worth of data in
the RTO's slow-start when the delayed ACKs arrive (basically the
original cwnd worth of it unnecessarily). In case one is
interested in minimizing unnecessary retransmissions e.g. due to
cost, those rexmissions must never see daylight. Besides, in the
worst case the generated burst overloads the bottleneck buffers
which is likely to significantly delay the further progress of
the flow. In case of ll rexmissions, ACK compression often
occurs at the same time making the burst very "sharp edged" (in
that case TCP often loses most of the segments above high_seq
=3D> very bad performance too). When FRTO is enabled, those
unnecessary retransmissions are fully avoided except for the
first segment and the cwnd behavior after detected spurious RTO
is determined by the response (one can tune that by sysctl).

Basic version (non-SACK enhanced one), FRTO can fail to detect
spurious RTO as spurious and falls back to conservative
behavior. ACK lossage is much less significant than reordering,
usually the FRTO can detect spurious RTO if at least 2
cumulative ACKs from original window are preserved (excluding
the ACK that advances to high_seq). With SACK-enhanced version,
the detection is quite robust.

=46RTO should remove the need to set a high lower bound for the
RTO estimator due to delay spikes that occur relatively common
in some environments (esp. in wireless/cellular ones).

[1] http://www1.ietf.org/mail-archive/web/tcpm/current/msg02862.html

Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>
---
 net/ipv4/tcp_input.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 948e79a..02b549b 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -85,7 +85,7 @@ int sysctl_tcp_adv_win_scale __read_mostly =3D 2;
 int sysctl_tcp_stdurg __read_mostly;
 int sysctl_tcp_rfc1337 __read_mostly;
 int sysctl_tcp_max_orphans __read_mostly =3D NR_FILE;
-int sysctl_tcp_frto __read_mostly;
+int sysctl_tcp_frto __read_mostly =3D 2;
 int sysctl_tcp_frto_response __read_mostly;
 int sysctl_tcp_nometrics_save __read_mostly;
=20
--=20
1.5.0.6

