From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: ipsec doesn't route TCP with 4.11 kernel
Date: Fri, 28 Apr 2017 09:13:37 +0200
Message-ID: <20170428071337.GG2649@secunet.com>
References: <CADJev78Cs0VBdagtfU-71pv3HHC5Vq41UXQee856aVbUqEqAYg@mail.gmail.com>
 <CAM_iQpWT5tF5+LpoTP98JNJ=440jEkxHFkn8=jtAsZgondN49A@mail.gmail.com>
 <20170427084238.GX2649@secunet.com>
 <CADJev7_=YEHmijGweqZvdATMQVuzwywEbBKweYvPurJfTEQRjQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        Herbert Xu <herbert@gondor.apana.org.au>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Don Bowman <db@donbowman.ca>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CADJev7_=YEHmijGweqZvdATMQVuzwywEbBKweYvPurJfTEQRjQ@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Apr 27, 2017 at 06:13:38PM -0400, Don Bowman wrote:
> On 27 April 2017 at 04:42, Steffen Klassert <steffen.klassert@secunet.com>
> wrote:
> > On Wed, Apr 26, 2017 at 10:01:34PM -0700, Cong Wang wrote:
> >> (Cc'ing netdev and IPSec maintainers)
> >>
> >> On Tue, Apr 25, 2017 at 6:08 PM, Don Bowman <db@donbowman.ca> wrote:
> 
> for 'esp' question, i have ' esp = aes256-sha256-modp1536!' is that what
> you mean?
> its nat-aware tunnel [from my desktop pc to my office]
> 
> root@office:~# ip -s x s
> src 172.16.0.8 dst 64.7.137.180
>         proto esp spi 0x0d588366(223904614) reqid 1(0x00000001) mode tunnel
>         replay-window 0 seq 0x00000000 flag af-unspec (0x00100000)
>         auth-trunc hmac(sha256)
> 0x046cafdf19c5d78d1c29165d96a0b9fce1c500029d77be0fe956dce1bf80a86a (256
> bits) 128
>         enc cbc(aes)
> 0x79ff2fbc2178eb468de6ff16612f0603b514a1d1d5f375c67222294463ec7c62 (256
> bits)
>         encap type espinudp sport 4500 dport 4500 addr 0.0.0.0

Ok, this is espinudp. This information was important.

> 
> I'm not sure what you mean the receiving interface, you mean the outer, the
> native interface?
> listening on eno1, link-type EN10MB (Ethernet), capture size 262144 bytes
> 18:11:32.061501 IP 172.16.0.8.3416 > 64.7.137.180.33638:
> truncated-udplength 0
> 18:11:32.788091 IP 64.7.137.180.4500 > 172.16.0.8.4500: NONESP-encap:
> isakmp: child_sa  inf2
> 18:11:32.788354 IP 172.16.0.8.4500 > 64.7.137.180.4500: NONESP-encap:
> isakmp: child_sa  inf2[IR]
> 18:11:33.066830 IP 172.16.0.8.3416 > 64.7.137.180.33638:
> truncated-udplength 0
> 18:11:35.082839 IP 172.16.0.8.3416 > 64.7.137.180.33638:
> truncated-udplength 0

This is not a GRO issue as I thought, the TX side is already broken.

Could you please try the patch below?

Subject: [PATCH] esp4: Fix udpencap for local TCP packets.

Locally generated TCP packets are usually cloned, so we
do skb_cow_data() on this packets. After that we need to
reload the pointer to the esp header. On udpencap this
header has an offset to skb_transport_header, so take this
offset into account.

Fixes: commit cac2661c53f ("esp4: Avoid skb_cow_data whenever possible")
Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 net/ipv4/esp4.c | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/net/ipv4/esp4.c b/net/ipv4/esp4.c
index b1e2444..ab71fbb 100644
--- a/net/ipv4/esp4.c
+++ b/net/ipv4/esp4.c
@@ -223,6 +223,7 @@ static int esp_output(struct xfrm_state *x, struct sk_buff *skb)
 	int extralen;
 	int tailen;
 	__be64 seqno;
+	int esp_offset = 0;
 	__u8 proto = *skb_mac_header(skb);
 
 	/* skb is pure payload to encrypt */
@@ -288,6 +289,8 @@ static int esp_output(struct xfrm_state *x, struct sk_buff *skb)
 			break;
 		}
 
+		esp_offset = (unsigned char *)esph - (unsigned char *)uh;
+
 		*skb_mac_header(skb) = IPPROTO_UDP;
 	}
 
@@ -397,7 +400,7 @@ static int esp_output(struct xfrm_state *x, struct sk_buff *skb)
 		goto error;
 	nfrags = err;
 	tail = skb_tail_pointer(trailer);
-	esph = ip_esp_hdr(skb);
+	esph = (struct ip_esp_hdr *)(skb_transport_header(skb) + esp_offset);
 
 skip_cow:
 	esp_output_fill_trailer(tail, tfclen, plen, proto);
-- 
2.7.4
