From: Sylvain Rochet <sylvain.rochet@finsecur.com>
Subject: [PATCH 0/2] ppp: mppe: fixes MPPE desync on links which don't guarantee packet ordering
Date: Sun, 26 Apr 2015 20:40:51 +0200
Message-ID: <1430073653-22131-1-git-send-email-sylvain.rochet@finsecur.com>
Cc: Sylvain Rochet <sylvain.rochet@finsecur.com>
To: Paul Mackerras <paulus@samba.org>, linux-ppp@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>
Return-path: <linux-ppp-owner@vger.kernel.org>
Sender: linux-ppp-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I am currently having an issue with PPP over L2TP (UDP) and MPPE in
stateless mode (default mode), UDP does not guarantee packet ordering so
we might get out of order packet. MPPE needs to be continuously synched
so we should drop late UDP packet.

I added a printk on the number of time we rekeyed in MPPE decompressor,
this is what we currently have if we receive a slightly out of order UDP
packet:

[1731001.049206] mppe_decompress[1]: ccount 1559
[1731001.049216] mppe_decompress[1]: rekeyed 1 times

[1731001.049228] mppe_decompress[1]: ccount 1560
[1731001.049232] mppe_decompress[1]: rekeyed 1 times

[1731001.050170] mppe_decompress[1]: ccount 1562
[1731001.050182] mppe_decompress[1]: rekeyed 2 times

[1731001.050191] mppe_decompress[1]: ccount 1561
[1731001.062576] mppe_decompress[1]: rekeyed 4095 times
                                             ^^^^
This is obviously wrong, we missed packet 1561 and we already rekeyed 2
times for 1562 we previously received, we can't recover the decryption
key we need for 1561, we should drop it instead of rekeying 4095 times.

This patch series drop any packet with are not within the 4096/2 forward
window.

Sylvain Rochet (2):
  ppp: mppe: sanity error path rework
  ppp: mppe: discard late packet in stateless mode

 drivers/net/ppp/ppp_mppe.c | 36 ++++++++++++++++++++----------------
 1 file changed, 20 insertions(+), 16 deletions(-)

-- 
2.1.4

