From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 9758] New: net_device refcnt bug when
 NFQUEUEing bridged packets
Date: Tue, 15 Jan 2008 15:56:55 -0800
Message-ID: <20080115155655.d1a24eaf.akpm@linux-foundation.org>
References: <bug-9758-10286@http.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bugme-daemon@bugzilla.kernel.org, jckn@gmx.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:53477 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1759767AbYAOX5b (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Jan 2008 18:57:31 -0500
In-Reply-To: <bug-9758-10286@http.bugzilla.kernel.org/>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 15 Jan 2008 15:28:31 -0800 (PST)
bugme-daemon@bugzilla.kernel.org wrote:

> http://bugzilla.kernel.org/show_bug.cgi?id=9758
> 
>            Summary: net_device refcnt bug when NFQUEUEing bridged packets
>            Product: Networking
>            Version: 2.5
>      KernelVersion: 2.6.24-rc7
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: normal
>           Priority: P1
>          Component: Netfilter/Iptables
>         AssignedTo: networking_netfilter-iptables@kernel-bugs.osdl.org
>         ReportedBy: jckn@gmx.net
> 
> 
> The bug is probably around since the combination bridge+NFQUEUE is possible,
> and does not depend on distro or environment:
> 
> Packets that are to be sent out over a bridge device are skb_clone()d in
> br_loop() before traversing the appropriate (FORWARD/OUTPUT) NF chain.
> The copies made by skb_clone() share their nf_bridge metadata with the
> original, which is no problem usually.
> If however one or more packets of a br_loop() run end up in a NFQUEUE,
> their shared nf_bridge metadata causes trouble when they are about to be
> reinjected: nf_reinject() decrements the net_device refcounts that were
> previously upped when queueing the packet in __nf_queue(), but as
> skb->nf_bridge->physoutdev points to the same device for all these
> packets, most (if not all) of them will affect the wrong refcnt.
> 
> (I originally encountered the bug on a Xen host because the hypervisor
> refused to shutdown a virtual device with non-zero refcount... but it is
> perfectly reproducible with a standard kernel, too, although it was a
> bit more tedious to create a test scenario, involving a couple of UMLs.)
> 
> I'd suggest to make a real copy of the nf_bridge member in br_loop() if
> CONFIG_BRIDGE_NETFILTER is defined, remedying the entanglement. I'd go ahead
> and create a patch, but I'm unsure as to where that logic should be
> implemented.
