From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [RFC PATCH 09/10] [TCP]: Rewrite SACK block processing &
 sack_recv_cache use
Date: Tue, 20 Nov 2007 11:22:58 +0200 (EET)
Message-ID: <Pine.LNX.4.64.0711201029540.25934@kivilampi-30.cs.helsinki.fi>
References: <11951338541351-git-send-email-ilpo.jarvinen@helsinki.fi>
 <20071115.200032.115040183.davem@davemloft.net>
 <Pine.LNX.4.64.0711161306490.29353@kivilampi-30.cs.helsinki.fi>
 <20071119.220807.216500794.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-696243703-1710446576-1195550578=:25934"
Cc: Netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:33086 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753922AbXKTJXB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Nov 2007 04:23:01 -0500
In-Reply-To: <20071119.220807.216500794.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696243703-1710446576-1195550578=:25934
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT

On Mon, 19 Nov 2007, David Miller wrote:

> From: "Ilpo_Järvinen" <ilpo.jarvinen@helsinki.fi>
> Date: Fri, 16 Nov 2007 15:44:40 +0200 (EET)
> 
> > Besides the log(n) search for which patches already exists, only O(new 
> > information) scan start..end range would be necessary. Or had you 
> > something else in mind (I'm not that sure what the "ideas", in plural,
> > were :-))? ...I haven't forgotten the RB-tree things either (and I'm
> > well aware of the limited scope of things this patch addresses).
> 
> Since you brought it up, can you respin the RB-tree patches?

Ok, I've the rb-tree directly in my tree. I'll check the fack_count 
patches since Tom (IIRC, with a long last name :-)) made some fixes 
to that.

I've also already done initial combining of things in the new lost marker 
(include the bug fixes & cleanups to the original ones) but its 
optimizations are awaiting the solution that is made for sacktag which may 
reduce need for them a lot.

> Let's just put them into net-2.6.25 and let them cook in there for
> a  long time.
> 
> If they prove to be too expensive in the no-loss case we can do
> something like lazy tree creation or simply improving the
> insert/delete implmentation.
>
> I think it's important to put RB-tree in because a lot of the ideas
> we are discussing have different implications if we go one way or
> the other so we should commit to something now in order to focus
> our efforts better.

I was thinking of trying a split approach where SACKed not yet SACKed 
would reside in a different trees. I've also observed that most of the 
range scan operations are insensitive to ordering, and if that's not yet 
fully implemented, they can deal with the mixed ordering fine after minor 
modifications. Therefore access to ->next available seems overkill 
requirement as well (would make dropping list easier). However, it's a bit 
complex to implement tree walker for a range because RB-tree is going to 
live underneath the walker (at least in clean_rtx_queue and sacktag) :-); 
if anyone knows some resources where such issue is dealt it might help, 
pointer would be nice :-). ...Maybe I just use list in the first step.

But we're still bound to extra walking for a while if a made up large 
DSACK block comes in. I was thinking of putting some sane limit to how 
many skbs the DSACK can deal (in normal case there shouldn't be no
more than two; two because of fragmenting cause by other dir SACK
blocks, with MTU probes up 2 times that seems valid).


For the record, another idea I had (have SACK-lowtree and others trees
here):

For each SACK block
	search_after_or_equal start_seq in SACK-lowtree
	if after end_seq
		search from others tree, move skb to SACK-lowtree
		block done
	endif

	loop
		search_before_or_equal end_seq in SACK-lowtree
		if they were the same skb
			update the skb in SACK-lowtree
			block done
		endif

		move end_seq result skb back to others tree
	end loop
endfor

But the laziness didn't help that much (would need to know R-bits; L-bits 
could be derived) and malicious guys could still do crazy thing by telling 
no S-bit, S, no S-bit, S, ... pattern for the whole window first and then 
SACKing them all in a single ACK => uh-oh, would have to do all those 
lowtree => others moves for 1/2 of the window.


-- 
 i.
---696243703-1710446576-1195550578=:25934--
