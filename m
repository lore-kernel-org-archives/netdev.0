From: "Rustad, Mark D" <mark.d.rustad@intel.com>
Subject: Re: [Intel-wired-lan] [PATCH] pci: Use a bus-global mutex to
 protect VPD operations
Date: Tue, 19 May 2015 21:53:27 +0000
Message-ID: <DE578829-90CD-4CB0-A206-68A21D91AB0B@intel.com>
References: <20150519000037.56109.68356.stgit@mdrustad-wks.jf.intel.com>
 <555B78F7.60908@redhat.com> <E9012788-257F-4C44-B7F1-789B94423924@intel.com>
 <555BA3F0.5030001@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/signed;
	boundary="Apple-Mail=_6C7E5418-F0F0-406E-A448-83C2E466583A";
	protocol="application/pgp-signature"; micalg=pgp-sha256
Cc: "bhelgaas@google.com" <bhelgaas@google.com>,
	"linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>,
	"intel-wired-lan@lists.osuosl.org" <intel-wired-lan@lists.osuosl.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Alexander Duyck <alexander.h.duyck@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:16414 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751261AbbESVxt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 May 2015 17:53:49 -0400
In-Reply-To: <555BA3F0.5030001@redhat.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--Apple-Mail=_6C7E5418-F0F0-406E-A448-83C2E466583A
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain;
	charset=windows-1252

> On May 19, 2015, at 1:58 PM, Alexander Duyck =
<alexander.h.duyck@redhat.com> wrote:
>=20
> I think you are assuming too much.  Have you root caused the other =
devices?

It is possible that you are right, but I think it is much more likely =
that this is a common design problem with many devices.

> All the "vpd r/w failed" means is that a given read or write timed =
out.  There are any number of possible reasons for that including VPD =
being unimplemented in firmware, a device falling off of the bus, and =
many others.  What you have is a common symptom, it doesn't mean it is a =
common ailment for all the other parts.

Yes, but it sure looks like many PCIe designers have shared the VPD =
registers across functions. It isn't just that the area they address is =
shared, it is that the register implementations are also shared across =
functions. That is the case with all the Intel devices (it is indicated =
in the datasheets) and I'm guessing that other designers have done the =
same thing. It is a guess at this point, but think it is a very good =
one.

>> If after doing that you still feel that this isn't the best solution, =
I can go and cook up something much bigger (I already had two much =
bigger patches that I abandoned in favor of this approach). Bear in mind =
that the quirk code is dead weight in all the kernels.
>=20
> The quirk code is there to deal with buggy hardware implementations =
and that is what it sounds like you have in this case.  I highly doubt =
all of the other vendors implemented the same mistake.  If they did then =
maybe you should implement a the quirk as a new function that can be =
used by any of the devices that implement VPD with the same limitation.

Just the device table to list the affected devices, even if Intel is the =
only vendor with this issue, will be very much larger than this patch =
and every kernel will carry that weight.

>> As you said in another message, VPD is not that vital. Given that, I =
would think that some possible needless synchronization that resolves =
real problems for many devices should be acceptable. If it was =
synchronizing all config space or something that would be different, but =
this is just VPD.
>=20
> The problem is it is needless synchronization, and it only resolves =
problems for some very specific devices.  The extra overhead for =
serializing what is already slow accesses can be very high so I am =
against it.

In any PCIe environment, it only serializes VPD access for one physical =
device's functions. That just isn't that bad.

> For example it will likely have unintended consequences on things like =
virtual machines where all direct assigned devices end up on the same =
bus.

Direct-assigned devices to virtual machines have problems here that I =
can't address. Hypervisors would have to be involved in resolving that =
problem, if it is important enough to do. At present I could only =
suggest that virtual machines should never access VPD at all. This is a =
problem. At least VFs, which are more commonly assigned to guests, do =
not have VPD.

Cutting off the VPD for non-zero functions will have consequences as =
well. Some may notice devices dropping out of their inventory. That =
can't be a good thing and could upset customers. I think that is a far =
larger problem with your approach. Arguably, that is a kernel interface =
change.

> We know that all Intel Ethernet parts to date only implement one VPD =
area per EEPROM, and that all functions in a multi-function Ethernet =
part share the same EEPROM, so the fix is to only present one VPD area =
so that the data is still there, without the ability of multiple access. =
 It seems like function 0 would be the obvious choice in that case so if =
somebody wants to be able to do their inventory they can go through and =
pull inventory information from function 0.  Really this is how this =
should have probably been implemented in the hardware in the first place =
if they couldn't support multiple accesses.

No argument from me there, but I don't have a time machine to go back =
and try to change the thinking on VPD. I'm sure it would take more gates =
to make the functions different, just as it would take more gates to do =
it right. Which is why I think the problem is as widespread as the =
Google results suggest.

Maybe I should send one of my big, ugly patches that only addresses the =
problem for Intel devices. This patch will look good in comparison.

Isn't getting rid of scary messages that upset customers worth =
something?

--
Mark Rustad, Networking Division, Intel Corporation


--Apple-Mail=_6C7E5418-F0F0-406E-A448-83C2E466583A
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename="signature.asc"
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Message signed with OpenPGP using GPGMail

-----BEGIN PGP SIGNATURE-----
Comment: GPGTools - http://gpgtools.org

iQIcBAEBCAAGBQJVW7DWAAoJEDwO/+eO4+5uEWsP/2/Z70ASEvn3sesTaGhUECE6
5NPGThqc8E4BUO5bpIi6b6NiU92XJuy8C2UANR8HWpXJ98HVZbpUQhD7iDgeVRA4
NUl1qDF3gW1MaxGBjZqssTz+InLUzYaxmvg/hzL+m6FOSErcj9WMaQyN9Z6eQ5RL
IVW9B5i2lfXtEzEPzlvjSXTQL6u5HrSVZIXErzatAo73QyA0ewmCQUvS/QegNGn9
7D0tWraLAbdMV0CrXhlvyMq0tID/fhzbi4HRdVLvohrxcLw9sFfpop1tL0nF3APa
95VY1fgDKN2l1lYNrLrPE8Ih8ijd55AqabtExEzyqlpY/NVRUpC/qAebGldXZxR6
3t/0w60XxGwBaRBL5Ly4eMdsieap0F0oGvNcZcJxA5U/Mot0lkEvd9IoiKf4cURr
TReJgZ2cvrmlg7zAtyqHKKuadO35aAOYL0oUkvmu3GtH0bXHRdX1O9XgtWM1L0+1
UkLVwADgYODxiulfzDEWARAlCPDR72eyBzLqU9VzbjJAjIDUgRK0BawdxV8jvoei
Ec/tN4GLsyOpNbbK6DkIZbZ2xndFaEweJ6fmHh3f8xSEjTgv6d7aF+Blc2gjvriR
8Rn5AED4BfQwCJGN706Os4hsirrXYSh0E4d+gE+D90D/oy/C5U6+ysdS6CTW3qE+
flXMuN68CU8ZhKdjZyPb
=Inh9
-----END PGP SIGNATURE-----

--Apple-Mail=_6C7E5418-F0F0-406E-A448-83C2E466583A--
