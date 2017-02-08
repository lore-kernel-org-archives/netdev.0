From: =?UTF-8?Q?Micka=c3=abl_Sala=c3=bcn?= <mic@digikod.net>
Subject: Re: [PATCH v3 2/5] bpf: Simplify bpf_load_program() error handling in
 the library
Date: Wed, 8 Feb 2017 21:03:48 +0100
Message-ID: <957ec638-1b72-1327-41e2-e924231cc7ff@digikod.net>
References: <20170207205609.8035-1-mic@digikod.net>
 <20170207205609.8035-3-mic@digikod.net>
 <59c4e38e-baa3-e130-3d74-14aa6b11bda5@huawei.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="waXsuuIj70tSccReNUP3kw75AIj4gnc1L"
Cc: Alexei Starovoitov <ast@fb.com>,
        Arnaldo Carvalho de Melo <acme@redhat.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        "David S . Miller" <davem@davemloft.net>,
        Joe Stringer <joe@ovn.org>, netdev@vger.kernel.org
To: "Wangnan (F)" <wangnan0@huawei.com>, linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-sh.infomaniak.ch ([128.65.195.4]:44897 "EHLO
        smtp-sh.infomaniak.ch" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750940AbdBHUNj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 8 Feb 2017 15:13:39 -0500
In-Reply-To: <59c4e38e-baa3-e130-3d74-14aa6b11bda5@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--waXsuuIj70tSccReNUP3kw75AIj4gnc1L
Content-Type: multipart/mixed; boundary="fBW7iMFu4qQnAJigblv90Q9q5ANu00oad";
 protected-headers="v1"
From: =?UTF-8?Q?Micka=c3=abl_Sala=c3=bcn?= <mic@digikod.net>
To: "Wangnan (F)" <wangnan0@huawei.com>, linux-kernel@vger.kernel.org
Cc: Alexei Starovoitov <ast@fb.com>,
 Arnaldo Carvalho de Melo <acme@redhat.com>,
 Daniel Borkmann <daniel@iogearbox.net>,
 "David S . Miller" <davem@davemloft.net>, Joe Stringer <joe@ovn.org>,
 netdev@vger.kernel.org
Message-ID: <957ec638-1b72-1327-41e2-e924231cc7ff@digikod.net>
Subject: Re: [PATCH v3 2/5] bpf: Simplify bpf_load_program() error handling in
 the library
References: <20170207205609.8035-1-mic@digikod.net>
 <20170207205609.8035-3-mic@digikod.net>
 <59c4e38e-baa3-e130-3d74-14aa6b11bda5@huawei.com>
In-Reply-To: <59c4e38e-baa3-e130-3d74-14aa6b11bda5@huawei.com>

--fBW7iMFu4qQnAJigblv90Q9q5ANu00oad
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable


On 08/02/2017 03:35, Wangnan (F) wrote:
>=20
>=20
> On 2017/2/8 4:56, Micka=C3=ABl Sala=C3=BCn wrote:
>> Do not call a second time bpf(2) when a program load failed.
>=20
> BPF_PROG_LOAD should success most of the time. Setting log_level to
> 0 by default and require log buffer when failure can make it faster
> in normal case.

OK, I'm not sure if this is relevant for a test but I'm going to remove
this patch.

Thanks

>=20
> Thank you.
>=20
>> Signed-off-by: Micka=C3=ABl Sala=C3=BCn <mic@digikod.net>
>> Cc: Alexei Starovoitov <ast@fb.com>
>> Cc: Arnaldo Carvalho de Melo <acme@redhat.com>
>> Cc: Daniel Borkmann <daniel@iogearbox.net>
>> Cc: Wang Nan <wangnan0@huawei.com>
>> ---
>>   tools/lib/bpf/bpf.c | 18 ++++++------------
>>   1 file changed, 6 insertions(+), 12 deletions(-)
>>
>> diff --git a/tools/lib/bpf/bpf.c b/tools/lib/bpf/bpf.c
>> index 3ddb58a36d3c..fda3f494f1cd 100644
>> --- a/tools/lib/bpf/bpf.c
>> +++ b/tools/lib/bpf/bpf.c
>> @@ -73,7 +73,6 @@ int bpf_load_program(enum bpf_prog_type type, struct=

>> bpf_insn *insns,
>>                size_t insns_cnt, char *license,
>>                __u32 kern_version, char *log_buf, size_t log_buf_sz)
>>   {
>> -    int fd;
>>       union bpf_attr attr;
>>         bzero(&attr, sizeof(attr));
>> @@ -81,20 +80,15 @@ int bpf_load_program(enum bpf_prog_type type,
>> struct bpf_insn *insns,
>>       attr.insn_cnt =3D (__u32)insns_cnt;
>>       attr.insns =3D ptr_to_u64(insns);
>>       attr.license =3D ptr_to_u64(license);
>> -    attr.log_buf =3D ptr_to_u64(NULL);
>> -    attr.log_size =3D 0;
>> -    attr.log_level =3D 0;
>> +    attr.log_buf =3D ptr_to_u64(log_buf);
>> +    attr.log_size =3D log_buf_sz;
>>       attr.kern_version =3D kern_version;
>>   -    fd =3D sys_bpf(BPF_PROG_LOAD, &attr, sizeof(attr));
>> -    if (fd >=3D 0 || !log_buf || !log_buf_sz)
>> -        return fd;
>> +    if (log_buf && log_buf_sz > 0) {
>> +        attr.log_level =3D 1;
>> +        log_buf[0] =3D 0;
>> +    }
>>   -    /* Try again with log */
>> -    attr.log_buf =3D ptr_to_u64(log_buf);
>> -    attr.log_size =3D log_buf_sz;
>> -    attr.log_level =3D 1;
>> -    log_buf[0] =3D 0;
>>       return sys_bpf(BPF_PROG_LOAD, &attr, sizeof(attr));
>>   }
>>  =20
>=20
>=20
>=20


--fBW7iMFu4qQnAJigblv90Q9q5ANu00oad--

--waXsuuIj70tSccReNUP3kw75AIj4gnc1L
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEzBAEBCgAdFiEEUysCyY8er9Axt7hqIt7+33O9apUFAlibeaQACgkQIt7+33O9
apXR0Af+JckYhWB/Gs52BjyauUQNlRWzB46hkpgva5Y6N5+NmNF/0vNLrx6H4e0D
Z5tcciCwO6HccT9Fhdb8AAvG6zDCQJW55NzPhETNSCiXYsYJn3ERUFHS3OBIeAHB
JpFUdRIk7JVrC2TqSybyuCQNsE4danvUG1Vj79g91NAJxSG5lrxdnyOgAHmmKtE5
cihhadY8XskiLun7WBCxhBL5LtLtXAHq+oiQuDgK/YTZ5P4nSc0wSHZUK4g/aEOi
D6aux4jMxVaRHDRQBWHnMa5WTuQW0AKfSYBjpMEELg2QJgSfcHVx17Ct619x3WiC
2IhHKl10q0kpW9gpYCwlWuSughAQJA==
=Id1v
-----END PGP SIGNATURE-----

--waXsuuIj70tSccReNUP3kw75AIj4gnc1L--
