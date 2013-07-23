From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] tcp: TCP_NOSENT_LOWAT socket option
Date: Mon, 22 Jul 2013 19:32:43 -0700
Message-ID: <1374546763.4990.116.camel@edumazet-glaptop>
References: <1374520422.4990.33.camel@edumazet-glaptop>
	 <51ED9957.9070107@hp.com> <1374533052.4990.89.camel@edumazet-glaptop>
	 <51EDBB8B.2000805@hp.com> <1374538422.4990.99.camel@edumazet-glaptop>
	 <1374540013.4990.100.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Yuchung Cheng <ycheng@google.com>,
	Neal Cardwell <ncardwell@google.com>,
	Michael Kerrisk <mtk.manpages@gmail.com>
To: Rick Jones <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f47.google.com ([209.85.219.47]:57545 "EHLO
	mail-oa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752015Ab3GWCcq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Jul 2013 22:32:46 -0400
Received: by mail-oa0-f47.google.com with SMTP id m1so69503oag.20
        for <netdev@vger.kernel.org>; Mon, 22 Jul 2013 19:32:46 -0700 (PDT)
In-Reply-To: <1374540013.4990.100.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2013-07-22 at 17:40 -0700, Eric Dumazet wrote:
> On Mon, 2013-07-22 at 17:13 -0700, Eric Dumazet wrote:
> 
> > 
> >  Performance counter stats for './netperf -H 10.246.17.84 -l 20 -t TCP_SENDFILE -c':
> > 
> >            714,395 context-switches                                            
> 
> Hmm, actually I need to send a v3, because sk_stream_write_space() is
> waking sockets too often.
> 

Yep, new results are more the expected ones :

lpq83:~# echo -1 >/proc/sys/net/ipv4/tcp_notsent_lowat
lpq83:~# perf stat -e context-switches ./netperf -H 10.246.17.84 -l 20 -t TCP_SENDFILE -c
TCP SENDFILE TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to 10.246.17.84 () port 0 AF_INET
Recv   Send    Send                          Utilization       Service Demand
Socket Socket  Message  Elapsed              Send     Recv     Send    Recv
Size   Size    Size     Time     Throughput  local    remote   local   remote
bytes  bytes   bytes    secs.    10^6bits/s  % S      % U      us/KB   us/KB

 87380  16384  16384    20.00      9408.18   1.60     -1.00    0.333   -1.000 

 Performance counter stats for './netperf -H 10.246.17.84 -l 20 -t TCP_SENDFILE -c':

            49,543 context-switches                                            

      20.005432791 seconds time elapsed

lpq83:~# echo 131072 >/proc/sys/net/ipv4/tcp_notsent_lowat
lpq83:~# perf stat -e context-switches ./netperf -H 10.246.17.84 -l 20 -t TCP_SENDFILE -c
TCP SENDFILE TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to 10.246.17.84 () port 0 AF_INET
Recv   Send    Send                          Utilization       Service Demand
Socket Socket  Message  Elapsed              Send     Recv     Send    Recv
Size   Size    Size     Time     Throughput  local    remote   local   remote
bytes  bytes   bytes    secs.    10^6bits/s  % S      % U      us/KB   us/KB

 87380  16384  16384    20.00      9407.71   1.55     -1.00    0.323   -1.000 

 Performance counter stats for './netperf -H 10.246.17.84 -l 20 -t TCP_SENDFILE -c':

           345,670 context-switches                                            

      20.004435166 seconds time elapsed


And the receiver disables LRO/GRO, no real difference this time :

lpq83:~# perf stat -e context-switches ./netperf -H 10.246.17.84 -l 20 -t TCP_SENDFILE -c
TCP SENDFILE TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to 10.246.17.84 () port 0 AF_INET
Recv   Send    Send                          Utilization       Service Demand
Socket Socket  Message  Elapsed              Send     Recv     Send    Recv
Size   Size    Size     Time     Throughput  local    remote   local   remote
bytes  bytes   bytes    secs.    10^6bits/s  % S      % U      us/KB   us/KB

 87380  16384  16384    20.00      9382.90   2.14     -1.00    0.448   -1.000 

 Performance counter stats for './netperf -H 10.246.17.84 -l 20 -t TCP_SENDFILE -c':

           336,501 context-switches                                            

      20.004579650 seconds time elapsed
