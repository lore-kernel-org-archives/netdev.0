From: "=?ISO-8859-15?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [PATCH] tcp: detect loss above high_seq in recovery
Date: Fri, 30 Dec 2011 13:19:18 +0200 (EET)
Message-ID: <alpine.DEB.2.00.1112301256060.15137@wel-95.cs.helsinki.fi>
References: <1325033182-25905-1-git-send-email-ycheng@google.com> <alpine.DEB.2.00.1112281736480.7752@melkinpaasi.cs.helsinki.fi> <CAK6E8=fu_KAnzMhKYa368BzhGkLGtjjPhvDUezQ_b6Nsd5o6Zw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="8323329-2023122206-1325243958=:15137"
Cc: David Miller <davem@davemloft.net>, ncardwell@google.com,
	nanditad@google.com, Netdev <netdev@vger.kernel.org>
To: Yuchung Cheng <ycheng@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:49975 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751459Ab1L3LTU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Dec 2011 06:19:20 -0500
In-Reply-To: <CAK6E8=fu_KAnzMhKYa368BzhGkLGtjjPhvDUezQ_b6Nsd5o6Zw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--8323329-2023122206-1325243958=:15137
Content-Type: TEXT/PLAIN; charset=iso-8859-1
Content-Transfer-Encoding: 8BIT

On Thu, 29 Dec 2011, Yuchung Cheng wrote:

> Ilpo,
> On Wed, Dec 28, 2011 at 7:42 AM, Ilpo Järvinen
> <ilpo.jarvinen@helsinki.fi> wrote:
> >
> > On Tue, 27 Dec 2011, Yuchung Cheng wrote:
> > > The new sequences sent during fast-recovery maybe marked as lost
> > > and/or retransmitted. It is possible these (new) losses are recovered
> > > within the current fast recovery and the state moves back to CA_Open
> > > without entering another fast recovery / cwnd redunction. This is
> > > especially possible for light losses.  Note RFC 3517 (implicitly)
> > > allows this as well.
> >
> > No it doesn't! It does not allow you to avoid the second cwnd reduction.
> > They're from different RTT. What you now claim is that we never need to
> > do cwnd reduction until we visit CA_Open in between. That's very very
> > dangerous if the congestion suddently spikes because nobody reduces twice
> > causing everyone to get losses and continues in the recovery forever.
> 
> Should TCP perform another CWR for sequences lost after recovery point?
> my colleagues and I all agree with you it should.

I agree, and it seems that neither Linux nor RFC3517 does this right
(I should have read the RFC more carefully instead just trust my own 
guesswork. It seems that there's instead this corner case not covered in 
the RFC correctly, probably because it would require rexmit loss that 
forces RTO with standard TCP or reordering).

> But my commit message did a poor job explain some subtle deviations in 
> standard and current Linux.

Right, I though you're changing (removing) the second reduction based on 
the commit message as I didn't have time to go through enough code. But it 
seems that it is pre-existing issue.

> RFC3517 supports this by principle; however, it may repair such new data 
> losses in the current recovery: Rue 1.b and 1.c in NextSeg() allow 
> retransmitting any segment below highest sacked sequence. Thus it may 
> repair every loss in the current recovery and won't never go into 
> another.

I suppose we should be moving high_seq (RecoveryPoint) to the snd_nxt when 
we retransmit something above high_seq and initiate the addition reduction 
using PRR. It won't be accurately measuring the next RTT though as rexmits 
and new data were mixed during the first recovery RTT but I suppose it's 
still good enough approximation.

> As a matter of fact, Linux already does that today, by implementing rule 3 in
> NextSeg(), aka forward-retransmit. But Linux won't mark these packets 
> lost even if there are >= tp->reordering packets sacked above. This 
> change fixes this.

I was thinking there used to be seq < high_seq condition in the rexmit 
loop but it seems that it either got dropped or I remember wrong. That 
would have prevented forward rexmits past the boundary.

> How often is second CWR avoided? it's probably rare b/c it requires new data
> during the recovery RTT and a complete repair any losses of them. It's 
> arguably OK to fix small new data losses during current recovery, and 
> RFC/Linux seem to do so.

There's one significant difference here: For RFC this is includes only 
some trivial reordering cases, but with Linux we can handle lost rexmits, 
making it more likely to happen (they would require RTO & its consequences 
with RFC/Std TCP if we assume no reordering cumulative ACKs end the 
previous recovery and the next one immediately gets triggered).

> To summarize:
> 1) this change does NOT forbid TCP performing further CWR on new losses
> 2) this change (merely) marks some forward-retransmitted packets LOST.
> 3) the commit message is to be explicit that CWR may not always be performed,
>     in both my change and current kernel.

I agree with these points. I wonder if you intend to look to fixing the 
lacking CWR problem or should I look to that once I get some spare time?

> HTH. I will update commit message if people can make sense of it :)

Please do.

-- 
 i.
--8323329-2023122206-1325243958=:15137--
