From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: Re: [PATCH v3] net: ip, diag -- Add diag interface for raw sockets
Date: Fri, 16 Sep 2016 23:07:22 +0300
Message-ID: <20160916200722.GA26044@uranus.lan>
References: <20160915210126.GC1867@uranus.lan>
 <1473979691.22679.55.camel@edumazet-glaptop3.roam.corp.google.com>
 <999f0ddb-82e4-ea07-b52a-59d08bc7816d@cumulusnetworks.com>
 <20160916070623.GD1867@uranus.lan>
 <20160916190000.GA18116@uranus.lan>
 <59e12627-7043-fd20-0d68-899ab43b0e71@cumulusnetworks.com>
 <20160916193927.GB18116@uranus.lan>
 <d943c6b7-0f06-3823-58d2-6f79f17c3d59@cumulusnetworks.com>
 <20160916195252.GC18116@uranus.lan>
 <6464ac16-a15b-384e-ffb1-3ee84cdce313@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, David Miller <davem@davemloft.net>,
        kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
        kaber@trash.net, avagin@openvz.org, stephen@networkplumber.org
To: David Ahern <dsa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f67.google.com ([209.85.215.67]:35935 "EHLO
        mail-lf0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S965528AbcIPUH1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 16 Sep 2016 16:07:27 -0400
Content-Disposition: inline
In-Reply-To: <6464ac16-a15b-384e-ffb1-3ee84cdce313@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Sep 16, 2016 at 01:55:42PM -0600, David Ahern wrote:
> >> Since the display is showing sockets in addition to IPPROTO_RAW:
> >>
> >> $ ss -A raw
> >> State      Recv-Q Send-Q        Local Address:Port                         Peer Address:Port
> >> UNCONN     0      0                    *%eth0:icmp                                    *:*
> >>
> >> It is going to be confusing if only ipproto-255 sockets can be killed.
> > 
> > OK, gimme some time to implement it. Hopefully on the weekend or monday.
> > Thanks a huge for feedback!
> > 
> 
> It may well be a ss bug / problem. As I mentioned I am always seeing 255 for the protocol which

It is rather not addressed in ss. I mean, look, when we send out a diag packet
the kernel look ups for a handler, which for raw protocol we register as

static const struct inet_diag_handler raw_diag_handler = {
	.dump= raw_diag_dump,
	.dump_one= raw_diag_dump_one,
	.idiag_get_info= raw_diag_get_info,
	.idiag_type= IPPROTO_RAW,
	.idiag_info_size= 0,
#ifdef CONFIG_INET_DIAG_DESTROY
	.destroy= raw_diag_destroy,
#endif
};

so if we patch ss and ask for IPPROTO_ICMP in netlink packet the
kernel simply won't find anything. Thus I think we need (well, I need)
to extend the patch and register IPPROTO_ICMP diag type, then
extend ss as well. (If only I didn't miss somethin obvious).

> is odd since ss does a dump and takes the matches and invokes the kill. Thanks for taking
> the time to do the kill piece.

Sure!
