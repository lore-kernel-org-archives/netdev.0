From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: Re: linux-next: Tree for May 16 (net/core)
Date: Tue, 16 May 2017 15:44:40 -0400
Message-ID: <CAP=VYLoYkz1HE4yOHVGQvBanDtpkWhtHBMvbeuyd8PtNFCivRQ@mail.gmail.com>
References: <20170516112125.517607f8@canb.auug.org.au> <f63533e7-edd3-4c0d-ddff-e3409d15abc6@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Stephen Rothwell <sfr@canb.auug.org.au>,
        Linux-Next Mailing List <linux-next@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Eric Dumazet <edumazet@google.com>
To: Randy Dunlap <rdunlap@infradead.org>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <f63533e7-edd3-4c0d-ddff-e3409d15abc6@infradead.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, May 16, 2017 at 12:28 PM, Randy Dunlap <rdunlap@infradead.org> wrote:
> On 05/15/17 18:21, Stephen Rothwell wrote:
>> Hi all,
>>
>> Changes since 20170515:
>>
>
> on i386 or x86_64:
>
> when CONFIG_INET is not enabled:
>
> ../net/core/sock.c: In function 'skb_orphan_partial':
> ../net/core/sock.c:1810:2: error: implicit declaration of function 'skb_is_tcp_pure_ack' [-Werror=implicit-function-declaration]
>   if (skb_is_tcp_pure_ack(skb))

Automated bisect on an ARM build with the same issue reveals:

f6ba8d33cfbb46df569972e64dbb5bb7e929bfd9 is the first bad commit
commit f6ba8d33cfbb46df569972e64dbb5bb7e929bfd9
Author: Eric Dumazet <edumazet@google.com>
Date:   Thu May 11 15:24:41 2017 -0700

    netem: fix skb_orphan_partial()

    I should have known that lowering skb->truesize was dangerous :/

    In case packets are not leaving the host via a standard Ethernet device,
    but looped back to local sockets, bad things can happen, as reported
    by Michael Madsen ( https://bugzilla.kernel.org/show_bug.cgi?id=195713 )

    So instead of tweaking skb->truesize, lets change skb->destructor
    and keep a reference on the owner socket via its sk_refcnt.

    Fixes: f2f872f9272a ("netem: Introduce skb_orphan_partial() helper")
    Signed-off-by: Eric Dumazet <edumazet@google.com>
    Reported-by: Michael Madsen <mkm@nabto.com>
    Signed-off-by: David S. Miller <davem@davemloft.net>

:040000 040000 7bfb7a6f5e12373b1c50ede2455b6ddd6d79cee0
b45b7255322f1dff5e3ab8d3d707cf38a91c76ce M      net
bisect run success

http://kisskb.ellerman.id.au/kisskb/buildresult/13033081/

I'm guessing Eric already knows about this but I've Cc'd him just in case.

P.
--

>
>
> --
> ~Randy
