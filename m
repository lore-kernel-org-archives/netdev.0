From: Ben Greear <greearb@candelatech.com>
Subject: Re: Slow ramp-up for single-stream TCP throughput on 4.2 kernel.
Date: Fri, 2 Oct 2015 17:21:08 -0700
Message-ID: <560F1F74.9010207@candelatech.com>
References: <560F1672.5000602@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev <netdev@vger.kernel.org>,
	ath10k <ath10k@lists.infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail2.candelatech.com ([208.74.158.173]:40520 "EHLO
	mail2.candelatech.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751406AbbJCAVJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Oct 2015 20:21:09 -0400
In-Reply-To: <560F1672.5000602@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Gah, seems 'cubic' related.  That is the default tcp cong ctrl
I was using (same in 3.17, for that matter).

Most other rate-ctrls vastly out-perform it.



On 10/02/2015 04:42 PM, Ben Greear wrote:
> I'm seeing something that looks more dodgy than normal.

Gah, seems 'cubic' related. That is the default tcp cong ctrl
I was using (same in 3.17, for that matter).

Most other rate-ctrls vastly out-perform it.

Here's a throughput graph for single-stream TCP for each of the rate-ctrl
in 4.2

http://www.candelatech.com/downloads/tcp_cong_ctrl_ath10k_4.2.pdf

I'll re-run and annotate this for posterity's sake, but basically, I started with
'cubic', and then ran each of these in order:

[root@ben-ota-1 lanforge]# echo reno > /proc/sys/net/ipv4/tcp_congestion_control
[root@ben-ota-1 lanforge]# echo bic > /proc/sys/net/ipv4/tcp_congestion_control
[root@ben-ota-1 lanforge]# echo cdg > /proc/sys/net/ipv4/tcp_congestion_control
[root@ben-ota-1 lanforge]# echo dctcp > /proc/sys/net/ipv4/tcp_congestion_control
[root@ben-ota-1 lanforge]# echo westwood > /proc/sys/net/ipv4/tcp_congestion_control
[root@ben-ota-1 lanforge]# echo highspeed > /proc/sys/net/ipv4/tcp_congestion_control
[root@ben-ota-1 lanforge]# echo hybla > /proc/sys/net/ipv4/tcp_congestion_control
[root@ben-ota-1 lanforge]# echo htcp > /proc/sys/net/ipv4/tcp_congestion_control
[root@ben-ota-1 lanforge]# echo vegas > /proc/sys/net/ipv4/tcp_congestion_control
[root@ben-ota-1 lanforge]# echo veno > /proc/sys/net/ipv4/tcp_congestion_control
[root@ben-ota-1 lanforge]# echo scalable > /proc/sys/net/ipv4/tcp_congestion_control
[root@ben-ota-1 lanforge]# echo lp > /proc/sys/net/ipv4/tcp_congestion_control
[root@ben-ota-1 lanforge]# echo yeah > /proc/sys/net/ipv4/tcp_congestion_control
[root@ben-ota-1 lanforge]# echo illinois > /proc/sys/net/ipv4/tcp_congestion_control


The first low non-spike is cubic, then reno does OK, etc.
CDG was the next abject failure.
Vegas sucks
Yeah has issues, but is not horrible.


Thanks,
Ben



>
> Test case id ath10k station uploading to ath10k AP.
>
> AP is always running 4.2 kernel in this case, and both systems are using
> the same ath10k firmware.
>
> I have tuned the stack:
>
> echo 4000000 > /proc/sys/net/core/wmem_max
> echo 4096 87380 50000000 > /proc/sys/net/ipv4/tcp_rmem
> echo 4096 16384 50000000 > /proc/sys/net/ipv4/tcp_wmem
> echo 50000000 > /proc/sys/net/core/rmem_max
> echo 30000 > /proc/sys/net/core/netdev_max_backlog
> echo 1024000 > /proc/sys/net/ipv4/tcp_limit_output_bytes
>
>
> On the 3.17.8+ kernel, single stream TCP very quickly (1-2 seconds) reaches about
> 525Mbps upload throughput (station to AP).
>
> But, when station machine is running the 4.2 kernel, the connection goes to
> about 30Mbps for 5-10 seconds, then may ramp up to 200-300Mbps, and may plateau
> at around 400Mbps after another minute or two.  Once, I saw it finally reach 500+Mbps
> after about 3 minutes.
>
> Both behaviors are repeatable in my testing.
>
> For 4.2, I tried setting the send/rcv buffers to 2Mbps,
> I tried leaving them at system defaults, same behavior.  I tried doubling
> the tcp_limit_output_bytes to 2048k, and that had no affect.
>
> Netstat shows about 1MB of data setting in the TX queue for
> for 3.17 and 4.2 kernels when this test is running.
>
> If I start a 50-stream TCP test, then total throughput is 500+Mbps
> on 4.2, and generally correlates well with whatever UDP can do at
> that time.
>
> A 50-stream throughput has virtually identical performance to the 1 stream
> test on the 3.17 kernel.
>
>
> For the 4.0.4+ kernel, single stream stuck at 30Mbps and would not budge (4.2 does this sometimes too,
> perhaps it would have gone up if I had waited more than the ~15 seconds that I did)
> 50 stream stuck at 420Mbps and would not improve, but it ramped to that quickly.
> 100 stream test ran at 560Mbps throughput, which is about the maximum TCP throughput
> we normally see for ath10k over-the-air.
>
>
> I'm interested to know if someone has any suggestions for things to tune in 4.2
> or 4.0 that might help this, or any reason why I might be seeing this behaviour.
>
> I'm also interested to know if anyone else sees similar behaviour.
>
> Thanks,
> Ben
>


-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
