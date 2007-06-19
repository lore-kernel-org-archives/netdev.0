From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [RFC PATCH tcp-2.6 1/2] [TCP]: Discard fuzzy SACK blocks
Date: Wed, 20 Jun 2007 02:09:44 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0706200032250.9974@kivilampi-30.cs.helsinki.fi>
References: <1182205558580-git-send-email-ilpo.jarvinen@helsinki.fi>
 <1182205558564-git-send-email-ilpo.jarvinen@helsinki.fi>
 <20070618.231646.71856685.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; boundary="-696243703-2006252570-1182290543=:9974"
Cc: Netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:58108 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755223AbXFSXJq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Jun 2007 19:09:46 -0400
In-Reply-To: <20070618.231646.71856685.davem@davemloft.net>
Content-ID: <Pine.LNX.4.64.0706200107000.9974@kivilampi-30.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696243703-2006252570-1182290543=:9974
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT
Content-ID: <Pine.LNX.4.64.0706200104311.9974@kivilampi-30.cs.helsinki.fi>

On Mon, 18 Jun 2007, David Miller wrote:

> From: "Ilpo_Järvinen" <ilpo.jarvinen@helsinki.fi>
> Date: Tue, 19 Jun 2007 01:25:57 +0300
> 
> > From: =?ISO-8859-1?q?Ilpo_J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>
> > 
> > SACK processing code has been sort of russian roulette as no
> > validation of SACK blocks is previously attempted. It is not
> > very clear what all kinds of broken SACK blocks really mean
> > (e.g., one that has start and end sequence numbers reversed).
> > 
> > This fixes also one remote triggerable NULL-ptr access:
> > start_seq was trusted as a valid mark_lost_entry_seq but
> > without validation it is relatively easy to inject an invalid
> > sequence number there that will cause a crash in the lost
> > marker code. Other SACK processing code seems safe so this could
> > have been fixed locally but that would leave SACK processing
> > hazardous in case of future modifications. IMHO, it's just
> > better to close the whole roulette rather than disarming just
> > one bullet.
> > 
> > Signed-off-by: Ilpo Järvinen <ilpo.jarvinen@helsinki.fi>
> 
> This looks good applied.
> 
> Does mainline 2.6.x has this NULL-ptr issues too? If so
> we'll have to fix it there very soon.

The null-ptr issue is related to the new lost marker code which isn't
in the mainline (I have even tried to state this couple of times in the 
earlier posts so that you could have less worries as I understand that 
it's your highest priority concern :-)). I.e, the mainline lost marker 
code scans queue by using tcp_for_write_queue() or starts from the hint 
it has learned earlier, it doesn't have to trust any sequences that are
given by the peer in SACK block.

I'll try to explain this once again: Because the new lost marker 
fastpath blindly trusted start_seq from received SACK, it could be 
abused to search for a sequence number for which tcp_write_queue_find 
returns NULL (happens when the searched sequence is outside of current 
window).

Another trouble would nowadays occur if start_seq == snd_una because 
write_queue_find is now given start_seq - 1 (which is fully intentional, 
no need to find skb at start_seq but one below it). I disallowed SACK 
blocks starting from snd_una partly due to that, and partly due to it's 
non-sense interpretation. It would not end up to the lost marker though 
because sack reneging detection intervenes.

Obviously I would have alerted you and security folks if there would have 
been this problem in mainline & stable too (and probably had done a valid 
patch to those trees at the first time). In case you still want to verify 
mainline by yourself, you can see where start_seq and end_seq goes in 
mainline's sacktag (not very hard to see :-)). Like I've explained 
earlier, only serious suspect seems to be the calculation of pkt_len that 
is input to tcp_fragment. Other cases are relatively trivial. However, 
analytical analysis of pkt_len setting took me considerable amount of time 
due to vast number of negations which were able to defeat my brains at 
least partly. Therefore I really wouldn't mind if also you verify that 
pkt_len never becomes either zero or exceeds skb->len (even equal to 
skb->len is not very nice). Things I tried to consider are (you might find 
some additional thing to consider besides these): 
  - outside snd_una-snd_nxt start/end_seq
  - start/end_seq equal
  - start/end_seq reversing
  - 2^31 wrap problems
  - after/before ambiguity (discussed some time ago on netdev)
I couldn't find a problem causing case because the successive before() and 
after() jails were so tight. Neither did my limited bruteforcer succeed 
(as you can see, I wasn't that convinced about by my analysis validity)... 

For sure you're curious enough - have a nice day with the negations... ;-)
...Seriously, double verification of that pkt_len part wouldn't hurt 
considering it's complexity.

-- 
 i.
---696243703-2006252570-1182290543=:9974--
