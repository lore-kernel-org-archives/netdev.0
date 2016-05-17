From: John Stultz <john.stultz@linaro.org>
Subject: [PATCH] asix: Fix offset calculation in asix_rx_fixup() causing slow transmissions
Date: Mon, 16 May 2016 20:36:15 -0700
Message-ID: <1463456175-6674-1-git-send-email-john.stultz@linaro.org>
Cc: John Stultz <john.stultz@linaro.org>,
	Dean Jenkins <Dean_Jenkins@mentor.com>,
	"David B. Robins" <linux@davidrobins.net>,
	Mark Craske <Mark_Craske@mentor.com>,
	Emil Goode <emilgoode@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	YongQin Liu <yongqin.liu@linaro.org>,
	Guodong Xu <guodong.xu@linaro.org>,
	Ivan Vecera <ivecera@redhat.com>, linux-usb@vger.kernel.org,
	netdev@vger.kernel.org, stable <stable@vger.kernel.org>
To: lkml <linux-kernel@vger.kernel.org>
Return-path: <stable-owner@vger.kernel.org>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In testing with HiKey, we found that since
commit 3f30b158eba5 ("asix: On RX avoid creating bad Ethernet
frames"),
we're seeing lots of noise during network transfers:

[  239.027993] asix 1-1.1:1.0 eth0: asix_rx_fixup() Data Header synchronisation was lost, remaining 988
[  239.037310] asix 1-1.1:1.0 eth0: asix_rx_fixup() Bad Header Length 0x54ebb5ec, offset 4
[  239.045519] asix 1-1.1:1.0 eth0: asix_rx_fixup() Bad Header Length 0xcdffe7a2, offset 4
[  239.275044] asix 1-1.1:1.0 eth0: asix_rx_fixup() Data Header synchronisation was lost, remaining 988
[  239.284355] asix 1-1.1:1.0 eth0: asix_rx_fixup() Bad Header Length 0x1d36f59d, offset 4
[  239.292541] asix 1-1.1:1.0 eth0: asix_rx_fixup() Bad Header Length 0xaef3c1e9, offset 4
[  239.518996] asix 1-1.1:1.0 eth0: asix_rx_fixup() Data Header synchronisation was lost, remaining 988
[  239.528300] asix 1-1.1:1.0 eth0: asix_rx_fixup() Bad Header Length 0x2881912, offset 4
[  239.536413] asix 1-1.1:1.0 eth0: asix_rx_fixup() Bad Header Length 0x5638f7e2, offset 4

And network throughput ends up being pretty bursty and slow with
a overall throughput of at best ~30kB/s (where as previously we
got 1.1MB/s with the slower USB1.1 "full speed" host).

We found the issue also was reproducible on a x86_64 system,
using a "high-speed" USB2.0 port but the throughput did not
measurably drop (possibly due to the scp transfer being cpu
bound on my slow test hardware).

After lots of debugging, I found the check added in the
problematic commit seems to be calculating the offset
incorrectly.

In the normal case, in the main loop of the function, we do:
(where offset is zero, or set to "offset += (copy_length + 1) &
0xfffe" in the previous loop)
    rx->header = get_unaligned_le32(skb->data +
                                    offset);
    offset += sizeof(u32);

But the problematic patch calculates:
    offset = ((rx->remaining + 1) & 0xfffe) + sizeof(u32);
    rx->header = get_unaligned_le32(skb->data + offset);

Adding some debug logic to check those offset calculation used
to find rx->header, the one in problematic code is always too
large by sizeof(u32).

Thus, this patch removes the incorrect " + sizeof(u32)" addition
in the problematic calculation, and resolves the issue.

Cc: Dean Jenkins <Dean_Jenkins@mentor.com>
Cc: "David B. Robins" <linux@davidrobins.net>
Cc: Mark Craske <Mark_Craske@mentor.com>
Cc: Emil Goode <emilgoode@gmail.com>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: YongQin Liu <yongqin.liu@linaro.org>
Cc: Guodong Xu <guodong.xu@linaro.org>
Cc: Ivan Vecera <ivecera@redhat.com>
Cc: linux-usb@vger.kernel.org
Cc: netdev@vger.kernel.org
Cc: stable <stable@vger.kernel.org> #4.4+
Reported-by: Yongqin Liu <yongqin.liu@linaro.org>
Signed-off-by: John Stultz <john.stultz@linaro.org>
---
 drivers/net/usb/asix_common.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/usb/asix_common.c b/drivers/net/usb/asix_common.c
index 0c5c22b..7de5ab5 100644
--- a/drivers/net/usb/asix_common.c
+++ b/drivers/net/usb/asix_common.c
@@ -66,7 +66,7 @@ int asix_rx_fixup_internal(struct usbnet *dev, struct sk_buff *skb,
 	 * buffer.
 	 */
 	if (rx->remaining && (rx->remaining + sizeof(u32) <= skb->len)) {
-		offset = ((rx->remaining + 1) & 0xfffe) + sizeof(u32);
+		offset = ((rx->remaining + 1) & 0xfffe);
 		rx->header = get_unaligned_le32(skb->data + offset);
 		offset = 0;
 
-- 
1.9.1
