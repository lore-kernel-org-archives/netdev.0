From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: Re: [PATCH net-next] virtio-net: invoke zerocopy callback on xmit
 path if no tx napi
Date: Wed, 23 Aug 2017 11:20:45 -0400
Message-ID: <CAF=yD-+U_aWxSmPPY8v8t=JO0MRZ+N+DzVJTAMKYQ5F=pE1PfA@mail.gmail.com>
References: <20170819063854.27010-1-den@klaipeden.com> <5352c98a-fa48-fcf9-c062-9986a317a1b0@redhat.com>
 <CAF=yD-LZ4=WAYfUtY7xRWi50FRSkrcOa+b7uc46xRnC4sbDCzQ@mail.gmail.com>
 <64d451ae-9944-e978-5a05-54bb1a62aaad@redhat.com> <20170822204015-mutt-send-email-mst@kernel.org>
 <1503498504.8694.26.camel@klaipeden.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: "Michael S. Tsirkin" <mst@redhat.com>,
        Jason Wang <jasowang@redhat.com>,
        virtualization@lists.linux-foundation.org,
        Network Development <netdev@vger.kernel.org>
To: Koichiro Den <den@klaipeden.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f43.google.com ([209.85.218.43]:36059 "EHLO
        mail-oi0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932090AbdHWPV0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 23 Aug 2017 11:21:26 -0400
Received: by mail-oi0-f43.google.com with SMTP id g131so4220349oic.3
        for <netdev@vger.kernel.org>; Wed, 23 Aug 2017 08:21:26 -0700 (PDT)
In-Reply-To: <1503498504.8694.26.camel@klaipeden.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Please let me make sure if I understand it correctly:
> * always do copy with skb_orphan_frags_rx as Willem mentioned in the earlier
> post, before the xmit_skb as opposed to my original patch, is safe but too
> costly so cannot be adopted.

One more point about msg_zerocopy in the guest. This does add new allocation
limits on optmem and locked pages rlimit.

Hitting these should be extremely rare. The tcp small queues limit normally
throttles well before this.

Virtio-net is an exception because it breaks the tsq signal by calling
skb_orphan before transmission.

As a result hitting these limits is more likely here. But, in this edge case the
sendmsg call will not block, either, but fail with -ENOBUFS. The caller can
send without zerocopy to make forward progress and
trigger free_old_xmit_skbs from start_xmit.

> * as a generic solution, if we were to somehow overcome the safety issue, track
> the delay and do copy if some threshold is reached could be an answer, but it's
> hard for now.> * so things like the current vhost-net implementation of deciding whether or not
> to do zerocopy beforehand referring the zerocopy tx error ratio is a point of
> practical compromise.

The fragility of this mechanism is another argument for switching to tx napi
as default.

Is there any more data about the windows guest issues when completions
are not queued within a reasonable timeframe? What is this timescale and
do we really need to work around this. That is the only thing keeping us from
removing the HoL blocking in vhost-net zerocopy.
