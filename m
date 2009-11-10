From: Gregory Haskins <ghaskins@novell.com>
Subject: Re: [RFC PATCH] net: add dataref destructor to sk_buff
Date: Tue, 10 Nov 2009 09:11:10 -0500
Message-ID: <4AF9747E.8020408@novell.com>
References: <20091002141407.30224.54207.stgit@dev.haskins.net> <20091110115335.GC6989@redhat.com> <4AF919020200005A000586A9@sinclair.provo.novell.com> <20091110131722.GA19645@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enig1800449CB42F9F363F7605BC"
Cc: alacrityvm-devel@lists.sourceforge.net, herbert.xu@redhat.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756269AbZKJOLM@vger.kernel.org>
In-Reply-To: <20091110131722.GA19645@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig1800449CB42F9F363F7605BC
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

Michael S. Tsirkin wrote:
> On Tue, Nov 10, 2009 at 05:40:50AM -0700, Gregory Haskins wrote:
>>>>> On 11/10/2009 at  6:53 AM, in message <20091110115335.GC6989@redhat=
=2Ecom>,
>> "Michael S. Tsirkin" <mst@redhat.com> wrote:=20
>>> On Fri, Oct 02, 2009 at 10:20:00AM -0400, Gregory Haskins wrote:
>>>> (Applies to davem/net-2.6.git:4fdb78d30)
>>>>
>>>> Hi David, netdevs,
>>>>
>>>> The following is an RFC for an attempt at addressing a zero-copy sol=
ution.
>>>>
>>>> To be perfectly honest, I have no idea if this is the best solution,=
 or if
>>>> there is truly a problem with skb->destructor that requires an alter=
nate
>>>> mechanism.  What I do know is that this patch seems to work, and I w=
ould
>>>> like to see some kind of solution available upstream.  So I thought =
I would
>>>> send my hack out as at least a point of discussion.  FWIW: This has =
been
>>>> tested heavily in my rig and is technically suitable for inclusion a=
fter
>>>> review as is, if that is decided to be the optimal path forward here=
=2E
>>>>
>>>> Thanks for your review and consideration,
>>>>
>>>> Kind regards,
>>>> -Greg
>>>>
>>>> ----------------------------------------
>>>> From: Gregory Haskins <ghaskins@novell.com>
>>>> Subject: [RFC PATCH] net: add dataref destructor to sk_buff
>>>>
>>>> What: The skb->destructor field is reportedly unreliable for ensurin=
g
>>>> that all shinfo users have dropped their references.  Therefore, we =
add
>>>> a distinct ->release() method for the shinfo structure which is clos=
ely
>>>> tied to the underlying page resources we want to protect.
>>>>
>>>> Why: We want to add zero-copy transmit support for AlacrityVM guests=
=2E
>>>> In order to support this, the host kernel must map guest pages direc=
tly
>>>> into a paged-skb and send it as normal.  put_page() alone is not
>>>> sufficient lifetime management since the pages are ultimately alloca=
ted
>>>> from within the guest.  Therefore, we need higher-level notification=

>>>> when the skb is finally freed on the host so we can then inject a pr=
oper
>>>> "tx-complete" event into the guest context.
>>>>
>>>> Signed-off-by: Gregory Haskins <ghaskins@novell.com>
>>>> ---
>>>>
>>>>  include/linux/skbuff.h |    2 ++
>>>>  net/core/skbuff.c      |    9 +++++++++
>>>>  2 files changed, 11 insertions(+), 0 deletions(-)
>>>>
>>>> diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
>>>> index df7b23a..02cdab6 100644
>>>> --- a/include/linux/skbuff.h
>>>> +++ b/include/linux/skbuff.h
>>>> @@ -207,6 +207,8 @@ struct skb_shared_info {
>>>>  	/* Intermediate layers must ensure that destructor_arg
>>>>  	 * remains valid until skb destructor */
>>>>  	void *		destructor_arg;
>>>> +	void *          priv;
>>>> +	void           (*release)(struct sk_buff *skb);
>>>>  };
>>>> =20
>>>>  /* We divide dataref into two halves.  The higher 16 bits hold refe=
rences
>>>> diff --git a/net/core/skbuff.c b/net/core/skbuff.c
>>>> index 80a9616..a7e40a9 100644
>>>> --- a/net/core/skbuff.c
>>>> +++ b/net/core/skbuff.c
>>>> @@ -219,6 +219,8 @@ struct sk_buff *__alloc_skb(unsigned int size, g=
fp_t=20
>>> gfp_mask,
>>>>  	shinfo->tx_flags.flags =3D 0;
>>>>  	skb_frag_list_init(skb);
>>>>  	memset(&shinfo->hwtstamps, 0, sizeof(shinfo->hwtstamps));
>>>> +	shinfo->release =3D NULL;
>>>> +	shinfo->priv =3D NULL;
>>>> =20
>>>>  	if (fclone) {
>>>>  		struct sk_buff *child =3D skb + 1;
>>>> @@ -350,6 +352,9 @@ static void skb_release_data(struct sk_buff *skb=
)
>>>>  		if (skb_has_frags(skb))
>>>>  			skb_drop_fraglist(skb);
>>>> =20
>>>> +		if (skb_shinfo(skb)->release)
>>>> +			skb_shinfo(skb)->release(skb);
>>>> +
>>>>  		kfree(skb->head);
>>>>  	}
>>>>  }
>>>> @@ -514,6 +519,8 @@ int skb_recycle_check(struct sk_buff *skb, int s=
kb_size)
>>>>  	shinfo->tx_flags.flags =3D 0;
>>>>  	skb_frag_list_init(skb);
>>>>  	memset(&shinfo->hwtstamps, 0, sizeof(shinfo->hwtstamps));
>>>> +	shinfo->release =3D NULL;
>>>> +	shinfo->priv =3D NULL;
>>>> =20
>>>>  	memset(skb, 0, offsetof(struct sk_buff, tail));
>>>>  	skb->data =3D skb->head + NET_SKB_PAD;
>>>> @@ -856,6 +863,8 @@ int pskb_expand_head(struct sk_buff *skb, int nh=
ead, int=20
>>> ntail,
>>>>  	skb->hdr_len  =3D 0;
>>>>  	skb->nohdr    =3D 0;
>>>>  	atomic_set(&skb_shinfo(skb)->dataref, 1);
>>>> +	skb_shinfo(skb)->release =3D NULL;
>>>> +	skb_shinfo(skb)->priv =3D NULL;
>>>>  	return 0;
>>>> =20
>>>>  nodata:
>>> This is basically subset of the skb data destructors patch, isn't it?=

>> Sort of, but the emphasis is different.  Here are the main differences=
:
>>
>> 1) skb->destructor() is on the skb level, shinfo->release() is at the =
shared-info/page level
>>
>> 2) skb->destructor is (iiuc) modified during the skb's lifetime (for i=
nstance rmem hooks here to
>> manage the buffer-space dynamically), whereas shinfo->release is desig=
ned to be used by
>> "the owner" and is thus only set at creation.
>>
>> 3) shinfo->release tracks the lifetime of the pages, not the skb.  Thi=
s means it transcends
>> the skb's lifetime (such as splits for clone, etc) and focuses on the =
shared component: the pages
>=20
> You are comparing with skb destructors, not skb data destructors :) skb=

> data destructor is Rusty's patch which he wanted to use for vringfd.  I=

> mean e.g. this:
> http://lists.openwall.net/netdev/2008/04/18/7

Ah, I wasn't aware.  I believe Anthony Ligouri had pointed me at this
same patch earlier this year.  However, more recently when I saw
skb->destructor() in mainline (seemingly from Rusty), I thought it had
been accepted and didn't investigate further.  I see now that you are
talking about something else.

>=20
>>> Last time this was tried, this is the objection that was voiced:
>>>
>>> 	The problem with this patch is that it's tracking skb's, while
>>> 	you want use it to track pages for zero-copy.  That just doesn't
>>> 	work.  Through mechanisms like splice, individual pages in the
>>> 	skb can be detached and metastasize to other locations, e.g.,
>>> 	the VFS.
>> Right, and I don't think this applies here because I specifically chos=
e the shinfo level to try to properly
>> track the page level avoid this issue.  Multiple skb's can point to a =
single shinfo, iiuc.
>=20
> VFS does not know about shinfo either, does it?

I do not follow the reference.  Where does VFS come into play?

>=20
>>> and I think this applies here.
>> I don't think so, but if you think I missed something, do not be shy (=
not that you ever are).
>=20
> Well, I hope the reviews are helpful.

Yes, I didn't mean it as a slam.  Was only trying to convey that I
didn't think I was wrong but am open minded to the possibility, so
please keep the discussion going.

>  I'll be happy if we learn to
> track pages involved in transmit, but need to be careful.
>=20

Agreed.

>>> In other words, this only *seems*
>>> to work for you because you are not trying to do things like
>>> guest to host communication, with host doing smart things.
>> I am not following what you mean here, as I do use this for guest->hos=
t and guest->host->remote, and
>> it works quite nicely.  I map the guest pages in, and when the last re=
ference to the pages are dropped,
>> I release the pages back to the guest.  It doesn't matter if the skb e=
gresses out a physical adapter or is
>> received locally.  All that matters is the lifetime of the shinfo (and=
 thus its pages) is handled correctly.
>=20
> Not if someone else is referencing the pages without a reference to shi=
nfo.

I agree that if we can reference pages outside of the skb/shinfo then
there is a problem.  I wasn't aware that we could do this, tbh.

However, it seems to me that this is a problem with the overall stack,
if true....isn't it?  For instance, if I do a sendmsg() from a userspace
app and block until its consumed, how can the system function sanely if
the app returns from the call but something is still referencing the
page(s)?  This seems broken to me.

>=20
>>> Cc Herbert which was involved in the original discussion.
>>>
>>> In the specific case, it seems that things like pskb_copy,
>>> skb_split and others will also be broken, won't they?
>> Not to my knowledge.   They up the reference to the shinfo before proc=
eeding.
>=20
> I don't seem to find where does skb_split reference the shinfo.
> It seems to do get_page on individual pages?

Ill take a look.

If so, one alternate solution that I had considered was to look at some
kind of page->release() hook.  There are obvious disadvantages to such a
solution (for one, it has no such notion, and second we have to manage
the aggregate collection which has overhead), so I shied away from that
design in favor of this one.  But perhaps we will ultimately have no choi=
ce.

Kind Regards,
-Greg


--------------enig1800449CB42F9F363F7605BC
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG/MacGPG2 v2.0.11 (Darwin)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iEYEARECAAYFAkr5dH4ACgkQP5K2CMvXmqEKxQCfa2XknFCAj0zWl45y3JVw5c21
5L8AnifVmEcgkqjIUPDME6GI7ocfZgfm
=gfms
-----END PGP SIGNATURE-----

--------------enig1800449CB42F9F363F7605BC--
