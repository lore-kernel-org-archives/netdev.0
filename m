From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Subject: Re: [E1000-devel] [PATCH 1/2] if_link: Add VF multicast promiscuous mode control
Date: Thu, 22 Jan 2015 20:31:52 +0100
Message-ID: <87bnlqpq6v.fsf@nemi.mork.no>
References: <7F861DC0615E0C47A872E6F3C5FCDDBD05E0734E@BPXM14GP.gisp.nec.co.jp>
	<874mrlu18e.fsf@nemi.mork.no>
	<7F861DC0615E0C47A872E6F3C5FCDDBD05E07B7C@BPXM14GP.gisp.nec.co.jp>
	<F6FB0E698C9B3143BDF729DF222866469129B7F5@ORSMSX110.amr.corp.intel.com>
	<7F861DC0615E0C47A872E6F3C5FCDDBD05E07F09@BPXM14GP.gisp.nec.co.jp>
	<F6FB0E698C9B3143BDF729DF222866469129B844@ORSMSX110.amr.corp.intel.com>
	<7F861DC0615E0C47A872E6F3C5FCDDBD05E08FF6@BPXM14GP.gisp.nec.co.jp>
	<063D6719AE5E284EB5DD2968C1650D6D1CAD01D6@AcuExch.aculab.com>
	<7F861DC0615E0C47A872E6F3C5FCDDBD05E090FE@BPXM14GP.gisp.nec.co.jp>
	<F6FB0E698C9B3143BDF729DF222866469129BC03@ORSMSX110.amr.corp.intel.com>
	<063D6719AE5E284EB5DD2968C1650D6D1CAD0C8A@AcuExch.aculab.com>
	<F6FB0E698C9B3143BDF729DF222866469129BFFD@ORSMSX110.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Laight <David.Laight@ACULAB.COM>,
	Hiroshi Shimamoto <h-shimamoto@ct.jp.nec.com>,
	"e1000-devel\@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>,
	"netdev\@vger.kernel.org" <netdev@vger.kernel.org>,
	"Choi\, Sy Jong" <sy.jong.choi@intel.com>,
	"linux-kernel\@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Hayato Momma <h-momma@ce.jp.nec.com>
To: "Skidmore\, Donald C" <donald.c.skidmore@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <F6FB0E698C9B3143BDF729DF222866469129BFFD@ORSMSX110.amr.corp.intel.com>
	(Donald C. Skidmore's message of "Thu, 22 Jan 2015 19:00:51 +0000")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

"Skidmore, Donald C" <donald.c.skidmore@intel.com> writes:

> My hang up is more related to: without the nob to enable it (off by
> default) we are letting one VF dictate policy for all the other VFs
> and the PF.  If one VF needs to be in promiscuous multicast so is
> everyone else.  Their stacks now needs to deal with all the extra
> multicast packets.  As you point out this might not be a direct
> concern for isolation in that the VM could have 'chosen' to join any
> Multicast group and seen this traffic.  My concern over isolation is
> one VF has chosen that all the other VM now have to see this multicas=
t
> traffic.

Apologies if this question is stupid, but I just have to ask about stuf=
f
I don't understand...

Looking at the proposed implementation, the promiscous multicast flag
seems to be a per-VF flag:

+int ixgbe_ndo_set_vf_mc_promisc(struct net_device *netdev, int vf, boo=
l setting)
+{
+	struct ixgbe_adapter *adapter =3D netdev_priv(netdev);
+	struct ixgbe_hw *hw =3D &adapter->hw;
+	u32 vmolr;
+
+	if (vf >=3D adapter->num_vfs)
+		return -EINVAL;
+
+	adapter->vfinfo[vf].mc_promisc_enabled =3D setting;
+
+	vmolr =3D IXGBE_READ_REG(hw, IXGBE_VMOLR(vf));
+	if (setting) {
+		e_info(drv, "VF %u: enabling multicast promiscuous\n", vf);
+		vmolr |=3D IXGBE_VMOLR_MPE;
+	} else {
+		e_info(drv, "VF %u: disabling multicast promiscuous\n", vf);
+		vmolr &=3D ~IXGBE_VMOLR_MPE;
+	}
+
+	IXGBE_WRITE_REG(hw, IXGBE_VMOLR(vf), vmolr);
+
+	return 0;
+}
+

I haven't read the data sheet, but I took a quick look at the excellent
high level driver docs:
http://www.intel.com/content/dam/doc/design-guide/82599-sr-iov-driver-c=
ompanion-guide.pdf

It mentions "Multicast Promiscuous Enable" in its "Thoughts for
Customization" section:

 7.1 Multicast Promiscuous Enable

 The controller has provisions to allow each VF to be put into Multicas=
t
 Promiscuous mode.  The Intel reference driver does not configure this
 option .

 The capability can be enabled/disabled by manipulating the MPE field
 (bit 28) of the PF VF L2 Control Register (PFVML2FLT =E2=80=93 0x0F000=
)

and showing a section from the data sheet describing the
"PF VM L2 Control Register - PFVML2FLT[n]  (0x0F000 + 4 * n, n=3D0...63=
; RW)"

To me it looks like enabling Promiscuos Multicast for a VF won't affect
any other VF at all.  Is this really not the case?



Bj=C3=B8rn
