From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: Netperf UDP issue with connected sockets
Date: Thu, 17 Nov 2016 09:16:38 +0100
Message-ID: <20161117091638.5fab8494@redhat.com>
References: <20140903165943.372b897b@redhat.com>
        <1409757426.26422.41.camel@edumazet-glaptop2.roam.corp.google.com>
        <20161116131609.4e5726b4@redhat.com>
        <7c4b43a4-74bf-1ee2-6f0d-17783b5d8fcb@hpe.com>
        <20161116234022.2bad179b@redhat.com>
        <1479342849.8455.233.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Rick Jones <rick.jones2@hpe.com>,
        "netdev@vger.kernel.org\" <netdev@vger.kernel.org>, brouer@redhat.com"@redhat.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:60988 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751059AbcKQIQm (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 17 Nov 2016 03:16:42 -0500
In-Reply-To: <1479342849.8455.233.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 16 Nov 2016 16:34:09 -0800
Eric Dumazet <eric.dumazet@gmail.com> wrote:

> On Wed, 2016-11-16 at 23:40 +0100, Jesper Dangaard Brouer wrote:
> 
> > Using -R 1 does not seem to help remove __ip_select_ident()
> > 
> > Samples: 56K of event 'cycles', Event count (approx.): 78628132661
> >   Overhead  Command        Shared Object        Symbol
> > +    9.11%  netperf        [kernel.vmlinux]     [k] __ip_select_ident
> > +    6.98%  netperf        [kernel.vmlinux]     [k] _raw_spin_lock
> > +    6.21%  swapper        [mlx5_core]          [k] mlx5e_poll_tx_cq
> > +    5.03%  netperf        [kernel.vmlinux]     [k] copy_user_enhanced_fast_string
> > +    4.69%  netperf        [kernel.vmlinux]     [k] __ip_make_skb
> > +    4.63%  netperf        [kernel.vmlinux]     [k] skb_set_owner_w
> > +    4.15%  swapper        [kernel.vmlinux]     [k] __slab_free
> > +    3.80%  netperf        [mlx5_core]          [k] mlx5e_sq_xmit
> > +    2.00%  swapper        [kernel.vmlinux]     [k] sock_wfree
> > +    1.94%  netperf        netperf              [.] send_data
> > +    1.92%  netperf        netperf              [.] send_omni_inner  
> 
> Check "ss -nu"  ?
> 
> You will see if sockets are connected (present in ss output or not)

Tested different versions of netperf, commands used below signature:

 netperf-2.6.0: connected "broken"
 netperf-2.7.0: connected works
 SVN-r709     : connected works

I noticed there is a Send-Q, and the perf-top2 is _raw_spin_lock, which
looks like it comes from __dev_queue_xmit(), but we know from
experience that this stall is actually caused by writing the
tailptr/doorbell in the HW.  Thus, this could benefit a lot from
bulk/xmit_more into the qdisc layer.


> UDP being connected does not prevent __ip_select_ident() being used.
> 
>     if ((iph->frag_off & htons(IP_DF)) && !skb->ignore_df) {
> 
> So you need IP_DF being set, and skb->ignore_df being 0

Thanks for explaining that! :-)

http://lxr.free-electrons.com/source/include/net/ip.h?v=4.8#L332
http://lxr.free-electrons.com/source/net/ipv4/ip_output.c?v=4.8#L449

Netperf UDP_STREAM default send 64K packets that get fragmented...
which actually is very unfortunate because people end-up testing a code
path in the kernel they didn't expect.  That is why I use the
option "-- -m 1472".


> time to try IP_MTU_DISCOVER ;)  

To Rick, maybe you can find a good solution or option with Eric's hint,
to send appropriate sized UDP packets with Don't Fragment (DF).

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer

Testing with ss -nua

$ /usr/local/stow/netperf-2.6.0-demo/bin/netperf -H 198.18.50.1 -t UDP_STREAM -l 3 -- -m 1472 -n -N > /dev/null & sleep 1; ss -una

State      Recv-Q Send-Q       Local Address:Port          Peer Address:Port
UNCONN     0      11520                    *:54589                    *:*

$ /usr/local/stow/netperf-2.7.0-demo/bin/netperf -H 198.18.50.1 -t UDP_STREAM -l 3 -- -m 1472 -n -N > /dev/null & sleep 1; ss -una
State      Recv-Q Send-Q       Local Address:Port          Peer Address:Port
ESTAB      0      18432          198.18.50.3:46803          198.18.50.1:51851

$ ~/tools/netperf2-svn/src/netperf -H 198.18.50.1 -t UDP_STREAM -l 3 -- -m 1472 -n -N > /dev/null & sleep 1; ss -una
State      Recv-Q Send-Q       Local Address:Port          Peer Address:Port
ESTAB      0      43776          198.18.50.3:42965          198.18.50.1:51948
