From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH net] xfrm: calculate L4 checksums also for GSO case
 before encrypting packets
Date: Thu, 27 Apr 2017 11:04:04 +0200
Message-ID: <20170427090404.GY2649@secunet.com>
References: <1491849727-32008-1-git-send-email-aatteka@ovn.org>
 <20170411070755.GW5092@secunet.com>
 <CAMQa7Biajree5Kc1fOWQN42R1UDDGp7ZevZZRtUMZOKDWTk-Vw@mail.gmail.com>
 <20170418090919.GD30104@secunet.com>
 <CAMQa7Bimd378QJgsv6yBP0ULH+__C9gjjcXa39wx1z7p_9mT=g@mail.gmail.com>
 <20170420094743.GI2649@secunet.com>
 <CAMQa7Bgn58eWhwH-tOJcoNoF7ATs5yBpAyu1rR4JN5=8pBdaMA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Ansis Atteka <aatteka@ovn.org>, <netdev@vger.kernel.org>
To: Ansis Atteka <ansisatteka@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([62.96.220.36]:57168 "EHLO a.mx.secunet.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1032291AbdD0JXI (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 27 Apr 2017 05:23:08 -0400
Content-Disposition: inline
In-Reply-To: <CAMQa7Bgn58eWhwH-tOJcoNoF7ATs5yBpAyu1rR4JN5=8pBdaMA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Apr 21, 2017 at 02:45:17PM -0700, Ansis Atteka wrote:
> 
> I removed Geneve tunneling from equation and tried to run a simple
> iperf underlay UDP test while IPsec was still enabled to observe
> issues with the udp4_ufo_fragment() case.
> 
> Unfortunately, as can be seen from kernel tracer output below, I was
> unable to come up with a test case where udp4_ufo_fragment function
> would ever be invoked while IPsec is enabled:
> 
> admin1@ubuntu1:~/xfrm_test/net$ ifconfig em2.4001 | grep "inet addr"
>           inet addr:192.168.1.1  Bcast:192.168.1.255  Mask:255.255.255.0
> admin1@ubuntu1:~/xfrm_test/net$ ethtool -k em2.4001 | grep
> udp-fragmentation-offload
> udp-fragmentation-offload: on
> admin1@ubuntu1:~/xfrm_test/net$ sudo trace-cmd record -p
> function_graph -c -F iperf -c 192.168.1.2 -u -l20000
> admin1@ubuntu1:~/xfrm_test/net$ trace-cmd report | grep udp4
> admin1@ubuntu1:~/xfrm_test/net$
> 
> 
> Nevertheless, after disabling IPsec and leaving everything else the
> same, I start to see that udp4_ufo_fragment() gets invoked:
> 
> admin1@ubuntu1:~/xfrm_test/net$ trace-cmd report | grep udp4
>            iperf-25466 [004] 242431.203307: funcgraph_entry:
> 0.113 us   |                  udp4_hwcsum();
>            iperf-25466 [004] 242431.203360: funcgraph_entry:
>         |
> udp4_ufo_fragment() {
>            iperf-25466 [004] 242431.508436: funcgraph_entry:
> 0.080 us   |                  udp4_hwcsum();
>            iperf-25466 [004] 242431.508542: funcgraph_entry:
>         |
> udp4_ufo_fragment() {
> 
> 
> However, non-IPsec case really does not have this ESP packet
> corruption problem, because then the packets are in plain and can
> utilize checksum offloads. Do we really have a problem there for
> IPsec?

Probably not, at least locally generated packets don't do
ufo if they have an IPsec route. So it seems to be ok to
leave udp4_ufo_fragment as it is.
