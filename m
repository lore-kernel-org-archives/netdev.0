From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: Fix FRTO+NewReno problem (Was: Re: This has a work around)
Date: Mon, 12 May 2008 13:08:09 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0805120859470.1041@wrl-59.cs.helsinki.fi>
References: <48207F06.50306@damtek.com> <Pine.LNX.4.64.0805061912350.8965@wrl-59.cs.helsinki.fi>
 <4821C37A.7040306@damtek.com> <Pine.LNX.4.64.0805072357240.23091@wrl-59.cs.helsinki.fi>
 <4823437D.20005@damtek.com> <Pine.LNX.4.64.0805082336440.31776@wrl-59.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; boundary="=_courier-13210-1210270579-0001-2"
Cc: Bug 213081 <213081@bugs.launchpad.net>, 478062@bugs.debian.org,
	Netdev <netdev@vger.kernel.org>
To: "Damon L. Chesser" <damon@damtek.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:58242 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752345AbYELKIM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 May 2008 06:08:12 -0400
In-Reply-To: <Pine.LNX.4.64.0805082336440.31776@wrl-59.cs.helsinki.fi>
Content-ID: <Pine.LNX.4.64.0805121246450.1888@wrl-59.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--=_courier-13210-1210270579-0001-2
Content-Type: TEXT/PLAIN; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 8BIT
Content-ID: <Pine.LNX.4.64.0805082336442.31776@wrl-59.cs.helsinki.fi>

On Thu, 8 May 2008, Ilpo Järvinen wrote:

> On Thu, 8 May 2008, Damon L. Chesser wrote:
> 
> > reran the print job with the correct kernel (for control reasons) and
> > received
> > the same results:  tcp_frto=1 no print.  tcp_frto=0 I can print.  Attached
> > is
> > the output of tcpdump
> > 
> > uname -r = 2.6.24-1-amd64
> 
> Well, that was a surprise, there must be something else too I didn't yet
> notice. I don't think it's that necessary for you to test that patch I sent
> earlier (basically the code paths it would have fixed were already in use with
> tcp_frto=1). And that patch was "obviously correct" anyway though it wasn't
> enough to fix this issue.
> 
> ...I too can probably reproduce this locally with small amount of work because
> the receiver pattern is dead obvious from the logs.

Yes indeed, some hping3 tcl acting as a clone of that network printer did 
it :-). Below is the 2nd patch (both are necessary). Besides them there's 
still SACKFRTO snd_nxt != frto_highmark problem remaining but it is a lot 
less severe and rare than this problem was and I'm still trying to find a 
simple way to fix it w/o adding another u32 to tcp_sock. I may need to 
think this retrans_stamp usage more around the rest of TCP code too as 
it seems to be somewhat suspicious here and there.

-- 
 i.

ps. ...you could have at least considered reporting upstream a bit 
earlier if some problem goes away/appears by changing kernel version 
(especially since you already tried some non-distro kernels and found 
them non-working), it might help to catch devs attention who hardly
hang much around distro bug trackers :-).

--
[PATCH] [TCP] FRTO: Fix fallback to conventional recovery

It seems that commit 009a2e3e4ec ("[TCP] FRTO: Improve
interoperability with other undo_marker users") run into
another land-mine which caused fallback to conventional
recovery to break:

1. Cumulative ACK arrives after FRTO retransmission
2. tcp_try_to_open sees zero retrans_out, clears retrans_stamp
   which should be kept like in CA_Loss state it would be
3. undo_marker change allowed tcp_packet_delayed to return
   true because of the cleared retrans_stamp once FRTO is
   terminated causing LossUndo to occur, which means all loss
   markings FRTO made are reverted.

This means that the conventional recovery basically recovered
one loss per RTO, which is not that efficient. It becomes a
serious problem to progress of the flow if many segments were
lost or when losses will persist to the FRTO RTTs as well.
Retrans_stamp was incorrectly cleared even before that
particular change (though it's effect is not often significant).

It was quite unobvious that the undo_marker change broken
something like this, I had a quite long session to track it
down because of the non-intuitiviness of the bug (luckily I
had a trivial reproducer at hand and I was also able to learn
to use kprobes in the process as well :-)).

This together with the NewReno+FRTO fix (62ab22278308a)
should finally fix Damon's problems.

Compile tested (but I did experiment with a similar fix on
a live kernel with systemtap+kprobes).

Signed-off-by: Ilpo Järvinen <ilpo.jarvinen@helsinki.fi>
Reported-by: Damon L. Chesser <damon@damtek.com>
---
 net/ipv4/tcp_input.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 81ece1f..4c2255c 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -2481,7 +2481,7 @@ static void tcp_try_to_open(struct sock *sk, int flag)
 
 	tcp_verify_left_out(tp);
 
-	if (tp->retrans_out == 0)
+	if (!tp->frto_counter && tp->retrans_out == 0)
 		tp->retrans_stamp = 0;
 
 	if (flag & FLAG_ECE)
-- 
1.5.2.2
--=_courier-13210-1210270579-0001-2--
