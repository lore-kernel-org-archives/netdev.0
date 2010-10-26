From: Lorenzo Colitti <lorenzo@google.com>
Subject: Re: [PATCH] ipv6: addrconf: clear IPv6 addresses and routes when
 losing link
Date: Mon, 25 Oct 2010 22:44:03 -0700
Message-ID: <AANLkTinGpt=EQX3aXRaj5mEUMDNpyEapbs4VyOwgtN55@mail.gmail.com>
References: <AANLkTikC4pv8aOODM2pOg2bKQGL69wivcUU3f9ZziPhe@mail.gmail.com> <20101025213841.635b9a15@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([74.125.121.35]:37769 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751867Ab0JZFo0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Oct 2010 01:44:26 -0400
Received: from hpaq1.eem.corp.google.com (hpaq1.eem.corp.google.com [172.25.149.1])
	by smtp-out.google.com with ESMTP id o9Q5iOcn022251
	for <netdev@vger.kernel.org>; Mon, 25 Oct 2010 22:44:25 -0700
Received: from gyg10 (gyg10.prod.google.com [10.243.50.138])
	by hpaq1.eem.corp.google.com with ESMTP id o9Q5iNZ4018934
	for <netdev@vger.kernel.org>; Mon, 25 Oct 2010 22:44:24 -0700
Received: by gyg10 with SMTP id 10so2892840gyg.29
        for <netdev@vger.kernel.org>; Mon, 25 Oct 2010 22:44:23 -0700 (PDT)
In-Reply-To: <20101025213841.635b9a15@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 25, 2010 at 9:38 PM, Stephen Hemminger
<shemminger@vyatta.com> wrote:
> This is incorrect. When link is lost, routes and address should not be
> flushed. They should be marked as tentative and then go through DAD again
> on the new network.

That won't help the case I am trying to fix, which is the case where
the new link has a global prefix different than the old link. Marking
the addresses as tentative will simply make them pass DAD and come
back as soon as link comes back. But since they don't match the prefix
that is assigned to the new link, they are unusable, because packets
can't be routed back to them.

> If you do it this way, you break routing protocols when link is brought
> down and back up.

The only addresses and routes flushed in this way should be ones that
aren't manually configured, i.e., the ones created by autoconf
(addrconf.c:2720 onwards). These won't be used by routing protocols,
except for link-local addresses. So I assume you're talking about
link-local here.

Link-local addresses are immediately recreated in a tentative state as
soon as link comes back, because on NETDEV_UP addrconf_notify calls
addrconf_dev_config. So, this patch only makes it so that they become
tentative when link goes away and comes back. In that time, the router
that temporarily loses link is unable to send packets for the brief
period of time that the link is performing DAD, but if the router has
lost link, it will also fail to send the packet while link is lost.
What's the additional failure scenario? Will it help if I make it so
that link-local addresses aren't touched at all?
