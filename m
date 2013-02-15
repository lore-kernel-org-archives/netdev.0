From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: PROBLEM: Software injected vlan tagged packets are unable to be identified using recent BPF modifications
Date: Thu, 14 Feb 2013 23:20:08 -0800
Message-ID: <87fw0y6o2f.fsf@xmission.com>
References: <CAOUgPvQP2RrngPPf=hYxpPdGSQ4L-Db0T-BMDwVg6iy8LTAu=Q@mail.gmail.com>
	<20130108103811.GA1621@minipsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Paul Pearce <pearce@cs.berkeley.edu>, netdev@vger.kernel.org,
	tcpdump-workers@lists.tcpdump.org, davem@davemloft.net,
	edumazet@google.com, jpirko@redhat.com,
	Ani Sinha <ani@aristanetworks.com>
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:60457 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S935345Ab3BOHUU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Feb 2013 02:20:20 -0500
In-Reply-To: <20130108103811.GA1621@minipsycho.orion> (Jiri Pirko's message of
	"Tue, 8 Jan 2013 11:38:11 +0100")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jiri Pirko <jiri@resnulli.us> writes:

> Tue, Jan 08, 2013 at 01:05:39AM CET, pearce@cs.berkeley.edu wrote:
>>Hello folks,
>>
>>PROBLEM:
>>
>>vlan tagged packets that are injected via software are not picked up
>>by filters using recent (kernel commit
>>f3335031b9452baebfe49b8b5e55d3fe0c4677d1)
>>BPF vlan modifications. I suspect this is a problem with the Linux
>>kernel.
>>
>>linux-netdev and tcpdump-workers are both cc'd.
>>
>>BACKGROUND:
>>
>>Kernel commit bcc6d47903612c3861201cc3a866fb604f26b8b2 (Jiri
>>Pirko/David S. Miller) removed vlan headers on rx packets prior to
>>them reaching the packet filters. This broke BPF/libpcap's ability to
>>do kernel-level packet filtering based on vlan tag information (the
>>'vlan' keyword).
>>
>>Kernel commit f3335031b9452baebfe49b8b5e55d3fe0c4677d1 (Eric
>>Dumazet/David S. Miller, just merged into Linus's tree
>>http://git.kernel.org/?p=linux/kernel/git/torvalds/linux.git;a=commit;h=f3335031b9452baebfe49b8b5e55d3fe0c4677d1)
>>added the ability to use BPF to once again filter based on vlan
>>tags. Related bpf jit commit:
>>http://www.spinics.net/lists/netdev/msg214759.html
>>
>>libpcap (Ani Sinha) recently RFC'd a patch to use Eric/David's BPF
>>modifications to restore vlan filtering to libpcap.
>>http://www.mail-archive.com/tcpdump-workers@lists.tcpdump.org/msg06810.html
>>I'm using this patch and it works.
>>
>>DETAILS:
>>
>>Under these patches vlan tagged packets received from mediam (actual
>>packets from the wire) can be identified based on vlan tag information
>>using the new BPF functionality.This is good.
>>
>>However, raw vlan tagged packets that are *injected* into the
>>interface using libpcap's pcap_inject() (which is just a fancy wrapper
>>for the send() syscall) are not identified by filters using the recent
>>BPF modifications.
>>
>>The bug manifests itself if you attempt to use the new BPF
>>modifications to filter vlan tagged packets on a live interface. All
>>packets from the medium show up, but all injected packets are dropped.
>>
>>Prior to commit bcc6d47 both medium and injected packets could both be
>>identified using BPFs.
>>
>>These injected packets can however still be identified using the
>>previous, now incorrect "offset into the header" technique. Given
>>this, I suspect what's going on is the kernel code path for these
>>injected packets is not setting skb->vlan_tci correctly (at all?).
>>Since the vlan tag is not in the skb data structure the new BPF
>>modifications don't identify the packets as having a vlan tag,
>>despite it being in the packet header.
>
>
> You are right. skb->vlan_tci is not set. Looking at packet_snd() function
> in net/packet/af_packet.c I guess that something like following patch
> would be needed:
>
> diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
> index e639645..2238559 100644
> --- a/net/packet/af_packet.c
> +++ b/net/packet/af_packet.c
> @@ -2292,6 +2292,12 @@ static int packet_snd(struct socket *sock,
>  	if (unlikely(extra_len == 4))
>  		skb->no_fcs = 1;
>  
> +	if (skb->protocol == cpu_to_be16(ETH_P_8021Q)) {
> +		skb = vlan_untag(skb);
> +		if (unlikely(!skb))
> +			goto out_unlock;
> +	}
> +
>  	/*
>  	 *	Now send it
>  	 */
>
> Thoughts?

That sounds about right.  I don't know how much NIC drivers care but it
looks like af_packet is the only path through the code that can generate
a vlan tagged packet that we will transmit where a vlan tagged packet
can be generated without setting vlan_tci.  So it should make the code
safer.

Certainly we want this to look to the vlan driver like a proper case of
nested vlans and not something weird.

But note we need to handle tpacket_snd as well as packet_snd.

Eric
