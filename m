From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: Linux 2.6.22: Leak r=1 1
Date: Thu, 12 Jul 2007 10:53:57 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0707120827280.12545@kivilampi-30.cs.helsinki.fi>
References: <20070711174030.tjmxpxtfsn4twgk2@m.safari.iki.fi>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-696243703-605683641-1184226837=:12545"
Cc: Linux Networking Mailing List <netdev@vger.kernel.org>
To: Sami Farin <safari-kernel@safari.iki.fi>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:54437 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758456AbXGLHyB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Jul 2007 03:54:01 -0400
In-Reply-To: <20070711174030.tjmxpxtfsn4twgk2@m.safari.iki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696243703-605683641-1184226837=:12545
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT

On Wed, 11 Jul 2007, Sami Farin wrote:

> That's right, so descriptive is the new Linux kernel 2.6.22.
> Took a while to grep what is "leaking".
> 
> Linux safari.finland.fbi 2.6.22-cfs-v19 #3 SMP Tue Jul 10 00:22:25 EEST 2007 i686 i686 i386 GNU/Linux
> 
> Just normal Internet usage, azureus for example =)
> I think this is easy to trigger.

I guess those packet loss periods help you to reproduce it so easily.

> # ss -n|wc -l
> 870
> 
> # ping -A 80.223.96.1 
> PING 80.223.96.1 (80.223.96.1) 56(84) bytes of data.
> 64 bytes from 80.223.96.1: icmp_seq=1 ttl=255 time=431 ms
> ...
> --- 80.223.96.1 ping statistics ---
> 40 packets transmitted, 25 received, 37% packet loss, time 17954ms
> rtt min/avg/max/mdev = 406.000/467.758/530.983/29.384 ms, pipe 2, ipg/ewma 460.361/456.381 ms
> 
> But ploss is only temporary (when I am downloading with azureus =) ,
> when only uploading (95% of bandwidth used) rtt avg = 32ms).
> 
> # dmesg|grep Leak
> [114992.191011] Leak r=1 4
> [124231.713348] Leak r=1 4
> [142807.938284] Leak r=1 4
> [142999.674521] Leak r=1 1
> [143177.462073] Leak r=1 4
> [143230.001570] Leak r=1 4
> [143232.982560] Leak r=1 4
> [143234.537096] Leak r=1 4
> [143297.927760] Leak r=1 4
> [143300.633603] Leak r=1 4
> [143302.172917] Leak r=1 4
> [143357.083193] Leak r=1 1
> [143361.780879] Leak r=1 4
> [143413.706490] Leak r=1 4
> [143552.996598] Leak r=1 1
> 
> [root@safari /proc/sys/net/ipv4]# grep . *
[...snip...]

> tcp_frto:1

I suspect this is the main ingrediment to trigger these leaks, well, 
I'm pretty sure of... Sami, please test the patch included below, 
Dave can then put that one to net-2.6 and to stable too.

This is sort of poking to dark still... But it's pretty much the only 
place where the SACKED_RETRANS bit is touched without checking first that 
the adjustment can safely be made (and all SACKED_RETRANS changes in 
2.6.22 are FRTO related as well). Most likely something cleared 
SACKED_RETRANS bit underneath FRTO and in tcp_enter_frto_loss I just 
blindly assumed that it's still there.

While the patch below probably works, and leaks are no more, I'd like to 
get bottom of this by really figuring out what caused the SACKED_RETRANS 
bit to get cleared in the first place (wasn't expecting this happen while 
I wrote the FRTO). I guess that it could be "lost retransmit" loop in 
sacktag but again I've no concrete proof for that yet. Because for that to
trigger, something must have allowed sending skbs past the snd_nxt at the 
time of the RTO, which too must be prevented during FRTO! Thus there could 
be other issues while this is just a sympthom of the main problem.

I'd be interested to study some tcpdumps that relate to Leak cases you're 
seeing. Could you record some Sami? I'm not sure though how one can figure 
out the timestamp relation between the kernel log and a tcpdump log... 
Anyway, for this debugging, you should use a debug version of this patch 
with WARN_ON to get exact timestamp of the event since the leak print may 
occur much later on, I put one available at 
http://www.cs.helsinki.fi/u/ijjarvin/patches/ .


Other candidates for the cause are even less likely. The first two are 
self-standing so that this patch is going to be necessary as long as 
fuzzy SACK blocks are allowed to be received and processed in sacktag 
(regardless there turns to be additional problem triggering this one or 
not):
 - DSACK touching snd_una (receiver is pretty inconsistent with itself 
   because snd_una wasn't advanced).
 - 2xRTO and SACK @ snd_una (same note as above)
 - snd_una advanced full skb _without_ FLAG_DATA_ACKED being set 
   (unlikely)
 - Head not retransmitted on RTO when FRTO was enabled (no, it's not
   going to be this one)
It cannot be double SACKED_RETRANS because another msg would be printed
already in tcp_retransmit_skb.

Anyway, I'll be offline over the weekend starting from the Friday
morning.

...thanks for your report Sami.

-- 
 i.



[PATCH] [TCP]: Verify the presence of RETRANS bit when leaving FRTO

For yet unknown reason, something cleared SACKED_RETRANS bit
underneath FRTO.

Signed-off-by: Ilpo Järvinen <ilpo.jarvinen@helsinki.fi>
---
 net/ipv4/tcp_input.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 69f9f1e..4e5884a 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -1398,7 +1398,9 @@ static void tcp_enter_frto_loss(struct sock *sk, int allowed_segments, int flag)
 		 * waiting for the first ACK and did not get it)...
 		 */
 		if ((tp->frto_counter == 1) && !(flag&FLAG_DATA_ACKED)) {
-			tp->retrans_out += tcp_skb_pcount(skb);
+			/* For some reason this R-bit might get cleared? */
+			if (TCP_SKB_CB(skb)->sacked & TCPCB_SACKED_RETRANS)
+				tp->retrans_out += tcp_skb_pcount(skb);
 			/* ...enter this if branch just for the first segment */
 			flag |= FLAG_DATA_ACKED;
 		} else {
-- 
1.5.0.6

---696243703-605683641-1184226837=:12545--
