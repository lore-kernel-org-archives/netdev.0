From: =?UTF-8?q?Linus=20L=C3=BCssing?= <linus.luessing@c0d3.blue>
Subject: [PATCHv3] net: fix bridge multicast packet checksum
	validation
Date: Wed, 24 Feb 2016 04:21:42 +0100
Message-ID: <1456284102-32557-1-git-send-email-linus.luessing@c0d3.blue>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: Tom Herbert <tom@herbertland.com>, bridge@lists.linux-foundation.org,
	linux-kernel@vger.kernel.org,
	"Steinar H . Gunderson" <sgunderson@bigfoot.com>,
	"David S . Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <bridge-bounces@lists.linux-foundation.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/bridge/>
List-Post: <mailto:bridge@lists.linux-foundation.org>
List-Help: <mailto:bridge-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=subscribe>
Sender: bridge-bounces@lists.linux-foundation.org
Errors-To: bridge-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

We need to update the skb->csum after pulling the skb, otherwise
an unnecessary checksum (re)computation can ocure for IGMP/MLD packets
in the bridge code. Additionally this fixes the following splats for
network devices / bridge ports with support for and enabled RX checksum
offloading:

[...]
[   43.986968] eth0: hw csum failure
[   43.990344] CPU: 3 PID: 0 Comm: swapper/3 Not tainted 4.4.0 #2
[   43.996193] Hardware name: BCM2709
[   43.999647] [<800204e0>] (unwind_backtrace) from [<8001cf14>] (show_st=
ack+0x10/0x14)
[   44.007432] [<8001cf14>] (show_stack) from [<801ab614>] (dump_stack+0x=
80/0x90)
[   44.014695] [<801ab614>] (dump_stack) from [<802e4548>] (__skb_checksu=
m_complete+0x6c/0xac)
[   44.023090] [<802e4548>] (__skb_checksum_complete) from [<803a055c>] (=
ipv6_mc_validate_checksum+0x104/0x178)
[   44.032959] [<803a055c>] (ipv6_mc_validate_checksum) from [<802e111c>]=
 (skb_checksum_trimmed+0x130/0x188)
[   44.042565] [<802e111c>] (skb_checksum_trimmed) from [<803a06e8>] (ipv=
6_mc_check_mld+0x118/0x338)
[   44.051501] [<803a06e8>] (ipv6_mc_check_mld) from [<803b2c98>] (br_mul=
ticast_rcv+0x5dc/0xd00)
[   44.060077] [<803b2c98>] (br_multicast_rcv) from [<803aa510>] (br_hand=
le_frame_finish+0xac/0x51c)
[...]

Fixes: 9afd85c9e455 ("net: Export IGMP/MLD message validation code")
Reported-by: =C3=81lvaro Fern=C3=A1ndez Rojas <noltari@gmail.com>
Signed-off-by: Linus L=C3=BCssing <linus.luessing@c0d3.blue>
---

v3:
* Missed that an skb_postpush_rcsum() was just added for v4.5, using that
  one instead

v2:
* substituted the storing of the csum with an skb_push_rcsum() approach
 (did some more reading about CHECKSUM_PARTIAL, and it seems to me that t=
he
  skb_push direction is actually the easier/"safer" one, so there should =
be
  no resetting to CHECKSUM_NONE necessary)
* Rewording of commit message, this bug should not cause any packet loss
  due to "automatic" checksum recomputations in software if skb->csum
  is bogus (in the CHECKSUM_COMPLETE case)


 net/core/skbuff.c |   22 ++++++++++++++++++++--
 1 file changed, 20 insertions(+), 2 deletions(-)

diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 5bf88f5..8616d11 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -2948,6 +2948,24 @@ int skb_append_pagefrags(struct sk_buff *skb, stru=
ct page *page,
 EXPORT_SYMBOL_GPL(skb_append_pagefrags);
=20
 /**
+ *	skb_push_rcsum - push skb and update receive checksum
+ *	@skb: buffer to update
+ *	@len: length of data pulled
+ *
+ *	This function performs an skb_push on the packet and updates
+ *	the CHECKSUM_COMPLETE checksum.  It should be used on
+ *	receive path processing instead of skb_push unless you know
+ *	that the checksum difference is zero (e.g., a valid IP header)
+ *	or you are setting ip_summed to CHECKSUM_NONE.
+ */
+static unsigned char *skb_push_rcsum(struct sk_buff *skb, unsigned len)
+{
+	skb_push(skb, len);
+	skb_postpush_rcsum(skb, skb->data, len);
+	return skb->data;
+}
+
+/**
  *	skb_pull_rcsum - pull skb and update receive checksum
  *	@skb: buffer to update
  *	@len: length of data pulled
@@ -4084,9 +4102,9 @@ struct sk_buff *skb_checksum_trimmed(struct sk_buff=
 *skb,
 	if (!pskb_may_pull(skb_chk, offset))
 		goto err;
=20
-	__skb_pull(skb_chk, offset);
+	skb_pull_rcsum(skb_chk, offset);
 	ret =3D skb_chkf(skb_chk);
-	__skb_push(skb_chk, offset);
+	skb_push_rcsum(skb_chk, offset);
=20
 	if (ret)
 		goto err;
--=20
1.7.10.4
