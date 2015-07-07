From: "Jason A. Donenfeld" <Jason@zx2c4.com>
Subject: Performance bottleneck with ndo_start_xmit
Date: Tue, 7 Jul 2015 18:32:22 +0200
Message-ID: <CAHmME9rfOqA1mYmFDomcG+G55dV7it5406vL02ZRWcr0PmVbQg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi folks,

I'm writing a kernel module that creates a virtual network device with
rtnl_link_register. At initialization time, it creates a UDP socket
with sock_create_kern. On ndo_start_xmit, it passes the data of the
skb to the UDP socket's sendmsg, after some minimal crypto and
processing. The device's MTU takes things into account properly. In
other words: it's a UDP-based tunnel device. And it works.

But I'm hitting a bottleneck in the send path (ndo_start_xmit) that I
can't seem to figure out. None of the aforementioned crypto or
processing contributes significantly. I boot up two virtual machines,
configure the tunnel on them, and run iperf to test bandwidth. Using
the tunnel device I get around 450mbps. Without using the tunnel
device, I get around 5gbps. These performance characteristics remain
the same for 1 CPU and for 4 CPUs and for 8 CPUs.

When it maxes out at ~5gbps without using the tunnel device, the CPU
is at around 80%. When it maxes out at ~450mbps using the tunnel
device, the CPU is at 100%. Running perf top indicates that most the
kernel time is spent in e1000_xmit, or the xmit function of whichever
driver underlies the UDP socket. Very little percent of time is spent
in any functions related to my module or even inside UDP's sendmsg
call tree.

I'm stumped. I've tried workqueues, tasklets, all sorts of deferal.
I've tried not using a UDP _socket_ and instead constructing an
Ethernet, IP, and UDP header myself, checksumming it, computing the
flowi4s,  getting the macs, and passing it to dev_queue_xmit. But in
all cases, the bandwidth stays the same: 450mbps at 100% CPU
utilization with the e1000_xmit (or vmxnet3_xmit if I'm using that
driver instead) function at the top of the list in perf top.

I can confirm that the receive path never reaches 100% CPU
utilization, and hence the bottleneck is in the send path, described
above.

Can anyone help? Or point me in the right direction of where to learn?
I have exhausted all of the documentation resources I've been able to
find, and my eyes hurt from reading tens of thousands of lines of
kernel code trying to figure this out. I'm at a loss.

Any pointers would be greatly appreciated.

Regards,
Jason
