From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: PROBLEM: Software injected vlan tagged packets are unable to be
 identified using recent BPF modifications
Date: Tue, 8 Jan 2013 11:38:11 +0100
Message-ID: <20130108103811.GA1621@minipsycho.orion>
References: <CAOUgPvQP2RrngPPf=hYxpPdGSQ4L-Db0T-BMDwVg6iy8LTAu=Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, tcpdump-workers@lists.tcpdump.org,
	davem@davemloft.net, edumazet@google.com, jpirko@redhat.com,
	Ani Sinha <ani@aristanetworks.com>
To: Paul Pearce <pearce@cs.berkeley.edu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f176.google.com ([209.85.215.176]:34962 "EHLO
	mail-ea0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755419Ab3AHKiQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Jan 2013 05:38:16 -0500
Received: by mail-ea0-f176.google.com with SMTP id d13so111921eaa.21
        for <netdev@vger.kernel.org>; Tue, 08 Jan 2013 02:38:15 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <CAOUgPvQP2RrngPPf=hYxpPdGSQ4L-Db0T-BMDwVg6iy8LTAu=Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tue, Jan 08, 2013 at 01:05:39AM CET, pearce@cs.berkeley.edu wrote:
>Hello folks,
>
>PROBLEM:
>
>vlan tagged packets that are injected via software are not picked up
>by filters using recent (kernel commit
>f3335031b9452baebfe49b8b5e55d3fe0c4677d1)
>BPF vlan modifications. I suspect this is a problem with the Linux
>kernel.
>
>linux-netdev and tcpdump-workers are both cc'd.
>
>BACKGROUND:
>
>Kernel commit bcc6d47903612c3861201cc3a866fb604f26b8b2 (Jiri
>Pirko/David S. Miller) removed vlan headers on rx packets prior to
>them reaching the packet filters. This broke BPF/libpcap's ability to
>do kernel-level packet filtering based on vlan tag information (the
>'vlan' keyword).
>
>Kernel commit f3335031b9452baebfe49b8b5e55d3fe0c4677d1 (Eric
>Dumazet/David S. Miller, just merged into Linus's tree
>http://git.kernel.org/?p=linux/kernel/git/torvalds/linux.git;a=commit;h=f3335031b9452baebfe49b8b5e55d3fe0c4677d1)
>added the ability to use BPF to once again filter based on vlan
>tags. Related bpf jit commit:
>http://www.spinics.net/lists/netdev/msg214759.html
>
>libpcap (Ani Sinha) recently RFC'd a patch to use Eric/David's BPF
>modifications to restore vlan filtering to libpcap.
>http://www.mail-archive.com/tcpdump-workers@lists.tcpdump.org/msg06810.html
>I'm using this patch and it works.
>
>DETAILS:
>
>Under these patches vlan tagged packets received from mediam (actual
>packets from the wire) can be identified based on vlan tag information
>using the new BPF functionality.This is good.
>
>However, raw vlan tagged packets that are *injected* into the
>interface using libpcap's pcap_inject() (which is just a fancy wrapper
>for the send() syscall) are not identified by filters using the recent
>BPF modifications.
>
>The bug manifests itself if you attempt to use the new BPF
>modifications to filter vlan tagged packets on a live interface. All
>packets from the medium show up, but all injected packets are dropped.
>
>Prior to commit bcc6d47 both medium and injected packets could both be
>identified using BPFs.
>
>These injected packets can however still be identified using the
>previous, now incorrect "offset into the header" technique. Given
>this, I suspect what's going on is the kernel code path for these
>injected packets is not setting skb->vlan_tci correctly (at all?).
>Since the vlan tag is not in the skb data structure the new BPF
>modifications don't identify the packets as having a vlan tag,
>despite it being in the packet header.


You are right. skb->vlan_tci is not set. Looking at packet_snd() function
in net/packet/af_packet.c I guess that something like following patch
would be needed:

diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index e639645..2238559 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -2292,6 +2292,12 @@ static int packet_snd(struct socket *sock,
 	if (unlikely(extra_len == 4))
 		skb->no_fcs = 1;
 
+	if (skb->protocol == cpu_to_be16(ETH_P_8021Q)) {
+		skb = vlan_untag(skb);
+		if (unlikely(!skb))
+			goto out_unlock;
+	}
+
 	/*
 	 *	Now send it
 	 */

Thoughts?

>
>I'm not sure exactly where the bug exists so I'm reaching out to both
>netdev and tcpdump-workers. Although, as I said, I suspect this is on
>the kernel side.
>
>SOFTWARE:
>
>kernel-3.6.11-1.fc16.x86_64, with both kernel commits
>f3335031b9452baebfe49b8b5e55d3fe0c4677d1 and the related commit
>http://www.spinics.net/lists/netdev/msg214759.html backported.
>tcpdump version 4.4.0-PRE-GIT_2013_01_06 (commit
>05bf602ef684d5b75c0ac71be04212d909c37834)
>libpcap version 1.4.0-PRE-GIT_2013_01_06 (commit
>713034fc4b3a2c14ae81e44dca34d998db8d0795 with patch specified above)
>
>Thanks.
>
>-Paul Pearce
>
>Security Graduate Student
>Computer Science
>University of California, Berkeley
>--
>To unsubscribe from this list: send the line "unsubscribe netdev" in
>the body of a message to majordomo@vger.kernel.org
>More majordomo info at  http://vger.kernel.org/majordomo-info.html
