From: Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH for-next 01/10] net/core: Add support for configuring VF
 GUIDs
Date: Fri, 4 Mar 2016 09:35:41 -0500
Message-ID: <56D99D3D.4000606@redhat.com>
References: <1456851143-138332-1-git-send-email-eli@mellanox.com>
 <1456851143-138332-2-git-send-email-eli@mellanox.com>
 <20160301173751.GA25176@obsidianresearch.com>
 <20160301174951.GA19366@x-vnc01.mtx.labs.mlnx>
 <20160301182516.GA12495@obsidianresearch.com>
 <CAJ3xEMgrAUCj7PS6fegmuSUsjMruH3gzSHZmuzAX+ZbHZOpL9w@mail.gmail.com>
 <56D719E3.2000206@redhat.com>
 <CAJ3xEMh5vJAZVO03=rRVCvqqXzXvah3idrMtMQfFP-wBxR7R_Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 protocol="application/pgp-signature";
 boundary="LGm3xcXRHMHrJStIWFcQiNo14CM4LFoeS"
Cc: Jason Gunthorpe <jgunthorpe-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>,
	Eli Cohen <eli-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	"linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Liran Liss <liranl-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Linux Netdev List <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Or Gerlitz <gerlitz.or-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CAJ3xEMh5vJAZVO03=rRVCvqqXzXvah3idrMtMQfFP-wBxR7R_Q-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--LGm3xcXRHMHrJStIWFcQiNo14CM4LFoeS
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

On 03/02/2016 01:40 PM, Or Gerlitz wrote:
> On Wed, Mar 2, 2016 at 6:50 PM, Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> wrot=
e:
>=20
>> Exactly *what* provisioning system tries to set the VF_MAC on an IPoIB=

>> interface and expects it to set the GUID of an underlying IB device?
>=20
> The provisioning system need not be fully aware in all their
> components this is IB here, there's PCI linkage that tells these are
> VFs of this PF and they have to be used for these VMs.

If I understand you correctly, then I don't think I agree.

=46rom what I read, I gather you mean:

libvirt can be used to control guests today, and you can list a PCI
device as "managed" and specify a MAC address (which has libvirt
assuming the device is an ethernet device).  In that case, libvirt
automatically detaches the device from the host (if attached), figures
out if it's a PF or VF, sets the MAC address using either PF or VF MAC
setting methods in ethtool, attaches the device to the guest, then
starts the guest.  And you're saying we should put the MAC->GUID
transformation into this code for IB so that libvirt can be blissfully
ignorant and people can tell libvirt it's an ethernet device with a MAC
and libvirt will treat it as such and life will be grand.

Except it won't.  Along with setting the GUID, we also need to set the
P_Keys allowed list (at least using the alias GUIDs method of mlx4 you
do, so unless you add a patch to this series to switch mlx4 to this new
method, that's a valid concern).  And nothing in libvirt can do that as
long libvirt thinks this is ethernet because libvirt doesn't control the
vlans on a guest's ethernet device, the guest does.  In that sense, IB
and ethernet vary greatly.

So, at *best*, the solution you are suggesting for existing setups is a
partial solution that leaves things only half done.

I don't see the justification to clutter up upstream code with a
solution that isn't at least completely functional in its
implementation.  If the solution is only partial, then I would rather
leave it out and tell people to upgrade their libvirt to know about IB
devices.

This is actually further backed up, in my mind, by the fact that you can
have RoCE/iWARP Ethernet devices and regular Ethernet devices, and
libvirt needs to be taught the concept of an RDMA capable device,
whether Ethernet or IB, so that when trying to select a host for
migration it can make sure that the migration target has the same
capabilities as the hardware you are migrating from.  So, to me, doing
this right *requires* a libvirt upgrade, and there is no sense in this
middle ground GUID from MAC hack that you are suggesting.

>>> along with the fully IB aware solution where the
>>> upper level does provision IB GUIDs.
>=20
>> There has never been upstream support for this MAC->GUID stuff you ref=
er
>> to.  I'm not convinced we should add it now versus just doing things
>> right, period.
>=20
> We **are** doing things right with the new ndo.
>=20
> Using the small MAC->GUID addition, people could be using non-modified
> (or almost non-modified) provisioning systems that assign SRIOV VMs
> with a MACs --- just use these patches on their hosts and get DHCP
> server supplying IP addresses based on the derived GUIDs (this is
> supported today).
>=20


--=20
Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
              GPG KeyID: 0E572FDD



--LGm3xcXRHMHrJStIWFcQiNo14CM4LFoeS
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2
Comment: Using GnuPG with Thunderbird - http://www.enigmail.net/

iQIcBAEBCAAGBQJW2Z0+AAoJELgmozMOVy/dHEEP/34tlwk6k4Hj5nf0HdzRZYso
y4lV+qcTqZP7+qF8uloLpI03FOs2Ezwgk7UG+qbUcMd5fmPes7BmlTyyEnmwCyWd
wd6E2jVyXp2x37Iujo/Hwt/Xh7ii3TRQ/nFsZBOiwPFAG3lkcNmLJY4DPgM+DNBv
MPj0qEShdxmRBx6TfoZtNXYmXSjUUV+HXnCNWa9xfVRa3XiHV+sB/3OwR1eXuqVm
MVciC5LVp+3/4Oit38+eZ25nn9pSlCxOkWIljZ5HXKTgqsv4JKUpknmooDAtU3/3
4kvCMS49EcchFy8UoxXm8RLdq8fE0HTSnkCAYQ7W0sNUPUw/nXc1hNc5ga4wo5Jr
Dm+xm6wZYl6Qi7j0265bTAPrTaJgBlI4bA/qSGKTDgRRCsUJLUijkJEtaoOyCjzE
7QN2P9gHgP48sZj0JNn5ABuU870smaD7nQlGPBqNbuxsOw7Zzvc6N34wfOOaJrwv
lY8utefCbxvKwDrmkuVuU7J0DAIX2YvG5nnrPLOlofXHFs8bJ48ZMThJTOK6Lbo3
oSoU8mW5xPALtehtV92SyU6WjMygYddXUtxxGnaxQOVnTHsYj+eQgc7Do4megmCm
4I1nzpAR7KFfl2gC472PO7wZsGjiGFb9abS6teshQy16gl+lMM4kg8UuK9yQBCNi
uVQsGvkeDc5MOF76r9Q9
=0TJE
-----END PGP SIGNATURE-----

--LGm3xcXRHMHrJStIWFcQiNo14CM4LFoeS--
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
