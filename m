From: Flavio Leitner <fbl@redhat.com>
Subject: Re: [PATCH net-next] bonding: fix wrong port enabling in 802.3ad
Date: Thu, 13 Oct 2011 15:20:31 -0300
Message-ID: <20111013152031.6e2ff168@asterix.rh>
References: <1318526483-16073-1-git-send-email-fbl@redhat.com>
	<18216.1318527991@death>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Andy Gospodarek <andy@greyhouse.net>
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:39888 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753553Ab1JMSUi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 13 Oct 2011 14:20:38 -0400
In-Reply-To: <18216.1318527991@death>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 13 Oct 2011 10:46:31 -0700
Jay Vosburgh <fubar@us.ibm.com> wrote:

> Flavio Leitner <fbl@redhat.com> wrote:
> 
> >The port shouldn't be enabled unless its current MUX
> >state is DISTRIBUTING which is correctly handled by
> >ad_mux_machine(), otherwise the packet sent can be
> >lost because the other end may not be ready.
> >
> >The issue happens on every port initialization, but
> >as the ports are expected to move quickly to DISTRIBUTING,
> >it doesn't cause much problem.  However, it does cause
> >constant packet loss if the other peer has the port
> >configured to stay in STANDBY (i.e. SYNC set to OFF).
> 
> 	This may explain another misbehavior I've been looking into: if
> the bond's outgoing LACPDUs are lost (never received by the switch), but
> the switch's incoming LACPDUs are received, bonding puts the port into
> use, and packets to the switch are dropped by the switch.
>

Yeah, it could explain that as well because on my tests here,
all ports were enabled as soon as the aggregator is active.

 
> >Signed-off-by: Flavio Leitner <fbl@redhat.com>
> >---
> >
> >The comments there suggests it was a workaround for losses
> >of link events, but I couldn't track the changelog as it
> >seems to be pretty old.  Thus, as all the link notification
> >stuff has been improved a lot, maybe this is not an issue
> >anymore.  At least, I didn't find any problem while
> >unplugging/plugging cables here.
> 
> 	I believe this code fragment is original to the 802.3ad
> submission, which would have been around 2003 or so.
> 
> 	Did you check the standard for what it says should happen in
> this case?  I'm guessing this is something not specified by the
> standard, given the comment, but we should check to make sure.
> 

The standard says that the port should receive when its mux state
is COLLECTING and transmitting when its mux state is DISTRIBUTING.
So, that seems to be violationing the standard because it doesn't
consider the mux state at all.  It is harmless for almost all cases
though, because ports move quickly to DISTRIBUTING or no link at
all, which disables the port.

fbl
