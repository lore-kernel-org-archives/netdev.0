From: Ben Greear <greearb-my8/4N5VtI7c+919tysfdA@public.gmane.org>
Subject: Re: Poor TCP performance with ath10k in 4.0 kernel, again.
Date: Tue, 19 May 2015 16:22:58 -0700
Message-ID: <555BC5D2.3090802@candelatech.com>
References: <555A5938.9080706@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: "linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	ath10k <ath10k-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>,
	netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <555A5938.9080706-my8/4N5VtI7c+919tysfdA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Additional info & pkt capture at bottom...


On 05/18/2015 02:27 PM, Ben Greear wrote:
> Disclosure: I am working with a patched 4.0 kernel, patched ath10k driver, and
> patched (CT) ath10k firmware.  Traffic generator is of our own making.
> 
> First, this general problem has been reported before, but the
> work-arounds previously suggested do not fully resolve my problems.
> 
> The basic issue is that when the sending socket is directly on top
> of a wifi interface (ath10k driver), then TCP throughput sucks.
> 
> For instance, if AP interface sends to station, with 10 concurrent
> TCP streams, I see about 426Mbps.  With 100 streams, I see total throughput
> of 750Mbps.  These were maybe 10-30 second tests that I did.
> 
> Interestingly, a single stream connection performs very poorly at first,
> but at least in one test, it eventually ran quite fast.  It is too
> complicated to describe in words, but the graph is here:
> 
> http://www.candelatech.com/downloads/single-tcp-4.0.pdf
> 
> The 10-stream test did not go above about 450Mbps even after running for more than
> 1 minute, and it was fairly stable around the 450Mbps range after the first few seconds.
> 
> 100-stream test shows nice stable aggregate throughput:
> 
> http://www.candelatech.com/downloads/100-tcp-4.0.pdf
> 
> I have tweaked the kernel tcp_limit_output_bytes setting
> (tested at 1024k too, did not make any significant difference).
> 
> # cat /proc/sys/net/ipv4/tcp_limit_output_bytes
> 2048000
> 
> I have tried forcing TCP send/rcv buffers to be 1MB and 2MB, but that
> did not make obvious difference except that it started at the maximum
> rate very quickly instead of taking a few seconds to train up to full speed.
> 
> If I run a single-stream TCP test, sending on eth1 (Intel 1G NIC)
> through the AP machine, then single stream download is about 540 Mbps, and ramps up
> quickly.  So, the AP can definitely send the needed amount of TCP packets.
> 
> UDP throughput in download direction, single stream, is about 770Mbps, regardless
> of whether I originate the socket on the AP or if I pass it through the AP.
> send/recv bufs are set to 1MB for UDP sockets.
> 
> The 3.17 kernel shows similar behaviour, and the 3.14 kernel is a lot better
> for TCP traffic.
> 
> Are there tweaks other than tcp_limit_output_bytes that might
> improve this behaviour?
> 
> I will be happy to grab captures or provide any other debugging info
> that someone thinks will be helpful.
> 
> Thanks,
> Ben


Here is a capture for the single stream vap -> station test case.

http://www.candelatech.com/downloads/vap-to-sta-1-stream.pcap.bz2

It starts fairly slow, and manages up to around 440Mbps before it plateaus.



The qdisc is pfifo_fast (this is Fedora 19 system).  The interface being used for
this test is 'vap1'.  This is the sender system.

[root@ct523-1ac-lr201408006507 tmp]# tc qdisc
qdisc pfifo_fast 0: dev eth0 root refcnt 2 bands 3 priomap  1 2 2 2 1 2 0 0 1 1 1 1 1 1 1 1
qdisc pfifo_fast 0: dev eth1 root refcnt 2 bands 3 priomap  1 2 2 2 1 2 0 0 1 1 1 1 1 1 1 1
qdisc mq 0: dev wlan0 root
qdisc pfifo_fast 0: dev wlan0 parent :1 bands 3 priomap  1 2 2 2 1 2 0 0 1 1 1 1 1 1 1 1
qdisc pfifo_fast 0: dev wlan0 parent :2 bands 3 priomap  1 2 2 2 1 2 0 0 1 1 1 1 1 1 1 1
qdisc pfifo_fast 0: dev wlan0 parent :3 bands 3 priomap  1 2 2 2 1 2 0 0 1 1 1 1 1 1 1 1
qdisc pfifo_fast 0: dev wlan0 parent :4 bands 3 priomap  1 2 2 2 1 2 0 0 1 1 1 1 1 1 1 1
qdisc mq 0: dev vap1 root
qdisc pfifo_fast 0: dev vap1 parent :1 bands 3 priomap  1 2 2 2 1 2 0 0 1 1 1 1 1 1 1 1
qdisc pfifo_fast 0: dev vap1 parent :2 bands 3 priomap  1 2 2 2 1 2 0 0 1 1 1 1 1 1 1 1
qdisc pfifo_fast 0: dev vap1 parent :3 bands 3 priomap  1 2 2 2 1 2 0 0 1 1 1 1 1 1 1 1
qdisc pfifo_fast 0: dev vap1 parent :4 bands 3 priomap  1 2 2 2 1 2 0 0 1 1 1 1 1 1 1 1


Thanks,
Ben



-- 
Ben Greear <greearb-my8/4N5VtI7c+919tysfdA@public.gmane.org>
Candela Technologies Inc  http://www.candelatech.com

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
