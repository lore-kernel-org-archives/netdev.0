From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [RFC PATCHv5 1/5] [TCP]: Add highest_sack seqno, points to
 globally highest SACK
Date: Tue, 27 Mar 2007 00:43:41 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0703262357080.10147@kivilampi-30.cs.helsinki.fi>
References: <11740704662337-git-send-email-ilpo.jarvinen@helsinki.fi>
 <20070324.210428.78711276.davem@davemloft.net>
 <Pine.LNX.4.64.0703260034120.9398@kivilampi-30.cs.helsinki.fi>
 <20070325.183522.15263841.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; boundary="-696243703-1998813461-1174944037=:10147"
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:47539 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932950AbXCZVnn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Mar 2007 17:43:43 -0400
In-Reply-To: <20070325.183522.15263841.davem@davemloft.net>
Content-ID: <Pine.LNX.4.64.0703270021010.10147@kivilampi-30.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696243703-1998813461-1174944037=:10147
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT
Content-ID: <Pine.LNX.4.64.0703270021011.10147@kivilampi-30.cs.helsinki.fi>

On Sun, 25 Mar 2007, David Miller wrote:

> From: "Ilpo_Järvinen" <ilpo.jarvinen@helsinki.fi>
> Date: Mon, 26 Mar 2007 00:55:57 +0300 (EEST)
> 
> > On Sat, 24 Mar 2007, David Miller wrote:
> > 
> > > From: "Ilpo_Järvinen" <ilpo.jarvinen@helsinki.fi>
> > >
> > > > It is guaranteed to be valid only when !tp->sacked_out. In most
> > > > cases this seqno is available in the last ACK but there is no
> > > > guarantee for that. The new fast recovery loss marking algorithm
> > > > needs this as entry point.
> > > 
> > > It's a shame we keep around multiple values which represent very
> > > related values.  For example, this new seqno could be computed
> > > using "fackets_out" if we knew also how many holes there were.
> > 
> > It would then be an estimate which is 100% accurate in most cases (when 
> > all related skbs are full sized). I think it must never underestimate 
> > highest_sack though, it would be quite ok to use fackets_out * mss but
> > any > mss skb would obviously be a problem (if they ever occur)... 
> > Are all paths ok with that (this is beoynd the codepaths I'm quite 
> > sure of...)?!

I was being overly broad here, of course these happen with gso, but the 
point was to say if skb's pcount * current mss < size of the skb, using 
fackets_count to estimate highest sack is problematic... At least path MTU 
discovery comes to my mind as a potential problematic case since it's 
playing with sizing but as I said, I'm not sure if it is bad after all...

> Right, I understand that we really can't even use such an estimate
> because of the "full mss size" assumption.

Are you sure of this "can't"?

I think the LOST marking algorithm can safely be used if highest_sack is 
never underestimated... As long as the search begins at or a point after 
the real highest_sack, the highest SACK block can be located by walking 
until the first SACKED_ACKED is found or TCP encounters a LOST skb (due to 
an earlier timedout).

Overestimating just means some extra backwards walking in the queue (and 
couple lines of code :-))... Of course care should be taken that the 
walk is never started from a sequence number that is after send_head... 
Also, if I understand your queue_find code correctly, the case where 
send_head is pointing to nothing (TCP cannot check it's seqno :-)) and we 
overestimated, the find would return NULL. In such case, instead of doing 
queue_find, a correct thing would be to start from the last skb I think...


-- 
 i.
---696243703-1998813461-1174944037=:10147--
