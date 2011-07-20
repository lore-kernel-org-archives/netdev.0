From: Dan Williams <dcbw@redhat.com>
Subject: Re: IPv6: autoconfiguration and suspend/resume or link down/up
Date: Wed, 20 Jul 2011 11:21:43 -0500
Message-ID: <1311178905.21004.9.camel@dcbw.foobar.com>
References: <20110719180222.GA7509@midget.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Herbert Xu <herbert@gondor.hengli.com.au>,
	"David S. Miller" <davem@davemloft.net>,
	stephen hemminger <shemminger@vyatta.com>
To: Jiri Bohac <jbohac@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:54970 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752458Ab1GTQSF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Jul 2011 12:18:05 -0400
In-Reply-To: <20110719180222.GA7509@midget.suse.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2011-07-19 at 20:02 +0200, Jiri Bohac wrote:
> Hi,
> 
> I came over a surprising behaviour with IPv6 autoconfiguration,
> which I think is a bug, but I would first like to hear other
> people's opinions before trying to fix this:
> 
> Problem 1: all the address/route lifetimes are kept in jiffies
> and jiffies don't get incremented on resume. So when a
> route/address lifetime is 30 minutes and the system resumes after
> 1 hour, the route/address should be considered expired, but it is
> not.
> 
> Problem 2: when a system is moved to a new network a RS is not
> sent. Thus, IPv6 does not autoconfigure until the router sends a
> periodic RA. This can occur both while the system is alive and
> while it is suspended. I think the autoconfigured state should be
> discarded when the kernel suspects the system could have been
> moved to a different network.
> 
> When the cable is unplugged and plugged in again, we already get
> notified through linkwatch -> netdev_state_change ->
>   -> call_netdevice_notifiers(NETDEV_CHANGE, ...)
> However, if the device has already been autoconfigured,
> addrconf_notify() only handles this event by printing a
> message.
> 
> So my idea was to:
> - handle link up/down in addrconf_notify() similarly to
>   NETDEV_UP/NETDEV_DOWN
> 
> - on suspend, faking a link down event; on resume, faking a link up event
>   (or better, having a special event type for suspend/resume)
> 
> This would cause autoconfiguration to be restarted on resume as
> well as cable plug/unplug, solving both the above problems.

Faking a link event seems like a hack.  We had this problem with the
wifi stack a while ago where the current AP list wasn't expired on
wakeup so it still looked like the APs that were there when you went to
sleep were there when you resumed even if you'd moved 100 miles.  What
we did there was save the current time (using get_seconds()) when
suspending, and in the resume handler use that value to age anything
that needs to know about time spent in suspend, and then do what needs
to be done with that.  So something like that may work for IPv6
addrconf; on suspend save current time, and on resume check the current
time, subtract the time you saved on suspend, and magically add that to
the lifetime counts and then run any expiry stuff.

Dan

