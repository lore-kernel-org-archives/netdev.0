From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] neighbour: update neigh timestamps iff update is
 effective
Date: Wed, 17 May 2017 11:42:08 -0400 (EDT)
Message-ID: <20170517.114208.19816687746845673.davem@davemloft.net>
References: <20170515.131023.1878814687849300375.davem@davemloft.net>
        <20170516154424.12864-1-ihrachys@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ja@ssi.bg, netdev@vger.kernel.org
To: ihrachys@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:34038 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750969AbdEQPmK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 17 May 2017 11:42:10 -0400
In-Reply-To: <20170516154424.12864-1-ihrachys@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ihar Hrachyshka <ihrachys@redhat.com>
Date: Tue, 16 May 2017 08:44:24 -0700

> It's a common practice to send gratuitous ARPs after moving an
> IP address to another device to speed up healing of a service. To
> fulfill service availability constraints, the timing of network peers
> updating their caches to point to a new location of an IP address can be
> particularly important.
> 
> Sometimes neigh_update calls won't touch neither lladdr nor state, for
> example if an update arrives in locktime interval. The neigh->updated
> value is tested by the protocol specific neigh code, which in turn
> will influence whether NEIGH_UPDATE_F_OVERRIDE gets set in the
> call to neigh_update() or not. As a result, we may effectively ignore
> the update request, bailing out of touching the neigh entry, except that
> we still bump its timestamps inside neigh_update.
> 
> This may be a problem for updates arriving in quick succession. For
> example, consider the following scenario:
> 
> A service is moved to another device with its IP address. The new device
> sends three gratuitous ARP requests into the network with ~1 seconds
> interval between them. Just before the first request arrives to one of
> network peer nodes, its neigh entry for the IP address transitions from
> STALE to DELAY.  This transition, among other things, updates
> neigh->updated. Once the kernel receives the first gratuitous ARP, it
> ignores it because its arrival time is inside the locktime interval. The
> kernel still bumps neigh->updated. Then the second gratuitous ARP
> request arrives, and it's also ignored because it's still in the (new)
> locktime interval. Same happens for the third request. The node
> eventually heals itself (after delay_first_probe_time seconds since the
> initial transition to DELAY state), but it just wasted some time and
> require a new ARP request/reply round trip. This unfortunate behaviour
> both puts more load on the network, as well as reduces service
> availability.
> 
> This patch changes neigh_update so that it bumps neigh->updated (as well
> as neigh->confirmed) only once we are sure that either lladdr or entry
> state will change). In the scenario described above, it means that the
> second gratuitous ARP request will actually update the entry lladdr.
> 
> Ideally, we would update the neigh entry on the very first gratuitous
> ARP request. The locktime mechanism is designed to ignore ARP updates in
> a short timeframe after a previous ARP update was honoured by the kernel
> layer. This would require tracking timestamps for state transitions
> separately from timestamps when actual updates are received. This would
> probably involve changes in neighbour struct. Therefore, the patch
> doesn't tackle the issue of the first gratuitous APR ignored, leaving
> it for a follow-up.
> 
> Signed-off-by: Ihar Hrachyshka <ihrachys@redhat.com>
> ---
> v2: added more details to commit message to explain relation between arp
>     and neigh code.

Applied, thanks for documenting things better.
