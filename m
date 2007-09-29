From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: 2.6.23-rc8-mm2 - tcp_fastretrans_alert() WARNING
Date: Sat, 29 Sep 2007 15:44:49 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0709291532200.6776@kivilampi-30.cs.helsinki.fi>
References: <20070927022220.c76a7a6e.akpm@linux-foundation.org>
 <46FD20F0.3050909@fr.ibm.com> <Pine.LNX.4.64.0709282143020.6013@kivilampi-30.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-696243703-957210457-1191069889=:6776"
Cc: Andrew Morton <akpm@linux-foundation.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
To: Cedric Le Goater <clg@fr.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:35497 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754744AbXI2Mow (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 29 Sep 2007 08:44:52 -0400
In-Reply-To: <Pine.LNX.4.64.0709282143020.6013@kivilampi-30.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696243703-957210457-1191069889=:6776
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT

On Fri, 28 Sep 2007, Ilpo Järvinen wrote:
> On Fri, 28 Sep 2007, Cedric Le Goater wrote:
>
> > I just found that warning in my logs. It seems that it's been 
> > happening since rc7-mm1 at least. 
> > 
> > WARNING: at /home/legoater/linux/2.6.23-rc8-mm2/net/ipv4/tcp_input.c:2314 tcp_fastretrans_alert()
> >
> > Call Trace:
> >  <IRQ>  [<ffffffff8040fdc3>] tcp_ack+0xcd6/0x1894
> > ...snip...
> 
> ...Thanks for the report, I'll have look what could still break 
> fackets_out...

I think this one is now clear to me, tcp_fragment/collapse adjusts 
fackets_out (incorrectly) also for reno flow when there were some dupACKs 
that made sacked_out != 0. Could you please try if patch below proves all 
them to be of non-SACK origin... In case that's true, it's rather 
harmless, I'll send a fix on Monday or so (this would anyway be needed)... 
If you find out that them occur with SACK enabled flow, that would be
more interesting and requires more digging...

-- 
 i.



diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 2286361..e642779 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -2311,8 +2311,10 @@ tcp_fastretrans_alert(struct sock *sk, int pkts_acked, int flag)
 	if (!tp->packets_out)
 		tp->sacked_out = 0;
 
-	if (WARN_ON(!tp->sacked_out && tp->fackets_out))
+	if (WARN_ON(!tp->sacked_out && tp->fackets_out)) {
+		printk(KERN_ERR "TCP %d\n", tcp_is_reno(tp));
 		tp->fackets_out = 0;
+	}
 
 	/* Now state machine starts.
 	 * A. ECE, hence prohibit cwnd undoing, the reduction is required. */
---696243703-957210457-1191069889=:6776--
