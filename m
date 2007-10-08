From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [RFC][PATCH 1/2] TCP: fix lost retransmit detection
Date: Mon, 8 Oct 2007 14:11:55 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0710081258440.31129@kivilampi-30.cs.helsinki.fi>
References: <20071004.184519.16476818.takano@axe-inc.co.jp>
 <Pine.LNX.4.64.0710041419560.31129@kivilampi-30.cs.helsinki.fi>
 <20071007.145100.00679926.takano@axe-inc.co.jp>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; boundary="-696243703-18623633-1191838383=:31129"
Cc: Netdev <netdev@vger.kernel.org>, y-kodama@aist.go.jp
To: TAKANO Ryousei <takano@axe-inc.co.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:53925 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753424AbXJHLL7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Oct 2007 07:11:59 -0400
In-Reply-To: <20071007.145100.00679926.takano@axe-inc.co.jp>
Content-ID: <Pine.LNX.4.64.0710081313180.31129@kivilampi-30.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696243703-18623633-1191838383=:31129
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT
Content-ID: <Pine.LNX.4.64.0710081313181.31129@kivilampi-30.cs.helsinki.fi>

On Sun, 7 Oct 2007, TAKANO Ryousei wrote:

> From: "Ilpo Järvinen" <ilpo.jarvinen@helsinki.fi>
> Subject: Re: [RFC][PATCH 1/2] TCP: fix lost retransmit detection
> Date: Fri, 5 Oct 2007 13:02:07 +0300 (EEST)
> 
> > On Thu, 4 Oct 2007, TAKANO Ryousei wrote:
> > 
> > In case sacktag uses fastpath, this code won't be executed for the skb's 
> > that we would like to check (those with SACKED_RETRANS set, that are 
> > below the fastpath_skb_hint). We will eventually deal with the whole queue 
> > when fastpath_skb_hint gets set to NULL, with the next cumulative ACK that 
> > fully ACKs an skb at the latest. Maybe there's a need for a larger surgery 
> > than this to fix it. I think we need additional field to tcp_sock to avoid 
> > doing a full-walk per ACK:
>
> I think the problem occurs in slowpath. For example, in case when the receiver
> detects and sends back a new SACK block, the sender may fail to detect loss
> of a retransmitted packet.

...No, the slow path is very likely to _correct_ the problem! The problem 
occurs because fastpath _skips_ processing of skbs below fastpath_skb_hint 
whereas slowpath starts from tcp_write_queue_head. The retransmitted skbs 
we're interested in reside exactly on that skipped range.

Currently fastpath_skb_hint is cleared rather often when it would not be 
mandatory, e.g., when a cumulative ACK arrives, thus slow-path is forced 
often enough for this problem to not show up too often in any real 
scenario, yet it's broken as is and should be fixed. ...It's actually 
something which is on a way for any solution which reduces the number of 
walked skb per ACK.

> > In future, please base your work to current development tree instead of 
> > linus' tree (net-2.6.24 at this point of time, there's also tcp-2.6 but 
> > it's currently a bit outdated).
> 
> Thanks for your suggestion. SACK processing has a heavy workload and 
> it is complex. I agree to make efforts toward a more generic solution. 
> Your recv_sack_cache patch seems valuable.

Agreed, and as is, it's getting more and more expensive to do. The current 
code is doing more and more processing compared to how much new SACK 
information was actually received. ...However, doing a large surgery like 
that and maintaining full correctness at the same time scares me a bit...


-- 
 i.
---696243703-18623633-1191838383=:31129--
