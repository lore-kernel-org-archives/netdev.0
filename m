From: Tom Herbert <tom@herbertland.com>
Subject: Re: [net-next PATCH v3 00/17] Future-proof tunnel offload handlers
Date: Mon, 20 Jun 2016 12:27:32 -0700
Message-ID: <CALx6S35C=QnD3WtK52Wc7FLXt77e80OWG1-5qjS5nMVm-nwkCA@mail.gmail.com>
References: <20160616191851.20872.67154.stgit@localhost.localdomain>
	<20160617.202641.1821023739498595024.davem@davemloft.net>
	<CALx6S34Y3Qq6nMHuMcC2LC5duLBO3KVN3+A+0qmPrNvFfY7gJg@mail.gmail.com>
	<34f19f9c-221b-78f0-3989-9384e0d22e54@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Alex Duyck <aduyck@mirantis.com>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	intel-wired-lan <intel-wired-lan@lists.osuosl.org>,
	Jesse Gross <jesse@kernel.org>,
	Eugenia Emantayev <eugenia@mellanox.com>,
	Jiri Benc <jbenc@redhat.com>,
	Alexander Duyck <alexander.duyck@gmail.com>,
	Saeed Mahameed <saeedm@mellanox.com>,
	Ariel Elior <ariel.elior@qlogic.com>,
	michael.chan@broadcom.com, Dept-GELinuxNICDev@qlogic.com
To: Hannes Frederic Sowa <hannes@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f48.google.com ([209.85.214.48]:38658 "EHLO
	mail-it0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752821AbcFTTfy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Jun 2016 15:35:54 -0400
Received: by mail-it0-f48.google.com with SMTP id h190so46109261ith.1
        for <netdev@vger.kernel.org>; Mon, 20 Jun 2016 12:35:54 -0700 (PDT)
In-Reply-To: <34f19f9c-221b-78f0-3989-9384e0d22e54@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Do we?
>
> We look up the socket in a proper way, inclusive the namespace belonging
> to the device we received the packet on. That said, I don't see a
> problem with that right now. But maybe I miss something?
>
When we so the socket lookup in udp_rcv this is done after IP layer
and packet has been determined to be loacally addressed. The packet is
for the host, and if a UDP socket is matched, even if just based on
destination port, the socket is matched and received functions are
called. There is no ambiguity.

When the lookup is performed in GRO this is before we processed IP and
determined that the packet is local. So a packet with any address
(local or not) will match a listener socket with the same UDP port.
The GRO can be performed an packet is subsequently forwarded maybe
having been modified. If this packet turns out to not be the protocol
we thought it was (e.g. VXLAN) then we have now potentially silently
corrupted someone else's packets. Grant it, there's probably a lot of
things that are required to make corruption happen, but it does allow
the possibly of systematic data corruption and we haven't discounted
this to become a security vulnerability.

Tom

> Thanks,
> Hannes
>
