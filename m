From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [tcpdump-workers] vlan tagged packets and libpcap breakage
Date: Sat, 17 Nov 2012 15:33:32 -0800
Message-ID: <87obivu7n7.fsf@xmission.com>
References: <CAOxq_8Nd8VP3MaNBfUt9v82nmGDpxZz5_5QMdsruET1tjwuQPw@mail.gmail.com>
	<3246.1351717319@obiwan.sandelman.ca>
	<CAOxq_8PsXb-oUy85Eji7GSAbUZD_Bds8skmGNP4BWSewQWx8PA@mail.gmail.com>
	<87mwyi9h1x.fsf@xmission.com> <12918.1353190488@obiwan.sandelman.ca>
Mime-Version: 1.0
Content-Type: text/plain
Cc: tcpdump-workers@lists.tcpdump.org,
	Ani Sinha <ani@aristanetworks.com>, netdev@vger.kernel.org,
	Francesco Ruggeri <fruggeri@aristanetworks.com>
To: Michael Richardson <mcr@sandelman.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out03.mta.xmission.com ([166.70.13.233]:52908 "EHLO
	out03.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752317Ab2KQXdq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 17 Nov 2012 18:33:46 -0500
In-Reply-To: <12918.1353190488@obiwan.sandelman.ca> (Michael Richardson's
	message of "Sat, 17 Nov 2012 17:14:48 -0500")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Michael Richardson <mcr@sandelman.ca> writes:

> Thank you for this reply.
>
>>>>>> "Eric" == Eric W Biederman <ebiederm@xmission.com> writes:
>     Eric> I don't see any need to add any kernel code to allow checking
>     Eric> if vlan tags are stripped.  Vlan headers are stripped on all
>     Eric> kernel interfaces today.  Vlan headers have been stripped on
>     Eric> all but a handful of software interfaces for 6+ years.  For
>     Eric> all kernels if the vlan header is stripped it is reported in
>     Eric> the auxdata, upon packet reception.  Careful code should also
>     Eric> look for TP_STATUS_VLAN_VALID which allows for distinguishing
>     Eric> a striped vlan header of 0 from no vlan header.
>
> I can regularly see vlan tags on raw dumps from the untagged ("eth0")
> today, running 3.2 (debian stable):
>
> obiwan-[~] mcr 4848 %sudo tcpdump -i eth0 -n -p -e | grep -i vlan
> listening on eth0, link-type EN10MB (Ethernet), capture size 65535 bytes
> 17:05:15.404909 38:60:77:38:e6:47 > ff:ff:ff:ff:ff:ff, ethertype 802.1Q (0x8100), length 46: vlan 3800, p 0, ethertype ARP, Request who-has 172.30.42.1 tell 172.30.42.11, length 28
>
> So, I'm curious about the statement that vlan tags have been stripped
> for some time, because I don't see them stripped today.  My desktop has
> an Intel 82579V NIC in it...

So I just took a quick look at libpcap 1.1.1.1.

In pcap_read_packet in pcap-linux.c the code to readd the vlan header is
protected by HAVE_PACKET_AUXDATA.

In pcap_read_linux_mmap in pcap-linux.c the code to readd the vlan
header is protected by HAVE_TPACKET2.

That code is shifting the the ethernet header up 4 bytes and inserting
the vlan header in packets as we receive them.

The code is correct except for the case of packets in vlan 0.  Currently
the packet reconstruction is ambiguous.  The most recent kernels have
a TP_STATUS_VLAN_VALID flag that can be checked to see if the packet was
in vlan 0 or if there was no vlan at all.  libpcap probably should be
taught how to handle TP_STATUS_VLAN_VALID so that it can get the vlan 0
handling correct.

>     Eric> For old kernels that do not support the new extensions it is
>     Eric> possible to generate code that looks at the ethernet header
>     Eric> and sees if the ethertype is 0x8100 and then does things with
>     Eric> it, but that will only work on a small handful of software
>     Eric> only interfaces.
>
> at tcpdump.org, our concern is to release code that works on both new,
> and what for kernel.org folks would be considered "ancient" systems,
> such as Centos5/RHEL5 machines which are regularly still in production
> in the field (sadly...), but often need the latest diagnostics.

> What I hear you saying is that our existing code will work on older
> kernels, and that once we have new code to use the VLAN tag extensions,
> we should simply attempt to load it, and either it loads, or we get an 
> error, and we go back to the code we had before.   That's great news.

The existing code will work as well as anything if you don't have the
VLAN tag extensions.  If you are not using the VLAN tag extensions there
is no reliable way to filter for vlan tagged packets in the kernel as on
most network devices (all for the last year) the vlan header has been
stripped at the time the bpf filter is run.

So yes.  Just falling back to the existing code seems as good as it is
going to get.  Which isn't very good but it took 5+ years before people
cared enough to get this fixed. :(

> The major concern is that if the 802.1q header is gone, although we can
> retrieve it somehow (I'm not sure how the AUXDATA is presented on the
> MMAP PF_PACKET interface...) we will have to reconstruct it in order to
> save it properly to a savefile.  Many entities, including most major
> Network Telescopes (http://en.wikipedia.org/wiki/Network_telescope) use
> libpcap (and often tcpdump itself) to capture packets on probe points,
> and having good performance matters here... 

Yes.  I wasn't looking at the mmap path.  The vlan information is
present in the tpacket2_hdr and tpacket3_hdr structures that accompany
packets read with the mmap interface.  The old tpacket1_hdr doesn't
support the vlan_tci information so that won't work.

Not having the vlan header on the packet when the bpf filter is run is
justified by performance, and likewise reading vlan tagged packets to
userspace with the vlan header stripped is justified by performance.

Eric
