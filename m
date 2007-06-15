From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [PATCH] [TCP]: Fix logic breakage due to DSACK separation
Date: Sat, 16 Jun 2007 02:04:25 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0706160121180.12770@kivilampi-30.cs.helsinki.fi>
References: <Pine.LNX.4.64.0706151606220.15358@kivilampi-30.cs.helsinki.fi>
 <20070615.151439.70217492.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; boundary="-696243703-1834166449-1181948478=:12770"
Cc: Netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:38480 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751876AbXFOXE1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Jun 2007 19:04:27 -0400
In-Reply-To: <20070615.151439.70217492.davem@davemloft.net>
Content-ID: <Pine.LNX.4.64.0706160201250.12770@kivilampi-30.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696243703-1834166449-1181948478=:12770
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT
Content-ID: <Pine.LNX.4.64.0706160201251.12770@kivilampi-30.cs.helsinki.fi>

On Fri, 15 Jun 2007, David Miller wrote:

> From: "Ilpo_Järvinen" <ilpo.jarvinen@helsinki.fi>
> Date: Fri, 15 Jun 2007 16:07:37 +0300 (EEST)
> 
> > Commit 6f74651ae626ec672028587bc700538076dfbefb is found guilty
> > of breaking DSACK counting, which should be done only for the
> > SACK block reported by the DSACK instead of every SACK block
> > that is received along with DSACK information.
> > 
> > Signed-off-by: Ilpo Järvinen <ilpo.jarvinen@helsinki.fi>
> 
> Thanks for performing such rigorous audits and finding
> regressions like this!

They just come across, one thing leads to another, which again leads to 
another and so on... ...I was just trying to address the concerns you 
noted about tcp-2.6 patchset a while ago and came across other issues...

There are still some things I must think carefully in sacktag processing 
since it does not validate start_seq and end_seq at all which can be 
abused currently at least in tcp-2.6. ...I would rather put end to the 
whole russian roulette in tcp-2.6 sacktag rather than fix/think individual 
cases and leave future modifications of it similarily hazardous. It's not 
very clear to me how to handle all possible cases of invalid SACK blocks 
though, perhaps TCP should just ignore such sack blocks without doing 
any processing based on them, i.e., ignore them whenever start_seq-end_seq 
does not fully fit to snd_una-snd_nxt (expect DSACK of course, which 
should be processed if it's between undo_marker-snd_nxt). Do you have any 
thoughts about this?

It seems to me that net-2.6 is safe in this respect (probably just by 
accident) but the analysis wasn't that trivial, my main concern was 
tcp_fragment's pkt_len argument, if it ever becomes > skb->len, a boom 
would result (and perhaps zero has similar issues)! I couldn't find 
breakage analytically (but I could be wrong in it due to mind-boggling 
number of negations :-)) nor by bruteforcing seqno combinations near 0, 
skb->len and 2^31 wrap.


> Patch applied.

...I think it should go to stable as well.


-- 
 i.
---696243703-1834166449-1181948478=:12770--
