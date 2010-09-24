From: Tom Herbert <therbert@google.com>
Subject: Re: [PATCH] net: reset skb queue mapping when rx'ing over tunnel
Date: Fri, 24 Sep 2010 09:18:30 -0700
Message-ID: <AANLkTimG9ZCZwDyo_9bYURShn7hk6ROzX4-qypo7nG5i@mail.gmail.com>
References: <alpine.DEB.1.00.1009231415290.25121@pokey.mtv.corp.google.com>
	<1285293960.2380.23.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net, chavey@google.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([74.125.121.35]:42532 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932428Ab0IXQSe convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Sep 2010 12:18:34 -0400
Received: from wpaz37.hot.corp.google.com (wpaz37.hot.corp.google.com [172.24.198.101])
	by smtp-out.google.com with ESMTP id o8OGIWh4025385
	for <netdev@vger.kernel.org>; Fri, 24 Sep 2010 09:18:32 -0700
Received: from pxi5 (pxi5.prod.google.com [10.243.27.5])
	by wpaz37.hot.corp.google.com with ESMTP id o8OGIRP4030364
	for <netdev@vger.kernel.org>; Fri, 24 Sep 2010 09:18:31 -0700
Received: by pxi5 with SMTP id 5so1186306pxi.14
        for <netdev@vger.kernel.org>; Fri, 24 Sep 2010 09:18:30 -0700 (PDT)
In-Reply-To: <1285293960.2380.23.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Hmm...
>
> This would need to be reverted later when tunnels are updated to be
> multiqueue aware ? I made an attempt with GRE some days ago.
>
> I dont understand why this patch is needed, since get_rps_cpu() has a
> check anyway
>
I think the skb queue_mapping should correspond to a queue in the
skb's device as an invariant.  In the case that an skb's device is
change from a multiqueue device to single queue device (like GRE), the
inconsistency in the queue_mapping is fairly innocuous, we get one
warning but will pretty much take the unlikely branch for GRE packets
then on.  But imagine a case where skb's device was change from one
multiqueue device to another, but the queue mapping was not also
updated.  This  would cause poor weighting in get_rps_cpus.  For
example, if the new device had fewer queues than the old one,
get_rps_cpu will bias toward using queue 0's rps mask.

> =A0 =A0 =A0 =A0if (skb_rx_queue_recorded(skb)) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0u16 index =3D skb_get_rx_queue(skb);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (unlikely(index >=3D dev->num_rx_qu=
eues)) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0WARN_ONCE(dev->num_rx_=
queues > 1, "%s received packet "
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0"on qu=
eue %u, but number of RX queues is %u\n",
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0dev->n=
ame, index, dev->num_rx_queues);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto done;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0rxqueue =3D dev->_rx + index;
> =A0 =A0 =A0 =A0} else
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0rxqueue =3D dev->_rx;
>
>
>
>
