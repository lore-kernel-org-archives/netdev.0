From: "Jason A. Donenfeld" <Jason@zx2c4.com>
Subject: Source address fib invalidation on IPv6
Date: Fri, 11 Nov 2016 20:29:55 +0100
Message-ID: <CAHmME9qi7_C7c=wsZg=EwBg3jzFzVmW1eiFGGXgcX8fCcOOZcA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel@vger.kernel.org>,
 WireGuard mailing list <wireguard@lists.zx2c4.com>
To: Netdev <netdev@vger.kernel.org>
Return-path: <wireguard-bounces@lists.zx2c4.com>
List-Unsubscribe: <http://lists.zx2c4.com/mailman/options/wireguard>,
 <mailto:wireguard-request@lists.zx2c4.com?subject=unsubscribe>
List-Archive: <http://lists.zx2c4.com/pipermail/wireguard/>
List-Post: <mailto:wireguard@lists.zx2c4.com>
List-Help: <mailto:wireguard-request@lists.zx2c4.com?subject=help>
List-Subscribe: <http://lists.zx2c4.com/mailman/listinfo/wireguard>,
 <mailto:wireguard-request@lists.zx2c4.com?subject=subscribe>
Errors-To: wireguard-bounces@lists.zx2c4.com
Sender: "WireGuard" <wireguard-bounces@lists.zx2c4.com>
List-Id: netdev.vger.kernel.org

Hi folks,

If I'm replying to a UDP packet, I generally want to use a source
address that's the same as the destination address of the packet to
which I'm replying. For example:

Peer A sends packet: src = 10.0.0.1,  dst = 10.0.0.3
Peer B replies with: src = 10.0.0.3, dst = 10.0.0.1

But let's complicate things. Let's say Peer B has multiple IPs on an
interface: 10.0.0.2, 10.0.0.3. The default route uses 10.0.0.2. In
this case what do you think should happen?

Case 1:
Peer A sends packet: src = 10.0.0.1,  dst = 10.0.0.3
Peer B replies with: src = 10.0.0.2, dst = 10.0.0.1

Case 2:
Peer A sends packet: src = 10.0.0.1,  dst = 10.0.0.3
Peer B replies with: src = 10.0.0.3, dst = 10.0.0.1

Intuition tells me the answer is "Case 2". If you agree, keep reading.
If you disagree, stop reading here, and instead correct my poor
intuition.

So, assuming "Case 2", when Peer B receives the first packet, he notes
that packet's destination address, so that he can use it as a source
address next. When replying, Peer B sets the stored source address and
calls the routing function:

    struct flowi4 fl = {
       .saddr = from_daddr_of_previous_packet,
       .daddr = from_saddr_of_previous_packet,
    };
    rt = ip_route_output_flow(sock_net(sock), &fl, sock);

What if, however, by the time Peer B chooses to reply, his interface
no longer has that source address? No problem, because
ip_route_output_flow will return -EINVAL in that case. So, we can do
this:

    struct flowi4 fl = {
       .saddr = from_daddr_of_previous_packet,
       .daddr = from_saddr_of_previous_packet,
    };
    rt = ip_route_output_flow(sock_net(sock), &fl, sock);
    if (unlikely(IS_ERR(rt))) {
        fl.saddr = 0;
        rt = ip_route_output_flow(sock_net(sock), &fl, sock);
    }

And then all is good in the neighborhood. This solution works. Done.

But what about IPv6? That's where we get into trouble:

    struct flowi6 fl = {
       .saddr = from_daddr_of_previous_packet,
       .daddr = from_saddr_of_previous_packet,
    };
    ret = ipv6_stub->ipv6_dst_lookup(sock_net(sock), sock, &dst, &fl);

In this case, IPv6 returns a valid dst, when no interface has the
source address anymore! So, there's no way to know whether or not the
source address for replying has gone stale. We don't have a means of
falling back to inaddr_any for the source address.

Primary question: is this behavior a bug? Or is this some consequence
of a fundamental IPv6 difference with v4? Or is something else
happening here?

Thanks,
Jason
