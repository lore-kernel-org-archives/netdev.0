From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 16568] New: Regression and incompatibility
 with Windows SP2-SP3-Vista TCP stack causing lost connections
Date: Thu, 12 Aug 2010 07:40:41 -0700
Message-ID: <20100812074041.cf62b793.akpm@linux-foundation.org>
References: <bug-16568-10286@https.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org, yuriy@ucoz.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:35208 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753680Ab0HLOkA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Aug 2010 10:40:00 -0400
In-Reply-To: <bug-16568-10286@https.bugzilla.kernel.org/>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


(switched to email.  Please respond via emailed reply-to-all, not via the
bugzilla web interface).


On Thu, 12 Aug 2010 08:20:01 GMT bugzilla-daemon@bugzilla.kernel.org wrote:

> https://bugzilla.kernel.org/show_bug.cgi?id=16568
> 
>            Summary: Regression and incompatibility with Windows
>                     SP2-SP3-Vista TCP stack causing lost connections
>            Product: Networking
>            Version: 2.5
>     Kernel Version: 2.6.30+
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: high
>           Priority: P1
>          Component: IPV4
>         AssignedTo: shemminger@linux-foundation.org
>         ReportedBy: yuriy@ucoz.com
>         Regression: No
> 
> 
> Hi.
> I administer about 50 highly-loaded web servers (free CMS hosting) under linux.
> Having on most of them kernel versions between 2.6.24 and 2.6.29 at the
> beginnig of the year, I made TCP sysctls tunings for increasing DDOS and
> different flooding protection (our servers have attacks rather often).
> tcp_tw_recyle=1 was among of them, as many manuals in the net recommend to do
> this and linux documentation does not say anything bad. Having periodic kernel
> panics connected with bugs in ethernet card drivers and ext3 and after founding
> that 2.6.31+ kernels work faster with ext3, I upgraded almost all kernels to
> 2.6.32.8, which was already being tested on several servers for several months. 
> Somewhen after that we began to receive complaints from our users (site owners)
> that they (and their visitors) see very unstable work of their sites. It looked
> like HTTP-connections were just lost in a random way. Not everybody had the
> problem, just a small percent. We tried to find problem with internet providers
> or buggy firewalls, but finally came to conclusion that problem is connected
> with our servers. Analizing situations with lost connections using tcpdump i
> found that client host send packets, BUT LINUX JUST IGNORES THEM, there was
> SYN-packet repeated 3 times with interval of 3 secs, but NO SYN-ACK reply.
> Most problems had users with Windows SP3 (i.e. almost all users with SP3 had
> the problem). I booted one server with old 2.6.24 kernel and found that problem
> dissappeared. Then began look for exact kernel version, that introduced
> incompatibility. Using binary search I compiled several kernels between 2.6.24
> and 2.6.32.8 and found that 2.6.29.6 DO NO have the problem, but 2.6.30 DOES.
> Studing commits made to tcp_input.c and tcp_ipv4.c (which i supposed were
> involved) between that releases I found this one.
>   author    Eric Dumazet <dada1@cosmosbay.com>    
>     Wed, 11 Mar 2009 16:23:57 +0000 (09:23 -0700)
>   committer    David S. Miller <davem@davemloft.net>    
>     Wed, 11 Mar 2009 16:23:57 +0000 (09:23 -0700)
>   commit    fc1ad92dfc4e363a055053746552cdb445ba5c57
> 
>   tcp: allow timestamps even if SYN packet has tsval=0
> 
>   Some systems send SYN packets with apparently wrong RFC1323 timestamp
>   option values [timestamp tsval=0 tsecr=0].
>   It might be for security reasons (http://www.secuobs.com/plugs/25220.shtml )
>   Linux TCP stack ignores this option and sends back a SYN+ACK packet
>   without timestamp option, thus many TCP flows cannot use timestamps
>   and lose some benefit of RFC1323.
>   Other operating systems seem to not care about initial tsval value, and let
>   tcp flows to negotiate timestamp option.
> 
>   net/ipv4/tcp_ipv4.c         diff :
> 
> --- a/net/ipv4/tcp_ipv4.c
> +++ b/net/ipv4/tcp_ipv4.c
> @@ -1226,15 +1226,6 @@ int tcp_v4_conn_request(struct sock *sk, struct sk_buff
> *skb)
>         if (want_cookie && !tmp_opt.saw_tstamp)
>                 tcp_clear_options(&tmp_opt);
> 
> -       if (tmp_opt.saw_tstamp && !tmp_opt.rcv_tsval) {
> -               /* Some OSes (unknown ones, but I see them on web server, which
> -                * contains information interesting only for windows'
> -                * users) do not send their stamp in SYN. It is easy case.
> -                * We simply do not advertise TS support.
> -                */
> -               tmp_opt.saw_tstamp = 0;
> -               tmp_opt.tstamp_ok  = 0;
> -       }
>         tmp_opt.tstamp_ok = tmp_opt.saw_tstamp;
> 
>         tcp_openreq_init(req, &tmp_opt, skb);
> 
> Removing that was not very good. Having analized lost connections from SP3 I
> know that they have timestamps turned on and timestamp value is 0. Here is it:
> 13:39:10.430498 IP 192.168.99.130.3493 > 192.168.99.100.80: S
> 2507911465:2507911465(0) win 65535 <mss 1460,nop,wscale 3,nop,nop,timestamp 0
> 0,nop,nop,sackOK>
>         0x0000:  4500 0040 2bda 4000 8006 86a6 c0a8 6382  E..@+.@.......c.
>         0x0010:  c0a8 6364 0da5 0050 957b b129 0000 0000  ..cd...P.{.)....
>         0x0020:  b002 ffff 992c 0000 0204 05b4 0103 0303  .....,..........
>         0x0030:  0101 080a 0000 0000 0000 0000 0101 0402  ................
> 
> Having above code fragment removed we got tmp_opt.tstamp_ok=1, as i understand.
> But a little later in source code of tcp_ipv4.c read:
>         /* VJ's idea. We save last timestamp seen
>          * from the destination in peer table, when entering
>          * state TIME-WAIT, and check against it before
>          * accepting new connection request.
>          *
>          * If "isn" is not zero, this request hit alive
>          * timewait bucket, so that all the necessary checks
>          * are made in the function processing timewait state.
>          */
>         if (tmp_opt.saw_tstamp &&
>             tcp_death_row.sysctl_tw_recycle &&
>             (dst = inet_csk_route_req(sk, req)) != NULL &&
>             (peer = rt_get_peer((struct rtable *)dst)) != NULL &&
>             peer->v4daddr == saddr) {
>             if ((u32)get_seconds() - peer->tcp_ts_stamp < TCP_PAWS_MSL &&
>                 (s32)(peer->tcp_ts - req->ts_recent) >
>                             TCP_PAWS_WINDOW) {
>                 NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_PAWSPASSIVEREJECTED);
>                 goto drop_and_release;
>             }
>         }
> which in some way (tmp_opt.saw_tstamp && tcp_death_row.sysctl_tw_recycle are
> true), random way, having not closed time-wait sockets from the pear, leads to
> packet ignorence.
> 
> As for me, i understand, that i should not enable tw_recycle, BUT DOCUMENTATION
> DOES NOT STATE, that enabling it i'll got random and rather often lost of
> connections from some types of popular clients (like Windows).
> Concerning above stated commit, it should include something to prevent above
> condition to become true if tmp_opt.rcv_tsval==0. I'm not sure, but something
> like
>         if (tmp_opt.saw_tstamp &&
> +           tmp_opt.rcv_tsval &&
>             tcp_death_row.sysctl_tw_recycle &&
>             (dst = inet_csk_route_req(sk, req)) != NULL &&
>             (peer = rt_get_peer((struct rtable *)dst)) != NULL &&
> 
> just to not provide regression and strong TCP-stack incompatibility in case
> tw_recycle is enabled.
> Also documentation does not state, that tw_recyle should not be used at all for
> internet servers, because web-clients, which are behind NAT, will have problems
> connected with the same above condition because successive connections from
> different clients (which have common IP) could have incompatible timestamps.
> 
> Sorry if i detracted somebody busy from his work with my unimportant problem.
> 

