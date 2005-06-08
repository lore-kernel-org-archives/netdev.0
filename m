From: Jesse Brandeburg <jesse.brandeburg@intel.com>
Subject: Re: RFC: NAPI packet weighting patch
Date: Tue, 7 Jun 2005 19:20:37 -0700 (PDT)
Message-ID: <Pine.LNX.4.62.0506071852290.31708@ladlxr>
References: <468F3FDA28AA87429AD807992E22D07E0450C01F@orsmsx408>
 <20050607.132159.35660612.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="8323328-1056581817-1118197237=:31708"
Cc: "Ronciak, John" <john.ronciak@intel.com>, hadi@cyberus.ca,
        shemminger@osdl.org, "Williams, Mitch A" <mitch.a.williams@intel.com>,
        mchan@broadcom.com, buytenh@wantstofly.org, jdmason@us.ibm.com,
        netdev@oss.sgi.com, Robert.Olsson@data.slu.se,
        "Venkatesan, Ganesh" <ganesh.venkatesan@intel.com>,
        "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20050607.132159.35660612.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--8323328-1056581817-1118197237=:31708
Content-Type: TEXT/PLAIN; charset=iso-8859-1; format=flowed
Content-Transfer-Encoding: quoted-printable
X-MIME-Autoconverted: from 8bit to quoted-printable by oss.sgi.com id j582OYXq018954

On Tue, 7 Jun 2005, David S. Miller wrote:
> > There also seems to be some misconceptions about changing the weight
> > value.=A0 It actually improves the performance of other drivers as we=
ll.
> > Not as much as it improves the e1000 performance but it does seem to
> > help others as well.
>=20
> One reason it helps e1000 more, which Robert Olsson mentioned, could
> be the HW irq mitigation settings used by the e1000 driver.=A0 Lowering
> these would be a good test.

Well, first a little more data.  The machine in question is a dual xeon=20
running 2.6.12-rc5 or 2.6.12-rc4-supertso

with the 2.6.12-rc5 kernel (the old) tso promptly shuts down after a SACK=
,=20
and after that point the machine is CPU bound at 100%.  This is the point=
=20
that we start to drop packets at the hardware level.

I tried the experiment today where I replenish buffers to hardware every=20
16 packets or so.  This appears to mitigate all drops at the hardware=20
level (no drops).  We're still at 100% with the rc5 kernel, however.

even with this replenish fix, the addition of dropping the weight to 16=20
helped increase our throughput, although only about 1%.

On the other hand, taking our driver as is with no changes and running th=
e=20
supertso (not the split out version, yet) kernel, we show no dropped=20
packets and 60% cpu use.  This combines with a 6% increase in throughput,=
=20
and the data pattern on the wire is much more constant (i have tcpdumps,=20
do you want to see them Dave?)

I'm looking forward to trying the split out patches tomorrow.

here is my (compile tested) patch, for e1000

diff -rup e1000-6.0.60.orig/src/e1000_main.c e1000-6.0.60/src/e1000_main.=
c
--- e1000-6.0.60.orig/src/e1000_main.c	2005-06-07 19:07:37.000000000 -070=
0
+++ e1000-6.0.60/src/e1000_main.c	2005-06-07 19:15:05.000000000 -0700
@@ -3074,11 +3074,14 @@ e1000_clean_rx_irq(struct e1000_adapter
  next_desc:
  		rx_desc->status =3D 0;
  		buffer_info->skb =3D NULL;
+		if(unlikely((i & ~(E1000_RX_BUFFER_WRITE - 1)) =3D=3D i))
+			adapter->alloc_rx_buf(adapter);
  		if(unlikely(++i =3D=3D rx_ring->count)) i =3D 0;

  		rx_desc =3D E1000_RX_DESC(*rx_ring, i);
  	}
  	rx_ring->next_to_clean =3D i;
+	/* not sure this is necessary any more, but its safe */
  	adapter->alloc_rx_buf(adapter);

  	return cleaned;
@@ -3209,12 +3212,15 @@ e1000_clean_rx_irq_ps(struct e1000_adapt
  next_desc:
  		rx_desc->wb.middle.status_error &=3D ~0xFF;
  		buffer_info->skb =3D NULL;
+		if(unlikely((i & ~(E1000_RX_BUFFER_WRITE - 1)) =3D=3D i))
+			adapter->alloc_rx_buf(adapter);
  		if(unlikely(++i =3D=3D rx_ring->count)) i =3D 0;

  		rx_desc =3D E1000_RX_DESC_PS(*rx_ring, i);
  		staterr =3D le32_to_cpu(rx_desc->wb.middle.status_error);
  	}
  	rx_ring->next_to_clean =3D i;
+	/* not sure this is necessary any more, but its safe */
  	adapter->alloc_rx_buf(adapter);

  	return cleaned;

PS e1000-6.0.60 is posted on sf.net/projects/e1000 now.


--8323328-1056581817-1118197237=:31708--
