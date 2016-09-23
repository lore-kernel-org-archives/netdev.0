From: Eric Nelson <eric@nelint.com>
Subject: Alignment issues with freescale FEC driver
Date: Fri, 23 Sep 2016 09:43:14 -0700
Message-ID: <02afb707-65de-5101-a79b-355929c4e00b@nelint.com>
References: <troy.kisky@boundarydevices.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: Otavio Salvador <otavio@ossystems.com.br>,
        Simone <cjb.sw.nospam@gmail.com>
To: "linux-arm-kernel@lists.infradead.org"
        <linux-arm-kernel@lists.infradead.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        rmk+kernel@arm.linux.org.uk, edumazet@google.com,
        Fugang Duan <fugang.duan@nxp.com>,
        Troy Kisky <troy.kisky@boundarydevices.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f181.google.com ([209.85.192.181]:34323 "EHLO
        mail-pf0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752017AbcIWQnR (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 23 Sep 2016 12:43:17 -0400
Received: by mail-pf0-f181.google.com with SMTP id p64so43812385pfb.1
        for <netdev@vger.kernel.org>; Fri, 23 Sep 2016 09:43:17 -0700 (PDT)
In-Reply-To: Troy Kisky <troy.kisky@boundarydevices.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello all,

We're seeing alignment issues from the ethernet stack on an i.MX6UL board:

root@mx6ul:~# cat /proc/cpu/alignment
User: 0
System: 470010 (inet_gro_receive+0x104/0x278)

This seems to be related to the ip header alignment, and there
was much discussion in mailing list threads [1] and [2].

In particular, Russell referred to a patch here, but I haven't been
able to find it:
https://lists.linaro.org/pipermail/linaro-toolchain/2012-October/002844.html

Eric Dumazet also suggested a path toward fixing it, but I don't quite
understand the suggestion:
http://www.spinics.net/lists/netdev/msg213166.htm

The immediate problem is addressed by just reading the id and frag_offs
fields in the iphdr structure as shown in this patch:

commit 98810abc911b1286a7e4a2ebdfbad66f12fae19d
Author: Eric Nelson <eric@nelint.com>
Date: Fri Sep 23 08:26:03 2016 -0700

net: ipv4: af_inet: don't read multiple 16-bit iphdr fields as a 32-bit
value

Change-Id: Idc7122c22c13ca078be31907d30ab1c3148ba807
Signed-off-by: Eric Nelson <eric@nelint.com>

diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index 0cc98b1..c17ef6e 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -1301,6 +1301,7 @@ static struct sk_buff **inet_gro_receive(struct
sk_buff **head,
unsigned int hlen;
unsigned int off;
unsigned int id;
+ unsigned int frag;
int flush = 1;
int proto;

@@ -1326,9 +1327,9 @@ static struct sk_buff **inet_gro_receive(struct
sk_buff **head,
if (unlikely(ip_fast_csum((u8 *)iph, 5)))
goto out_unlock;

- id = ntohl(*(__be32 *)&iph->id);
- flush = (u16)((ntohl(*(__be32 *)iph) ^ skb_gro_len(skb)) | (id & ~IP_DF));
- id >>= 16;
+ id = ntohs(*(__be16 *)&iph->id);
+ frag = ntohs(*(__be16 *)&iph->frag_off);
+ flush = (u16)((ntohl(*(__be32 *)iph) ^ skb_gro_len(skb)) | (frag &
~IP_DF));

for (p = *head; p; p = p->next) {
struct iphdr *iph2;


The reading of both fields in one "ntohl" seems obfuscated at best and
certainly worthy of a comment about the optimization but I understand
from other notes that the fundamental problem is that the IP header should
be aligned on a 4-byte boundary and that's not possible without a memcpy.

I'd like to hear suggestions about how we can address this.

Regards,


Eric

[1] - http://www.spinics.net/lists/netdev/msg213114.html
[2] -
https://lists.linaro.org/pipermail/linaro-toolchain/2012-October/002828.html
