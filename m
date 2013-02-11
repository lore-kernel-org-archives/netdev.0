From: Dan Williams <dcbw@redhat.com>
Subject: Re: bridge interface initial carrier state
Date: Mon, 11 Feb 2013 16:46:41 -0600
Message-ID: <1360622801.8633.34.camel@dcbw.foobar.com>
References: <1360612915.8633.6.camel@dcbw.foobar.com>
	 <20130211135930.4cdad83c@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:46340 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932782Ab3BKWqn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 Feb 2013 17:46:43 -0500
In-Reply-To: <20130211135930.4cdad83c@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2013-02-11 at 13:59 -0800, Stephen Hemminger wrote:
> On Mon, 11 Feb 2013 14:01:55 -0600
> Dan Williams <dcbw@redhat.com> wrote:
> 
> > Hi,
> > 
> > I'm wondering if the initial carrier state of 'on' is intentional for a
> > bridge without ports; immediately after adding ports, the carrier is
> > recalculated and depends on the combined state of each port's carrier
> > and STP forwarding state.  So a userspace program attempting to decide
> > whether the bridge was usable or not has to look at both (a) how many
> > ports are available and (b) bridge carrier state, instead of just
> > looking at the bridge carrier state.
> > 
> > Dan
> 
> Perhaps a future enhancement of bridge would be to use operstate flags
> to indicate lower layer down if there are no ports.

While we're at it, it appears that if a bridge port is added when it has
no carrier, nothing directly triggers br_port_state_selection() to
ensure that the bridge's carrier state is correct:

	if ((dev->flags & IFF_UP) && netif_carrier_ok(dev) &&
	    (br->dev->flags & IFF_UP))
		br_stp_enable_port(p);

Any reason why we can't run br_port_state_selection() unconditionally
when adding a new port?  When removing a port that gets run by
br_stp_disable_port(), which is somewhat asymmetrical.

When adding, we don't necessarily want to enable STP operation on the
port until it's ready, so that hunk above for br_stp_enable_port() is
probably just fine, but we should still probably be recalculating the
bridge's carrier when it gets its first port even if that port isn't yet
usable?  Or not?

Dan
