From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: 2.6.31 regression: e1000e jumbo frames no longer
	work: 'Unsupported MTU setting'
Date: Sat, 26 Sep 2009 19:14:55 -0700
Message-ID: <5f2db9d90909261914l3a927f4cya1dc5e4548688bce@mail.gmail.com>
References: <871vluc5wi.fsf@spindle.srvr.nix>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: e1000-devel@lists.sourceforge.net, netdev <netdev@vger.kernel.org>,
	bruce.w.allan@intel.com, linux-kernel@vger.kernel.org
To: Nix <nix@esperi.org.uk>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <871vluc5wi.fsf@spindle.srvr.nix>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On Sat, Sep 26, 2009 at 4:16 AM, Nix <nix@esperi.org.uk> wrote:
> [Bruce, you have changes in net-next in this area, so you might have a cl=
ue
> =A0what's going on here.]
>
> In 2.6.30.x, I was happily bringing up the 82574L cards in one server like
> this:
>
> ip link set fastnet up mtu 7200
>
> As of 2.6.31.x, what I see is this:
>
> spindle:/root# ip link set mtu 7200 dev fastnet
> RTNETLINK answers: Invalid argument
> [ 3380.261796] 0000:02:00.0: fastnet: Unsupported MTU setting
>
> As far as I can tell, all MTUs above 1500 now fail.
>
> 'Unsupported' or not, this used to work, and I'd certainly expect jumbo
> frames to be supported on a gigabit card!
>
> I can't see any terribly relevant changes to e1000e between 2.6.30 and
> 2.6.31, so I'm Cc:ing netdev on the offchance that this is something
> more generic (unlikely, as 7200-byte MTUs still work fine in 2.6.31 with
> the r8169 I'm typing this on, but that doesn't help if half the subnet
> is forced to use MTUs of 1500).

It looks like the problem is that the 82574 and 82583 seem to have
their max_hw_frame_size values swapped.  You might try applying the
patch below.  I am not sure if it will apply since I hand generated it
using the git patch that seems to have introduced the problem, and I
am sending the patch through an untested account that may mangle the
patch.  I will see about submitting an official patch for this
sometime next few days.

Thanks,

Alex

diff --git a/drivers/net/e1000e/82571.c b/drivers/net/e1000e/82571.c
--- a/drivers/net/e1000e/82571.c
+++ b/drivers/net/e1000e/82571.c
@@ -1803,7 +1803,7 @@ struct e1000_info e1000_82574_info =3D {
 				  | FLAG_HAS_AMT
 				  | FLAG_HAS_CTRLEXT_ON_LOAD,
 	.pba			=3D 20,
-	.max_hw_frame_size	=3D ETH_FRAME_LEN + ETH_FCS_LEN,
+	.max_hw_frame_size	=3D DEFAULT_JUMBO,
 	.get_variants		=3D e1000_get_variants_82571,
 	.mac_ops		=3D &e82571_mac_ops,
 	.phy_ops		=3D &e82_phy_ops_bm,
@@ -1820,7 +1820,7 @@ struct e1000_info e1000_82583_info =3D {
 				  | FLAG_HAS_AMT
 				  | FLAG_HAS_CTRLEXT_ON_LOAD,
 	.pba			=3D 20,
-	.max_hw_frame_size	=3D DEFAULT_JUMBO,
+	.max_hw_frame_size	=3D ETH_FRAME_LEN + ETH_FCS_LEN,
 	.get_variants		=3D e1000_get_variants_82571,
 	.mac_ops		=3D &e82571_mac_ops,
 	.phy_ops		=3D &e82_phy_ops_bm,

---------------------------------------------------------------------------=
---
Come build with us! The BlackBerry&reg; Developer Conference in SF, CA
is the only developer event you need to attend this year. Jumpstart your
developing skills, take BlackBerry mobile applications to market and stay =

ahead of the curve. Join us from November 9&#45;12, 2009. Register now&#33;
http://p.sf.net/sfu/devconf
