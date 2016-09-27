From: Jesper Dangaard Brouer via iovisor-dev <iovisor-dev-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org>
Subject: Explaining RX-stages for XDP
Date: Tue, 27 Sep 2016 11:32:37 +0200
Message-ID: <20160927113237.7138c097@redhat.com>
Reply-To: Jesper Dangaard Brouer <brouer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Tom Herbert <tom-BjP2VixgY4xUbtYUoyoikg@public.gmane.org>,
	"iovisor-dev-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org" <iovisor-dev-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org>,
	John Fastabend <john.fastabend-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Jamal Hadi Salim <jhs-jkUAjuhPggJWk0Htik3J/w@public.gmane.org>, Saeed Mahameed <saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Daniel Borkmann <borkmann-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, Pablo Neira Ayuso <pablo-Cap9r6Oaw4JrovVCs/uTlw@public.gmane.org>
To: "netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Return-path: <iovisor-dev-bounces-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org>
List-Unsubscribe: <https://lists.iovisor.org/mailman/options/iovisor-dev>,
	<mailto:iovisor-dev-request-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.iovisor.org/pipermail/iovisor-dev/>
List-Post: <mailto:iovisor-dev-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org>
List-Help: <mailto:iovisor-dev-request-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org?subject=help>
List-Subscribe: <https://lists.iovisor.org/mailman/listinfo/iovisor-dev>,
	<mailto:iovisor-dev-request-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org?subject=subscribe>
Sender: iovisor-dev-bounces-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org
Errors-To: iovisor-dev-bounces-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org
List-Id: netdev.vger.kernel.org


Let me try in a calm way (not like [1]) to explain how I imagine that
the XDP processing RX-stage should be implemented. As I've pointed out
before[2], I'm proposing splitting up the driver into RX-stages.  This
is a mental-model change, I hope you can follow my "inception" attempt.

The basic concept behind this idea is, if the RX-ring contains
multiple "ready" packets, then the kernel was too slow, processing
incoming packets. Thus, switch into more efficient mode, which is a
"packet-vector" mode.

Today, our XDP micro-benchmarks looks amazing, and they are!  But once
real-life intermixed traffic is used, then we loose the XDP I-cache
benefit.  XDP is meant for DoS protection, and an attacker can easily
construct intermixed traffic.  Why not fix this architecturally?

Most importantly concept: If XDP return XDP_PASS, do NOT pass the
packet up the network stack immediately (that would flush I-cache).
Instead store the packet for the next RX-stage.  Basically splitting
the packet-vector into two packet-vectors, one for network-stack and
one for XDP.  Thus, intermixed XDP vs. netstack not longer have effect
on XDP performance.

The reason for also creating an XDP packet-vector, is to move the
XDP_TX transmit code out of the XDP processing stage (and future
features).  This maximize I-cache availability to the eBPF program,
and make eBPF performance more uniform across drivers.


Inception:
 * Instead of individual packets, see it as a RX packet-vector.
 * XDP should be seen as a stage *before* the network stack gets called.

If your mind can handle it: I'm NOT proposing a RX-vector of 64-packets.
I actually want N-packet per vector (8-16).  As the NIC HW RX process
runs concurrently, and by the time it takes to process N-packets, more
packets have had a chance to arrive in the RX-ring queue.

-- 
Best regards,
  Jesper Dangaard Brouertho
  MSc.CS, Principal Kernel Engineer at Red Hat
  LinkedIn: http://www.linkedin.com/in/brouer

[1] https://mid.mail-archive.com/netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org/msg127043.html

[2] http://lists.openwall.net/netdev/2016/01/15/51  

[3] http://lists.openwall.net/netdev/2016/04/19/89
