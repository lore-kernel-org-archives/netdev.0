From: "=?ISO-8859-15?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [PATCH] tcp: fix tcp_retransmit_skb() to maintain MSS
 invariant
Date: Mon, 5 Mar 2012 11:31:05 +0200 (EET)
Message-ID: <alpine.DEB.2.00.1203051051440.2966@wel-95.cs.helsinki.fi>
References: <1330698449-2969-1-git-send-email-ncardwell@google.com> <alpine.DEB.2.00.1203022147100.3978@melkinpaasi.cs.helsinki.fi> <CAK6E8=eqAgw3_eMnvZUmDnHT0ETPFvDC2=HG3uj5nr3kGL7J5A@mail.gmail.com>
 <CADVnQy=MxPbbg+fVAU_dGwsZotbbnFMvbrtEHGb+MkQfNkioOA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="8323329-692024168-1330939865=:2966"
Cc: Yuchung Cheng <ycheng@google.com>,
	David Miller <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>,
	Nandita Dukkipati <nanditad@google.com>,
	Tom Herbert <therbert@google.com>
To: Neal Cardwell <ncardwell@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:39094 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756411Ab2CEJbH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Mar 2012 04:31:07 -0500
In-Reply-To: <CADVnQy=MxPbbg+fVAU_dGwsZotbbnFMvbrtEHGb+MkQfNkioOA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--8323329-692024168-1330939865=:2966
Content-Type: TEXT/PLAIN; charset=iso-8859-1
Content-Transfer-Encoding: 8BIT

On Sat, 3 Mar 2012, Neal Cardwell wrote:

> On Fri, Mar 2, 2012 at 10:05 PM, Yuchung Cheng <ycheng@google.com> wrote:
> > On Fri, Mar 2, 2012 at 12:25 PM, Ilpo Järvinen
> > <ilpo.jarvinen@helsinki.fi> wrote:
> >> Why would we be splitting SACKed segment there?!? ...Ah, it seems that
> >> it indeed is possible now after the non-FACK mode fragment, however, it
> >> is totally useless work and seems to be breaking stuff. I think that the
> >> proper solution is to prevent splitting of already SACKed stuff. ...Nice
> >> find btw. :-)
> >
> > Bingo! I totally agree this is the bug. looks like a one-line patch now.
> 
> Agreed. I sent out a proposal:
>   http://patchwork.ozlabs.org/patch/144408/
> 
> Thanks, Ilpo, for filling in the details.

This unnecessary fragmenting probably also ate up some of the benefits 
from the recombining efforts done by shift/merge.

> The comment in
> tcp_match_skb_to_sack() that says "Round if necessary so that SACKs
> cover only full MSSes and/or the remaining small portion (if
> present)", plus the analogous MSS alignment logic in
> tcp_mss_split_point(), had me convinced that this MSS alignment
> invariant that was needed for tcp_match_skb_to_sack() to work
> correctly was actually intended.

tcp_mss_split_point is there to work around received window non-MSS 
oddities (when the whole window is almost fully utilized), plus some 
logic to enforce nagle marker skb. That stuff always works with unsent 
stuff anyway so it's much simpler to handle than skbs where we've already 
made some real commitments.

tcp_match_skb_to_sack tries to find the original mss boundaries that 
gso/tso generated and align into them if SACK range does contain 
non-aligned octets. Again, this is there to avoid pcount tweaks that would 
be necessary if we split to two skbs that have less than MSS sized tail 
part, and also to prevent receiver driven split to very small skbs 
attacks. ...Hopefully it also serves as an incentive to fix those 
middleboxes/end hosts which are in violation here by not maintaining the 
original packet boundaries :-).

However, now that I look it in this new light also tcp_match_skb_to_sack 
is subject to similar kind of bug, ie., it can fragment already 
shifted/merged skbs (although it's not that likely one would get a 
scenario to actually trigger that, requires partial re-SACK). Fixing this 
will be significantly more complicated though, and seems to require that 
sacktag logic inspects ->sacked much earlier making it again harder to 
follow :-(.


-- 
 i.
--8323329-692024168-1330939865=:2966--
