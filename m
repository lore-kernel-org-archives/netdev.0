From: Rick Jones <rick.jones2@hpe.com>
Subject: Re: A second case of XPS considerably reducing single-stream
 performance
Date: Thu, 25 Aug 2016 13:18:38 -0700
Message-ID: <bc180ced-9d54-1ef4-1202-22b02df3b266@hpe.com>
References: <549357ea-dfda-284b-cdd6-4408060f9ca8@hpe.com>
 <a661ff61-9cf8-fe86-ca20-2181394e1dbb@hpe.com>
 <CAKgT0UeQ_cL4aaSSc47EgzbYp7WZF7C-4+JG6T7gw78J3rv+ZA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@vger.kernel.org>, sathya.perla@broadcom.com,
        ajit.khaparde@broadcom.com, sriharsha.basavapatna@broadcom.com,
        somnath.kotur@broadcom.com
To: Alexander Duyck <alexander.duyck@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g2t2353.austin.hpe.com ([15.233.44.26]:13679 "EHLO
        g2t2353.austin.hpe.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753773AbcHYUSk (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 25 Aug 2016 16:18:40 -0400
In-Reply-To: <CAKgT0UeQ_cL4aaSSc47EgzbYp7WZF7C-4+JG6T7gw78J3rv+ZA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/25/2016 12:19 PM, Alexander Duyck wrote:
> The problem is that there is no socket associated with the guest from
> the host's perspective.  This is resulting in the traffic bouncing
> between queues because there is no saved socket  to lock the interface
> onto.
>
> I was looking into this recently as well and had considered a couple
> of options.  The first is to fall back to just using skb_tx_hash()
> when skb->sk is null for a given buffer.  I have a patch I have been
> toying around with but I haven't submitted it yet.  If you would like
> I can submit it as an RFC to get your thoughts.  The second option is
> to enforce the use of RPS for any interfaces that do not perform Rx in
> NAPI context.  The correct solution for this is probably some
> combination of the two as you have to have all queueing done in order
> at every stage of the packet processing.

I don't know with interfaces would be hit, but just in general, I'm not 
sure that requiring RPS be enabled is a good solution - picking where 
traffic is processed based on its addressing is fine in a benchmarking 
situation, but I think it is better to have the process/thread scheduler 
decide where something should run and not the addressing of the 
connections that thread/process is servicing.

I would be interested in seeing the RFC patch you propose.

Apart from that, given the prevalence of VMs these days I wonder if 
perhaps simply not enabling XPS by default isn't a viable alternative. 
I've not played with containers to know if they would exhibit this too.

Drifting ever so slightly, if drivers are going to continue to enable 
XPS by default, Documentation/networking/scaling.txt might use a tweak:

diff --git a/Documentation/networking/scaling.txt 
b/Documentation/networking/sca
index 59f4db2..8b5537c 100644
--- a/Documentation/networking/scaling.txt
+++ b/Documentation/networking/scaling.txt
@@ -402,10 +402,12 @@ acknowledged.

  ==== XPS Configuration

-XPS is only available if the kconfig symbol CONFIG_XPS is enabled (on by
-default for SMP). The functionality remains disabled until explicitly
-configured. To enable XPS, the bitmap of CPUs that may use a transmit
-queue is configured using the sysfs file entry:
+XPS is available only when the kconfig symbol CONFIG_XPS is enabled
+(on by default for SMP). The drivers for some NICs will enable the
+functionality by default.  For others the functionality remains
+disabled until explicitly configured. To enable XPS, the bitmap of
+CPUs that may use a transmit queue is configured using the sysfs file
+entry:

  /sys/class/net/<dev>/queues/tx-<n>/xps_cpus


The original wording leaves the impression that XPS is not enabled by 
default.

rick
