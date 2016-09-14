From: =?UTF-8?Q?Micka=c3=abl_Sala=c3=bcn?= <mic@digikod.net>
Subject: Re: [RFC v3 07/22] landlock: Handle file comparisons
Date: Thu, 15 Sep 2016 00:39:33 +0200
Message-ID: <57D9D1A5.90801@digikod.net>
References: <20160914072415.26021-1-mic@digikod.net>
 <20160914072415.26021-8-mic@digikod.net> <20160914190723.GB5617@pc.thejh.net>
Reply-To: kernel-hardening@lists.openwall.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="olpoOXigjcelS6hELK6MgiUNxevNcb6J2"
Cc: linux-kernel@vger.kernel.org, Alexei Starovoitov <ast@kernel.org>,
        Andy Lutomirski <luto@amacapital.net>, Arnd Bergmann <arnd@arndb.de>,
        Casey Schaufler <casey@schaufler-ca.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Daniel Mack <daniel@zonque.org>, David Drysdale <drysdale@google.com>,
        "David S . Miller"
 <davem@davemloft.net>,
        Elena Reshetova <elena.reshetova@intel.com>,
        "Eric W . Biederman" <ebiederm@xmission.com>,
        James Morris <james.l.morris@oracle.com>,
        Kees Cook <keescook@chromium.org>, Paul Moore <pmoore@redhat.com>,
        Sargun Dhillon <sargun@sargun.me>,
        "Serge E . Hallyn" <serge@hallyn.com>, Tejun Heo <tj@kernel.org>,
        Will Drewry <wad@chromium.org>, kernel-hardening@lists.openwall.com,
        linux-api@vger.kernel.org, linux-security-module@vger.kernel.org,
        netdev@vger.ker
To: Jann Horn <jann@thejh.net>
Return-path: <kernel-hardening-return-4639-glkh-kernel-hardening=m.gmane.org@lists.openwall.com>
List-Post: <mailto:kernel-hardening@lists.openwall.com>
List-Help: <mailto:kernel-hardening-help@lists.openwall.com>
List-Unsubscribe: <mailto:kernel-hardening-unsubscribe@lists.openwall.com>
List-Subscribe: <mailto:kernel-hardening-subscribe@lists.openwall.com>
In-Reply-To: <20160914190723.GB5617@pc.thejh.net>
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--olpoOXigjcelS6hELK6MgiUNxevNcb6J2
Content-Type: multipart/mixed; boundary="Wh50T70gIfMwQxJgGkp8TWhWAiKeEwOqC";
 protected-headers="v1"
From: =?UTF-8?Q?Micka=c3=abl_Sala=c3=bcn?= <mic@digikod.net>
To: Jann Horn <jann@thejh.net>
Cc: linux-kernel@vger.kernel.org, Alexei Starovoitov <ast@kernel.org>,
 Andy Lutomirski <luto@amacapital.net>, Arnd Bergmann <arnd@arndb.de>,
 Casey Schaufler <casey@schaufler-ca.com>,
 Daniel Borkmann <daniel@iogearbox.net>, Daniel Mack <daniel@zonque.org>,
 David Drysdale <drysdale@google.com>, "David S . Miller"
 <davem@davemloft.net>, Elena Reshetova <elena.reshetova@intel.com>,
 "Eric W . Biederman" <ebiederm@xmission.com>,
 James Morris <james.l.morris@oracle.com>, Kees Cook <keescook@chromium.org>,
 Paul Moore <pmoore@redhat.com>, Sargun Dhillon <sargun@sargun.me>,
 "Serge E . Hallyn" <serge@hallyn.com>, Tejun Heo <tj@kernel.org>,
 Will Drewry <wad@chromium.org>, kernel-hardening@lists.openwall.com,
 linux-api@vger.kernel.org, linux-security-module@vger.kernel.org,
 netdev@vger.kernel.org, cgroups@vger.kernel.org
Message-ID: <57D9D1A5.90801@digikod.net>
Subject: Re: [RFC v3 07/22] landlock: Handle file comparisons
References: <20160914072415.26021-1-mic@digikod.net>
 <20160914072415.26021-8-mic@digikod.net> <20160914190723.GB5617@pc.thejh.net>
In-Reply-To: <20160914190723.GB5617@pc.thejh.net>

--Wh50T70gIfMwQxJgGkp8TWhWAiKeEwOqC
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: quoted-printable


On 14/09/2016 21:07, Jann Horn wrote:
> On Wed, Sep 14, 2016 at 09:24:00AM +0200, Micka=EBl Sala=FCn wrote:
>> Add eBPF functions to compare file system access with a Landlock file
>> system handle:
>> * bpf_landlock_cmp_fs_prop_with_struct_file(prop, map, map_op, file)
>>   This function allows to compare the dentry, inode, device or mount
>>   point of the currently accessed file, with a reference handle.
>> * bpf_landlock_cmp_fs_beneath_with_struct_file(opt, map, map_op, file)=

>>   This function allows an eBPF program to check if the current accesse=
d
>>   file is the same or in the hierarchy of a reference handle.
> [...]
>> diff --git a/kernel/bpf/arraymap.c b/kernel/bpf/arraymap.c
>> index 94256597eacd..edaab4c87292 100644
>> --- a/kernel/bpf/arraymap.c
>> +++ b/kernel/bpf/arraymap.c
>> @@ -603,6 +605,9 @@ static void landlock_put_handle(struct map_landloc=
k_handle *handle)
>>  	enum bpf_map_handle_type handle_type =3D handle->type;
>> =20
>>  	switch (handle_type) {
>> +	case BPF_MAP_HANDLE_TYPE_LANDLOCK_FS_FD:
>> +		path_put(&handle->path);
>> +		break;
>>  	case BPF_MAP_HANDLE_TYPE_UNSPEC:
>>  	default:
>>  		WARN_ON(1);
> [...]
>> diff --git a/security/landlock/checker_fs.c b/security/landlock/checke=
r_fs.c
>> new file mode 100644
>> index 000000000000..39eb85dc7d18
>> --- /dev/null
>> +++ b/security/landlock/checker_fs.c
> [...]
>> +static inline u64 bpf_landlock_cmp_fs_prop_with_struct_file(u64 r1_pr=
operty,
>> +		u64 r2_map, u64 r3_map_op, u64 r4_file, u64 r5)
>> +{
>> +	u8 property =3D (u8) r1_property;
>> +	struct bpf_map *map =3D (struct bpf_map *) (unsigned long) r2_map;
>> +	enum bpf_map_array_op map_op =3D r3_map_op;
>> +	struct file *file =3D (struct file *) (unsigned long) r4_file;
>> +	struct bpf_array *array =3D container_of(map, struct bpf_array, map)=
;
>> +	struct path *p1, *p2;
>> +	struct map_landlock_handle *handle;
>> +	int i;
>=20
> Please don't use int when iterating over an array, use size_t.

OK, I will use size_t.

>=20
>=20
>> +	/* for now, only handle OP_OR */
>=20
> Is "OP_OR" an appropriate name for something that ANDs the success of
> checks?
>=20
>=20
> [...]
>> +	synchronize_rcu();
>=20
> Can you put a comment here that explains what's going on?

Hum, this should not be here.

>=20
>=20
>> +	for (i =3D 0; i < array->n_entries; i++) {
>> +		bool result_dentry =3D !(property & LANDLOCK_FLAG_FS_DENTRY);
>> +		bool result_inode =3D !(property & LANDLOCK_FLAG_FS_INODE);
>> +		bool result_device =3D !(property & LANDLOCK_FLAG_FS_DEVICE);
>> +		bool result_mount =3D !(property & LANDLOCK_FLAG_FS_MOUNT);
>> +
>> +		handle =3D (struct map_landlock_handle *)
>> +				(array->value + array->elem_size * i);
>> +
>> +		if (handle->type !=3D BPF_MAP_HANDLE_TYPE_LANDLOCK_FS_FD) {
>> +			WARN_ON(1);
>> +			return -EFAULT;
>> +		}
>> +		p1 =3D &handle->path;
>> +
>> +		if (!result_dentry && p1->dentry =3D=3D p2->dentry)
>> +			result_dentry =3D true;
>=20
> Why is this safe? As far as I can tell, this is not in an RCU read-side=

> critical section (synchronize_rcu() was just called), and no lock has b=
een
> taken. What prevents someone from removing the arraymap entry while we'=
re
> looking at it? Am I missing something?

I will try to properly deal with RCU.


--Wh50T70gIfMwQxJgGkp8TWhWAiKeEwOqC--

--olpoOXigjcelS6hELK6MgiUNxevNcb6J2
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEcBAEBCgAGBQJX2dGlAAoJECLe/t9zvWqVRmEH/2RiEHl/8mlhSUxmHnzy72kP
6RCNsP/jQZp95UQEKsYWmRA0j0jXLIY9T+PngqlSKZ0QMBJbkSmQfUlUuhm0gtWv
AevJ3eZpxRt6SIDPg1w0amcb1BSMw14FRa8PxzGqSCtM2+ssBIqT8QovJvddfq5w
qATm6jsOtbmazkt8cTaI7uclpPlI0k4XqjjazzIOxtRsTRWcTkwS+ksDJOdKrml+
iVO+i1WMENQAbg2U8dT31K7P1G1AO7jd9Gr1z37hegdQC9IuF6Yy3kpNOoAR0Dnj
IMBOCFgZUvIl5duqg3h3yj7FT9dcouTcMAdQ2DrJKIl0eDqkxtT8vE56q/bKGDs=
=0Thb
-----END PGP SIGNATURE-----

--olpoOXigjcelS6hELK6MgiUNxevNcb6J2--
