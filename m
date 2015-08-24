From: Andy Fleming <afleming@gmail.com>
Subject: Re: [PATCH] net: phy: fix PHY_RUNNING in phy_state_machine
Date: Mon, 24 Aug 2015 00:35:09 -0500
Message-ID: <CAKWjMd4+CFZsdKvHXk201x_EKY-fQR7YUVtvhfZ8DpsimHDPAg@mail.gmail.com>
References: <1439526220-31458-1-git-send-email-shh.xie@gmail.com>
	<20150817.121834.1051074493425670431.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: shh.xie@gmail.com,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Shaohui Xie <Shaohui.Xie@freescale.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f182.google.com ([209.85.213.182]:36885 "EHLO
	mail-ig0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750725AbbHXFfK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Aug 2015 01:35:10 -0400
Received: by igui7 with SMTP id i7so48689939igu.0
        for <netdev@vger.kernel.org>; Sun, 23 Aug 2015 22:35:09 -0700 (PDT)
In-Reply-To: <20150817.121834.1051074493425670431.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 17, 2015 at 2:18 PM, David Miller <davem@davemloft.net> wrote:
>
> From: <shh.xie@gmail.com>
> Date: Fri, 14 Aug 2015 12:23:40 +0800
>
> > From: Shaohui Xie <Shaohui.Xie@freescale.com>
> >
> > Currently, if phy state is PHY_RUNNING, we always register a CHANGE
> > when phy works in polling or interrupt ignored, this will make the
> > adjust_link being called even the phy link did Not changed.
> >
> > checking the phy link to make sure the link did changed before we
> > register a CHANGE, if link did not changed, we do nothing.
> >
> > Signed-off-by: Shaohui Xie <Shaohui.Xie@freescale.com>
>
> Applied, thank you.

My 3rd attempt to send this, so I apologize. Hopefully this final
attempt is finally in plain text. Clearly, it's been a while...

Florian had some good objections to this patch. Doing a PHY status
read is a very time-consuming operation to do every iteration (it's
probably thousands of cycles), and the idea is supposed to be that the
read only happens in the PHY_CHANGELINK state. Every cycle of the
state machine will read the status, and a change will require that the
status be read twice. Worst of all, if you were to change between two
links quickly, the state machine will NEVER notice the change, because
it is only looking for the link up/down state to change.

One solution might be to modify genphy_read_status() so that it
doesn't do the dummy read up front to clear the sticky low bit. This
*might* make it so that PHY_RUNNING always catches a link change. What
I'm not 100% sure of is whether you can guarantee that any link change
will require the link to first go down. We'd have to read the spec,
though I suspect this would work. The other concern with this solution
is that something might be depending on the old behavior. Certainly
phy_change() would need to make sure to do that "dummy" read sometime
after interrupts are enabled.

Another solution is to revert this patch, and modify adjust_link()
functions to only make changes if the state has changed (They all
should be doing this, anyway, but I can imagine that some
drivers/devices might have difficulty determining what's changed).

Anyone have other ideas? I'm happy to implement the first solution,
but I should note I don't have a lot of test hardware these days.

Andy
