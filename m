From: "Jason A. Donenfeld" <Jason@zx2c4.com>
Subject: Re: Source address fib invalidation on IPv6
Date: Sat, 12 Nov 2016 16:40:29 +0100
Message-ID: <CAHmME9oeAuBQJguTFivYsYw4fMoc4+sgxcdS4MArN474m7NjTQ@mail.gmail.com>
References: <CAHmME9qi7_C7c=wsZg=EwBg3jzFzVmW1eiFGGXgcX8fCcOOZcA@mail.gmail.com>
 <31e050e2-0499-a77e-f698-86e58ad2fa6b@cumulusnetworks.com>
 <CAHmME9o_AM1Lms6CJSpbjfAgcyGuRx8yqwSaNWEbSnY7gGnt6w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>,
 WireGuard mailing list <wireguard@lists.zx2c4.com>
To: David Ahern <dsa@cumulusnetworks.com>
Return-path: <wireguard-bounces@lists.zx2c4.com>
In-Reply-To: <CAHmME9o_AM1Lms6CJSpbjfAgcyGuRx8yqwSaNWEbSnY7gGnt6w@mail.gmail.com>
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

Hi again,

I've done some pretty in depth debugging now to determine exactly what
the behavior of ipv6_stub->ipv6_dst_lookup is. First I'll start with
ip_route_output_flow, which I believe to be well behaved, and then
I'll show ipv6_stub->ipv6_dst_lookup, which seems ill-behaved:

Userspace:
    ip addr add 192.168.1.2/24 dev eth0
Kernelspace:
    struct flowi4 fl = {
       .saddr = 192.168.1.2,
       .daddr = 192.168.1.99,
    };
    rt = ip_route_output_flow(sock_net(sock), &fl, sock);
    // rt returns valid rt for routing to 192.168.1.99 from
192.168.1.2 using eth0
Userspace:
    ip addr add 192.168.1.3/24 dev eth0
    ip addr del 192.168.1.2/24 dev eth0
Kernelspace:
    struct flowi4 fl = {
       .saddr = 192.168.1.2,
       .daddr = 192.168.1.99,
    };
    rt = ip_route_output_flow(sock_net(sock), &fl, sock);
    // PTR_ERR(rt) == -EINVAL

This seems correct behavior to me, since no interface has 192.168.1.2
as a source address.

Now for the incorrect IPv6 behavior:

Userspace:
    ip -6 addr add abcd::2/96 dev eth0
Kernelspace:
    struct flowi6 fl = {
       .saddr = abcd::2,
       .daddr = abcd::99,
    };
    ret = ipv6_stub->ipv6_dst_lookup(sock_net(sock), sock, &dst, &fl);
    // ret is 0, and dst is a non-null dst routing to abcd::99 from
abcd::2 using eth0
Userspace:
    ip -6 addr add abcd::3/96 dev eth0
    ip -6 addr del abcd::2/96 dev eth0
Kernelspace:
    struct flowi6 fl = {
       .saddr = abcd::2,
       .daddr = abcd::99,
    };
    ret = ipv6_stub->ipv6_dst_lookup(sock_net(sock), sock, &dst, &fl);
    // ret is 0, and dst is a non-null dst routing to abcd::99 from
abcd::2 using eth0 **INCORRECT BEHAVIOR!**

This seems *INCORRECT* behavior to me, since no interface has abcd::2
as a source address.

So, to summarize, the problem is that ipv6_dst_lookup will happily
return a dst even though the source IP has been removed from the
interface.

I hope this clarifies things. I await your response.

Regards,
Jason
