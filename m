From: "Hwang Jae-Hyun" <jhhwang@os.korea.ac.kr>
Subject: About TCP Westwood implementation...
Date: Thu, 24 Dec 2009 11:45:20 +0900
Message-ID: <016f01ca8443$226881b0$67398510$@korea.ac.kr>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from os.korea.ac.kr ([163.152.39.64]:35443 "EHLO os.korea.ac.kr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751115AbZLXC4L (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Dec 2009 21:56:11 -0500
Received: from jhhwang ([163.152.41.60])
	by os.korea.ac.kr (8.13.8/8.13.8) with ESMTP id nBO2jPus026378
	for <netdev@vger.kernel.org>; Thu, 24 Dec 2009 11:45:25 +0900
Content-Language: ko
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

(I re-send this posting that was sent to linux-net.)
I think that the current Westwood algorithm implemented in the Linux kernel
(since 2.6.13) is not same with one described in its original paper.
In the Linux implementation, Westwood uses 'tcp_reno_ssthresh' function as a
'ssthresh' interface as below codes.

---------------------------------------------------
<tcp_westwood.c>
...
static struct tcp_congestion_ops tcp_westwood = {
	.init		= tcp_westwood_init,
	.ssthresh	= tcp_reno_ssthresh,
	.cong_avoid	= tcp_reno_cong_avoid,
	.min_cwnd	= tcp_westwood_bw_rttmin,
	.cwnd_event	= tcp_westwood_event,
	.get_info	= tcp_westwood_info,
	.pkts_acked	= tcp_westwood_pkts_acked,

	.owner		= THIS_MODULE,
	.name		= "westwood"
};
----------------------------------------------------

But, Westwood basically sets its ssthresh value based on bandwidth
estimation, not by cwnd/2 as Reno does.
In this case, Linux-Westwood would call 'tcp_reno_ssthresh' to set its
ssthresh value when retransmission timeout expires.
I don't know why Westwood uses Reno's ssthresh function.

In my opinion,
1) '.ssthresh' interface should be changed from 'tcp_reno_ssthresh' to
'tcp_westwood_bw_rttmin'.
Then, '.min_cwnd' interface can be removed.
2) In 'tcp_westwood_event()' function,
 2.1) The case of 'CA_EVENT_COMPLETE_CWR' can be removed. (corresponding
codes are already executed)
 2.2) In the case of 'CA_EVENT_FRTO', 'tp->snd_ssthresh =
tcp_westwood_bw_rttmin(sk);' can be removed because '.ssthresh' interface is
called before tcp_ca_event(sk, CA_EVENT_FRTO) is called.

Thanks,
Jaehyun Hwang

