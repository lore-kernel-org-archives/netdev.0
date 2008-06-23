From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: bnx2_poll panicking kernel
Date: Mon, 23 Jun 2008 15:48:39 -0700
Message-ID: <48602847.1020203@broadcom.com>
References: <20080621113406.5f89ae8d.billfink@mindspring.com>
 <C27F8246C663564A84BB7AB343977242019B6FEC8E@IRVEXCHCCR01.corp.ad.broadcom.com>
 <20080623180439.GA18829@orion.carnet.hr>
 <20080623213657.GA26447@orion.carnet.hr>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: "'Bill Fink'" <billfink@mindspring.com>,
	"Ben Hutchings" <bhutchings@solarflare.com>,
	netdev <netdev@vger.kernel.org>,
	"mirrors@debian.org" <mirrors@debian.org>
To: "Josip Rodin" <joy@entuzijast.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:4764 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751699AbYFWWqf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 23 Jun 2008 18:46:35 -0400
In-Reply-To: <20080623213657.GA26447@orion.carnet.hr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Josip Rodin wrote:
> On Mon, Jun 23, 2008 at 08:04:39PM +0200, Josip Rodin wrote:
>> Oh, duh, yes, I'm a moron. It's back on now, sorry about that.
> 
> There we go, I got the debugging messages:
> 
> [...]
> Jun 23 19:53:18 arrakis kernel: HTB: quantum of class 10100 is big. Consider r2q change.
> Jun 23 22:57:55 arrakis kernel: bnx2: skb->nr_frags=1 is corrupted, should be 4
> Jun 23 22:58:32 arrakis kernel: bnx2: skb->nr_frags=1 is corrupted, should be 2
> Jun 23 22:59:02 arrakis kernel: bnx2: skb->nr_frags=1 is corrupted, should be 3
> Jun 23 22:59:23 arrakis kernel: bnx2: skb->nr_frags=1 is corrupted, should be 9
> Jun 23 22:59:36 arrakis kernel: bnx2: skb->nr_frags=1 is corrupted, should be 3
> Jun 23 23:08:19 arrakis kernel: bnx2: skb->nr_frags=1 is corrupted, should be 3
> 

OK, this definitely confirms the theory that the skb->nr_frags is changed
between ->hard_start_xmit() and tx completion.  Since we rely on nr_frags to
locate the packet boundaries in the tx ring, it would definitely crash.

One possibility is that it is corrupted by the driver and only happens when
there are HTB rules.  I think this is unlikely.

TG3 which operates the same way has also been reported to crash in the
presence of HTB rules.  We were not able to pinpoint the problem at that
time.

Can anyone think of a scenario where the stack can modify the SKB this way?
These SKBs look like they are TSO packets.  

If not, I will send Josip another patch to print more SKB fields.  I can
even save all the SKB fields and see which other ones are modified besides
the nr_frags.  May be that will give us a better clue.

Thanks.

