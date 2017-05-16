From: Ihar Hrachyshka <ihrachys@redhat.com>
Subject: Re: [PATCH] neighbour: update neigh timestamps iff update is effective
Date: Tue, 16 May 2017 08:47:00 -0700
Message-ID: <CAKwN9=BfuUFPEQm5ED4W6UxTtWGLPNC37QEd02BCfEE0c5YC9g@mail.gmail.com>
References: <20170515.131023.1878814687849300375.davem@davemloft.net> <20170515214025.28575-1-ihrachys@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Julian Anastasov <ja@ssi.bg>, netdev@vger.kernel.org,
        Ihar Hrachyshka <ihrachys@redhat.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f178.google.com ([209.85.161.178]:35122 "EHLO
        mail-yw0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752636AbdEPPrW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 16 May 2017 11:47:22 -0400
Received: by mail-yw0-f178.google.com with SMTP id l74so40441525ywe.2
        for <netdev@vger.kernel.org>; Tue, 16 May 2017 08:47:21 -0700 (PDT)
In-Reply-To: <20170515214025.28575-1-ihrachys@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, May 15, 2017 at 2:40 PM, Ihar Hrachyshka <ihrachys@redhat.com> wrote:
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

Please disregard this email, I forgot to update the patch version to
v2 and provide changelog. I posted (hopefully) correct version. Still
learning the process...

Ihar
