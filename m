From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: Re: [net-next PATCH 16/16] Add documentation
Date: Wed, 1 Oct 2008 09:22:34 -0700
Message-ID: <20081001092234.a0658f40.randy.dunlap@oracle.com>
References: <20081001142431.4893.48078.stgit@este>
	<20081001142431.4893.5367.stgit@este>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org
To: KOVACS Krisztian <hidden@sch.bme.hu>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20081001142431.4893.5367.stgit@este>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 01 Oct 2008 16:24:31 +0200 KOVACS Krisztian wrote:

> Add basic usage instructions to Documentation/networking.
> 
> Signed-off-by: KOVACS Krisztian <hidden@sch.bme.hu>
> ---
> 
>  Documentation/networking/tproxy.txt |   85 +++++++++++++++++++++++++++++++++++
>  1 files changed, 85 insertions(+), 0 deletions(-)
> 
> diff --git a/Documentation/networking/tproxy.txt b/Documentation/networking/tproxy.txt
> new file mode 100644
> index 0000000..cf79e60
> --- /dev/null
> +++ b/Documentation/networking/tproxy.txt
> @@ -0,0 +1,85 @@
> +Transparent proxy support
> +=========================
> +
> +This feature adds Linux 2.2-like transparent proxy support to current kernels.
> +To use it, enable NETFILTER_TPROXY, the socket match and the TPROXY target in
> +your kernel config. You will need policy routing too, so be sure to enable that
> +as well.
> +
> +
> +1. Making non-local sockets work
> +================================
> +
> +The idea is that you identify packets with destination address matching a local
> +socket your box, set the packet mark to a certain value, and then match on that

          on your box   (?)

> +value using policy routing to have those packets delivered locally:
> +
> +# iptables -t mangle -N DIVERT
> +# iptables -t mangle -A PREROUTING -p tcp -m socket -j DIVERT
> +# iptables -t mangle -A DIVERT -j MARK --set-mark 1
> +# iptables -t mangle -A DIVERT -j ACCEPT
> +
> +# ip rule add fwmark 1 lookup 100
> +# ip route add local 0.0.0.0/0 dev lo table 100
> +
> +Because of certain restrictions in the IPv4 routing output code you'll have to
> +modify your application to allow it sending datagrams _from_ non-local IP

                                       to send datagrams

> +addresses. All you have to do is to enable the (SOL_IP, IP_TRANSPARENT) socket

                                 is enable the

> +option before calling bind:
> +
> +fd = socket(AF_INET, SOCK_STREAM, 0);
> +/* - 8< -*/
> +int value = 1;
> +setsockopt(fd, SOL_IP, IP_TRANSPARENT, &value, sizeof(value));
> +/* - 8< -*/
> +name.sin_family = AF_INET;
> +name.sin_port = htons(0xCAFE);
> +name.sin_addr.s_addr = htonl(0xDEADBEEF);
> +bind(fd, &name, sizeof(name));
> +
> +A trivial patch for netcat is available here:
> +http://people.netfilter.org/hidden/tproxy/netcat-ip_transparent-support.patch
> +
> +
> +2. Redirecting traffic
> +======================
> +
> +Transparent proxying often involves "intercepting" traffic on a router. This is
> +usually done with the iptables REDIRECT target, however, there are serious

                                           target;

> +limitations of that method. One of the major issues is that it actually
> +modifies the packets to change the destination address -- which might not be
> +acceptable in certain situations. (Think of proxying UDP for example: you won't
> +be able to find out the original destination address. Even in case of TCP
> +getting the original destination address is racy.)
> +
> +The 'TPROXY' target provides similar functionality without relying on NAT. Simply
> +add rules like this to the iptables ruleset above:
> +
> +# iptables -t mangle -A PREROUTING -p tcp --dport 80 -j TPROXY \
> +  --tproxy-mark 0x1/0x1 --on-port 50080
> +
> +Note that for this to work you'll have to modify the proxy to enable (SOL_IP,
> +IP_TRANSPARENT) for the listening socket.

Thanks.
---
~Randy
