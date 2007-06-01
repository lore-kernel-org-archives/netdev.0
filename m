From: "Laurent Chavey" <chavey@google.com>
Subject: Re: [PATCH]: bonding: Fix 802.3ad no carrier on "no partner found" instance
Date: Fri, 1 Jun 2007 10:56:46 -0700
Message-ID: <97949e3e0706011056u4fcf9b88k7d1476a85daf3630@mail.gmail.com>
References: <97949e3e0706010933h6921ca72p9858daa229bcfce6@mail.gmail.com>
	 <9575.1180719013@death>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "Jay Vosburgh" <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.33.17]:15890 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760823AbXFAR5D (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Jun 2007 13:57:03 -0400
Received: from spaceape13.eur.corp.google.com (spaceape13.eur.corp.google.com [172.28.16.147])
	by smtp-out.google.com with ESMTP id l51Huw9T031257
	for <netdev@vger.kernel.org>; Fri, 1 Jun 2007 18:56:58 +0100
Received: from wr-out-0506.google.com (wrai4.prod.google.com [10.54.60.4])
	by spaceape13.eur.corp.google.com with ESMTP id l51HudCD003634
	for <netdev@vger.kernel.org>; Fri, 1 Jun 2007 18:56:48 +0100
Received: by wr-out-0506.google.com with SMTP id i4so605639wra
        for <netdev@vger.kernel.org>; Fri, 01 Jun 2007 10:56:47 -0700 (PDT)
In-Reply-To: <9575.1180719013@death>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 6/1/07, Jay Vosburgh <fubar@us.ibm.com> wrote:
> Laurent Chavey <chavey@google.com> wrote:
>
> >On 5/31/07, Laurent Chavey <chavey@google.com> wrote:
> >> if a host configured with 802.3ad bond mode is connected to a switch
> >> that does not support 802.3ad,  then an aggregator is selected as the
> >> active aggregator (first link that has carrier in the slave list).
> >> This is perfectly fine, since it lets at least one of the link become active.
> >> (this was the behavior prior to 2.6.18)
> >>
> >> In 2.6.18 and above, a new check for the partner mac address was added
> >> before an aggregator's carrier is set on. If a host is  configured as
> >> previously
> >> described,  then no links will become active.
> >>
> >> is that the intended behavior ?
>
>         Prior to the change in question, the carrier state of the master
> device was always on, regardless of the state of the slaves (so even if
> things didn't work, bonding would claim to be up).

looking at the code, this will only work if there is an actual active
aggregator. If that is not the case, and as you mention there could
be an active aggregator before completing all LACP pahses (on all the slaves)
then we would need to add a check (not for the mac) but for the churned state.
(I added a churned state machine that could be use there, I did not submit
the patch yet)

>
>         My concern specifically was more with failures in negotiation
> with 802.3ad capable peers, not for interoperability with non-802.3ad
> devices (since bonding can always be run in a non-802.3ad mode).
agree. This re-inforces that we should use the churned state

>
>         This behavior (don't pass traffic if no 802.3ad setup occurs)
> also parallels the behavior of the Cisco switches I use to test bonding
> (they will not pass traffic across ports of a lacp channel-group if the
> 802.3ad negotation does not occur), so it seemed appropriate.
yop, but the switch has to be configured with LACP support.
>
>         I'm checking the standard to see what it says, but I'm also
> curious if this has some real-world impact, or is just something you
> happened across?
this is the case when a switch is not configured with LACP support, and
a host is attached to it. this is something that happens in a pre release
environment where a host is tested  (using a switch that has no LACP support).
The host is then moved to its "real" rack (where the switch has LACP). The host
is not re-configured between the 2 steps (bonding is always enabled with
802.3ad mode)

>
>         -J
>
> ---
>         -Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
>
