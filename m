From: Andrey Ryabinin <ryabinin.a.a-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: KASAN+netlink, was: [PATCH] [net-next?] hns: avoid stack overflow
 with CONFIG_KASAN
Date: Wed, 8 Feb 2017 17:58:44 +0300
Message-ID: <CAPAsAGx4UoUv3tyef56Dfvo7bfinY-hUHhUeDTGWbCxsw72Bqw@mail.gmail.com>
References: <20170203163607.3488037-1-arnd@arndb.de> <20170206.120318.1268240226202516488.davem@davemloft.net>
 <4910112.l20yySyWnA@wuerfel> <1486556665.24745.6.camel@sipsolutions.net> <CAK8P3a2fHm9j7roYjTAXJ_zsdXF88p_6Y-hCF6aWjJzcAaQ3Uw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>,
        David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        Networking <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, stable-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        nikolay-qUQiAmfTcIp+XZJcv9eMoEEOCMrvLtNR@public.gmane.org, nicolas.dichtel-pdR9zngts4EAvxtiuMwx3w@public.gmane.org,
        adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
        linux-wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CAK8P3a2fHm9j7roYjTAXJ_zsdXF88p_6Y-hCF6aWjJzcAaQ3Uw-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

2017-02-08 16:10 GMT+03:00 Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>:
> On Wed, Feb 8, 2017 at 1:24 PM, Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org> wrote:

>
>> Btw, what's causing this to start with? Can't the compiler reuse the
>> stack places?
>
> I have no idea. It's trying to find out of bounds accesses for
> objects on the stack, so maybe it gives each variable a separate
> stack location in order to see which one caused problems?
>

If compiler cannot prove that access to the local variable is valid it
will add redzones around that variable
to be able to detect out of bounds accesses.

For example:
    static inline int nla_put_u8(struct sk_buff *skb, int attrtype, u8 value)
    {
           return nla_put(skb, attrtype, sizeof(u8), &value);
    }
compiler will surround 'value' with redzones to catch potential oob
access in nla_put().


Another way to fix this, would be something like this:

#ifdef CONFIG_KASAN
/* don't bloat stack */
#define __noinline_for_kasan    __noinline __maybe_unused
#else
#define __noinline_for_kasan    inline
#endif

static __noinline_for_kasan int nla_put_u8(struct sk_buff *skb, int
attrtype, u8 value)
{
       return nla_put(skb, attrtype, sizeof(u8), &value);
}
