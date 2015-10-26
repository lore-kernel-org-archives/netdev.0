From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net-next] ipv6: recreate ipv6 link-local addresses when
 increasing MTU over IPV6_MIN_MTU
Date: Mon, 26 Oct 2015 18:21:11 +0100
Message-ID: <1445880071.1081871.420626089.581A7ED3@webmail.messagingengine.com>
References: <1445870205-27202-1-git-send-email-hannes@stressinduktion.org>
 <562E4C26.3030501@gmail.com>
 <1445875501.168420.420547673.4BB6C209@webmail.messagingengine.com>
 <562E5DD4.40908@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: Alexander Duyck <alexander.duyck@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out3-smtp.messagingengine.com ([66.111.4.27]:34550 "EHLO
	out3-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752126AbbJZRVL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Oct 2015 13:21:11 -0400
Received: from compute3.internal (compute3.nyi.internal [10.202.2.43])
	by mailout.nyi.internal (Postfix) with ESMTP id 6907A208E9
	for <netdev@vger.kernel.org>; Mon, 26 Oct 2015 13:21:11 -0400 (EDT)
In-Reply-To: <562E5DD4.40908@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Alex,

On Mon, Oct 26, 2015, at 18:07, Alexander Duyck wrote:
> >> Seems like this code isn't quite correct.  You are calling ipv6_add_dev
> >> for slave devices, and if I understand things correctly I don't believe
> >> that was happening before and may be an unintended side effect.
> > Hmm, could you quickly help me where I get into this situation? I made
> > sure I enter the NETDEV_UP part before the IFF_SLAVE test and
> > disable_ipv6 te
> 
> I think I was getting a bit a head of myself.  I was looking over the 
> NETDEV_UP code and thinking that we could just fall into that path since 
> it is already calling ipv6_add_dev.  However now I am wondering if maybe 
> we need to look at adding an idev allocation somewhere before the 
> disable_ipv6 check.  I assume that is why you were allocating the idev 
> before you were getting into NETDEV_UP?

The original bug report was:

If user reduces the MTU below IPV6_MIN_MTU we addrconf_ifdown the
interface but don't reinitialize the interface if the MTU is increased
later on.

> >> You might want to instead just make it so that you only do the jump, and
> >> perhaps change the code in the NETDEV_UP/NETDEV_CHANGE section so that
> >> you test for NETDEV_CHANGE instead of NETDEV_UP.  That should be enough
> >> to get the effect you are looking for and I believe there would be no
> >> change to behaviour other than adding IPv6 link-local addresses when the
> >> MTU is increased.
> >>
> >> Give me a bit and I can submit an alternative that may actually work out
> >> a bit better I think.
> > If you go the NETDEV_CHANGE route instead of NETDEV_UP, you end up with
> > the IF_READY flag already set from ipv6_add_dev and thus won't do any
> > initialization of the device.
> 
> What I meant was that you don't need to change the event.  If you change 
> the check inside the NETDEV_UP/CHANGE code path so that it tests for 
> event != NETDEV_CHANGE instead of event == NETDEV_UP you don't need to 
> change the event type.

Yeah, that would be possible, too. I just find an equal easier to
follow. ;)

> > Sure, I wait.
> 
> Might be a bit longer.  I just realized that I think there is another 
> bug here where you are going through the NETDEV_UP path even though the 
> interface isn't up.  I'll run through some testing this morning to work 
> out the kinks.

Ok, cool. I have a look at it again, too.

Bye,
Hannes
