From: Mark Charlebois <charlebm@gmail.com>
Subject: Re: [PATCH v3] net: netfilter: LLVMLinux: vlais-netfilter
Date: Wed, 19 Mar 2014 10:25:57 -0700
Message-ID: <20140319172557.GA31869@mcharleb3-linux.qualcomm.com>
References: <063D6719AE5E284EB5DD2968C1650D6D0F6E0286@AcuExch.aculab.com>
 <1395193841-2886-1-git-send-email-behanw@converseincode.com>
 <063D6719AE5E284EB5DD2968C1650D6D0F6E0F8D@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "'behanw@converseincode.com'" <behanw@converseincode.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"pablo@netfilter.org" <pablo@netfilter.org>,
	"kaber@trash.net" <kaber@trash.net>,
	"kadlec@blackhole.kfki.hu" <kadlec@blackhole.kfki.hu>,
	"netfilter-devel@vger.kernel.org" <netfilter-devel@vger.kernel.org>,
	"netfilter@vger.kernel.org" <netfilter@vger.kernel.org>,
	"coreteam@netfilter.org" <coreteam@netfilter.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"torvalds@linux-foundation.org" <torvalds@linux-foundation.org>,
	"dwmw2@infradead.org" <dwmw2@infradead.org>,
	"pageexec@freemail.hu" <pageexec@freemail.hu>,
	=?iso-8859-1?Q?Vin=EDcius?= Tinti <viniciustinti@gmail.com>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D0F6E0F8D@AcuExch.aculab.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Mar 19, 2014 at 09:52:40AM +0000, David Laight wrote:
> From: behanw@converseincode.com=20
> > From: Mark Charlebois <charlebm@gmail.com>
> >=20
> > Replaced non-standard C use of Variable Length Arrays In Structs (V=
LAIS) in
> > xt_repldata.h with a C99 compliant flexible array member and then c=
alculated
> > offsets to the other struct members. These other members aren't ref=
erenced by
> > name in this code, however this patch maintains the same memory lay=
out and
> > padding as was previously accomplished using VLAIS.
> >=20
> > Had the original structure been ordered differently, with the entri=
es VLA at
> > the end, then it could have been a flexible member, and this patch =
would have
> > been a lot simpler. However since the data stored in this structure=
 is
> > ultimately exported to userspace, the order of this structure can't=
 be changed.
> >=20
> > This patch makes no attempt to change the existing behavior, merely=
 the way in
> > which the current layout is accomplished using standard C99 constru=
cts. As such
> > the code can now be compiled with either gcc or clang.
> >=20
> > Author: Mark Charlebois <charlebm@gmail.com>
> > Signed-off-by: Mark Charlebois <charlebm@gmail.com>
> > Signed-off-by: Behan Webster <behanw@converseincode.com>
> > Signed-off-by: Vin=EDcius Tinti <viniciustinti@gmail.com>
> > ---
> >  net/netfilter/xt_repldata.h | 27 ++++++++++++++++++++++-----
> >  1 file changed, 22 insertions(+), 5 deletions(-)
> >=20
> > diff --git a/net/netfilter/xt_repldata.h b/net/netfilter/xt_repldat=
a.h
> > index 6efe4e5..343599e 100644
> > --- a/net/netfilter/xt_repldata.h
> > +++ b/net/netfilter/xt_repldata.h
> > @@ -5,23 +5,40 @@
> >   * they serve as the hanging-off data accessed through repl.data[]=
=2E
> >   */
> >=20
> > +/* tbl has the following structure equivalent, but is C99 complian=
t:
> > + * struct {
> > + *	struct type##_replace repl;
> > + *	struct type##_standard entries[nhooks];
> > + *	struct type##_error term;
> > + * } *tbl;
> > + */
> > +
> >  #define xt_alloc_initial_table(type, typ2) ({ \
> >  	unsigned int hook_mask =3D info->valid_hooks; \
> >  	unsigned int nhooks =3D hweight32(hook_mask); \
> >  	unsigned int bytes =3D 0, hooknum =3D 0, i =3D 0; \
> >  	struct { \
> >  		struct type##_replace repl; \
> > -		struct type##_standard entries[nhooks]; \
> > -		struct type##_error term; \
> > -	} *tbl =3D kzalloc(sizeof(*tbl), GFP_KERNEL); \
> > +		struct type##_standard entries[]; \
> > +	} *tbl; \
> > +	struct type##_error *term; \
> > +	size_t entries_end =3D offsetof(typeof(*tbl), \
> > +		entries[nhooks-1]) + sizeof(tbl->entries[0]); \
>=20
> Is the compiler complaining about:
> 	offsetof(typeof(*tbl), entries[nhooks])
> If it does it is a PITA.
>=20
> > +	size_t term_offset =3D (entries_end + __alignof__(*term) - 1) \
> > +		& ~(__alignof__(*term) - 1); \
>=20
> You've not tested this - the () are in the wrong places.

I have tested it with both clang and gcc. Unit test is at http://git.li=
nuxfoundation.org/?p=3Dllvmlinux.git;a=3Dblob;f=3Dtest/unit/vlais/netfi=
lter.c;h=3D7adc255e47e15a252d2bda7af7ae217ac683c25e;hb=3DHEAD

Basic calulation of a new offset is:

new offset =3D (offset + align - 1) & ~(align - 1)

The parenthesis seem correct to me.
>=20
> > +	size_t term_end =3D term_offset + sizeof(*term); \
> > +	size_t tbl_sz =3D (term_end + __alignof__(tbl->repl) - 1) \
> > +		& ~(__alignof__(tbl->repl) - 1); \
> > +	tbl =3D kzalloc(tbl_sz, GFP_KERNEL); \
>=20
> The number of temporary variables make the above hard to read.
> I'm not at all sure you need to worry about the trailing alignment.
> It rather depends on how the final data is used.
> If the combined buffer is copied to userspace you may not
> be copying all of the required data.
> It might be easier to call copytouser() twice.

I can try to remove more variables if that is prefered.
The existing memory layout was preserved exactly so that however the
data currently used will be unaffected. I can remove the trailing
alignment but was not 100% sure it wasn't needed.

>=20
> >  	if (tbl =3D=3D NULL) \
> >  		return NULL; \
> > +	term =3D (struct type##_error *)&(((char *)tbl)[term_offset]); \
> >  	strncpy(tbl->repl.name, info->name, sizeof(tbl->repl.name)); \
> > -	tbl->term =3D (struct type##_error)typ2##_ERROR_INIT;  \
> > +	*term =3D (struct type##_error)typ2##_ERROR_INIT;  \
>=20
> 	David
>=20

Mark
--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
