From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: [RFC] New driver API to speed up small packets xmits
Date: Fri, 18 May 2007 00:04:08 -0700
Message-ID: <1551EAE59135BE47B544934E30FC4FC094012F@nt-irva-0751.brcm.ad.broadcom.com>
References: <20070515.142821.42775365.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: rdreier@cisco.com, ak@suse.de, krkumar2@in.ibm.com,
	netdev@vger.kernel.org
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:3707 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755271AbXERHEq convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 May 2007 03:04:46 -0400
Content-class: urn:content-classes:message
In-Reply-To: <20070515.142821.42775365.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller wrote:

> From: "Michael Chan" <mchan@broadcom.com>
> Date: Tue, 15 May 2007 15:05:28 -0700
> 
> > For each gso_seg, there will be a header and the payload may span 2
> > pages for 1500-byte packets.  We always assume 1500-byte packets
> > because the buggy chips do not support jumbo frames.
> 
> Correct.
> 
> I think there may be a case where you could see up to 4 segments.
> If the user corks the TCP socket, does a sendmsg() (which puts
> the data in the per-socket page) then does a sendfile() you'll
> see something like:
> 
> skb->data	IP, TCP, ethernet headers, etc.
> page0		sendmsg() data
> page1		sendfile
> page2		sendfile
> 
> Ie. this can happen if the sendfile() part starts near the
> end of a page, so it would get split even for a 1500 MTU
> frame.
> 
> Even more complex variants are possible if the user does
> tiny sendfile() requests to different pages within the file.
> 
> So in fact it can span up to N pages.
> 
> But there is an upper limit defined by the original GSO
> frame, and that is controlled by MAX_SKB_FRAGS, so at most
> you would see MAX_SKB_FRAGS plus some small constant.
> 
> 

I see.  Is the following a better estimate?

(gso_segs * 2) + skb_shinfo(skb)->nr_frags

For each gso_seg, you get at least a header segment and a
segment from a page for 1500-byte packets.  You can get more
segments if packets cross page boundaries or if there are tiny
sendfile pages or some sendmsg pages mixed in.  But these
additional segments will never be more than nr_frags.

