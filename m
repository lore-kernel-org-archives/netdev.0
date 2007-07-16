From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 8766] New: 802.1q VLAN stacking + REORDER_HDR
 is broken
Date: Mon, 16 Jul 2007 00:48:37 -0700
Message-ID: <20070716004837.47cd60c1.akpm@linux-foundation.org>
References: <bug-8766-10286@http.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "bugme-daemon@kernel-bugs.osdl.org"
	<bugme-daemon@kernel-bugs.osdl.org>,
	tristan_schmelcher@alumni.uwaterloo.ca
To: netdev@vger.kernel.org, Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:50850 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753204AbXGPHsw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Jul 2007 03:48:52 -0400
In-Reply-To: <bug-8766-10286@http.bugzilla.kernel.org/>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 15 Jul 2007 23:57:32 -0700 (PDT) bugme-daemon@bugzilla.kernel.org wrote:

> http://bugzilla.kernel.org/show_bug.cgi?id=8766
> 
>            Summary: 802.1q VLAN stacking + REORDER_HDR is broken
>            Product: Networking
>            Version: 2.5
>      KernelVersion: 2.6.20
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: normal
>           Priority: P1
>          Component: Other
>         AssignedTo: acme@ghostprotocols.net
>         ReportedBy: tristan_schmelcher@alumni.uwaterloo.ca
> 
> 
> Most recent kernel where this bug did not occur: Unknown
> Distribution: Several (see below)
> Hardware Environment: Several (see below)
> Software Environment: Several (see below)
> Problem Description: Combining VLAN stacking with the REORDER_HDR flag on
> either the inner or outer VLAN interface does not work. The computer puts only
> one VLAN tag on the wire.
> 
> Steps to reproduce:
> 
> vconfig add eth0 12
> ifconfig eth0.12 up
> vconfig add eth0.12 2
> ifconfig eth0.12.2 192.168.254.100
> (default is REORDER_HDR 1, so they both have it set)
> ping 192.168.254.101
> (no response)
> 
> tcpdump -i eth0:
> 
> 23:04:53.301156 vlan 2, p 0, arp who-has 192.168.254.101 tell tinygod2.local
> 23:04:54.301214 vlan 2, p 0, arp who-has 192.168.254.101 tell tinygod2.local
> 23:04:56.301326 vlan 2, p 0, arp who-has 192.168.254.101 tell tinygod2.local
> 
> But:
> 
> vconfig set_flag eth0.12 1 0
> vconfig set_flag eth0.12.2 1 0
> ping 192.168.254.101
> (Responses)
> 
> tcpdump -i eth0:
> 
> 23:10:44.932200 vlan 12, p 0, vlan 2, p 0, IP tinygod2.local > tinygod3.local:
> ICMP echo request, id 61054, seq 1, length 64
> 23:10:44.932364 vlan 12, p 0, vlan 2, p 0, IP tinygod3.local > tinygod2.local:
> ICMP echo reply, id 61054, seq 1, length 64
> 23:10:45.937238 vlan 12, p 0, vlan 2, p 0, IP tinygod2.local > tinygod3.local:
> ICMP echo request, id 61054, seq 2, length 64
> 23:10:45.937445 vlan 12, p 0, vlan 2, p 0, IP tinygod3.local > tinygod2.local:
> ICMP echo reply, id 61054, seq 2, length 64
> 23:10:46.937196 vlan 12, p 0, vlan 2, p 0, IP tinygod2.local > tinygod3.local:
> ICMP echo request, id 61054, seq 3, length 64
> 23:10:46.937401 vlan 12, p 0, vlan 2, p 0, IP tinygod3.local > tinygod2.local:
> ICMP echo reply, id 61054, seq 3, length 64
> 
> If REORDER_HDR is 1 on only one of the two VLAN interfaces, it's still broken.
> However, if it's 1 on the inner interface and 0 on the outer one, then it's the
> outer tag that shows up on the wire, instead of the inner tag as in the rest of
> the cases.
> 
> Note also that if the NIC card has VLAN acceleration then there's no problem
> with the above case. However, if you do 3 levels of stacked VLANs and put
> REORDER_HDR on one of the two inner ones, then it's broken in the analogous
> way.
> 
> I have tested this on 3 computers, which between them have the same number of
> distinct distributions, kernel versions, NIC cards, and architectures. They
> are:
> 
> (1) Kubuntu Feisty Fawn 2.6.20-15-generic on a Compaq AMD Athlon64 laptop with
> a Realtek RTL-8139 (used for the above output)
> (2) Debian Lenny 2.6.18-4-amd64 on a Dell Intel Core 2 Duo laptop with a
> Broadcom NetXtreme BCM5752 (which has acceleration)
> (3) uClinux 2.6.17-uc1 on a Nios II embedded system with the OpenCores MAC.
> 
> Note that this appears to be the same bug as was long ago discovered by another
> user and described here:
> http://www.candelatech.com/pipermail/vlan/2004-December/000190.html
> 
