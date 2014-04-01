From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the audit tree with the net-next tree
Date: Tue, 1 Apr 2014 15:12:11 +1100
Message-ID: <20140401151211.522eed6e3c26c2c10da77d7f@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA256";
 boundary="Signature=_Tue__1_Apr_2014_15_12_11_+1100_rp0a2i9a6pYHK6G+"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Alexei Starovoitov <ast@plumgrid.com>
To: Eric Paris <eparis@redhat.com>, David Miller <davem@davemloft.net>,
	<netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Tue__1_Apr_2014_15_12_11_+1100_rp0a2i9a6pYHK6G+
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi all,

Today's linux-next merge of the audit tree got a conflict in
kernel/seccomp.c between commit bd4cf0ed331a ("net: filter:
rework/optimize internal BPF interpreter's instruction set") from the
net-next tree and commit 5e937a9ae913 ("syscall_get_arch: remove useless
function arguments") from the audit tree.

I fixed it up (see below) and can carry the fix as necessary (no action
is required).

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

diff --cc kernel/seccomp.c
index fd609bd9d6dd,eda2da3df822..000000000000
--- a/kernel/seccomp.c
+++ b/kernel/seccomp.c
@@@ -65,23 -74,41 +65,23 @@@ struct seccomp_filter=20
   * Endianness is explicitly ignored and left for BPF program authors to m=
anage
   * as per the specific architecture.
   */
 -static inline u32 get_u32(u64 data, int index)
 +static void populate_seccomp_data(struct seccomp_data *sd)
  {
 -	return ((u32 *)&data)[index];
 -}
 +	struct task_struct *task =3D current;
 +	struct pt_regs *regs =3D task_pt_regs(task);
 =20
 -/* Helper for bpf_load below. */
 -#define BPF_DATA(_name) offsetof(struct seccomp_data, _name)
 -/**
 - * bpf_load: checks and returns a pointer to the requested offset
 - * @off: offset into struct seccomp_data to load from
 - *
 - * Returns the requested 32-bits of data.
 - * seccomp_check_filter() should assure that @off is 32-bit aligned
 - * and not out of bounds.  Failure to do so is a BUG.
 - */
 -u32 seccomp_bpf_load(int off)
 -{
 -	struct pt_regs *regs =3D task_pt_regs(current);
 -	if (off =3D=3D BPF_DATA(nr))
 -		return syscall_get_nr(current, regs);
 -	if (off =3D=3D BPF_DATA(arch))
 -		return syscall_get_arch();
 -	if (off >=3D BPF_DATA(args[0]) && off < BPF_DATA(args[6])) {
 -		unsigned long value;
 -		int arg =3D (off - BPF_DATA(args[0])) / sizeof(u64);
 -		int index =3D !!(off % sizeof(u64));
 -		syscall_get_arguments(current, regs, arg, 1, &value);
 -		return get_u32(value, index);
 -	}
 -	if (off =3D=3D BPF_DATA(instruction_pointer))
 -		return get_u32(KSTK_EIP(current), 0);
 -	if (off =3D=3D BPF_DATA(instruction_pointer) + sizeof(u32))
 -		return get_u32(KSTK_EIP(current), 1);
 -	/* seccomp_check_filter should make this impossible. */
 -	BUG();
 +	sd->nr =3D syscall_get_nr(task, regs);
- 	sd->arch =3D syscall_get_arch(task, regs);
++	sd->arch =3D syscall_get_arch();
 +
 +	/* Unroll syscall_get_args to help gcc on arm. */
 +	syscall_get_arguments(task, regs, 0, 1, (unsigned long *) &sd->args[0]);
 +	syscall_get_arguments(task, regs, 1, 1, (unsigned long *) &sd->args[1]);
 +	syscall_get_arguments(task, regs, 2, 1, (unsigned long *) &sd->args[2]);
 +	syscall_get_arguments(task, regs, 3, 1, (unsigned long *) &sd->args[3]);
 +	syscall_get_arguments(task, regs, 4, 1, (unsigned long *) &sd->args[4]);
 +	syscall_get_arguments(task, regs, 5, 1, (unsigned long *) &sd->args[5]);
 +
 +	sd->instruction_pointer =3D KSTK_EIP(task);
  }
 =20
  /**

--Signature=_Tue__1_Apr_2014_15_12_11_+1100_rp0a2i9a6pYHK6G+
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIcBAEBCAAGBQJTOjywAAoJEMDTa8Ir7ZwV4G8QAIT/z3U8eniQNOrCE7a/LFrS
VjyYotNIzcZIpbB4pS3JR4m1do+iUGki3KVdnKrC0XAR8NxYKDoYopU1oVVwOHO9
4IWxDpWHsf0HEJBOAM1FJQ85e5e0gKY6wqh5T85lxiclmHsNabm8zeAS58AzKX3k
1Vc3+qawGrsC5myxUBBWuJ/t35vyqMkJjhOR09qtr07vhkP70iplOuP/fE0+KWS9
SEcVq1/g4GdNuk4yuNp6ND5b5mse45ligs/SbOZ4XLFCxDRfB9Vw56OaKIxDHa6Q
wXqYzY3F5uSwejEhDhxmze+N3TARTdhphI5O1w+zFFR5WpqMHPZVet9wZez1QEKn
TZ6GRdT+AWbXbh6eAroisUjiukJ6NhVncgdHloSE/uhNeBYmqGEBNJ1ikL6rBEIZ
lMztP+ekhu8wOtoYbbGJ+TVO2Bhg4Z80PGP0ZH4xWyVXtiQTmSiQ/AWY7ScBhPet
sshmQnniD1PEB3UIEAOYhapibu2t8tGwSzhtfGCAOhJGcWrXPA2CjzFkqGNxMyQ6
FBtU9gGIeqVO09m20DUu0tQGmhl3mdMmaun1mTvGmQsOSMTd8Qpnn1ZT/XEpWD7r
hICGk46Ac5rQEY2iTTVCs3n/4lOzlT5CDh6o/xNMrE7twf7T/xYtnK1OtGDSRwjZ
AlnCyVXxAzWgn2ApAVXc
=Db6I
-----END PGP SIGNATURE-----

--Signature=_Tue__1_Apr_2014_15_12_11_+1100_rp0a2i9a6pYHK6G+--
