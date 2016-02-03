From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [RFC] Inverse of flowi{4,6}_oif: flowi{4,6}_not_oif
Date: Wed, 3 Feb 2016 09:28:05 -0700
Message-ID: <56B22A95.4010408@cumulusnetworks.com>
References: <CAHmME9pgwgjKJAFH2=sEEMJauno_rVEzY6JORTQze91Xo5zefw@mail.gmail.com>
 <CAHmME9pGKeM9=qqcxrN12ELtTjhwgBkPV0K3ixfVz3a_CBugAw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
To: "Jason A. Donenfeld" <Jason@zx2c4.com>,
	Netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	"Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f171.google.com ([209.85.214.171]:34338 "EHLO
	mail-ob0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754146AbcBCQ2L (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Feb 2016 11:28:11 -0500
Received: by mail-ob0-f171.google.com with SMTP id wb13so37485773obb.1
        for <netdev@vger.kernel.org>; Wed, 03 Feb 2016 08:28:10 -0800 (PST)
In-Reply-To: <CAHmME9pGKeM9=qqcxrN12ELtTjhwgBkPV0K3ixfVz3a_CBugAw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2/3/16 7:27 AM, Jason A. Donenfeld wrote:
> FYI, for v4 at least, it's ridiculously easy and simple to implement:
>
> =~=~=~=~=~=~=~=~=
>
> diff --git a/include/net/flow.h b/include/net/flow.h
> index 83969ee..29967ad 100644
> --- a/include/net/flow.h
> +++ b/include/net/flow.h
> @@ -26,6 +26,7 @@ struct flowi_tunnel {
>
>   struct flowi_common {
>    int flowic_oif;
> + int flowic_not_oif;
>    int flowic_iif;
>    __u32 flowic_mark;
>    __u8 flowic_tos;

I was going to suggest a flag:

@@ -36,6 +36,7 @@ struct flowi_common {
  #define FLOWI_FLAG_KNOWN_NH            0x02
  #define FLOWI_FLAG_L3MDEV_SRC          0x04
  #define FLOWI_FLAG_SKIP_NH_OIF         0x08
+#define FLOWI_FLAG_NOT_OIF             0x10
         __u32   flowic_secid;
         struct flowi_tunnel flowic_tun_key;
  };


but there are a number of oif checks that would have to be enhanced with 
the flag check. Adding a flowic_not_oif member is certainly simpler and 
there is a 4-byte hole in the struct.

> @@ -67,6 +68,7 @@ union flowi_uli {
>   struct flowi4 {
>    struct flowi_common __fl_common;
>   #define flowi4_oif  __fl_common.flowic_oif
> +#define flowi4_not_oif  __fl_common.flowic_not_oif
>   #define flowi4_iif  __fl_common.flowic_iif
>   #define flowi4_mark  __fl_common.flowic_mark
>   #define flowi4_tos  __fl_common.flowic_tos
> diff --git a/net/ipv4/fib_trie.c b/net/ipv4/fib_trie.c
> index 7aea0cc..d03e991 100644
> --- a/net/ipv4/fib_trie.c
> +++ b/net/ipv4/fib_trie.c
> @@ -1429,6 +1429,8 @@ found:
>           flp->flowi4_oif != nh->nh_oif)
>        continue;
>      }
> +   if (flp->flowi4_not_oif && flp->flowi4_not_oif == nh->nh_oif)
> +    continue;
>
>      if (!(fib_flags & FIB_LOOKUP_NOREF))
>       atomic_inc(&fi->fib_clntref);
>

For IPv6 start with ip6_pol_route_lookup and modifying rt6_device_match
