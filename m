From: Daniel Borkmann <danborkmann@iogearbox.net>
Subject: Re: [tcpdump-workers] vlan tagged packets and libpcap breakage
Date: Thu, 13 Dec 2012 22:49:38 +0100
Message-ID: <CAD6jFUTht82HOjGjDU7hFCEWyE3TOx_W4_j=SZK-DrcGfrio-A@mail.gmail.com>
References: <CAOxq_8Nd8VP3MaNBfUt9v82nmGDpxZz5_5QMdsruET1tjwuQPw@mail.gmail.com>
	<3246.1351717319@obiwan.sandelman.ca>
	<CAOxq_8PsXb-oUy85Eji7GSAbUZD_Bds8skmGNP4BWSewQWx8PA@mail.gmail.com>
	<21992.1351723328@obiwan.sandelman.ca>
	<alpine.OSX.2.00.1212121205040.78903@animac.local>
	<50C9936B.2000201@redhat.com>
	<CAOxq_8PuMF2n80g30aXbPFQyo6UfsypZOHREjB36dnnp87nv=A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Michael Richardson <mcr@sandelman.ca>, netdev@vger.kernel.org,
	tcpdump-workers@lists.tcpdump.org,
	Francesco Ruggeri <fruggeri@aristanetworks.com>
To: Ani Sinha <ani@aristanetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:52131 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755699Ab2LMVtr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Dec 2012 16:49:47 -0500
Received: from [78.46.5.203] (helo=sslproxy01.your-server.de)
	by www62.your-server.de with esmtpsa (TLSv1:AES256-SHA:256)
	(Exim 4.74)
	(envelope-from <danborkmann@iogearbox.net>)
	id 1TjGf3-0004PF-K3
	for netdev@vger.kernel.org; Thu, 13 Dec 2012 22:49:45 +0100
Received: from [209.85.215.174] (helo=mail-ea0-f174.google.com)
	by sslproxy01.your-server.de with esmtpsa (TLS1.0:RSA_ARCFOUR_SHA1:16)
	(Exim 4.72)
	(envelope-from <danborkmann@iogearbox.net>)
	id 1TjGf8-00031R-C3
	for netdev@vger.kernel.org; Thu, 13 Dec 2012 22:49:50 +0100
Received: by mail-ea0-f174.google.com with SMTP id e13so971469eaa.19
        for <netdev@vger.kernel.org>; Thu, 13 Dec 2012 13:49:38 -0800 (PST)
In-Reply-To: <CAOxq_8PuMF2n80g30aXbPFQyo6UfsypZOHREjB36dnnp87nv=A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 13, 2012 at 6:34 PM, Ani Sinha <ani@aristanetworks.com> wrote:
> On Thu, Dec 13, 2012 at 12:35 AM, Daniel Borkmann <dborkman@redhat.com> wrote:
>> On 12/12/2012 10:53 PM, Ani Sinha wrote:
>>>>
>>>> unsigned int netdev_8021q_inskb = 1;
>>>>
>>>> ...
>>>>         {
>>>>                 .ctl_name       = NET_CORE_8021q_INSKB,
>>>>                 .procname       = "netdev_8021q_inskb",
>>>>                 .data           = &netdev_8021q_inskb,
>>>>                 .maxlen         = sizeof(int),
>>>>                 .mode           = 0444,
>>>>                 .proc_handler   = proc_dointvec
>>>>         },
>>>>
>>>> would seem to do it to me.
>>>> Then pcap can fopen("/proc/sys/net/core/netdev_8021q_inskb") and if it
>>>> finds it, and it is >0, then do the cmsg thing.
>>>>
>>
>> I think it doesn't. Because then you are obviously considering adding one
>> procfs file into /proc/sys/net/core/ *for each* feature that is added into
>> the ancillary ops which cannot be the right way ...
>
> We had already brought up this topic previously in the same thread. A
> suggestion was made to add that proc entry and no one from netdev
> responded to it saying that it did not make any sense. Therefore
> before I went ahead and made the fixes in libpcap, I wanted to run
> this by your guys again to make sure we are still on the same page.

Well, not everyone on netdev might be following this thread (resp.
following fully). The best way to get responses for a patch is to go
through the normal patch submission process on netdev, and if you like
to request for comments, then mark it as RFC in the subject. This way,
people will know and likely comment on it if it makes sense or not.

> I do agree that instead of a /proc entry, we should check for a kenrel
> version >= X where X is the upstream version that first started
> supporting all the features needed by libpcap for vlan filtering. This
> is not a compile time check but a run time one. Does anyone see any
> issues with this? Is there any long term implications of this, like if
> you backport patches to an older long term supported kernel? Are there
> other better ways to do this, like may be returning feature bits from
> an ioctl call? This is something we need to deal with on a continuous
> basis as we keep supporting newer AUX fields and libpcap and other
> user land code needs to make use of it. At the same time, they need to
> handle backward compatibility issues with older kernels.

As Eric mentioned earlier, for now there seems not to be a reliable
way to get to know which ops are present and which not. It's not
really nice, but if you want to make use of those new (ANC*) features,
probably checking kernel version might be the only way if I'm not
missing something. Now net-next is closed, but if it reopens, I'll
submit a version 2 of my patch where you've been CC'd to. If it gets
in, then at least it's for sure that since kernel <xyz> this kind of
feature test is present.
