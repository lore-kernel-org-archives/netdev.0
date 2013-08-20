From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH 1/3] net: add a new NETDEV_CHANGEROOM event type
Date: Tue, 20 Aug 2013 18:35:16 +0200
Message-ID: <1377016516.13829.17.camel@jlt4.sipsolutions.net>
References: <1377002752-4622-1-git-send-email-f.fainelli@gmail.com>
	 <1377002752-4622-2-git-send-email-f.fainelli@gmail.com>
	 <1377011818.13829.9.camel@jlt4.sipsolutions.net>
	 <CAGVrzcahRhYJM-1KcNDOoekKCetSZCN67hHQ0fgjndehZ=9EUw@mail.gmail.com>
	 (sfid-20130820_173131_746711_47EADE45)
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, amwang <amwang@redhat.com>,
	Jiri Pirko <jiri@resnulli.us>,
	Stephen Hemminger <stephen@networkplumber.org>,
	kaber <kaber@trash.net>, David Miller <davem@davemloft.net>,
	vyasevic <vyasevic@redhat.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([144.76.43.152]:55712 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751226Ab3HTQf1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Aug 2013 12:35:27 -0400
In-Reply-To: <CAGVrzcahRhYJM-1KcNDOoekKCetSZCN67hHQ0fgjndehZ=9EUw@mail.gmail.com> (sfid-20130820_173131_746711_47EADE45)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-08-20 at 16:30 +0100, Florian Fainelli wrote:

> > Also, maybe it would be worth doing it in one call? If you need to
> > change both, then you'd end up calling the notifier twice, which is less
> > efficient?
> 
> I have mixed feelings about this. I do not expect changing the
> headroom/tailroom to be in a hot-path, and we would need to have a
> name such as dev_set_head_and_tailroom() or something that clearly
> states that it operates on both quantities. Looking at the subsystems
> and drivers, there are quite a lot of users which only set one or the
> other, occasionaly both before registration.

No, it shouldn't be on a path that has any performance impact at all,
that's true.

> > I suppose you could make them 'int' arguments and reserve -1
> > for no changes, or just require both new values to be given (if doing
> > this at all.)
> 
> What I like about keeping them separate is that we can use the
> "native" storage type that is used in struct net_device, and have
> compile-time checking of this.

Makes sense.

I was really more thinking about the notifier complexity.

Right now, you can potentially blow up your iterations - for example if
you have a vlan on a bridge:
 * driver sets headroom (or tailroom)
 * this iterates all netdevs, including the bridge
 * bridge calls the function again, and while iterating iterates again,
then
   going into the vlan
   (is it even valid to iterate while iterating?)
 * vlan calls it again and it iterates again, doing nothing this time

So now you've iterated the netdevs many times...

johannes
