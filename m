From: Gregory Haskins <ghaskins@novell.com>
Subject: Re: [RFC PATCH v2 03/19] vbus: add connection-client helper infrastructure
Date: Thu, 04 Jun 2009 14:18:10 -0400
Message-ID: <4A280FE2.2090101@novell.com>
References: <20090409155200.32740.19358.stgit@dev.haskins.net> <20090409163057.32740.27829.stgit@dev.haskins.net> <20090604180611.GA16387@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enigA341847BB9D50AC04914441E"
Cc: linux-kernel@vger.kernel.org, agraf@suse.de, pmullaney@novell.com,
	pmorreale@novell.com, anthony@codemonkey.ws, rusty@rustcorp.com.au,
	netdev@vger.kernel.org, kvm@vger.kernel.org, avi@redhat.com,
	bhutchings@solarflare.com, andi@firstfloor.org, gregkh@suse.de,
	herber@gondor.apana.org.au, chrisw@sous-sol.org,
	shemminger@vyatta.com
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <20090604180611.GA16387@redhat.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enigA341847BB9D50AC04914441E
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

Michael S. Tsirkin wrote:
> On Thu, Apr 09, 2009 at 12:30:57PM -0400, Gregory Haskins wrote:
>  =20
>> +static unsigned long
>> +task_memctx_copy_to(struct vbus_memctx *ctx, void *dst, const void *s=
rc,
>> +		    unsigned long n)
>> +{
>> +	struct task_memctx *tm =3D to_task_memctx(ctx);
>> +	struct task_struct *p =3D tm->task;
>> +
>> +	while (n) {
>> +		unsigned long offset =3D ((unsigned long)dst)%PAGE_SIZE;
>> +		unsigned long len =3D PAGE_SIZE - offset;
>> +		int ret;
>> +		struct page *pg;
>> +		void *maddr;
>> +
>> +		if (len > n)
>> +			len =3D n;
>> +
>> +		down_read(&p->mm->mmap_sem);
>> +		ret =3D get_user_pages(p, p->mm,
>> +				     (unsigned long)dst, 1, 1, 0, &pg, NULL);
>> +
>> +		if (ret !=3D 1) {
>> +			up_read(&p->mm->mmap_sem);
>> +			break;
>> +		}
>> +
>> +		maddr =3D kmap_atomic(pg, KM_USER0);
>> +		memcpy(maddr + offset, src, len);
>> +		kunmap_atomic(maddr, KM_USER0);
>> +		set_page_dirty_lock(pg);
>> +		put_page(pg);
>> +		up_read(&p->mm->mmap_sem);
>> +
>> +		src +=3D len;
>> +		dst +=3D len;
>> +		n -=3D len;
>> +	}
>> +
>> +	return n;
>> +}
>>    =20
>
> BTW, why did you decide to use get_user_pages?
> Would switch_mm + copy_to_user work as well
> avoiding page walk if all pages are present?
>  =20

Well, basic c_t_u() won't work because its likely not "current" if you
are updating the ring from some other task, but I think you have already
figured that out based on the switch_mm suggestion.  The simple truth is
I was not familiar with switch_mm at the time I wrote this (nor am I
now).  If this is a superior method that allows you to acquire
c_t_u(some_other_ctx) like behavior, I see no problem in changing.  I
will look into this, and thanks for the suggestion!

> Also - if we just had vmexit because a process executed
> io (or hypercall), can't we just do copy_to_user there?
> Avi, I think at some point you said that we can?
>  =20

Right, and yes that will work I believe.  We could always do a "if (p =3D=
=3D
current)" check to test for this.  To date, I don't typically do
anything mem-ops related directly in vcpu context so this wasn't an
issue...but that doesn't mean someone wont try in the future. =20
Therefore, I agree we should strive to optimize it if we can.
>
>  =20

Thanks Michael,
-Greg


--------------enigA341847BB9D50AC04914441E
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG/MacGPG2 v2.0.11 (Darwin)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org

iEYEARECAAYFAkooD+cACgkQlOSOBdgZUxlkNACfQEOjtMv7FON0XSvCmRZPVi8q
lpYAn15HANx1OAqDecKTdkK+y+hBPX87
=jdq7
-----END PGP SIGNATURE-----

--------------enigA341847BB9D50AC04914441E--
