From: Vlad Yasevich <vyasevich@gmail.com>
Subject: Re: [PATCH net] net: sctp: fix ipv6 ipsec encryption bug in sctp_v6_xmit
Date: Tue, 10 Sep 2013 14:58:37 -0400
Message-ID: <522F6BDD.3050309@gmail.com>
References: <1378836316-17503-1-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-sctp@vger.kernel.org, adobriyan@gmail.com,
	Steffen Klassert <steffen.klassert@secunet.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f182.google.com ([209.85.223.182]:54721 "EHLO
	mail-ie0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750901Ab3IJS6n (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Sep 2013 14:58:43 -0400
In-Reply-To: <1378836316-17503-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/10/2013 02:05 PM, Daniel Borkmann wrote:
> Alan Chester reported an issue with IPv6 on SCTP that IPsec traffic is not
> being encrypted, whereas on IPv4 it is. Setting up an AH + ESP transport
> does not seem to have the desired effect:
>
> SCTP + IPv4:
>
>    22:14:20.809645 IP (tos 0x2,ECT(0), ttl 64, id 0, offset 0, flags [DF], proto AH (51), length 116)
>      192.168.0.2 > 192.168.0.5: AH(spi=0x00000042,sumlen=16,seq=0x1): ESP(spi=0x00000044,seq=0x1), length 72
>    22:14:20.813270 IP (tos 0x2,ECT(0), ttl 64, id 0, offset 0, flags [DF], proto AH (51), length 340)
>      192.168.0.5 > 192.168.0.2: AH(spi=0x00000043,sumlen=16,seq=0x1):
>
> SCTP + IPv6:
>
>    22:31:19.215029 IP6 (class 0x02, hlim 64, next-header SCTP (132) payload length: 364)
>      fe80::222:15ff:fe87:7fc.3333 > fe80::92e6:baff:fe0d:5a54.36767: sctp
>      1) [INIT ACK] [init tag: 747759530] [rwnd: 62464] [OS: 10] [MIS: 10]
>
> Moreover, Alan says:
>
>    This problem was seen with both Racoon and Racoon2. Other people have seen
>    this with OpenSwan. When IPsec is configured to encrypt all upper layer
>    protocols the SCTP connection does not initialize. After using Wireshark to
>    follow packets, this is because the SCTP packet leaves Box A unencrypted and
>    Box B believes all upper layer protocols are to be encrypted so it drops
>    this packet, causing the SCTP connection to fail to initialize. When IPsec
>    is configured to encrypt just SCTP, the SCTP packets are observed unencrypted.
>
> In fact, using `socat sctp6-listen:3333 -` on one end and transferring "plaintext"
> string on the other end, results in cleartext on the wire where SCTP eventually
> does not report any errors, thus in the latter case that Alan reports, the
> non-paranoid user might think he's communicating over an encrypted transport on
> SCTP although he's not (tcpdump ... -X):
>
>    ...
>    0x0030: 5d70 8e1a 0003 001a 177d eb6c 0000 0000  ]p.......}.l....
>    0x0040: 0000 0000 706c 6169 6e74 6578 740a 0000  ....plaintext...
>
> Only in /proc/net/xfrm_stat we can see XfrmInTmplMismatch increasing on the
> receiver side. Initial follow-up analysis from Alan's bug report was done by
> Alexey Dobriyan.
>
> SCTP has its own implementation of sctp_v6_xmit() not calling inet6_csk_xmit().
> This has the implication that it probably never really got updated along with
> changes in inet6_csk_xmit() and therefore does not seem to invoke xfrm handlers.
> SCTP's IPv4 xmit however, properly calls ip_queue_xmit() to do the work. Hence,
> lets do the same for IPv6 and invoke inet6_csk_xmit() [it does the same work
> for us we do here manually anyway]; result is that we do not have any
> XfrmInTmplMismatch increase plus on the wire with this patch it now looks like:
>
> SCTP + IPv6:
>
>    08:17:47.074080 IP6 2620:52:0:102f:7a2b:cbff:fe27:1b0a > 2620:52:0:102f:213:72ff:fe32:7eba:
>      AH(spi=0x00005fb4,seq=0x1): ESP(spi=0x00005fb5,seq=0x1), length 72
>    08:17:47.074264 IP6 2620:52:0:102f:213:72ff:fe32:7eba > 2620:52:0:102f:7a2b:cbff:fe27:1b0a:
>      AH(spi=0x00003d54,seq=0x1): ESP(spi=0x00003d55,seq=0x1), length 296
>
> This fixes Kernel Bugzilla 24412. This security issue seems to be present since
> 2.6.18 kernels. Lets just hope some big passive adversary in the wild didn't have
> its fun with that. lksctp-tools IPv6 regression test suite passes as well with
> this patch.
>
> Reported-by: Alan Chester <alan.chester@tekelec.com>
> Reported-by: Alexey Dobriyan <adobriyan@gmail.com>
> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
> Cc: Steffen Klassert <steffen.klassert@secunet.com>
> Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>
> ---
>   net/sctp/ipv6.c | 34 ++++++++--------------------------
>   1 file changed, 8 insertions(+), 26 deletions(-)
>
> diff --git a/net/sctp/ipv6.c b/net/sctp/ipv6.c
> index da613ce..74ba5ee 100644
> --- a/net/sctp/ipv6.c
> +++ b/net/sctp/ipv6.c
> @@ -69,6 +69,7 @@
>   #include <net/addrconf.h>
>   #include <net/ip6_route.h>
>   #include <net/inet_common.h>
> +#include <net/inet6_connection_sock.h>
>   #include <net/inet_ecn.h>
>   #include <net/sctp/sctp.h>
>
> @@ -209,39 +210,20 @@ static int sctp_v6_xmit(struct sk_buff *skb, struct sctp_transport *transport)
>   {
>   	struct sock *sk = skb->sk;
>   	struct ipv6_pinfo *np = inet6_sk(sk);
> -	struct flowi6 fl6;
>
> -	memset(&fl6, 0, sizeof(fl6));
> -
> -	fl6.flowi6_proto = sk->sk_protocol;
> -
> -	/* Fill in the dest address from the route entry passed with the skb
> -	 * and the source address from the transport.
> -	 */
> -	fl6.daddr = transport->ipaddr.v6.sin6_addr;
> -	fl6.saddr = transport->saddr.v6.sin6_addr;
> -
> -	fl6.flowlabel = np->flow_label;
> -	IP6_ECN_flow_xmit(sk, fl6.flowlabel);
> -	if (ipv6_addr_type(&fl6.saddr) & IPV6_ADDR_LINKLOCAL)
> -		fl6.flowi6_oif = transport->saddr.v6.sin6_scope_id;
> -	else
> -		fl6.flowi6_oif = sk->sk_bound_dev_if;
> -
> -	if (np->opt && np->opt->srcrt) {
> -		struct rt0_hdr *rt0 = (struct rt0_hdr *) np->opt->srcrt;
> -		fl6.daddr = *rt0->addr;
> -	}
> +	/* This needs to explicitly done as we can have different transports. */
> +	np->daddr = transport->ipaddr.v6.sin6_addr;
> +	np->saddr = transport->saddr.v6.sin6_addr;
>
>   	pr_debug("%s: skb:%p, len:%d, src:%pI6 dst:%pI6\n", __func__, skb,
> -		 skb->len, &fl6.saddr, &fl6.daddr);
> -
> -	SCTP_INC_STATS(sock_net(sk), SCTP_MIB_OUTSCTPPACKS);
> +		 skb->len, &np->saddr, &np->daddr);
>
>   	if (!(transport->param_flags & SPP_PMTUD_ENABLE))
>   		skb->local_df = 1;
>
> -	return ip6_xmit(sk, skb, &fl6, np->opt, np->tclass);
> +	SCTP_INC_STATS(sock_net(sk), SCTP_MIB_OUTSCTPPACKS);
> +
> +	return inet6_csk_xmit(skb, NULL);
>   }
>
>   /* Returns the dst cache entry for the given source and destination ip
>


I don't think this is actually the correct thing to do.
1) Every transmit has a possibility of changing np and thus changing
the result of getsockname() and getpeername()
2) You will end up with a route lookup on every packet since 
np->dst_cookie is not set properly.

I wonder if it would solve things if you simply pass the flowi cached in 
the transport to ip6_xmit().

If not, then probably sctp_v6_get_dst() needs to be updated to find the
correct route, so then it can be cached in the transport along with the
flowi and used on output.

-vlad

-vlad

-vlad
