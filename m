From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH v5] net: ip, diag -- Add diag interface for raw sockets
Date: Wed, 28 Sep 2016 06:08:00 -0400
Message-ID: <caef7649-9d25-6429-eeab-96c027d6cbc2@mojatatu.com>
References: <20160928090357.GT1876@uranus.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        David Miller <davem@davemloft.net>, kuznet@ms2.inr.ac.ru,
        jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net,
        avagin@openvz.org, stephen@networkplumber.org
To: Cyrill Gorcunov <gorcunov@gmail.com>,
        Eric Dumazet <eric.dumazet@gmail.com>,
        David Ahern <dsa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f195.google.com ([209.85.223.195]:35577 "EHLO
        mail-io0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752384AbcI1KIJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 28 Sep 2016 06:08:09 -0400
Received: by mail-io0-f195.google.com with SMTP id 92so2730662iom.2
        for <netdev@vger.kernel.org>; Wed, 28 Sep 2016 03:08:08 -0700 (PDT)
In-Reply-To: <20160928090357.GT1876@uranus.lan>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-09-28 05:03 AM, Cyrill Gorcunov wrote:
> In criu we are actively using diag interface to collect sockets
> present in the system when dumping applications. And while for
> unix, tcp, udp[lite], packet, netlink it works as expected,
> the raw sockets do not have. Thus add it.
>
> v2:
>  - add missing sock_put calls in raw_diag_dump_one (by eric.dumazet@)
>  - implement @destroy for diag requests (by dsa@)
>
> v3:
>  - add export of raw_abort for IPv6 (by dsa@)
>  - pass net-admin flag into inet_sk_diag_fill due to
>    changes in net-next branch (by dsa@)
>
> v4:
>  - use @pad in struct inet_diag_req_v2 for raw socket
>    protocol specification: raw module carries sockets
>    which may have custom protocol passed from socket()
>    syscall and sole @sdiag_protocol is not enough to
>    match underlied ones
>  - start reporting protocol specifed in socket() call
>    when sockets are raw ones for the same reason: user
>    space tools like ss may parse this attribute and use
>    it for socket matching
>
> v5 (by eric.dumazet@):
>  - use sock_hold in raw_sock_get instead of atomic_inc,
>    we're holding (raw_v4_hashinfo|raw_v6_hashinfo)->lock
>    when looking up so counter won't be zero here.
>
> CC: David S. Miller <davem@davemloft.net>
> CC: Eric Dumazet <eric.dumazet@gmail.com>
> CC: David Ahern <dsa@cumulusnetworks.com>
> CC: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
> CC: James Morris <jmorris@namei.org>
> CC: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
> CC: Patrick McHardy <kaber@trash.net>
> CC: Andrey Vagin <avagin@openvz.org>
> CC: Stephen Hemminger <stephen@networkplumber.org>
> Signed-off-by: Cyrill Gorcunov <gorcunov@openvz.org>
> ---
>
> Thanks all for feedback! Take a look please once time permit.
>
>  include/net/raw.h              |    6 +
>  include/net/rawv6.h            |    7 +
>  include/uapi/linux/inet_diag.h |    5
>  net/ipv4/Kconfig               |    8 +
>  net/ipv4/Makefile              |    1
>  net/ipv4/inet_diag.c           |    9 +
>  net/ipv4/raw.c                 |   21 +++
>  net/ipv4/raw_diag.c            |  233 +++++++++++++++++++++++++++++++++++++++++
>  net/ipv6/raw.c                 |    7 -
>  9 files changed, 292 insertions(+), 5 deletions(-)
>
> Index: linux-ml.git/include/net/raw.h
> ===================================================================
> --- linux-ml.git.orig/include/net/raw.h
> +++ linux-ml.git/include/net/raw.h
> @@ -23,6 +23,12 @@
>
>  extern struct proto raw_prot;
>
> +extern struct raw_hashinfo raw_v4_hashinfo;
> +struct sock *__raw_v4_lookup(struct net *net, struct sock *sk,
> +			     unsigned short num, __be32 raddr,
> +			     __be32 laddr, int dif);
> +
> +int raw_abort(struct sock *sk, int err);
>  void raw_icmp_error(struct sk_buff *, int, u32);
>  int raw_local_deliver(struct sk_buff *, int);
>
> Index: linux-ml.git/include/net/rawv6.h
> ===================================================================
> --- linux-ml.git.orig/include/net/rawv6.h
> +++ linux-ml.git/include/net/rawv6.h
> @@ -3,6 +3,13 @@
>
>  #include <net/protocol.h>
>
> +extern struct raw_hashinfo raw_v6_hashinfo;
> +struct sock *__raw_v6_lookup(struct net *net, struct sock *sk,
> +			     unsigned short num, const struct in6_addr *loc_addr,
> +			     const struct in6_addr *rmt_addr, int dif);
> +
> +int raw_abort(struct sock *sk, int err);
> +
>  void raw6_icmp_error(struct sk_buff *, int nexthdr,
>  		u8 type, u8 code, int inner_offset, __be32);
>  bool raw6_local_deliver(struct sk_buff *, int);
> Index: linux-ml.git/include/uapi/linux/inet_diag.h
> ===================================================================
> --- linux-ml.git.orig/include/uapi/linux/inet_diag.h
> +++ linux-ml.git/include/uapi/linux/inet_diag.h
> @@ -38,7 +38,10 @@ struct inet_diag_req_v2 {
>  	__u8	sdiag_family;
>  	__u8	sdiag_protocol;
>  	__u8	idiag_ext;
> -	__u8	pad;
> +	union {
> +		__u8	pad;
> +		__u8	sdiag_raw_protocol;	/* SOCK_RAW only, @pad for others */
> +	};


Above looks funny. Why is it a union? pad is for exposing a byte-hole
for padding/alignment reasons and i doubt anybody is using it.
Should you not just rename it?
Also I notice when things like __raw_v4_lookup() are claiming it is 
unsigned short instead of a u8?

cheers,
jamal
