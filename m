From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH] pktgen: Clone skb to avoid corruption of skbs in
 ndo_start_xmit methods
Date: Thu, 21 Jul 2011 19:50:49 -0400
Message-ID: <20110721235049.GA29489@hmsreliant.think-freely.org>
References: <20110720151827.GD12349@hmsreliant.think-freely.org>
 <20110721.150107.25773992475689131.davem@davemloft.net>
 <4E28A4C8.8040707@candelatech.com>
 <20110721.151903.297506479006061401.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: greearb@candelatech.com, eric.dumazet@gmail.com, jpirko@redhat.com,
	netdev@vger.kernel.org, adobriyan@gmail.com,
	robert.olsson@its.uu.se
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:38198 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752716Ab1GUXvD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Jul 2011 19:51:03 -0400
Content-Disposition: inline
In-Reply-To: <20110721.151903.297506479006061401.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jul 21, 2011 at 03:19:03PM -0700, David Miller wrote:
> From: Ben Greear <greearb@candelatech.com>
> Date: Thu, 21 Jul 2011 15:14:32 -0700
>=20
> > On 07/21/2011 03:01 PM, David Miller wrote:
> >> From: Neil Horman<nhorman@tuxdriver.com>
> >> Date: Wed, 20 Jul 2011 11:18:27 -0400
> >>
> >>> On Wed, Jul 20, 2011 at 06:24:15AM +0200, Eric Dumazet wrote:
> >>>> Le mardi 19 juillet 2011 =E0 22:07 -0400, Neil Horman a =E9crit =
:
> >>>>>>
> >>>>> I think this is a good idea.  It lets pktgen dynamically make t=
he
> >>>>> clone/share
> >>>>> decision dynamically and only impacts performance for those sys=
tems.
> >>>>>
> >>>>
> >>>> Just let pktgen refuse to use clone_skb command for these device=
s.
> >>>>
> >>> copy that, This is by no means final, but what do you think of th=
is?
> >>> If its
> >>> agreeable to you, Ben, et al. I can add this to my local tree and
> >>> start auditing
> >>> all the drivers that may need to have the flag set.
> >>
> >> I think there is a much simpler solution.
> >>
> >> Set a flag in the SKB when pktgen does SKB sharing.
> >>
> >> In dev_queue_xmit() (or perhaps, dev_hard_start_xmit()), check the
> >> flag
> >> and if it's set then we copy the SKB.
> >>
> >> If this works, then we fix the crash and no driver changes are
> >> necessary both now and in the future.
> >=20
> > Doesn't that make clone-skb in pktgen much less efficient
> > in all cases?
>=20
> No, the copy only happens if we enter dev_queue_xmit() which pktgen
> doesn't do, it calls the driver's ->ndo_start_xmit() method directly.
>=20
> That's the whole idea.  Only these encapsulating software devices
> will trigger the condition.
>=20


I'm happy to go down this route Dave, and agree, its a more solid solut=
ion, but
I think the problem with it (which Ben may have been alluding to previo=
usly) is
that pktgen doesn't use dev_queue_xmit or dev_hard_start_xmit to send f=
rames.
It mimics the locking of dev_hard_start_xmit (but ignores the other che=
cks that
function does), and just calls the ndo_start_xmit routine of the driver
directly.  So theres no common code that an skb traverses from pktgen t=
o a given
driver where we can check such a flag

Again, I'm happy to change that so that pktgen uses dev_hard_start_xmit=
, but I
wonder if thats going to get the same sort of pushback about performanc=
e that my
origional patch did.  Eric, et al., thoughts?

Regards
Neil

