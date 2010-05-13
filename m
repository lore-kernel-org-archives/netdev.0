From: Dan Williams <dan.j.williams@intel.com>
Subject: Re: [PATCH 2/2] ioat2,3: convert to producer/consumer locking
Date: Thu, 13 May 2010 16:42:30 -0700
Message-ID: <AANLkTinHKVk9iWTKgEwcuKgmoCyCif2kSy3v0ZIsZ50p@mail.gmail.com>
References: <20100511184949.6139.96826.stgit@localhost.localdomain>
	 <20100511185141.6139.98842.stgit@localhost.localdomain>
	 <31229.1273653365@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, linux-raid@vger.kernel.org,
	netdev@vger.kernel.org,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Maciej Sosnowski <maciej.sosnowski@intel.com>
To: David Howells <dhowells@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <31229.1273653365@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, May 12, 2010 at 1:36 AM, David Howells <dhowells@redhat.com> wr=
ote:
>
> Out of interest, does it make the code smaller if you mark
> ioat2_get_ring_ent() and ioat2_ring_mask() with __attribute_const__?
>
> I'm not sure whether it'll affect how long gcc is willing to cache th=
ese, but
> once computed, I would guess they won't change within the calling fun=
ction.

Unfortunately, it does not make a difference, but I'll keep this in
mind if ioat2_get_ring_ent() ever gets more complicated (which it
might in the future).

> Also, is the device you're driving watching the ring and its indices?=
 =A0If so,
> does it modify the indices? =A0If that is the case, you might need to=
 use
> read_barrier_depends() rather than smp_read_barrier_depends().

The device does not observe the indices directly.  Instead we
increment a free running 'count' register by the distance between
ioat->pending and ioat->head.

>
>> + =A0 =A0 =A0 =A0 =A0 =A0 prefetch(ioat2_get_ring_ent(ioat, idx + i =
+ 1));
>> + =A0 =A0 =A0 =A0 =A0 =A0 desc =3D ioat2_get_ring_ent(ioat, idx + i)=
;
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 dump_desc_dbg(ioat, desc);
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 tx =3D &desc->txd;
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (tx->cookie) {
>
> Is this right, I wonder? =A0You're prefetching [i+1] before reading [=
i]? =A0Doesn't
> this mean that you might have to wait for [i+1] to be retrieved from =
RAM before
> [i] can be read? =A0Should you instead read tx->cookie before issuing=
 the
> prefetch? =A0Admittedly, this is only likely to affect the reading of=
 the head of
> the queue - subsequent reads in the same loop will, of course, have b=
een
> prefetched.

Yes, it should be the other way around.

Thanks!

--
Dan
