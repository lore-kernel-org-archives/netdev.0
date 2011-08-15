From: Eduard Sinelnikov <eduard.sinelnikov@gmail.com>
Subject: Bonding problem
Date: Mon, 15 Aug 2011 12:44:17 +0300
Message-ID: <CANMAZFWYUqDDp+_9EOOubRcvC90zHO9NR7D_N5D=uTjokpgU6A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary=000e0cd66d60594d5e04aa881b37
To: netdev@vger.kernel.org, Andy Gospodarek <andy@greyhouse.net>,
	Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:47235 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751481Ab1HOJoT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Aug 2011 05:44:19 -0400
Received: by wyg24 with SMTP id 24so3370456wyg.19
        for <netdev@vger.kernel.org>; Mon, 15 Aug 2011 02:44:18 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--000e0cd66d60594d5e04aa881b37
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: quoted-printable

Hi all,

Following the thread:
http://marc.info/?l=3Dlinux-netdev&m=3D131282467512508&w=3D2

I have created the this patch for kernel version:3.0.1, which may fix
the bonding problem

Patch explanation:
The patch seting all slaves active prior to switching to round robin mode.
This is done to ensure that every posibly active slave will be used in
communication.

Also, I noticed that just changing the bond_xmit_round_robin will only
partially fix the problem.
Since slaves with inactive bit will not CATCH any trafic.

I wonder if I should remove the check "bond_is_active_slave(slave))"
in bond_xmit_round_robin

Please advice.
            Eduard


On Mon, Aug 08, 2011 at 10:06:05AM -0700, Jay Vosburgh wrote:
>
> Andy Gospodarek <andy@greyhouse.net> wrote:
>
> >On Sun, Aug 07, 2011 at 03:00:30PM +0300, Eduard Sinelnikov wrote:
> >> Hi,
> >>
> >> In the kernel 2.6.39.3 ( /drivers/net/bond/bond_main.c).
> >> In the function =C2 =E2=80=98bond_xmit_roundrobin=E2=80=99
> >> The code check if the bond is active via
> >> =E2=80=98bond_is_active_slave(slave)=E2=80=99 Function call.
> >> Which actually checks if the slave is backup or active
> >> What is the meaning of slave being =C2 backup in round robin mode?
> >> Correct me if I wrong but in round robin every slave should send a
> >> packet, regardless of being active or backup.
> >>
> >> Thank you,
> >> =C2 =A0=C2 =A0=C2 =A0=C2 =A0=C2 =A0=C2 Eduard
> >
> >There probably is not a compelling reason to continue to have it. =A0The=
re
> >may be a reason historically, but I'm not aware what that might be at
> >this point. =A0For modes other than active-backup, the value of
> >slave->link and slave->backup should always contain a value that
> >indicates the slave is up and available for transmit.
>
> If you read Eduard's other posts regarding this, the actual
> issue is that when changing from another mode into round-robin,
> occasionally slaves will still be marked as "backup" and won't be used:
>

I did notice that one after I sent this first response.

> >Date: Mon, 8 Aug 2011 11:16:39 +0300
> >Subject: On line Bonding configuration change fails
> >From: Eduard Sinelnikov <eduard.sinelnikov@gmail.com>
> >To: netdev@vger.kernel.org
> >Sender: netdev-owner@vger.kernel.org
> >
> >Hi,
> >
> >My configuration is a follows:
> >
> >=C2 =A0=C2 =A0=C2 =A0=C2 =A0=C2 =A0=C2 =A0=C2 | eth0 -------------->
> >Ububntu | eth1 --------------> =C2 =A0=C2 Swith ------------> Other comp=
uter
> >
> >Scenario:
> >=E2=80=A2 change the bond mode to active/backup
> >=E2=80=A2 unplug some of the cable
> >=E2=80=A2 plug-in the unplugged cable
> >=E2=80=A2 change bond mode to round robin
> >
> >I can see that only one eth1 is sending data. When I unplug it the ping =
stops.
> >
> >Is it a bug or some mis-configuration?
> >
> >In the kernel ( /drivers/net/bond/bond_main.c).
> >In the function =C2 =E2=80=98bond_xmit_roundrobin
> >=E2=80=99
> >The code check if the bond is active via
> >=E2=80=98bond_is_active_slave(slave)=E2=80=99 Function call.
> >Which actually checks if the slave is backup or active
> >What is the meaning of backup in round robin?
> >Correct me if I wrong but in round robin every slave should send a
> >packet, regardless of being active or backup.
>
> So from looking at the code, it seems that the actual problem is
> that when transitioning to round-robin mode, one or more slaves can
> remain marked as "backup," and in round-robin mode, that won't ever
> change. =A0We could probably work around that by removing the "is_active"
> test (essentially declaring that "is_active" is only valid in
> active-backup mode). =A0That might produce a few odd messages here and
> there (when removing a slave or during a link failure, for example).
>
> From inspection, the bond_xmit_xor function likely has this same
> problem.
>

Agreed.

> -J
>
> ---
> -Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com

--000e0cd66d60594d5e04aa881b37
Content-Type: application/octet-stream; name="bond_patch.patch"
Content-Disposition: attachment; filename="bond_patch.patch"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_grd8we0z0

ZGlmZiAtdXByTiBsaW51eC0zLjAuMS9kcml2ZXJzL25ldC9ib25kaW5nL2JvbmRfc3lzZnMuYyBs
aW51eC0zLjAuMS5ib25kL2RyaXZlcnMvbmV0L2JvbmRpbmcvYm9uZF9zeXNmcy5jCi0tLSBsaW51
eC0zLjAuMS9kcml2ZXJzL25ldC9ib25kaW5nL2JvbmRfc3lzZnMuYwkyMDExLTA4LTA1IDA3OjU5
OjIxLjAwMDAwMDAwMCArMDMwMAorKysgbGludXgtMy4wLjEuYm9uZC9kcml2ZXJzL25ldC9ib25k
aW5nL2JvbmRfc3lzZnMuYwkyMDExLTA4LTE1IDExOjU5OjEzLjM0NjM3NzI2MyArMDMwMApAQCAt
MjkwLDYgKzI5MCwzNyBAQCBzdGF0aWMgc3NpemVfdCBib25kaW5nX3Nob3dfbW9kZShzdHJ1Y3QK
IAkJCWJvbmQtPnBhcmFtcy5tb2RlKTsKIH0KIAorCisKKy8vIGFjdGl2YXRlIGFsbCBpbnRlcmZh
Y2VzLgorc3RhdGljIHZvaWQgaW5saW5lIGJvbmRpbmdfYWN0aXZhdGVfaW50ZXJmYWNlcyhzdHJ1
Y3QgYm9uZGluZyAqIGJvbmQgKQoreworCXN0cnVjdCBzbGF2ZSAqc2xhdmUgOworCWludCBpIDsK
KworCQorCisJcmVhZF9sb2NrKCZib25kLT5sb2NrKTsJCisJCisJYm9uZF9mb3JfZWFjaF9zbGF2
ZShib25kLCBzbGF2ZSwgaSkgeworCQorCQlyZWFkX2xvY2soJmJvbmQtPmN1cnJfc2xhdmVfbG9j
ayk7CisJCisJCS8vIGNoYW5nZSB0aGUgYmFja3VwIHRvIGFjdGl2ZSBzaW5jZSB0aGVyZSBpcyBu
byBtZWFuaW5uZyBvZiBiYWNrdXAgaW4gcm91bmQgcm9iaW4uCisJCS8vIEFsc28sIGNoYW5nZSB0
aGUgZGV2aWNlIHN0YXRlIHNvIGl0IGNhbiBjYXRjaCB0cmFmZmljLgorCQlpZiAoKCAgYm9uZF9z
bGF2ZV9zdGF0ZShzbGF2ZSkgKSB8fCBzbGF2ZS0+aW5hY3RpdmUgKSB7CisJCQlpZiAoKHNsYXZl
LT5saW5rID09IEJPTkRfTElOS19VUCkgJiYgSVNfVVAoc2xhdmUtPmRldikpIHsKKwkJCQlib25k
X3NldF9zbGF2ZV9hY3RpdmVfZmxhZ3Moc2xhdmUpOworCQkJfQorCQl9CisJCQorCQlyZWFkX3Vu
bG9jaygmYm9uZC0+Y3Vycl9zbGF2ZV9sb2NrKTsKKwl9CisJCisJcmVhZF91bmxvY2soJmJvbmQt
PmxvY2spOworCit9IAorCiBzdGF0aWMgc3NpemVfdCBib25kaW5nX3N0b3JlX21vZGUoc3RydWN0
IGRldmljZSAqZCwKIAkJCQkgIHN0cnVjdCBkZXZpY2VfYXR0cmlidXRlICphdHRyLAogCQkJCSAg
Y29uc3QgY2hhciAqYnVmLCBzaXplX3QgY291bnQpCkBAIC0zMjAsNiArMzUxLDEwIEBAIHN0YXRp
YyBzc2l6ZV90IGJvbmRpbmdfc3RvcmVfbW9kZShzdHJ1Y3QKIAkJZ290byBvdXQ7CiAJfQogCisJ
aWYgKGJvbmQtPnBhcmFtcy5tb2RlID09IEJPTkRfTU9ERV9ST1VORFJPQklOKSB7CisJCWJvbmRp
bmdfYWN0aXZhdGVfaW50ZXJmYWNlcyhib25kKSA7CisJfQorCiAJYm9uZC0+cGFyYW1zLm1vZGUg
PSBuZXdfdmFsdWU7CiAJYm9uZF9zZXRfbW9kZV9vcHMoYm9uZCwgYm9uZC0+cGFyYW1zLm1vZGUp
OwogCXByX2luZm8oIiVzOiBzZXR0aW5nIG1vZGUgdG8gJXMgKCVkKS5cbiIsCg==
--000e0cd66d60594d5e04aa881b37--
