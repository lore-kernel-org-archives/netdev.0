From: Gregory Haskins <ghaskins@novell.com>
Subject: Re: [RFC PATCH] net: add dataref destructor to sk_buff
Date: Tue, 10 Nov 2009 10:45:16 -0500
Message-ID: <4AF98A8C.9040201@novell.com>
References: <20091002141407.30224.54207.stgit@dev.haskins.net> <20091110115335.GC6989@redhat.com> <4AF919020200005A000586A9@sinclair.provo.novell.com> <20091110131722.GA19645@redhat.com> <4AF9747E.8020408@novell.com> <20091110143652.GB19645@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enig755F04A89FB5DA7DE994117F"
Cc: alacrityvm-devel@lists.sourceforge.net, herbert.xu@redhat.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756740AbZKJPpc@vger.kernel.org>
In-Reply-To: <20091110143652.GB19645@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig755F04A89FB5DA7DE994117F
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

Michael S. Tsirkin wrote:
> On Tue, Nov 10, 2009 at 09:11:10AM -0500, Gregory Haskins wrote:
>> Michael S. Tsirkin wrote:
>>> On Tue, Nov 10, 2009 at 05:40:50AM -0700, Gregory Haskins wrote:
>>>>>>> On 11/10/2009 at  6:53 AM, in message <20091110115335.GC6989@redh=
at.com>,
>>>> "Michael S. Tsirkin" <mst@redhat.com> wrote:=20
>>
>>>>> Last time this was tried, this is the objection that was voiced:
>>>>>
>>>>> 	The problem with this patch is that it's tracking skb's, while
>>>>> 	you want use it to track pages for zero-copy.  That just doesn't
>>>>> 	work.  Through mechanisms like splice, individual pages in the
>>>>> 	skb can be detached and metastasize to other locations, e.g.,
>>>>> 	the VFS.
>>>> Right, and I don't think this applies here because I specifically ch=
ose the shinfo level to try to properly
>>>> track the page level avoid this issue.  Multiple skb's can point to =
a single shinfo, iiuc.
>>> VFS does not know about shinfo either, does it?
>> I do not follow the reference.  Where does VFS come into play?
>=20
> "Through mechanisms like splice, individual pages in the
> skb can be detached and metastasize to other locations, e.g.,
> the VFS"

Right, understood.  What I mean is: How is that actually used in
real-life in a way that is valid?

What I am getting at is as follows:  From a real basic perspective, you
can look at all of this as a simple synchronous call (i.e. sendmsg()).
The "app" (be it a userspace app, or a guest) prepares a buffer for
transmission, and offers it to the next layer in the stack.  The app
must maintain the integrity of that buffer at least until the layer
below it signifies that it is "consumed".  This may mean its a
synchronous call, like sendmsg(), or it may be asynchronous, like AIO.

But the key thing here is that at some point, the lower layer has to
signify that the buffer stability constraint has been met.  In either
case, we have a clear delineated event: the io-completes =3D the buffer i=
s
free to be reused.

In the simple case, the buffer in question is copied to a kernel buffer,
and the io completes immediately. In other cases (such as zero copy),
the buffer is mapped into the skb, and we have to wait for even lower
layers to signify the completion.

I am not a stack expert, but I was under the impression that we use this
model for userspace pages today as well using the wmem callbacks in
skb->destructor().  If so, I do not see how you could do something like
detach a page from a pskb and still expect to have a proper event that
delineates the io-completion to the higher layers.

So the questions are:

1) do we in fact map userspace pages to pskbs today?
2a) if so, how do we delineate the completion event?
2b) and how do we prevent worrying about the get_page() issue you refer
to.


>>
>>>>> In other words, this only *seems*
>>>>> to work for you because you are not trying to do things like
>>>>> guest to host communication, with host doing smart things.
>>>> I am not following what you mean here, as I do use this for guest->h=
ost and guest->host->remote, and
>>>> it works quite nicely.  I map the guest pages in, and when the last =
reference to the pages are dropped,
>>>> I release the pages back to the guest.  It doesn't matter if the skb=
 egresses out a physical adapter or is
>>>> received locally.  All that matters is the lifetime of the shinfo (a=
nd thus its pages) is handled correctly.
>>> Not if someone else is referencing the pages without a reference to s=
hinfo.
>> I agree that if we can reference pages outside of the skb/shinfo then
>> there is a problem.  I wasn't aware that we could do this, tbh.
>>
>> However, it seems to me that this is a problem with the overall stack,=

>> if true....isn't it?  For instance, if I do a sendmsg() from a userspa=
ce
>> app and block until its consumed,
>=20
> consumed =3D=3D memcpy_from_iovec?

For non-zero-copy, sure why not.

>=20
>> how can the system function sanely if
>> the app returns from the call but something is still referencing the
>> page(s)?
>=20
> which pages?

You said that there are paths that get_page() out of shinfo without
holding a shinfo reference.

Kind Regards,
-Greg


--------------enig755F04A89FB5DA7DE994117F
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG/MacGPG2 v2.0.11 (Darwin)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iEYEARECAAYFAkr5iowACgkQP5K2CMvXmqGBJQCfdIq7CmFBA7/UF31JCUgJZqki
wkIAnRtRHTt7a+7ZEuH5Fal3IWH+xWhx
=ymlb
-----END PGP SIGNATURE-----

--------------enig755F04A89FB5DA7DE994117F--
