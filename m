From: Paul Pearce <pearce@cs.berkeley.edu>
Subject: Re: PROBLEM: Software injected vlan tagged packets are unable to be
 identified using recent BPF modifications
Date: Mon, 7 Jan 2013 19:04:02 -0800
Message-ID: <CAOUgPvQhyC5LTVAZeeRd3N-Jdpe+cHK4LQWZUB-qTKT_og7dSw@mail.gmail.com>
References: <CAOUgPvQP2RrngPPf=hYxpPdGSQ4L-Db0T-BMDwVg6iy8LTAu=Q@mail.gmail.com>
 <CAOxq_8MJZtFYHmsqQdZ+DSDuHjgkQYrHG2rPt32m6TRTV-ZS9A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org, Ani Sinha <ani@aristanetworks.com>,
	David Miller <davem@davemloft.net>,
	edumazet <edumazet@google.com>, jpirko@redhat.com,
	Francesco Ruggeri <fruggeri@aristanetworks.com>
To: tcpdump-workers <tcpdump-workers@lists.tcpdump.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f172.google.com ([209.85.214.172]:35310 "EHLO
	mail-ob0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753597Ab3AHDEn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Jan 2013 22:04:43 -0500
Received: by mail-ob0-f172.google.com with SMTP id za17so18384562obc.17
        for <netdev@vger.kernel.org>; Mon, 07 Jan 2013 19:04:42 -0800 (PST)
In-Reply-To: <CAOxq_8MJZtFYHmsqQdZ+DSDuHjgkQYrHG2rPt32m6TRTV-ZS9A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The original message didn't make it to the tcpdump-workers list. It follows.

---------- Forwarded message ----------
From: Paul Pearce <pearce@cs.berkeley.edu>
Date: Mon, Jan 7, 2013 at 4:05 PM
Subject: PROBLEM: Software injected vlan tagged packets are unable to
be identified using recent BPF modifications
To: netdev@vger.kernel.org, tcpdump-workers@lists.tcpdump.org
Cc: davem@davemloft.net, edumazet@google.com, jpirko@redhat.com, Ani
Sinha <ani@aristanetworks.com>


Hello folks,

PROBLEM:

vlan tagged packets that are injected via software are not picked up
by filters using recent (kernel commit
f3335031b9452baebfe49b8b5e55d3fe0c4677d1)
BPF vlan modifications. I suspect this is a problem with the Linux
kernel.

linux-netdev and tcpdump-workers are both cc'd.

BACKGROUND:

Kernel commit bcc6d47903612c3861201cc3a866fb604f26b8b2 (Jiri
Pirko/David S. Miller) removed vlan headers on rx packets prior to
them reaching the packet filters. This broke BPF/libpcap's ability to
do kernel-level packet filtering based on vlan tag information (the
'vlan' keyword).

Kernel commit f3335031b9452baebfe49b8b5e55d3fe0c4677d1 (Eric
Dumazet/David S. Miller, just merged into Linus's tree
http://git.kernel.org/?p=linux/kernel/git/torvalds/linux.git;a=commit;h=f3335031b9452baebfe49b8b5e55d3fe0c4677d1)
added the ability to use BPF to once again filter based on vlan
tags. Related bpf jit commit:
http://www.spinics.net/lists/netdev/msg214759.html

libpcap (Ani Sinha) recently RFC'd a patch to use Eric/David's BPF
modifications to restore vlan filtering to libpcap.
http://www.mail-archive.com/tcpdump-workers@lists.tcpdump.org/msg06810.html
I'm using this patch and it works.

DETAILS:

Under these patches vlan tagged packets received from mediam (actual
packets from the wire) can be identified based on vlan tag information
using the new BPF functionality.This is good.

However, raw vlan tagged packets that are *injected* into the
interface using libpcap's pcap_inject() (which is just a fancy wrapper
for the send() syscall) are not identified by filters using the recent
BPF modifications.

The bug manifests itself if you attempt to use the new BPF
modifications to filter vlan tagged packets on a live interface. All
packets from the medium show up, but all injected packets are dropped.

Prior to commit bcc6d47 both medium and injected packets could both be
identified using BPFs.

These injected packets can however still be identified using the
previous, now incorrect "offset into the header" technique. Given
this, I suspect what's going on is the kernel code path for these
injected packets is not setting skb->vlan_tci correctly (at all?).
Since the vlan tag is not in the skb data structure the new BPF
modifications don't identify the packets as having a vlan tag,
despite it being in the packet header.

I'm not sure exactly where the bug exists so I'm reaching out to both
netdev and tcpdump-workers. Although, as I said, I suspect this is on
the kernel side.

SOFTWARE:

kernel-3.6.11-1.fc16.x86_64, with both kernel commits
f3335031b9452baebfe49b8b5e55d3fe0c4677d1 and the related commit
http://www.spinics.net/lists/netdev/msg214759.html backported.
tcpdump version 4.4.0-PRE-GIT_2013_01_06 (commit
05bf602ef684d5b75c0ac71be04212d909c37834)
libpcap version 1.4.0-PRE-GIT_2013_01_06 (commit
713034fc4b3a2c14ae81e44dca34d998db8d0795 with patch specified above)

Thanks.

-Paul Pearce

Security Graduate Student
Computer Science
University of California, Berkeley
