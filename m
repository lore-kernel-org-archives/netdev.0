From: Tom Herbert <therbert@google.com>
Subject: Re: [RFC PATCH net-next-2.6 0/2] Automatic XPS mapping
Date: Tue, 19 Jul 2011 10:07:53 -0700
Message-ID: <CA+mtBx8mAKfHXbp4GbfYw6-h-U4mObEjYoS+_qR9UUjXA00Xuw@mail.gmail.com>
References: <1298045607.2570.17.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>,
	sf-linux-drivers <linux-net-drivers@solarflare.com>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.44.51]:3575 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751008Ab1GSRH5 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Jul 2011 13:07:57 -0400
Received: from hpaq5.eem.corp.google.com (hpaq5.eem.corp.google.com [172.25.149.5])
	by smtp-out.google.com with ESMTP id p6JH7t3S005504
	for <netdev@vger.kernel.org>; Tue, 19 Jul 2011 10:07:56 -0700
Received: from iwc10 (iwc10.prod.google.com [10.241.65.138])
	by hpaq5.eem.corp.google.com with ESMTP id p6JH50OR003560
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Tue, 19 Jul 2011 10:07:54 -0700
Received: by iwc10 with SMTP id 10so4728013iwc.37
        for <netdev@vger.kernel.org>; Tue, 19 Jul 2011 10:07:54 -0700 (PDT)
In-Reply-To: <1298045607.2570.17.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Ben,

I've finally gotten around to looking at how XPS interacts with the HW
priority queues...

On Fri, Feb 18, 2011 at 8:13 AM, Ben Hutchings
<bhutchings@solarflare.com> wrote:
> In the same way that we maintain a mapping CPUs to RX queues for RFS
> acceleration based on current IRQ affinity and the CPU topology, we c=
an
> maintain a mapping of CPUs to TX queues for queue selection in XPS. =A0=
(In
> fact this may be the same mapping.)
>

Any more progress on this?  It seem like a good way to provide default
configuration for XPS that is usable.

> Questions:
> - Does this make a real difference to performance?

XPS seems to when configured correctly :-)

> =A0(I've only barely tested this.)
> - Should there be a way to disable it?
> - Should the automatic mapping be made visible?

Yes, would be nice for this to be readable in the tx-<n> directory for
the queue.  Same thing for rmap in RFS acceleration.

> =A0(This applies RFS acceleration too.)

> - Should different mappings be allowed for different traffic classes,
> =A0in case they have separate sets of TX interrupts with different
> =A0affinity?
> =A0(This applies to manual XPS configuration too.)
>
Yes.  Looking at XPS and the HW traffic class support, I realized that
they don't seem to play together at all.  If XPS is enabled, we don't
do the skb_tx_hash which is where the priority is taken into account.
It's probably worse than that, AFAICT XPS could be configured so that
packets are inadvertently sent on arbitrary priority queues.

I think the correct approach is to first choose a set of queues by
priority, and then among those queues perform XPS.  Probably requires
some new configuration to make this hierarchy visible.

Tom

> Ben Hutchings (2):
> =A0net: XPS: Allow driver to provide a default mapping of CPUs to TX
> =A0 =A0queues
> =A0sfc: Add CPU queue mapping for XPS
>
> =A0drivers/net/sfc/efx.c =A0 =A0 | =A0 59 +++++++++++++++++++++++++++=
++++-------------
> =A0include/linux/netdevice.h | =A0 10 +++++--
> =A0net/Kconfig =A0 =A0 =A0 =A0 =A0 =A0 =A0 | =A0 17 +++++++++----
> =A0net/core/dev.c =A0 =A0 =A0 =A0 =A0 =A0| =A0 41 +++++++++++++++++--=
-----------
> =A04 files changed, 83 insertions(+), 44 deletions(-)
>
> --
> 1.7.3.4
>
>
> --
> Ben Hutchings, Senior Software Engineer, Solarflare Communications
> Not speaking for my employer; that's the marketing department's job.
> They asked us to note that Solarflare product names are trademarked.
>
>
