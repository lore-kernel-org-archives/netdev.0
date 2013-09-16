From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH net-next 2/2] bridge: fix NULL pointer deref of
 br_port_get_rcu
Date: Mon, 16 Sep 2013 11:32:42 -0700
Message-ID: <20130916113242.38562647@nehalam.linuxnetplumber.net>
References: <1379169748-767-1-git-send-email-zhiguohong@tencent.com>
	<1379169748-767-3-git-send-email-zhiguohong@tencent.com>
	<523746C6.3010700@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Hong Zhiguo <honkiko@gmail.com>, netdev@vger.kernel.org,
	davem@davemloft.net, eric.dumazet@gmail.com,
	Hong Zhiguo <zhiguohong@tencent.com>
To: vyasevic@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f52.google.com ([209.85.160.52]:63643 "EHLO
	mail-pb0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751762Ab3IPScr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Sep 2013 14:32:47 -0400
Received: by mail-pb0-f52.google.com with SMTP id wz12so4424146pbc.11
        for <netdev@vger.kernel.org>; Mon, 16 Sep 2013 11:32:47 -0700 (PDT)
In-Reply-To: <523746C6.3010700@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 16 Sep 2013 13:58:30 -0400
Vlad Yasevich <vyasevic@redhat.com> wrote:

> On 09/14/2013 10:42 AM, Hong Zhiguo wrote:
> > From: Hong Zhiguo <zhiguohong@tencent.com>
> >
> > The NULL deref happens when br_handle_frame is called between these
> > 2 lines of del_nbp:
> > 	dev->priv_flags &= ~IFF_BRIDGE_PORT;
> > 	/* --> br_handle_frame is called at this time */
> > 	netdev_rx_handler_unregister(dev);
> >
> > In br_handle_frame the return of br_port_get_rcu(dev) is dereferenced
> > without check but br_port_get_rcu(dev) returns NULL if:
> > 	!(dev->priv_flags & IFF_BRIDGE_PORT)
> >
> > Eric Dumazet pointed out the testing of IFF_BRIDGE_PORT is not necessary
> > here since we're in rcu_read_lock and we have synchronize_net() in
> > netdev_rx_handler_unregister. So remove the testing of IFF_BRIDGE_PORT
> > and by the previous patch, make sure br_port_get_rcu is called in
> > bridging code.
> >
> > Signed-off-by: Hong Zhiguo <zhiguohong@tencent.com>
> 
> I think would be better to also include your initial patch to move the
> call netdev_rx_handler_unregister(dev) up higher as it would reduce the
> racy nature of input processing and port removal.
> 
> As it is now, up until netdev_rx_handler_unregister(dev) call, the input
> process may call into the bridge code only to drop the packet.  With 
> ebtables, that can consume considerable time that is wasted.  By 
> performing the unregister() sooner we reduce the racy nature of the two
> calls.
> 
> -vlad

The change to just use rcu_dereference is safe.
The flag ordering doesn't matter. it is only valid to check it under RTNL.
