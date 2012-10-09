From: Andre Tomt <andre@tomt.net>
Subject: Re: [PATCH net] e1000e: Change wthresh to 1 to avoid possible Tx
 stalls.
Date: Wed, 10 Oct 2012 00:48:42 +0200
Message-ID: <5074A9CA.50308@tomt.net>
References: <20120606174355.823e9aa7.shimoda.hiroaki@gmail.com> <1339030752.2075.1.camel@jtkirshe-mobl> <1339043085.26966.77.camel@edumazet-glaptop> <1339044752.2075.14.camel@jtkirshe-mobl> <loom.20121009T020718-563@post.gmane.org> <1349762863.21172.3848.camel@edumazet-glaptop> <20121009103629.0000569a@unknown>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Frank Reppin <frank@undermydesk.org>, netdev@vger.kernel.org,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	e1000-devel@lists.sourceforge.net
To: Jesse Brandeburg <jesse.brandeburg@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from catastrophix.ugh.no ([178.79.162.34]:46428 "EHLO
	catastrophix.ugh.no" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755993Ab2JIWss (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Oct 2012 18:48:48 -0400
In-Reply-To: <20121009103629.0000569a@unknown>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09. okt. 2012 19:36, Jesse Brandeburg wrote:
> I'm not sure what went wrong internally here that this hasn't been
> fixed, and I'm personally embarrassed.  I am working on it until I have
> a patch/solution.
>
> currently am trying to reproduce the issue, am in some weird how to
> use BQL limbo, the lack of documentation on user usage of BQL is slowing
> me down.
>
> Hints or clues (I'm trying to follow the repro steps mentioned in
> some related threads) are appreciated.

I found it simplest to reproduce when doing forwarding, and *not* 
saturating the interface doing the TX. 100Mbps forwarding on gigabit 
link triggered it in seconds. Doing gigabit forwarding speeds (~980Mbps) 
did not trigger anything.

Setup looked somewhat like this, GE beeing gigabit link, FE 100Mbps;

reciever PC (iperf -s)
     |
     GE
     |
    eth0   <- TX lockups
router with 2*e1000e
    eth1
     |
     GE
     |
switch
     |
     FE
     |
source PC (iperf -c recieverPC)

I don't recall all the details anymore, but I'm fairly certain I didnt 
use any non-default qdiscs to reproduce - eg just pfifo_fast (usually 
doing fq_codel though).

For the bug to manifest itself was somewhat dependent on GRO and TSO in 
kernel 3.5, but with 3.6 it didnt matter anymore (at least the rc's).
