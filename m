From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net-next] ipv6: recreate ipv6 link-local addresses when
 increasing MTU over IPV6_MIN_MTU
Date: Mon, 26 Oct 2015 17:05:01 +0100
Message-ID: <1445875501.168420.420547673.4BB6C209@webmail.messagingengine.com>
References: <1445870205-27202-1-git-send-email-hannes@stressinduktion.org>
 <562E4C26.3030501@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: Alexander Duyck <alexander.duyck@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out3-smtp.messagingengine.com ([66.111.4.27]:38012 "EHLO
	out3-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751475AbbJZQFC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Oct 2015 12:05:02 -0400
Received: from compute6.internal (compute6.nyi.internal [10.202.2.46])
	by mailout.nyi.internal (Postfix) with ESMTP id D47F3202CC
	for <netdev@vger.kernel.org>; Mon, 26 Oct 2015 12:05:01 -0400 (EDT)
In-Reply-To: <562E4C26.3030501@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Alex,

On Mon, Oct 26, 2015, at 16:52, Alexander Duyck wrote:
> On 10/26/2015 07:36 AM, Hannes Frederic Sowa wrote:
> > Take into consideration that the interface might be disabled for IPv6,
> > thus switch event type.
> >
> > Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
> > ---
> >   net/ipv6/addrconf.c | 7 +++++--
> >   1 file changed, 5 insertions(+), 2 deletions(-)
> >
> > diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
> > index d0c685c..c2dcebe 100644
> > --- a/net/ipv6/addrconf.c
> > +++ b/net/ipv6/addrconf.c
> > @@ -3149,6 +3149,7 @@ static int addrconf_notify(struct notifier_block *this, unsigned long event,
> >   
> >   	case NETDEV_UP:
> >   	case NETDEV_CHANGE:
> > +netdev_change:
> >   		if (dev->flags & IFF_SLAVE)
> >   			break;
> >   
> > @@ -3244,8 +3245,10 @@ static int addrconf_notify(struct notifier_block *this, unsigned long event,
> >   
> >   		if (!idev && dev->mtu >= IPV6_MIN_MTU) {
> >   			idev = ipv6_add_dev(dev);
> > -			if (!IS_ERR(idev))
> > -				break;
> > +			if (!IS_ERR(idev)) {
> > +				event = NETDEV_UP;
> > +				goto netdev_change;
> > +			}
> >   		}
> >   
> >   		/*
> 
> Seems like this code isn't quite correct.  You are calling ipv6_add_dev 
> for slave devices, and if I understand things correctly I don't believe 
> that was happening before and may be an unintended side effect.

Hmm, could you quickly help me where I get into this situation? I made
sure I enter the NETDEV_UP part before the IFF_SLAVE test and
disable_ipv6 test.

> You might want to instead just make it so that you only do the jump, and 
> perhaps change the code in the NETDEV_UP/NETDEV_CHANGE section so that 
> you test for NETDEV_CHANGE instead of NETDEV_UP.  That should be enough 
> to get the effect you are looking for and I believe there would be no 
> change to behaviour other than adding IPv6 link-local addresses when the 
> MTU is increased.
> 
> Give me a bit and I can submit an alternative that may actually work out 
> a bit better I think.

If you go the NETDEV_CHANGE route instead of NETDEV_UP, you end up with
the IF_READY flag already set from ipv6_add_dev and thus won't do any
initialization of the device.

Sure, I wait.

Bye,
Hannes
