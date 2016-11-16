From: Rick Jones <rick.jones2@hpe.com>
Subject: Re: Netperf UDP issue with connected sockets
Date: Wed, 16 Nov 2016 09:46:37 -0800
Message-ID: <7c4b43a4-74bf-1ee2-6f0d-17783b5d8fcb@hpe.com>
References: <20140903165943.372b897b@redhat.com>
 <1409757426.26422.41.camel@edumazet-glaptop2.roam.corp.google.com>
 <20161116131609.4e5726b4@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Eric Dumazet <eric.dumazet@gmail.com>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t3428.houston.hpe.com ([15.241.140.76]:33922 "EHLO
        g4t3428.houston.hpe.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753924AbcKPRqj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 16 Nov 2016 12:46:39 -0500
In-Reply-To: <20161116131609.4e5726b4@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/16/2016 04:16 AM, Jesper Dangaard Brouer wrote:
> [1] Subj: High perf top ip_idents_reserve doing netperf UDP_STREAM
>  - https://www.spinics.net/lists/netdev/msg294752.html
>
> Not fixed in version 2.7.0.
>  - ftp://ftp.netperf.org/netperf/netperf-2.7.0.tar.gz
>
> Used extra netperf configure compile options:
>  ./configure  --enable-histogram --enable-demo
>
> It seems like some fix attempts exists in the SVN repository::
>
>  svn checkout http://www.netperf.org/svn/netperf2/trunk/ netperf2-svn
>  svn log -r709
>  # A quick stab at getting remote connect going for UDP_STREAM
>  svn diff -r708:709
>
> Testing with SVN version, still show __ip_select_ident() in top#1.

Indeed, there was a fix for getting the remote side connect()ed. 
Looking at what I have for the top of trunk I do though see a connect() 
call being made at the local end:

socket(PF_INET, SOCK_DGRAM, IPPROTO_UDP) = 4
getsockopt(4, SOL_SOCKET, SO_SNDBUF, [212992], [4]) = 0
getsockopt(4, SOL_SOCKET, SO_RCVBUF, [212992], [4]) = 0
setsockopt(4, SOL_SOCKET, SO_REUSEADDR, [1], 4) = 0
bind(4, {sa_family=AF_INET, sin_port=htons(0), 
sin_addr=inet_addr("0.0.0.0")}, 16) = 0
setsockopt(4, SOL_SOCKET, SO_DONTROUTE, [1], 4) = 0
setsockopt(4, SOL_IP, IP_RECVERR, [1], 4) = 0
brk(0xe53000)                           = 0xe53000
getsockname(4, {sa_family=AF_INET, sin_port=htons(59758), 
sin_addr=inet_addr("0.0.0.0")}, [16]) = 0
sendto(3, 
"\0\0\0a\377\377\377\377\377\377\377\377\377\377\377\377\0\0\0\10\0\0\0\0\0\0\0\321\377\377\377\377"..., 
656, 0, NULL, 0) = 656
select(1024, [3], NULL, NULL, {120, 0}) = 1 (in [3], left {119, 995630})
recvfrom(3, 
"\0\0\0b\0\0\0\0\0\3@\0\0\3@\0\0\0\0\2\0\3@\0\377\377\377\377\0\0\0\321"..., 
656, 0, NULL, NULL) = 656
write(1, "need to connect is 1\n", 21)  = 21
rt_sigaction(SIGALRM, {0x402ea6, [ALRM], SA_RESTORER|SA_INTERRUPT, 
0x7f2824eb2cb0}, NULL, 8) = 0
rt_sigaction(SIGINT, {0x402ea6, [INT], SA_RESTORER|SA_INTERRUPT, 
0x7f2824eb2cb0}, NULL, 8) = 0
alarm(1)                                = 0
connect(4, {sa_family=AF_INET, sin_port=htons(34832), 
sin_addr=inet_addr("127.0.0.1")}, 16) = 0
sendto(4, "netperf\0netperf\0netperf\0netperf\0"..., 1024, 0, NULL, 0) = 
1024
sendto(4, "netperf\0netperf\0netperf\0netperf\0"..., 1024, 0, NULL, 0) = 
1024
sendto(4, "netperf\0netperf\0netperf\0netperf\0"..., 1024, 0, NULL, 0) = 
1024

the only difference there with top of trunk is that "need to connect" 
write/printf I just put in the code to be a nice marker in the system 
call trace.

It is a wild guess, but does setting SO_DONTROUTE affect whether or not 
a connect() would have the desired effect?  That is there to protect 
people from themselves (long story about people using UDP_STREAM to 
stress improperly air-gapped systems during link up/down testing....) 
It can be disabled with a test-specific -R 1 option, so your netperf 
command would become:

netperf -H 198.18.50.1 -t UDP_STREAM -l 120 -- -m 1472 -n -N -R 1

>
> (p.s. is netperf ever going to be converted from SVN to git?)
>

Well....  my git-fu could use some work (gentle, offlinetaps with a 
clueful tutorial bat would be welcome), and at least in the past, going 
to git was held back because there were a bunch of netperf users on 
Windows and there wasn't (at the time) support for git under Windows.

But I am not against the idea in principle.

happy benchmarking,

rick jones

PS - rick.jones@hp.com no longer works.  rick.jones2@hpe.com should be 
used instead.
