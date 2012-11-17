From: Daniel Borkmann <danborkmann@iogearbox.net>
Subject: Re: [tcpdump-workers] vlan tagged packets and libpcap breakage
Date: Sun, 18 Nov 2012 00:16:49 +0100
Message-ID: <CAD6jFUQguS0oqGuA-HDFV2gd9m_=kZAvKJJq3ymr8zWM2cePXw@mail.gmail.com>
References: <CAOxq_8Nd8VP3MaNBfUt9v82nmGDpxZz5_5QMdsruET1tjwuQPw@mail.gmail.com>
	<3246.1351717319@obiwan.sandelman.ca>
	<CAOxq_8PsXb-oUy85Eji7GSAbUZD_Bds8skmGNP4BWSewQWx8PA@mail.gmail.com>
	<87mwyi9h1x.fsf@xmission.com>
	<12918.1353190488@obiwan.sandelman.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: tcpdump-workers@lists.tcpdump.org,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Ani Sinha <ani@aristanetworks.com>, netdev@vger.kernel.org,
	Francesco Ruggeri <fruggeri@aristanetworks.com>
To: Michael Richardson <mcr@sandelman.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:45839 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752325Ab2KQXQ5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 17 Nov 2012 18:16:57 -0500
Received: from [78.46.4.229] (helo=sslproxy03.your-server.de)
	by www62.your-server.de with esmtpsa (TLSv1:AES256-SHA:256)
	(Exim 4.74)
	(envelope-from <danborkmann@iogearbox.net>)
	id 1TZrdA-0000uR-5w
	for netdev@vger.kernel.org; Sun, 18 Nov 2012 00:16:56 +0100
Received: from [209.85.215.174] (helo=mail-ea0-f174.google.com)
	by sslproxy03.your-server.de with esmtpsa (TLS1.0:RSA_ARCFOUR_SHA1:16)
	(Exim 4.72)
	(envelope-from <danborkmann@iogearbox.net>)
	id 1TZrd6-0005Lq-WB
	for netdev@vger.kernel.org; Sun, 18 Nov 2012 00:16:53 +0100
Received: by mail-ea0-f174.google.com with SMTP id e13so1530009eaa.19
        for <netdev@vger.kernel.org>; Sat, 17 Nov 2012 15:16:49 -0800 (PST)
In-Reply-To: <12918.1353190488@obiwan.sandelman.ca>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Nov 17, 2012 at 11:14 PM, Michael Richardson <mcr@sandelman.ca> wrote:
>
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

Speaking of netsniff-ng where we don't reconstruct VLAN headers, users
have reported that depending on the NIC/driver resp. ethtool setting,
they can come in stripped or not (in the pf_packet's rx_ring buffer).
However, I assume VLAN AUXDATA is always consistent (and so the
BPF/BPF JIT filtering).

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
>
> What I hear you saying is that our existing code will work on older
> kernels, and that once we have new code to use the VLAN tag extensions,
> we should simply attempt to load it, and either it loads, or we get an
> error, and we go back to the code we had before.   That's great news.

Yes, this should be handled in such a way.
