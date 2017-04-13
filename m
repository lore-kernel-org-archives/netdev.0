From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: ney/key: slab-out-of-bounds in parse_ipsecrequests
Date: Wed, 12 Apr 2017 17:39:22 -0700
Message-ID: <CAM_iQpXC03OpCxMQd3VoaVuDHma0Z6h=BuDUf63qc5x1aZvdww@mail.gmail.com>
References: <CAAeHK+yuQZ1v-BBLoeGxfuXg-5uFe6sS5qC-gagaVkq4YroS8g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Steffen Klassert <steffen.klassert@secunet.com>,
        Herbert Xu <herbert@gondor.apana.org.au>,
        "David S. Miller" <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        Dmitry Vyukov <dvyukov@google.com>,
        Kostya Serebryany <kcc@google.com>,
        syzkaller <syzkaller@googlegroups.com>,
        Eric Dumazet <edumazet@google.com>
To: Andrey Konovalov <andreyknvl@google.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAAeHK+yuQZ1v-BBLoeGxfuXg-5uFe6sS5qC-gagaVkq4YroS8g@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Apr 12, 2017 at 8:02 AM, Andrey Konovalov <andreyknvl@google.com> wrote:
> Hi,
>
> I've got the following error report while fuzzing the kernel with syzkaller.
>
> On commit 39da7c509acff13fc8cb12ec1bb20337c988ed36 (4.11-rc6).
>
> A reproducer and .config are attached.
>
> When subtracting rq->sadb_x_ipsecrequest_len from len it can become
> negative and the while loop condition remains true.

Good catch! Seems the fix is pretty straight forward:

diff --git a/net/key/af_key.c b/net/key/af_key.c
index c6252ed..cbce595 100644
--- a/net/key/af_key.c
+++ b/net/key/af_key.c
@@ -1945,7 +1945,7 @@ parse_ipsecrequests(struct xfrm_policy *xp,
struct sadb_x_policy *pol)
        if (pol->sadb_x_policy_len * 8 < sizeof(struct sadb_x_policy))
                return -EINVAL;

-       while (len >= sizeof(struct sadb_x_ipsecrequest)) {
+       while (len >= (int)sizeof(struct sadb_x_ipsecrequest)) {
                if ((err = parse_ipsecrequest(xp, rq)) < 0)
                        return err;
                len -= rq->sadb_x_ipsecrequest_len;

But pol->sadb_x_policy_len and rq->sadb_x_ipsecrequest_len
are controllable by user (fortunately root), I am feeling there might
be other problem I miss too.
