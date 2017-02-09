From: Dmitry Vyukov <dvyukov@google.com>
Subject: Re: [PATCH] netlink: move nla_put_{u8,u16,u32} out of line
Date: Thu, 9 Feb 2017 12:28:59 +0100
Message-ID: <CACT4Y+ZCZPh8be8zL1zNt=mqW586ngybiZ66b4Wc7Jt03qqtCw@mail.gmail.com>
References: <20170208211843.2822208-1-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
        David Laight <David.Laight@aculab.com>,
        netdev <netdev@vger.kernel.org>,
        Johannes Berg <johannes.berg@intel.com>,
        Andrey Ryabinin <aryabinin@virtuozzo.com>,
        Alexander Potapenko <glider@google.com>,
        kasan-dev <kasan-dev@googlegroups.com>,
        Nicolas Dichtel <nicolas.dichtel@6wind.com>,
        Alexey Dobriyan <adobriyan@gmail.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Thomas Graf <tgraf@suug.ch>,
        Eric Dumazet <edumazet@google.com>,
        LKML <linux-kernel@vger.kernel.org>
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ua0-f179.google.com ([209.85.217.179]:34623 "EHLO
        mail-ua0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752061AbdBILaw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 9 Feb 2017 06:30:52 -0500
Received: by mail-ua0-f179.google.com with SMTP id 35so560354uak.1
        for <netdev@vger.kernel.org>; Thu, 09 Feb 2017 03:29:21 -0800 (PST)
In-Reply-To: <20170208211843.2822208-1-arnd@arndb.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Feb 8, 2017 at 10:18 PM, Arnd Bergmann <arnd@arndb.de> wrote:
> When CONFIG_KASAN is enabled, the "--param asan-stack=1" causes rather large
> stack frames in some functions. This goes unnoticed normally because
> CONFIG_FRAME_WARN is disabled with CONFIG_KASAN by default as of commit
> 3f181b4d8652 ("lib/Kconfig.debug: disable -Wframe-larger-than warnings with
> KASAN=y").
>
> The kernelci.org build bot however has the warning enabled and that led
> me to investigate it a little further, as every build produces these warnings:
>
> net/wireless/nl80211.c:4389:1: warning: the frame size of 2240 bytes is larger than 2048 bytes [-Wframe-larger-than=]
> net/wireless/nl80211.c:1895:1: warning: the frame size of 3776 bytes is larger than 2048 bytes [-Wframe-larger-than=]
> net/wireless/nl80211.c:1410:1: warning: the frame size of 2208 bytes is larger than 2048 bytes [-Wframe-larger-than=]
> net/bridge/br_netlink.c:1282:1: warning: the frame size of 2544 bytes is larger than 2048 bytes [-Wframe-larger-than=]


This may be a good thing in itself, I don't know. But I don't think we
need to do this for KASAN.
KASAN does increase stack frames, but it also doubles stack size. So
at the very least we need to also double CONFIG_FRAME_WARN under KASAN
to 4096, which would auto-fix your warnings. Enabling 4096 warning for
KASAN may be moderately useful (catch cases of extremely large frames,
because KASAN frame increase can be much larger than 2x). But I am
watching these "used greatest stack depth" messages and also my test
bots and never seen anything worryingly low.

I've built kernel with KASAN+KCOV and there is 381 case throughout the codebase:
https://gist.githubusercontent.com/dvyukov/038426827b369f62d56e50cb39db29df/raw/96cdd758f06751339428c05fda3bc09c6beb700b/gistfile1.txt
Changing code for each of them looks like lots of work, and can
introduce bugs. 4096 would leave about 50 of them, but it's still
lots.


> It turns out that there is a relatively simple workaround for the netlink
> users that currently use a local variable in order to do the type conversion:
> Moving the three functions (for each of the typical sizes) to lib/nlattr.c
> avoids using local variables in the caller, which drastically reduces the
> stack usage for nl80211 and br_netlink.
>
> It would be good if we could enable the frame size check after that again,
> but that should be a separate patch and it requires some more testing
> to see which the largest acceptable frame size should be.
>
> Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>
> Cc: Alexander Potapenko <glider@google.com>
> Cc: Dmitry Vyukov <dvyukov@google.com>
> Cc: kasan-dev@googlegroups.com
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>
> ---
>  include/net/netlink.h | 23 +++++++----------------
>  lib/nlattr.c          | 18 ++++++++++++++++++
>  2 files changed, 25 insertions(+), 16 deletions(-)
>
> diff --git a/include/net/netlink.h b/include/net/netlink.h
> index b239fcd33d80..48b117e80509 100644
> --- a/include/net/netlink.h
> +++ b/include/net/netlink.h
> @@ -755,10 +755,7 @@ static inline int nla_parse_nested(struct nlattr *tb[], int maxtype,
>   * @attrtype: attribute type
>   * @value: numeric value
>   */
> -static inline int nla_put_u8(struct sk_buff *skb, int attrtype, u8 value)
> -{
> -       return nla_put(skb, attrtype, sizeof(u8), &value);
> -}
> +extern int nla_put_u8(struct sk_buff *skb, int attrtype, u8 value);
>
>  /**
>   * nla_put_u16 - Add a u16 netlink attribute to a socket buffer
> @@ -766,10 +763,7 @@ static inline int nla_put_u8(struct sk_buff *skb, int attrtype, u8 value)
>   * @attrtype: attribute type
>   * @value: numeric value
>   */
> -static inline int nla_put_u16(struct sk_buff *skb, int attrtype, u16 value)
> -{
> -       return nla_put(skb, attrtype, sizeof(u16), &value);
> -}
> +extern int nla_put_u16(struct sk_buff *skb, int attrtype, u16 value);
>
>  /**
>   * nla_put_be16 - Add a __be16 netlink attribute to a socket buffer
> @@ -779,7 +773,7 @@ static inline int nla_put_u16(struct sk_buff *skb, int attrtype, u16 value)
>   */
>  static inline int nla_put_be16(struct sk_buff *skb, int attrtype, __be16 value)
>  {
> -       return nla_put(skb, attrtype, sizeof(__be16), &value);
> +       return nla_put_u16(skb, attrtype, (u16 __force)value);
>  }
>
>  /**
> @@ -801,7 +795,7 @@ static inline int nla_put_net16(struct sk_buff *skb, int attrtype, __be16 value)
>   */
>  static inline int nla_put_le16(struct sk_buff *skb, int attrtype, __le16 value)
>  {
> -       return nla_put(skb, attrtype, sizeof(__le16), &value);
> +       return nla_put_u16(skb, attrtype, (u16 __force)value);
>  }
>
>  /**
> @@ -810,10 +804,7 @@ static inline int nla_put_le16(struct sk_buff *skb, int attrtype, __le16 value)
>   * @attrtype: attribute type
>   * @value: numeric value
>   */
> -static inline int nla_put_u32(struct sk_buff *skb, int attrtype, u32 value)
> -{
> -       return nla_put(skb, attrtype, sizeof(u32), &value);
> -}
> +int nla_put_u32(struct sk_buff *skb, int attrtype, u32 value);
>
>  /**
>   * nla_put_be32 - Add a __be32 netlink attribute to a socket buffer
> @@ -823,7 +814,7 @@ static inline int nla_put_u32(struct sk_buff *skb, int attrtype, u32 value)
>   */
>  static inline int nla_put_be32(struct sk_buff *skb, int attrtype, __be32 value)
>  {
> -       return nla_put(skb, attrtype, sizeof(__be32), &value);
> +       return nla_put_u32(skb, attrtype, (u32 __force)value);
>  }
>
>  /**
> @@ -845,7 +836,7 @@ static inline int nla_put_net32(struct sk_buff *skb, int attrtype, __be32 value)
>   */
>  static inline int nla_put_le32(struct sk_buff *skb, int attrtype, __le32 value)
>  {
> -       return nla_put(skb, attrtype, sizeof(__le32), &value);
> +       return nla_put_u32(skb, attrtype, (u32 __force)value);
>  }
>
>  /**
> diff --git a/lib/nlattr.c b/lib/nlattr.c
> index b42b8577fc23..2988b08a7e4d 100644
> --- a/lib/nlattr.c
> +++ b/lib/nlattr.c
> @@ -548,6 +548,24 @@ int nla_put(struct sk_buff *skb, int attrtype, int attrlen, const void *data)
>  }
>  EXPORT_SYMBOL(nla_put);
>
> +int nla_put_u8(struct sk_buff *skb, int attrtype, u8 value)
> +{
> +       return nla_put(skb, attrtype, sizeof(u8), &value);
> +}
> +EXPORT_SYMBOL(nla_put_u8);
> +
> +int nla_put_u16(struct sk_buff *skb, int attrtype, u16 value)
> +{
> +       return nla_put(skb, attrtype, sizeof(u16), &value);
> +}
> +EXPORT_SYMBOL(nla_put_u16);
> +
> +int nla_put_u32(struct sk_buff *skb, int attrtype, u32 value)
> +{
> +       return nla_put(skb, attrtype, sizeof(u32), &value);
> +}
> +EXPORT_SYMBOL(nla_put_u32);
> +
>  /**
>   * nla_put_64bit - Add a netlink attribute to a socket buffer and align it
>   * @skb: socket buffer to add attribute to
> --
> 2.9.0
>
