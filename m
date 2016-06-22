From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [PATCH net-next 0/5] qed/qede: Tunnel hardware GRO support
Date: Wed, 22 Jun 2016 09:27:31 -0700
Message-ID: <CAKgT0Ue6_cPb88wfTtMMetJzBSJnGDNWj8YVHWC=9WdztCxOuQ@mail.gmail.com>
References: <1466583926-27762-1-git-send-email-manish.chopra@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>,
	Ariel Elior <Ariel.Elior@qlogic.com>,
	Yuval Mintz <Yuval.Mintz@qlogic.com>,
	Tom Herbert <tom@herbertland.com>,
	Hannes Frederic Sowa <hannes@redhat.com>
To: Manish Chopra <manish.chopra@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f169.google.com ([209.85.223.169]:34763 "EHLO
	mail-io0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932297AbcFVQ1c (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Jun 2016 12:27:32 -0400
Received: by mail-io0-f169.google.com with SMTP id g13so41864925ioj.1
        for <netdev@vger.kernel.org>; Wed, 22 Jun 2016 09:27:32 -0700 (PDT)
In-Reply-To: <1466583926-27762-1-git-send-email-manish.chopra@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 22, 2016 at 1:25 AM, Manish Chopra <manish.chopra@qlogic.com> wrote:
> Hi David,
>
> This series adds driver support for the processing of tunnel
> [specifically vxlan/geneve/gre tunnels] packets which are
> aggregated [GROed] by the hardware before driver passes
> such packets upto the stack.

First off I am pretty sure this isn't GRO.  This is LRO.  The
distinction is that LRO is performed in hardware and/or the driver
while GRO is performed by the kernel.  Think of this as the same
distinction between GSO and TSO.  The reason why we want to make
certain to keep them separate is that LRO has a bad habit of mangling
frames in ways that can be counter productive.  It also is not
extensible since it is implemented in hardware.  The best way to think
of it is that LRO is a subset of GRO.  If done correctly the LRO can
be as good as GRO, but if not there are usually some pieces of the
frame that end up being mangled which make it difficult to undo later.
As such I would recommend first going through and updating your "GRO"
feature to use the correct "LRO" feature flag if you haven't already.
The drivers should not really be messing with the GRO bit and should
be using the LRO bit to indicate this type of feature.

Also I don't know if you have been paying attention to recent
discussions on the mailing list but the fact is GRO over UDP tunnels
is still a subject for debate.  This patch takes things in the
opposite direction of where we are currently talking about going with
GRO.  I've added Hannes and Tom to this discussion just to make sure I
have the proper understanding of all this as my protocol knowledge is
somewhat lacking.

Ideally we need to be able to identify that a given packet terminates
on a local socket in our namespace before we could begin to perform
any sort of mangling on the local packets.  It is always possible that
we could be looking at a frame that uses the same UDP port but is not
the tunnel protocol if we are performing bridging or routing.  The
current GRO implementation fails in that regard and there are
discussions between several of us on how to deal with that.  It is
likely that we would be forcing GRO for tunnels to move a bit further
up the stack if bridging or routing so that we could verify that the
frame is not being routed back out before we could aggregate it.

Also I would be interested in knowing how your hardware handles
tunnels with outer checksums.  Is it just ignoring the frames in such
a case, ignoring the checksum, or is it actually validating the frames
and then merging the resulting checksum?

Thanks.

- Alex
