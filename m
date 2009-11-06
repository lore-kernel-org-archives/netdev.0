From: Gregory Haskins <ghaskins@novell.com>
Subject: Re: [RFC PATCH] net: add dataref destructor to sk_buff
Date: Fri, 06 Nov 2009 11:08:37 -0500
Message-ID: <4AF44A05.4060701@novell.com>
References: <20091002141407.30224.54207.stgit@dev.haskins.net> <20091105.210810.124818005.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enig62984E88BA9121BD157CBBAD"
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	"alacrityvm-devel@lists.sourceforge.net"
	<alacrityvm-devel@lists.sourceforge.net>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1759421AbZKFQIw@vger.kernel.org>
In-Reply-To: <20091105.210810.124818005.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig62984E88BA9121BD157CBBAD
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

David Miller wrote:
> From: Gregory Haskins <ghaskins@novell.com>
> Date: Fri, 02 Oct 2009 10:20:00 -0400
>=20
>> The following is an RFC for an attempt at addressing a zero-copy solut=
ion.
>>
>> To be perfectly honest, I have no idea if this is the best solution, o=
r if
>> there is truly a problem with skb->destructor that requires an alterna=
te
>> mechanism.  What I do know is that this patch seems to work, and I wou=
ld
>> like to see some kind of solution available upstream.  So I thought I =
would
>> send my hack out as at least a point of discussion.  FWIW: This has be=
en
>> tested heavily in my rig and is technically suitable for inclusion aft=
er
>> review as is, if that is decided to be the optimal path forward here.
>>
>> Thanks for your review and consideration,
>=20
> I have no fundamental objections, but when you submit this for
> real can you show the code that uses it so we can get a better
> idea about things?
>=20
> Thanks.

Absolutely.  I am not sure if this content would be appropriate for the
patch header, so I will just reply to your request here.  If you would
like to see the patch resubmitted with the following in the header, let
me know.

The way we use this today is in the venet driver as part of the
AlacrityVM hypervisor.  We therefore have a guest and host environment,
where the guest builds fully formed L2 frames, and the host generally
acts as a conduit for passing those frames to a real physical device
(such as through a soft-bridge, etc).  We would like to do this without
requiring copies for certain classes of packets (i.e. packets larger
than a threshold).  However we have to be smart about how we do this
since the guest technically "owns" the pages, and therefore needs
io-completion events to properly signify when pages are actually freed.

The way this all looks today is (I hope this doesn't get mangled):

----------------------------------------------------------------------
|              guest              |               host               |
----------------------------------------------------------------------
|     stack      |     venet      |     venetdev    |     phydev     |
----------------------------------------------------------------------
| alloc_skb()                                                        |
| dev_xmit()                                                         |
|                -> queue_tx(sg)                                     |
|                                 -> dequeue_rx(sg)                  |
|                                    alloc_pskb()                    |
|                                    map_sg(sg)->pskb                |
|                                    loop(get_page())                |
|                                    skb->release =3D cb               |
|                                                   -> dev_xmit()    |
|                                                                    |
|                                                     txc_isr() <-   |
|                                                     kfree_skb()    |
|                                                     skb->release() |
|                                    cb()           <-               |
|                                     queue_event(sg)                |
|                    txc_isr()    <-                                 |
|                    kfree_skb()                                     |
|                                                    loop(put_page())|
----------------------------------------------------------------------

And here is the actual code in action
(kernel/vbus/devices/venet/device.c) from the alacrityvm.git tree

http://git.kernel.org/?p=3Dlinux/kernel/git/ghaskins/alacrityvm/linux-2.6=
=2Egit;a=3Dblob;f=3Dkernel/vbus/devices/venet/device.c;h=3Dd49ba7fa9f70cb=
b7e61c366d52d4c316d15f8b73;hb=3DHEAD

Line 587 is the "dequeue_rx()" operation from the diagram.  Line 627 is
where we map in the guests pages to a scatterlist.  Line 649 is where we
update the skb_shinfo->frags with the mapping.  And finally, Line 677 is
where I register a callback for when the skb is released.

Line 853 is the callback that the stack invokes when the phydev finally
frees the packet.  You can see that line 863 then sends an
transmit-complete event back up to the guest.

If this is not what you were looking for, please let me know.  If this
looks acceptable to you, please consider the original patch for
inclusion at the next convenient merge window.

Thanks David!
-Greg


--------------enig62984E88BA9121BD157CBBAD
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG/MacGPG2 v2.0.11 (Darwin)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iEYEARECAAYFAkr0SgUACgkQP5K2CMvXmqHznwCeO0+B7MfMXZkXJ3m2lwg0G223
cikAn2mhwOibFLybMzy7hEqThtijVEJI
=C70E
-----END PGP SIGNATURE-----

--------------enig62984E88BA9121BD157CBBAD--
