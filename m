From: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Subject: Re: IGMP Join dropping multicast packets
Date: Fri, 20 Mar 2009 13:36:47 -0700 (Pacific Daylight Time)
Message-ID: <alpine.WNT.2.00.0903201330140.7220@jbrandeb-desk1.amr.corp.intel.com>
References: <91bdcedb0903141316j2dbf4160wb348a5a9e3bde8ad@mail.gmail.com>
	<49BC69D5.5000002@cosmosbay.com>
	<91bdcedb0903151904x1066ac24h63557b588e7c4967@mail.gmail.com>
	<49BEA1ED.4010907@cosmosbay.com>
	<91bdcedb0903172050td2ef895he48168987ad94472@mail.gmail.com>
	<alpine.WNT.2.00.0903181016120.5116@jbrandeb-desk1.amr.corp.intel.com>
	<91bdcedb0903181851v2b3190bekb832df227910e844@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: "e1000-devel@lists.sourceforge.net" <e1000-devel@lists.sourceforge.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Eric Dumazet <dada1@cosmosbay.com>
To: Dave Boutcher <daveboutcher@gmail.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <91bdcedb0903181851v2b3190bekb832df227910e844@mail.gmail.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On Wed, 18 Mar 2009, Dave Boutcher wrote:
> If you go back in this thread I had a dead easy unprivileged user-land te=
stcase
> that causes frame loss. =A0We ran into this in a production environment
> (and I kind
> of glossed over how long it took to figure out why the hell we were dropp=
ing
> frames...you can only increase rmem_max so many times ;-) =A0OTOH not tha=
t many
> people use multicast, and even fewer notice a few dropped frames, so the
> priority is probably lowish.
> =

> On the other other hand, I'm working in the financial trading space these=
 days,
> where Linux is pretty much king....and they're all about multicast.

here is a patch proposal [RFC] only, I've just briefly tested it for e1000 =

parts.  If you want to give it a spin I would appreciate feedback.

[RFC] e1000: fix loss of multicast packets

From: Jesse Brandeburg <jesse.brandeburg@intel.com>

e1000 (and e1000e, igb, ixgbe, ixgb) all do a series of operations each tim=
e a
multicast address is added.  The flow goes something like

1) stack adds one multicast address
2) stack passes whole current list of unicast and multicast addresses to
driver
3) driver clears entire list in hardware
4) driver programs each multicast address using iomem in a loop

This was causing multicast packets to be lost during the reprogramming
process.

reference with test program:
http://kerneltrap.org/mailarchive/linux-netdev/2009/3/14/5160514/thread

Thanks to Dave Boutcher for his report and test program.

This driver fix prepares an array all at once in memory and programs it in =

one shot to the hardware, not requiring an "erase" cycle.  It would still =

be possible for packets to be dropped while the receiver is off during =

reprogramming.

Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
CC: Dave Boutcher <daveboutcher@gmail.com>
---

 drivers/net/e1000/e1000_main.c |   40 +++++++++++++++++++++++++++++++-----=
----
 1 files changed, 31 insertions(+), 9 deletions(-)

diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
index 26474c9..65697ab 100644
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -2328,6 +2328,12 @@ static void e1000_set_rx_mode(struct net_device *net=
dev)
 	int mta_reg_count =3D (hw->mac_type =3D=3D e1000_ich8lan) ?
 				E1000_NUM_MTA_REGISTERS_ICH8LAN :
 				E1000_NUM_MTA_REGISTERS;
+	u32 *mcarray =3D kzalloc(512, GFP_ATOMIC);
+
+	if (!mcarray) {
+		DPRINTK(PROBE, ERR, "memory allocation failed\n");
+		return;
+	}
 =

 	if (hw->mac_type =3D=3D e1000_ich8lan)
 		rar_entries =3D E1000_RAR_ENTRIES_ICH8LAN;
@@ -2394,22 +2400,38 @@ static void e1000_set_rx_mode(struct net_device *ne=
tdev)
 	}
 	WARN_ON(uc_ptr !=3D NULL);
 =

-	/* clear the old settings from the multicast hash table */
-
-	for (i =3D 0; i < mta_reg_count; i++) {
-		E1000_WRITE_REG_ARRAY(hw, MTA, i, 0);
-		E1000_WRITE_FLUSH();
-	}
-
 	/* load any remaining addresses into the hash table */
 =

 	for (; mc_ptr; mc_ptr =3D mc_ptr->next) {
+		u32 hash_reg, hash_bit, mta;
 		hash_value =3D e1000_hash_mc_addr(hw, mc_ptr->da_addr);
-		e1000_mta_set(hw, hash_value);
+		hash_reg =3D (hash_value >> 5) & 0x7F;
+		hash_bit =3D hash_value & 0x1F;
+		mta =3D (1 << hash_bit);
+		mcarray[hash_reg] |=3D mta;
 	}
 =

+	/* write the hash table completely, write from bottom to avoid
+	 * stupid write combining chipsets, and flushing each write */
+	for (i =3D mta_reg_count - 1; i >=3D 0 ; i--) {
+		/* If we are on an 82544 and we are trying to write an odd
+		 * offset in the MTA, save off the previous entry before
+		 * writing and restore the old value after writing.
+		 */
+		if ((hw->mac_type =3D=3D e1000_82544) && ((i & 1) =3D=3D 1)) {
+			u32 temp =3D E1000_READ_REG_ARRAY(hw, MTA, (i - 1));
+			E1000_WRITE_REG_ARRAY(hw, MTA, i, mcarray[i]);
+			E1000_WRITE_REG_ARRAY(hw, MTA, (i - 1), temp);
+		} else {
+			E1000_WRITE_REG_ARRAY(hw, MTA, i, mcarray[i]);
+		}
+	}
+	E1000_WRITE_FLUSH();
+
 	if (hw->mac_type =3D=3D e1000_82542_rev2_0)
 		e1000_leave_82542_rst(adapter);
+	=

+	kfree(mcarray);
 }
 =

 /* Need to wait a few seconds after link up to get diagnostic information =
from
 =


---------------------------------------------------------------------------=
---
Apps built with the Adobe(R) Flex(R) framework and Flex Builder(TM) are
powering Web 2.0 with engaging, cross-platform capabilities. Quickly and
easily build your RIAs with Flex Builder, the Eclipse(TM)based development
software that enables intelligent coding and step-through debugging.
Download the free 60 day trial. http://p.sf.net/sfu/www-adobe-com
