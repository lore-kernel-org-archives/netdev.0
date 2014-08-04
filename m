From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the security tree with the net-next
 tree
Date: Mon, 4 Aug 2014 16:26:33 +1000
Message-ID: <20140804162633.2d2e8604@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 boundary="Sig_/vtrPX82f5i4WSq0LU4aSVVo"; protocol="application/pgp-signature"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Alexei Starovoitov <ast@plumgrid.com>,
	Kees Cook <keescook@chromium.org>
To: James Morris <jmorris@namei.org>,
	David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Sig_/vtrPX82f5i4WSq0LU4aSVVo
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

Hi James,

Today's linux-next merge of the security tree got a conflict in
kernel/seccomp.c between commit 7ae457c1e5b4 ("net: filter: split
'struct sk_filter' into socket and bpf parts") from the net-next tree
and commits c8bee430dc52 ("seccomp: split filter prep from check and
apply") and 3ba2530cc06e ("seccomp: allow mode setting across threads")
from the security tree.

I fixed it up (I hope - see below) and can carry the fix as necessary
(no action is required).

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

diff --cc kernel/seccomp.c
index 2f3fa2cc2eac,74f460179171..000000000000
--- a/kernel/seccomp.c
+++ b/kernel/seccomp.c
@@@ -186,8 -191,8 +191,8 @@@ static u32 seccomp_run_filters(int sysc
  	 * All filters in the list are evaluated and the lowest BPF return
  	 * value always takes priority (ignoring the DATA).
  	 */
- 	for (f =3D current->seccomp.filter; f; f =3D f->prev) {
+ 	for (; f; f =3D f->prev) {
 -		u32 cur_ret =3D SK_RUN_FILTER(f->prog, (void *)&sd);
 +		u32 cur_ret =3D BPF_PROG_RUN(f->prog, (void *)&sd);
 =20
  		if ((cur_ret & SECCOMP_RET_ACTION) < (ret & SECCOMP_RET_ACTION))
  			ret =3D cur_ret;
@@@ -273,15 -408,9 +408,9 @@@ static struct seccomp_filter *seccomp_p
  	atomic_set(&filter->usage, 1);
  	filter->prog->len =3D new_len;
 =20
 -	sk_filter_select_runtime(filter->prog);
 +	bpf_prog_select_runtime(filter->prog);
 =20
- 	/*
- 	 * If there is an existing filter, make it the prev and don't drop its
- 	 * task reference.
- 	 */
- 	filter->prev =3D current->seccomp.filter;
- 	current->seccomp.filter =3D filter;
- 	return 0;
+ 	return filter;
 =20
  free_filter_prog:
  	kfree(filter->prog);
@@@ -329,6 -506,14 +506,14 @@@ void get_seccomp_filter(struct task_str
  	atomic_inc(&orig->usage);
  }
 =20
+ static inline void seccomp_filter_free(struct seccomp_filter *filter)
+ {
+ 	if (filter) {
 -		sk_filter_free(filter->prog);
++		bpf_prog_free(filter->prog);
+ 		kfree(filter);
+ 	}
+ }
+=20
  /* put_seccomp_filter - decrements the ref count of tsk->seccomp.filter */
  void put_seccomp_filter(struct task_struct *tsk)
  {

--Sig_/vtrPX82f5i4WSq0LU4aSVVo
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJT3yeZAAoJEMDTa8Ir7ZwVyewP/2EthRDIbSfzL7/tGh+xAPyb
VIw1AIYS14wR5elLKRlaOCoDQvUqiFD5fX3VmMvja+sJpaJbHrRVNLhMdLTbk6pu
dpr8HrvdOazRRuJzTsuPk+z92D0YNYrWLPEiQFBnxxpsAxlfH5MKXtLHiwInKpv7
BZgOkzY2TkQxcp8YTz5UCKNNRuFa8vX8wd1mnDO2LIPnOY+Y0r52Cp45JpvqgCP2
0TM+CuxOs+5Dbx7cLN/gqx0iCl+XyiqudC7TkjwTrY4FIL4c9AlMHg4iaHStoXSf
VZi/WmKZVaCBbHuDlQnf9ns2V6oWR55wsKW/jisO7x4He3BqssC3CNSxymNJ9Xgs
+vgne0pq+WAWua+FV8ESUsqUcHGVDW2kBbGMCn4oQHRGeYYOI+dDVtwhZ1/kQxZq
TVFrtNRQLUg9OWlemV1hIIBDAaYLOz9D4h55sgCPp5pP2uOZwTXTpV/NDX+333/Z
z7r6Ba6RRdsYEolBX/IxXaEHR1iZyYxCEZ8mTC319g4/F3ewhhROnbl8TuPaAIYs
Axz+F7GxhxShB3CPwI4b2WfwcacTQfUgHY23UzJJLtuAH8BE28KQiD3ZTniUi2Ik
D7RJuXqsCUMMNhABv9ixcyPfHNoau4ZriDT/1wld6uX9girpTNcuud1Kj+raLljd
cRT0CC4Ynueqy7z3WCJ0
=CkHw
-----END PGP SIGNATURE-----

--Sig_/vtrPX82f5i4WSq0LU4aSVVo--
