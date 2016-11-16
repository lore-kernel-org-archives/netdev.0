From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Netperf UDP issue with connected sockets
Date: Wed, 16 Nov 2016 13:16:09 +0100
Message-ID: <20161116131609.4e5726b4@redhat.com>
References: <20140903165943.372b897b@redhat.com>
        <1409757426.26422.41.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Rick Jones <rick.jones2@hpe.com>, brouer@redhat.com,
        Eric Dumazet <eric.dumazet@gmail.com>
To: Rick Jones <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:49910 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752679AbcKPMQN (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 16 Nov 2016 07:16:13 -0500
In-Reply-To: <1409757426.26422.41.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


While optimizing the kernel RX path, I've run into an issue where I
cannot use netperf UDP_STREAM for testing, because the sender is
slower than receiver.  Thus, it cannot show my receiver improvements
(as receiver have idle cycles).

Eric Dumazet previously told me[1] this was related to netperf need to
use connected socket for UDP.  Netperf options "-- -n -N" should
enable connected UDP sockets, but it never worked! Options are
documented, but netperf seems to have a bug.

Called like:
 netperf -H 198.18.50.1 -t UDP_STREAM -l 120 -- -m 1472 -n -N

Problem on sender-side is "__ip_select_ident".

 Samples: 15K of event 'cycles', Event count (approx.): 16409681913
   Overhead  Command         Shared Object     Symbol
 +   11.18%  netperf         [kernel.vmlinux]  [k] __ip_select_ident
 +    6.93%  netperf         [kernel.vmlinux]  [k] _raw_spin_lock
 +    6.12%  netperf         [kernel.vmlinux]  [k] copy_user_enhanced_fast_string
 +    4.31%  netperf         [kernel.vmlinux]  [k] __ip_make_skb
 +    3.97%  netperf         [kernel.vmlinux]  [k] fib_table_lookup
 +    3.51%  netperf         [mlx5_core]       [k] mlx5e_sq_xmit
 +    2.43%  netperf         [kernel.vmlinux]  [k] __ip_route_output_key_hash
 +    2.24%  netperf         netperf           [.] send_omni_inner
 +    2.17%  netperf         netperf           [.] send_data

[1] Subj: High perf top ip_idents_reserve doing netperf UDP_STREAM
 - https://www.spinics.net/lists/netdev/msg294752.html

Not fixed in version 2.7.0.
 - ftp://ftp.netperf.org/netperf/netperf-2.7.0.tar.gz

Used extra netperf configure compile options:
 ./configure  --enable-histogram --enable-demo

It seems like some fix attempts exists in the SVN repository::

 svn checkout http://www.netperf.org/svn/netperf2/trunk/ netperf2-svn
 svn log -r709
 # A quick stab at getting remote connect going for UDP_STREAM
 svn diff -r708:709

Testing with SVN version, still show __ip_select_ident() in top#1.

(p.s. is netperf ever going to be converted from SVN to git?)
-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer

(old email below)

On Wed, 03 Sep 2014 08:17:06 -0700
Eric Dumazet <eric.dumazet@gmail.com> wrote:

> On Wed, 2014-09-03 at 16:59 +0200, Jesper Dangaard Brouer wrote:
> > Hi Eric,
> > 
> > When doing:
> >  super_netperf 120 -H 192.168.8.2 -t UDP_STREAM -l 100 -- -m 256
> > 
> > I'm seeing function ip_idents_reserve() consuming most CPU.  Could you
> > help, explain what is going on, and how I can avoid this?
> > 
> > Perf top:
> >   11.67%  [kernel]   [k] ip_idents_reserve
> >    8.37%  [kernel]   [k] fib_table_lookup
> >    4.46%  [kernel]   [k] _raw_spin_lock
> >    3.21%  [kernel]   [k] copy_user_enhanced_fast_string
> >    2.92%  [kernel]   [k] sock_alloc_send_pskb
> >    2.88%  [kernel]   [k] udp_sendmsg
> >   
> 
> Because you use a single destination, all flows compete on a single
> atomic to get their next IP identifier.
> 
> You can try to use netperf options  (-- -N -n) so that netperf uses
> connected UDP sockets.
> 
> In this case, the IP identifier generator is held in each socket.
 
