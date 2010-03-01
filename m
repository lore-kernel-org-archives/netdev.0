From: Tom Herbert <therbert@google.com>
Subject: Re: [RFC] Setting processor affinity for network queues
Date: Mon, 1 Mar 2010 12:46:26 -0800
Message-ID: <65634d661003011246x24aad2c5m84fc5ee3d809b0d8@mail.gmail.com>
References: <1267464102.2092.136.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>,
	Peter Zijlstra <peterz@infradead.org>,
	Thomas Gleixner <tglx@linutronix.de>,
	Stephen Hemminger <shemminger@vyatta.com>,
	sf-linux-drivers <linux-net-drivers@solarflare.com>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.33.17]:47575 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751293Ab0CAUqb convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Mar 2010 15:46:31 -0500
Received: from wpaz13.hot.corp.google.com (wpaz13.hot.corp.google.com [172.24.198.77])
	by smtp-out.google.com with ESMTP id o21KkSEo020101
	for <netdev@vger.kernel.org>; Mon, 1 Mar 2010 20:46:29 GMT
Received: from fxm4 (fxm4.prod.google.com [10.184.13.4])
	by wpaz13.hot.corp.google.com with ESMTP id o21KkRDr032701
	for <netdev@vger.kernel.org>; Mon, 1 Mar 2010 12:46:27 -0800
Received: by fxm4 with SMTP id 4so2900662fxm.20
        for <netdev@vger.kernel.org>; Mon, 01 Mar 2010 12:46:27 -0800 (PST)
In-Reply-To: <1267464102.2092.136.camel@achroite.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 1, 2010 at 9:21 AM, Ben Hutchings <bhutchings@solarflare.co=
m> wrote:
> With multiqueue network hardware or Receive/Transmit Packet Steering
> (RPS/XPS) we can spread out network processing across multiple
> processors. =A0The administrator should be able to control the number=
 of
> channels and the processor affinity of each.
>
> By 'channel' I mean a bundle of:
> - a wakeup (IRQ or IPI)
> - a receive queue whose completions trigger the wakeup
> - a transmit queue whose completions trigger the wakeup
> - a NAPI instance scheduled by the wakeup, which handles the completi=
ons
>

Yes.  Also in the receive side it is really cumbersome to do per NAPI
RPS settings without the receive napi instance not be exposed in
netif_rx.  Maybe a reference to NAPI structure can be added in skb?
This could clean up RPS a lot.

Tom

> Numbers of RX and TX queues used on a device do not have to match, bu=
t
> ideally they should. =A0For generality, you can subsitute 'a receive
> and/or a transmit queue' above. =A0At the hardware level the numbers =
of
> queues could be different e.g. in the sfc driver a channel would be
> associated with 1 hardware RX queue, 2 hardware TX queues (with and
> without checksum offload) and 1 hardware event queue.
>
> Currently we have a userspace interface for setting affinity of IRQs =
and
> a convention for naming each channel's IRQ handler, but no such
> interface for memory allocation. =A0For RX buffers this should not be=
 a
> problem since they are normally allocated as older buffers are
> completed, in the NAPI context. =A0However, the DMA descriptor rings =
and
> driver structures for a channel should also be allocated on the NUMA
> node where NAPI processing is done. =A0Currently this allocation take=
s
> place when a net device is created or when it is opened, before an
> administrator has any opportunity to configure affinity. =A0Reallocat=
ion
> will normally require a complete stop to network traffic (at least on
> the affected queues) so it should not be done automatically when the
> driver detects a change in IRQ affinity. =A0There needs to be an expl=
icit
> mechanism for changing it.
>
> Devices using RPS will not generally be able to implement NUMA affini=
ty
> for RX buffer allocation, but there will be a similar issue of proces=
sor
> selection for IPIs and NUMA node affinity for driver structures. =A0T=
he
> proposed interface for setting processor affinity should cover this, =
but
> it is completely different from the IRQ affinity mechanism for hardwa=
re
> multiqueue devices. =A0That seems undesirable.
>
> Therefore I propose that:
>
> 1. Channels (or NAPI instances) should be exposed in sysfs.
> 2. Channels will have processor affinity, exposed read/write in sysfs=
=2E
> Changing this triggers the networking core and driver to reallocate
> associated structures if the processor affinity moved between NUMA
> nodes, and triggers the driver to set IRQ affinity.
> 3. The networking core will set the initial affinity for each channel=
=2E
> There may be global settings to control this.
> 4. Drivers should not set IRQ affinity.
> 5. irqbalanced should not set IRQ affinity for multiqueue network
> devices.
>
> (Most of this has been proposed already, but I'm trying to bring it a=
ll
> together.)
>
> Ben.
>
> --
> Ben Hutchings, Senior Software Engineer, Solarflare Communications
> Not speaking for my employer; that's the marketing department's job.
> They asked us to note that Solarflare product names are trademarked.
>
>
