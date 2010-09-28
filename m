From: Antonio Ospite <ospite@studenti.unina.it>
Subject: Re: [PATCH v4 1/2] HID: Add Support for Setting and Getting Feature
 Reports from hidraw
Date: Tue, 28 Sep 2010 15:30:11 +0200
Message-ID: <20100928153011.32750e5d.ospite@studenti.unina.it>
References: <1281442367.12579.206.camel@localhost.localdomain>
	<1281990059-3562-2-git-send-email-alan@signal11.us>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA1";
 boundary="Signature=_Tue__28_Sep_2010_15_30_11_+0200_04WdI0dfmz8J0Vd7"
Cc: Jiri Kosina <jkosina@suse.cz>,
	Stefan Achatz <erazor_de@users.sourceforge.net>,
	Alexey Dobriyan <adobriyan@gmail.com>,
	Tejun Heo <tj@kernel.org>,
	Alan Stern <stern@rowland.harvard.edu>,
	Greg Kroah-Hartman <gregkh@suse.de>,
	Marcel Holtmann <marcel@holtmann.org>,
	Stephane Chatty <chatty@enac.fr>,
	Michael Poole <mdpoole@troilus.org>,
	"David S. Miller" <davem@davemloft.net>,
	Bastien Nocera <hadess@hadess.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	linux-input@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-usb@vger.kernel.org, linux-bluetooth@vger.kernel.org,
	netdev@vger.kernel.org
To: Alan Ott <alan@signal11.us>
Return-path: <linux-input-owner@vger.kernel.org>
In-Reply-To: <1281990059-3562-2-git-send-email-alan@signal11.us>
Sender: linux-input-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Tue__28_Sep_2010_15_30_11_+0200_04WdI0dfmz8J0Vd7
Content-Type: multipart/mixed;
 boundary="Multipart=_Tue__28_Sep_2010_15_30_11_+0200_SaDIWec7Q_CkPCmg"


--Multipart=_Tue__28_Sep_2010_15_30_11_+0200_SaDIWec7Q_CkPCmg
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Mon, 16 Aug 2010 16:20:58 -0400
Alan Ott <alan@signal11.us> wrote:

> Per the HID Specification, Feature reports must be sent and received on
> the Configuration endpoint (EP 0) through the Set_Report/Get_Report
> interfaces.  This patch adds two ioctls to hidraw to set and get feature
> reports to and from the device.  Modifications were made to hidraw and
> usbhid.
>=20
> New hidraw ioctls:
>   HIDIOCSFEATURE - Perform a Set_Report transfer of a Feature report.
>   HIDIOCGFEATURE - Perform a Get_Report transfer of a Feature report.
>=20
> Signed-off-by: Alan Ott <alan@signal11.us>

Hi Alan, I am doing some stress testing on hidraw, if I have a loop with
HIDIOCGFEATURE on a given report and I disconnect the device while the
loop is running I get this:

BUG: unable to handle kernel NULL pointer dereference at 0000000000000028
IP: [<ffffffffa02c66b4>] hidraw_ioctl+0xfc/0x32c [hid]

Full log attached along with the test program, the device is a Sony PS3
Controller (sixaxis).

If my objdump analysis is right, hidraw_ioctl+0xfc should be around line
361 in hidraw.c (with your patch applied):

struct hid_device *hid =3D dev->hid;

It looks like 'dev' (which is hidraw_table[minor]) can be NULL
sometimes, can't it?
This is not introduced by your changes tho.

Just as a side note, the bug does not show up if the userspace program
handles return values properly and exits as soon as it gets an error
from the HID layer, see the XXX comment in test_hidraw_feature.c.

This fixes it, if it looks ok I will resend the patch rebased on
mainline code:

diff --git a/drivers/hid/hidraw.c b/drivers/hid/hidraw.c
index 7df1310..3c040c6 100644
--- a/drivers/hid/hidraw.c
+++ b/drivers/hid/hidraw.c
@@ -322,6 +322,10 @@ static long hidraw_ioctl(struct file *file, unsigned i=
nt cmd,

        mutex_lock(&minors_lock);
        dev =3D hidraw_table[minor];
+       if (!dev) {
+               ret =3D -ENODEV;
+               goto out;
+       }

        switch (cmd) {
                case HIDIOCGRDESCSIZE:
@@ -412,6 +416,7 @@ static long hidraw_ioctl(struct file *file, unsigned in=
t cmd,

                ret =3D -ENOTTY;
        }
+out:
        mutex_unlock(&minors_lock);
        return ret;
 }


this change covers also the other uses of hidraw_table[minor] in
hidraw_send_report/hidraw_get_report.

Regards,
   Antonio

--=20
Antonio Ospite
http://ao2.it

PGP public key ID: 0x4553B001

A: Because it messes up the order in which people normally read text.
   See http://en.wikipedia.org/wiki/Posting_style
Q: Why is top-posting such a bad thing?

--Multipart=_Tue__28_Sep_2010_15_30_11_+0200_SaDIWec7Q_CkPCmg
Content-Type: application/octet-stream;
 name="dmesg_hidraw_feature_bug.log"
Content-Disposition: attachment;
 filename="dmesg_hidraw_feature_bug.log"
Content-Transfer-Encoding: base64

WyAgMTExLjY0NTgzNl0gdXNiIDQtMTogVVNCIGRpc2Nvbm5lY3QsIGFkZHJlc3MgMgpbICAxMTEu
NjY5NDY2XSBCVUc6IHVuYWJsZSB0byBoYW5kbGUga2VybmVsIE5VTEwgcG9pbnRlciBkZXJlZmVy
ZW5jZSBhdCAwMDAwMDAwMDAwMDAwMDI4ClsgIDExMS42Njk0ODRdIElQOiBbPGZmZmZmZmZmYTAy
YzY2YjQ+XSBoaWRyYXdfaW9jdGwrMHhmYy8weDMyYyBbaGlkXQpbICAxMTEuNjY5NTI5XSBQR0Qg
NWE5NTMwNjcgUFVEIDZkNzQxMDY3IFBNRCAwIApbICAxMTEuNjY5NTM5XSBPb3BzOiAwMDAwIFsj
MV0gU01QIApbICAxMTEuNjY5NTQ1XSBsYXN0IHN5c2ZzIGZpbGU6IC9zeXMvZGV2aWNlcy9wY2kw
MDAwOjAwLzAwMDA6MDA6MDQuMC91c2I0L2lkVmVuZG9yClsgIDExMS42Njk1NTZdIENQVSAwIApb
ICAxMTEuNjY5NTU5XSBNb2R1bGVzIGxpbmtlZCBpbjogaGlkcCBwb3dlcm5vd19rOCBtcGVyZiBj
cHVmcmVxX3Bvd2Vyc2F2ZSBjcHVmcmVxX2NvbnNlcnZhdGl2ZSBjcHVmcmVxX3N0YXRzIGNwdWZy
ZXFfdXNlcnNwYWNlIGxpcmNfc2VyaWFsKEMpIGxpcmNfZGV2IGlwdF9NQVNRVUVSQURFIGJyaWRn
ZSBzdHAgcHBkZXYgbHAgc2NvIGJuZXAgcmZjb21tIGwyY2FwIGNyYzE2IHR1biBzaXQgdHVubmVs
NCBrdm1fYW1kIGt2bSBiaW5mbXRfbWlzYyB1aW5wdXQgZnVzZSBuZnNkIGlwNnRhYmxlX3JhdyBp
cDZ0YWJsZV9tYW5nbGUgaXA2dF9SRUpFQ1QgZXhwb3J0ZnMgbmZzIGlwNnRfTE9HIGxvY2tkIGZz
Y2FjaGUgbmZfY29ubnRyYWNrX2lwdjYgbmZzX2FjbCBhdXRoX3JwY2dzcyBpcDZ0YWJsZV9maWx0
ZXIgc3VucnBjIGlwNl90YWJsZXMgeHRfdGNwdWRwIGlwdF9SRUpFQ1QgaXB0X1VMT0cgeHRfbGlt
aXQgeHRfc3RhdGUgeHRfbXVsdGlwb3J0IGlwdGFibGVfZmlsdGVyIGlwdGFibGVfbmF0IG5mX25h
dCBuZl9jb25udHJhY2tfaXB2NCBuZl9jb25udHJhY2sgbmZfZGVmcmFnX2lwdjQgaXB0YWJsZV9t
YW5nbGUgaXB0YWJsZV9yYXcgaXBfdGFibGVzIHhfdGFibGVzIGh3bW9uX3ZpZCBsb29wIHNuZF9o
ZGFfY29kZWNfbnZoZG1pIHNuZF9oZGFfY29kZWNfdmlhIHNuZF9oZGFfaW50ZWwgc25kX2hkYV9j
b2RlYyBzbmRfaHdkZXAgc25kX3BjbV9vc3Mgc25kX21peGVyX29zcyBzbmRfcGNtIHNuZF9zZXFf
bWlkaSBzbmRfcmF3bWlkaSBudmlkaWEoUCkgc25kX3NlcV9taWRpX2V2ZW50IHNuZF9zZXEgcGFy
cG9ydF9wYyBidHVzYiBzbmRfdGltZXIgc25kX3NlcV9kZXZpY2UgYXN1c19hdGswMTEwIGpveWRl
diB2aWRlbyBzbmQgYmx1ZXRvb3RoIHJma2lsbCBoaWRfc29ueSBvdXRwdXQgd21pIHBhcnBvcnQg
ZWRhY19jb3JlIGkyY19uZm9yY2UyIHRwbV90aXMgc2hwY2hwIHBjaV9ob3RwbHVnIGs4dGVtcCBl
ZGFjX21jZV9hbWQgcGNzcGtyIHRwbSB0cG1fYmlvcyBldmRldiBzb3VuZGNvcmUgc25kX3BhZ2Vf
YWxsb2MgaTJjX2NvcmUgYnV0dG9uIHByb2Nlc3NvciBleHQzIGpiZCBtYmNhY2hlIGRtX21vZCBz
ZyBzcl9tb2Qgc2RfbW9kIGNyY190MTBkaWYgY2Ryb20gYXRhX2dlbmVyaWMgdXNiaGlkIGhpZCBh
aGNpIGxpYmFoY2kgcGF0YV9hbWQgb2hjaV9oY2QgbGliYXRhIGVoY2lfaGNkIHNjc2lfbW9kIHVz
YmNvcmUgdGhlcm1hbCBmb3JjZWRldGggbmxzX2Jhc2UgdGhlcm1hbF9zeXMgZmxvcHB5IFtsYXN0
IHVubG9hZGVkOiBzY3NpX3dhaXRfc2Nhbl0KWyAgMTExLjY2OTczNl0gClsgIDExMS42Njk3NDZd
IFBpZDogMjk2OSwgY29tbTogdGVzdF9oaWRyYXdfZmVhIFRhaW50ZWQ6IFAgICAgICAgICBDICAy
LjYuMzYtcmM1LWFvMisgIzEgTTNONzgtVk0vU3lzdGVtIFByb2R1Y3QgTmFtZQpbICAxMTEuNjY5
NzUzXSBSSVA6IDAwMTA6WzxmZmZmZmZmZmEwMmM2NmI0Pl0gIFs8ZmZmZmZmZmZhMDJjNjZiND5d
IGhpZHJhd19pb2N0bCsweGZjLzB4MzJjIFtoaWRdClsgIDExMS42Njk3NzFdIFJTUDogMDAxODpm
ZmZmODgwMDU2ODMxZTc4ICBFRkxBR1M6IDAwMDEwMjA2ClsgIDExMS42Njk3NzZdIFJBWDogMDAw
MDAwMDAwMDAwMDA0OCBSQlg6IDAwMDAwMDAwYzAyZDQ4MDcgUkNYOiAwMDAwMDAwMDAyMmM3ZTUw
ClsgIDExMS42Njk3ODNdIFJEWDogMDAwMDAwMDEwMDAwMDAwMCBSU0k6IGZmZmZmZmZmODEwMzc3
ZTAgUkRJOiBmZmZmZmZmZmEwMmNlYWEwClsgIDExMS42Njk3ODldIFJCUDogMDAwMDAwMDAwMjJj
N2U1MCBSMDg6IDAwMDA3Zjk4M2YxY2JlYzggUjA5OiAwMDAwMDAwMDAwNDAwYWNhClsgIDExMS42
Njk3OTVdIFIxMDogZmZmZmZmZmY4MTAwNzY5ZiBSMTE6IGZmZmY4ODAwMzdhNzhkZDggUjEyOiBm
ZmZmODgwMDVhODVjMzAwClsgIDExMS42Njk4MDFdIFIxMzogMDAwMDAwMDAwMDAwMDAwMCBSMTQ6
IDAwMDAwMDAwMDAwMDAwMDAgUjE1OiAwMDAwMDAwMDAwMDAwMDAwClsgIDExMS42Njk4MDhdIEZT
OiAgMDAwMDdmOTgzZjNjYzcwMCgwMDAwKSBHUzpmZmZmODgwMDAxYTAwMDAwKDAwMDApIGtubEdT
OjAwMDAwMDAwMDAwMDAwMDAKWyAgMTExLjY2OTgxNV0gQ1M6ICAwMDEwIERTOiAwMDAwIEVTOiAw
MDAwIENSMDogMDAwMDAwMDA4MDA1MDAzMwpbICAxMTEuNjY5ODIxXSBDUjI6IDAwMDAwMDAwMDAw
MDAwMjggQ1IzOiAwMDAwMDAwMDVhYmE5MDAwIENSNDogMDAwMDAwMDAwMDAwMDZmMApbICAxMTEu
NjY5ODI3XSBEUjA6IDAwMDAwMDAwMDAwMDAwMDAgRFIxOiAwMDAwMDAwMDAwMDAwMDAwIERSMjog
MDAwMDAwMDAwMDAwMDAwMApbICAxMTEuNjY5ODMzXSBEUjM6IDAwMDAwMDAwMDAwMDAwMDAgRFI2
OiAwMDAwMDAwMGZmZmYwZmYwIERSNzogMDAwMDAwMDAwMDAwMDQwMApbICAxMTEuNjY5ODQwXSBQ
cm9jZXNzIHRlc3RfaGlkcmF3X2ZlYSAocGlkOiAyOTY5LCB0aHJlYWRpbmZvIGZmZmY4ODAwNTY4
MzAwMDAsIHRhc2sgZmZmZjg4MDA1YWI5MzY4MCkKWyAgMTExLjY2OTg0NF0gU3RhY2s6ClsgIDEx
MS42Njk4NDhdICAwMDAwMDAwMDAxMGFhZDE0IGZmZmY4ODAwNWFiOTM2YjggZmZmZjg4MDA1YTg1
YzMwMCBmZmZmODgwMDM3ZmM2NzAwClsgIDExMS42Njk4NTddIDwwPiAwMDAwMDAwMDAyMmM3ZTUw
IDAwMDAwMDAwMDIyYzdlNTAgMDAwMDAwMDAwMDAwMDAwMCBmZmZmZmZmZjgxMGY2NGE1ClsgIDEx
MS42Njk4NjVdIDwwPiBmZmZmODgwMDAxYTE0ODgwIGZmZmY4ODAwNWFiOTM2ODAgZmZmZmZmZmY4
MTMwMjc3NiAwMDAwMDAwMDAwMDAwMDAwClsgIDExMS42Njk4NzVdIENhbGwgVHJhY2U6ClsgIDEx
MS42Njk4OThdICBbPGZmZmZmZmZmODEwZjY0YTU+XSA/IGRvX3Zmc19pb2N0bCsweDRhMi8weDRl
ZgpbICAxMTEuNjY5OTE1XSAgWzxmZmZmZmZmZjgxMzAyNzc2Pl0gPyBzY2hlZHVsZSsweDU3My8w
eDViNwpbICAxMTEuNjY5OTIzXSAgWzxmZmZmZmZmZjgxMGY2NTNkPl0gPyBzeXNfaW9jdGwrMHg0
Yi8weDcyClsgIDExMS42Njk5MzNdICBbPGZmZmZmZmZmODEwZWEwMDI+XSA/IHN5c193cml0ZSsw
eDVmLzB4NmIKWyAgMTExLjY2OTk0N10gIFs8ZmZmZmZmZmY4MTAwOGEwMj5dID8gc3lzdGVtX2Nh
bGxfZmFzdHBhdGgrMHgxNi8weDFiClsgIDExMS42Njk5NTJdIENvZGU6IDJjIDY2IDg5IDQ0IDI0
IDA2IGU4IDFhIGMyIDAzIGUxIDQ4IDg5IGU2IGJhIDA4IDAwIDAwIDAwIDQ4IDg5IGVmIGU4IGNj
IDc5IGVjIGUwIDg1IGMwIDBmIDg0IDE4IDAyIDAwIDAwIGU5IDAxIDAyIDAwIDAwIDBmIGI2IGM3
IDw0OT4gOGIgN2QgMjggODMgZjggNDggMGYgODUgZmEgMDEgMDAgMDAgMGYgYjYgYzMgODMgZjgg
MDYgNzUgMjQgClsgIDExMS42NzAwMTFdIFJJUCAgWzxmZmZmZmZmZmEwMmM2NmI0Pl0gaGlkcmF3
X2lvY3RsKzB4ZmMvMHgzMmMgW2hpZF0KWyAgMTExLjY3MDAyNV0gIFJTUCA8ZmZmZjg4MDA1Njgz
MWU3OD4KWyAgMTExLjY3MDAyOV0gQ1IyOiAwMDAwMDAwMDAwMDAwMDI4ClsgIDExMS42NzAwMzZd
IC0tLVsgZW5kIHRyYWNlIDljNzUzMGNmYzcwMDkyMDIgXS0tLQo=

--Multipart=_Tue__28_Sep_2010_15_30_11_+0200_SaDIWec7Q_CkPCmg
Content-Type: text/x-csrc;
 name="test_hidraw_feature.c"
Content-Disposition: attachment;
 filename="test_hidraw_feature.c"
Content-Transfer-Encoding: quoted-printable

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdint.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h>
#include <sys/ioctl.h>

/*
#include <linux/hidraw.h>
*/
#include "/home/ao2/Proj/linux/linux-2.6/include/linux/hidraw.h"

void dump_hex_string(unsigned char *buf, unsigned int len)
{
	unsigned int i;

	for (i =3D 0; i < len; i++)
		printf("%02x%c", buf[i], i < len - 1 ? ' ' : 0);
}

void dump_feature_report(int fd, uint8_t report_number, unsigned int len)
{
	unsigned char *buf;
	int ret;

	buf =3D calloc(len, sizeof(*buf));

	buf[0] =3D report_number;

	ret =3D ioctl(fd, HIDIOCGFEATURE(len), buf);
	if (ret < 0) {
		fprintf(stderr, "report: 0x%02x ret: %d\n", report_number, ret);
		/* XXX: if I put exit(1) here the bug is masked */
		return;
	}

	dump_hex_string(buf, len);
	printf("\r");
	fflush(stdout);

	free(buf);
}

int main(int argc, char *argv[])
{
	int fd =3D -1;

	if (argc !=3D 2) {
		fprintf(stderr, "usage: %s </dev/hidrawX>\n", argv[0]);
		exit(1);
	}

	fd =3D open(argv[1], O_RDWR);
	if (fd < 0) {
		perror("hidraw open");
		exit(1);
	}

	while (1)
		dump_feature_report(fd, 0x01, 45);
	printf("\n");

	close(fd);
	exit(0);
}

--Multipart=_Tue__28_Sep_2010_15_30_11_+0200_SaDIWec7Q_CkPCmg--

--Signature=_Tue__28_Sep_2010_15_30_11_+0200_04WdI0dfmz8J0Vd7
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iEYEARECAAYFAkyh7eMACgkQ5xr2akVTsAHSYwCfc7sGcTmFBpVyUVyk6cYK+LPn
pwIAoIGB+RtAuLA2xUOo8DtE9bJqNlmy
=g/gZ
-----END PGP SIGNATURE-----

--Signature=_Tue__28_Sep_2010_15_30_11_+0200_04WdI0dfmz8J0Vd7--
