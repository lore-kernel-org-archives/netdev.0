From: David Ahern <dsahern@gmail.com>
Subject: Re: [RFC PATCH 00/29] net: VRF support
Date: Tue, 10 Feb 2015 21:14:21 -0700
Message-ID: <54DAD71D.1060400@gmail.com>
References: <1423100070-31848-1-git-send-email-dsahern@gmail.com>	<20150205173334.08248382@uryu.home.lan> <54D4227B.6080709@gmail.com>	<87r3u3vfpr.fsf@x220.int.ebiederm.org> <54D45C15.7090602@gmail.com> <87iofe7n1x.fsf@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	netdev@vger.kernel.org,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	roopa <roopa@cumulusnetworks.com>, hannes@stressinduktion.org,
	Dinesh Dutt <ddutt@cumulusnetworks.com>,
	Vipin Kumar <vipin@cumulusnetworks.com>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f176.google.com ([209.85.213.176]:58677 "EHLO
	mail-ig0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750840AbbBKEOX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Feb 2015 23:14:23 -0500
Received: by mail-ig0-f176.google.com with SMTP id hl2so28428890igb.3
        for <netdev@vger.kernel.org>; Tue, 10 Feb 2015 20:14:22 -0800 (PST)
In-Reply-To: <87iofe7n1x.fsf@x220.int.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2/6/15 2:22 PM, Eric W. Biederman wrote:
> I think you have also introduced a second layer of indirection and thus
> an extra cache-line miss with net_ctx.  At 60ns-100ns per cache line
> miss that could be significant.
>
> Overall the standard should be that there is no measurable performance
> overhead with something like this enabled.  At least at 1Gbps we were
> able to demonstrate there was not measuable performance impact with
> network namespaces before they were merged.
>
> Eric
>

Here's a quick look at performance impacts of this patch set.

Host:
     Fedora 21
     Intel(R) Core(TM) i7-4770 CPU @ 3.40GHz
     1 socket, 4 cores, 8 threads

VM:
     Fedora 21
     2 vcpus, cpu model is 'host,x2apic'
     1G RAM
     network: virtio + vhost with tap device connected to a bridge

Tests are between host OS and VM (RX: netperf in host; TX: netperf in 
guest; netserver is the reverse).

No tweaks have been done to the default Fedora settings. In particular 
all of the offloads that default to enabled on tap devices and virtio 
devices are left enabled. Specifically, these offloads are what 
accelerate the stream tests to the 40,000 Mbps range and hence really 
stress the overhead. Nor has any cpu pinning been done or any other 
attempts at optimizations.

Commands:
     netperf -l 10 -t TCP_STREAM -H <ip>
     netperf -l 10 -t TCP_RR -H <ip>

Results are the average of 3 runs:

                       pre-VRF          with VRF
                       TX      RX       TX     RX
TCP Stream (Mbps)   39503    40325    39856  38211
TCP RR (trans/sec)  46047    46512    47619  43032

* pre-VRF means commit id 7e8acbb69ee2 which is the commit id before 
this patch st
* with VRF = patches posted in this thread

The VM setup definitely pushes some limits and represents an extreme in 
performance comparisons. While the VRF patches do show a degradation in 
RX performance the delta is fairly small. As I mentioned before I can 
remove the vrf tagging to skbs which should help. Overall I have focused 
more on concept than the performance; I'm sure that delta can be reduced.

David
