From: Ani Sinha <ani@aristanetworks.com>
Subject: Re: [tcpdump-workers] vlan tagged packets and libpcap breakage
Date: Mon, 17 Dec 2012 11:49:15 -0800
Message-ID: <CAOxq_8PXR=xV+DrY5tPueRBygaKkRhpMwzZKJc6-nXWjSLOCsg@mail.gmail.com>
References: <CAOxq_8Nd8VP3MaNBfUt9v82nmGDpxZz5_5QMdsruET1tjwuQPw@mail.gmail.com>
	<3246.1351717319@obiwan.sandelman.ca>
	<CAOxq_8PsXb-oUy85Eji7GSAbUZD_Bds8skmGNP4BWSewQWx8PA@mail.gmail.com>
	<21992.1351723328@obiwan.sandelman.ca>
	<alpine.OSX.2.00.1212121205040.78903@animac.local>
	<50C9936B.2000201@redhat.com>
	<CAOxq_8PuMF2n80g30aXbPFQyo6UfsypZOHREjB36dnnp87nv=A@mail.gmail.com>
	<CAD6jFUTht82HOjGjDU7hFCEWyE3TOx_W4_j=SZK-DrcGfrio-A@mail.gmail.com>
	<AE90C24D6B3A694183C094C60CF0A2F6026B70EF@saturn3.aculab.com>
	<DE6D5B28-FA1E-4F04-9BDF-F6D35878776E@alum.mit.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: David Laight <David.Laight@aculab.com>,
	Daniel Borkmann <danborkmann@iogearbox.net>,
	netdev@vger.kernel.org, Michael Richardson <mcr@sandelman.ca>,
	tcpdump-workers@lists.tcpdump.org,
	Francesco Ruggeri <fruggeri@aristanetworks.com>
To: Guy Harris <guy@alum.mit.edu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vc0-f174.google.com ([209.85.220.174]:48966 "EHLO
	mail-vc0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752559Ab2LQTtQ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Dec 2012 14:49:16 -0500
Received: by mail-vc0-f174.google.com with SMTP id d16so7752708vcd.19
        for <netdev@vger.kernel.org>; Mon, 17 Dec 2012 11:49:15 -0800 (PST)
In-Reply-To: <DE6D5B28-FA1E-4F04-9BDF-F6D35878776E@alum.mit.edu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Dec 17, 2012 at 2:35 AM, Guy Harris <guy@alum.mit.edu> wrote:
>
> On Dec 17, 2012, at 1:50 AM, "David Laight" <David.Laight@ACULAB.COM> wrote:
>
>> How are you going to tell whether a feature is present in a non-Linux
>> kernel ?
>
> The Linux memory-mapped capture mechanism is not present in a non-Linux kernel, so all the libpcap work involved here would, if necessary on other platforms, have to be done >differently on those platforms.  Those platforms would have to have their own mechanisms to indicate whether any changes to filter code, processing of VLAN tags supplied out of >band, etc. would need to be done.

Actually lib-pcap has these pcap-<platform>.c files that are kind of
like platform specific drivers that plug into platform independent
code like gencode.c or bpf_filter.c. These platform specific drivers
are responsible for getting packets from the kernel and running
filters (kernel or userland) on it. So all linux specific code to get
a packet and packet metadata from the kernel can neatly reside in
pcap-linux.c.

Unfortunately though, in this specific problem involving filtering
with vlan tags, both code generation (gentags.c) and code running the
filter (bpf_filter.c) will have to be aware of linux specific
semantics. Due to the issues that Bill had explained earlier in the
thread, we can not rely on post processing before installing the
kernel filter. Therefore, we need to generate a filter that can be
directly installed in the kernel. For the same reason, bpf_filter()
code also needs to change - be aware of linux specific semantics.
