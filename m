From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: TSO trimming question
Date: Thu, 20 Dec 2007 00:02:56 +0200 (EET)
Message-ID: <Pine.LNX.4.64.0712200000050.27945@kivilampi-30.cs.helsinki.fi>
References: <Pine.LNX.4.64.0712192336130.27945@kivilampi-30.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-696243703-174300309-1198101776=:27945"
Cc: Netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:53069 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752086AbXLSWC7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Dec 2007 17:02:59 -0500
In-Reply-To: <Pine.LNX.4.64.0712192336130.27945@kivilampi-30.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696243703-174300309-1198101776=:27945
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT

On Wed, 19 Dec 2007, Ilpo Järvinen wrote:

> I'm not fully sure what's purpose of this code in tcp_write_xmit:
> 
>                        if (skb->len < limit) {
>                                unsigned int trim = skb->len % mss_now;
> 
>                                if (trim)
>                                        limit = skb->len - trim;
> 			}
> 
> Is it used to make sure we send only multiples of mss_now here and leave 
> the left-over into another skb? Or does it try to make sure that
> tso_fragment result honors multiple of mss_now boundaries when snd_wnd
> is the limitting factor? For latter IMHO this would be necessary:
> 
> 			if (skb->len > limit)
> 				limit -= limit % mss_now;

...Anyway, here's an untested patch to just do it :-):

-- 
 i.


[PATCH] [TCP]: Force tso skb split to mss_now boundary (if snd_wnd limits)

If snd_wnd was limitting factor, the tso_fragment might not
create full-sized skbs but would include the window left-overs
as well.

Signed-off-by: Ilpo Järvinen <ilpo.jarvinen@helsinki.fi>
---
 net/ipv4/tcp_output.c |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 1c7ef17..8dafda9 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -1453,6 +1453,8 @@ static int tcp_write_xmit(struct sock *sk, unsigned int mss_now, int nonagle)
 
 				if (trim)
 					limit = skb->len - trim;
+			} else if (skb->len > limit) {
+				limit -= limit % mss_now;
 			}
 		}
 
@@ -1525,6 +1527,8 @@ void tcp_push_one(struct sock *sk, unsigned int mss_now)
 
 				if (trim)
 					limit = skb->len - trim;
+			} else if (skb->len > limit) {
+				limit -= limit % mss_now;
 			}
 		}
 
-- 
1.5.0.6

---696243703-174300309-1198101776=:27945--
