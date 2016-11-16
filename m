From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: Netperf UDP issue with connected sockets
Date: Wed, 16 Nov 2016 23:40:22 +0100
Message-ID: <20161116234022.2bad179b@redhat.com>
References: <20140903165943.372b897b@redhat.com>
        <1409757426.26422.41.camel@edumazet-glaptop2.roam.corp.google.com>
        <20161116131609.4e5726b4@redhat.com>
        <7c4b43a4-74bf-1ee2-6f0d-17783b5d8fcb@hpe.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Eric Dumazet <eric.dumazet@gmail.com>, brouer@redhat.com
To: Rick Jones <rick.jones2@hpe.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:36796 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1422817AbcKPWk0 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 16 Nov 2016 17:40:26 -0500
In-Reply-To: <7c4b43a4-74bf-1ee2-6f0d-17783b5d8fcb@hpe.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 16 Nov 2016 09:46:37 -0800
Rick Jones <rick.jones2@hpe.com> wrote:

> On 11/16/2016 04:16 AM, Jesper Dangaard Brouer wrote:
> > [1] Subj: High perf top ip_idents_reserve doing netperf UDP_STREAM
> >  - https://www.spinics.net/lists/netdev/msg294752.html
> >
> > Not fixed in version 2.7.0.
> >  - ftp://ftp.netperf.org/netperf/netperf-2.7.0.tar.gz
> >
> > Used extra netperf configure compile options:
> >  ./configure  --enable-histogram --enable-demo
> >
> > It seems like some fix attempts exists in the SVN repository::
> >
> >  svn checkout http://www.netperf.org/svn/netperf2/trunk/ netperf2-svn
> >  svn log -r709
> >  # A quick stab at getting remote connect going for UDP_STREAM
> >  svn diff -r708:709
> >
> > Testing with SVN version, still show __ip_select_ident() in top#1.  
> 
> Indeed, there was a fix for getting the remote side connect()ed. 
> Looking at what I have for the top of trunk I do though see a connect() 
> call being made at the local end:
> 
> socket(PF_INET, SOCK_DGRAM, IPPROTO_UDP) = 4
> getsockopt(4, SOL_SOCKET, SO_SNDBUF, [212992], [4]) = 0
> getsockopt(4, SOL_SOCKET, SO_RCVBUF, [212992], [4]) = 0
> setsockopt(4, SOL_SOCKET, SO_REUSEADDR, [1], 4) = 0
> bind(4, {sa_family=AF_INET, sin_port=htons(0), 
> sin_addr=inet_addr("0.0.0.0")}, 16) = 0
> setsockopt(4, SOL_SOCKET, SO_DONTROUTE, [1], 4) = 0
> setsockopt(4, SOL_IP, IP_RECVERR, [1], 4) = 0
> brk(0xe53000)                           = 0xe53000
> getsockname(4, {sa_family=AF_INET, sin_port=htons(59758), 
> sin_addr=inet_addr("0.0.0.0")}, [16]) = 0
> sendto(3, 
> "\0\0\0a\377\377\377\377\377\377\377\377\377\377\377\377\0\0\0\10\0\0\0\0\0\0\0\321\377\377\377\377"..., 
> 656, 0, NULL, 0) = 656
> select(1024, [3], NULL, NULL, {120, 0}) = 1 (in [3], left {119, 995630})
> recvfrom(3, 
> "\0\0\0b\0\0\0\0\0\3@\0\0\3@\0\0\0\0\2\0\3@\0\377\377\377\377\0\0\0\321"..., 
> 656, 0, NULL, NULL) = 656
> write(1, "need to connect is 1\n", 21)  = 21
> rt_sigaction(SIGALRM, {0x402ea6, [ALRM], SA_RESTORER|SA_INTERRUPT, 
> 0x7f2824eb2cb0}, NULL, 8) = 0
> rt_sigaction(SIGINT, {0x402ea6, [INT], SA_RESTORER|SA_INTERRUPT, 
> 0x7f2824eb2cb0}, NULL, 8) = 0
> alarm(1)                                = 0
> connect(4, {sa_family=AF_INET, sin_port=htons(34832), 
> sin_addr=inet_addr("127.0.0.1")}, 16) = 0
> sendto(4, "netperf\0netperf\0netperf\0netperf\0"..., 1024, 0, NULL, 0) = 
> 1024
> sendto(4, "netperf\0netperf\0netperf\0netperf\0"..., 1024, 0, NULL, 0) = 
> 1024
> sendto(4, "netperf\0netperf\0netperf\0netperf\0"..., 1024, 0, NULL, 0) = 
> 1024
> 
> the only difference there with top of trunk is that "need to connect" 
> write/printf I just put in the code to be a nice marker in the system 
> call trace.
> 
> It is a wild guess, but does setting SO_DONTROUTE affect whether or not 
> a connect() would have the desired effect?  That is there to protect 
> people from themselves (long story about people using UDP_STREAM to 
> stress improperly air-gapped systems during link up/down testing....) 
> It can be disabled with a test-specific -R 1 option, so your netperf 
> command would become:
> 
> netperf -H 198.18.50.1 -t UDP_STREAM -l 120 -- -m 1472 -n -N -R 1

Using -R 1 does not seem to help remove __ip_select_ident()

Samples: 56K of event 'cycles', Event count (approx.): 78628132661
  Overhead  Command        Shared Object        Symbol
+    9.11%  netperf        [kernel.vmlinux]     [k] __ip_select_ident
+    6.98%  netperf        [kernel.vmlinux]     [k] _raw_spin_lock
+    6.21%  swapper        [mlx5_core]          [k] mlx5e_poll_tx_cq
+    5.03%  netperf        [kernel.vmlinux]     [k] copy_user_enhanced_fast_string
+    4.69%  netperf        [kernel.vmlinux]     [k] __ip_make_skb
+    4.63%  netperf        [kernel.vmlinux]     [k] skb_set_owner_w
+    4.15%  swapper        [kernel.vmlinux]     [k] __slab_free
+    3.80%  netperf        [mlx5_core]          [k] mlx5e_sq_xmit
+    2.00%  swapper        [kernel.vmlinux]     [k] sock_wfree
+    1.94%  netperf        netperf              [.] send_data
+    1.92%  netperf        netperf              [.] send_omni_inner


> >
> > (p.s. is netperf ever going to be converted from SVN to git?)
> >  
> 
> Well....  my git-fu could use some work (gentle, offlinetaps with a 
> clueful tutorial bat would be welcome), and at least in the past, going 
> to git was held back because there were a bunch of netperf users on 
> Windows and there wasn't (at the time) support for git under Windows.
> 
> But I am not against the idea in principle.

Once you have learned git, you will never go back to SVN. Just do it! :-)

Here are even nice writeups of how to convert and preserve history:
 http://john.albin.net/git/convert-subversion-to-git

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer
