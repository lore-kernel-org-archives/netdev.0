From: Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH for-next V7 00/10] Move RoCE GID management to IB/Core
Date: Fri, 31 Jul 2015 20:30:15 -0400
Message-ID: <55BC1317.50700@redhat.com>
References: <1438270411-17648-1-git-send-email-matanb@mellanox.com>
 <CAJ3xEMh9z=LG7dW0nBP8Zdrbf0SkZ_GCxjCoowWXuw2dueN+xg@mail.gmail.com>
 <55BB6F10.5030408@redhat.com> <20150731163201.GA6027@obsidianresearch.com>
 <55BBB353.7020806@redhat.com> <20150731201828.GA28263@obsidianresearch.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 protocol="application/pgp-signature";
 boundary="m1jPjNeow8MRhmI0FapSv1SmCUXPNeLNo"
Cc: Or Gerlitz <gerlitz.or-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Matan Barak <matanb-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	"linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Sean Hefty <sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Somnath Kotur <Somnath.Kotur-1wcpHE2jlwO1Z/+hSey0Gg@public.gmane.org>,
	Moni Shoua <monis-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	"talal-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org" <talal-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Haggai Eran <haggaie-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Linux Netdev List <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Jason Gunthorpe <jgunthorpe-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20150731201828.GA28263-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--m1jPjNeow8MRhmI0FapSv1SmCUXPNeLNo
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: quoted-printable

On 07/31/2015 04:18 PM, Jason Gunthorpe wrote:
> On Fri, Jul 31, 2015 at 01:41:39PM -0400, Doug Ledford wrote:
>> Please be more specific here.  What are you objecting to?  Are you
>> objecting to a flush_workqueue from a release() context?  Because I
>> don't see anything in the kref documentation or the kref
>> implementation that prevents or prohibits this.  Or are you
>> referring to the fact that they aren't unregistering their event
>> handler until well after the parent device is unregistered?
>=20
> I'm talking about the basic invarient we have for our removal process:
> ib_unregister_device must fence all calls into the driver, so the
> driver can proceed with the low level remove on the asumption that
> nothing will call into it after unregister returns.

Agreed.

> Clients create this fence by calling things like flush_workqueue and
> ib_unregister_event_handler.

Agreed.

> If the fence is moved out of ib_unregister_device and into release
> then the whole model breaks.

Agreed.

> I've explained this all before on the v1 of these series..
>=20
>> That's obviously wrong, but it's also easy to fix (the obvious fix
>> is that they should be calling ib_cache_cleanup_one from the top of
>> ib_unregister_device versus waiting for a kref put).
>=20
> Well, no, that is not the obvious fix, that puts things back the way
> they were in v6. As I explained the kfrees need to be in the release
> function,

Disagree.

> the async fencing needs to remain in the remove_one or
> equivalent.

Agree.

So, my point of disagreement above.  Except in circumstances with a damn
good reason, I expect code to be symmetrical.  If you allocate some
caches in ib_cache_init_one(), I expect you to kfree those caches in
ib_cache_cleanup_one().  Further, if you call ib_cache_init_one() as one
of the last items before returning from ib_register_device(), then I
expect you to call ib_cache_cleanup_one() as one of the first items in
ib_unregister_device().

However, the fencing doesn't belong to ib_cache_cleanup_one(), it
belongs at the head of ib_unregister_device() and ib_cache_cleanup_one()
should only be called after the fence is complete.

And in this respect, removing the device from the various clients is
actually part of the fencing.  The order of ops in ib_register_device is:=


ib_device_register_sysfs
ib_cache_init_one
for client_list {
    add_client_context
    client->add
}

Consequently, the order of ops in ib_unregister_device should be:

for client_list
    mark coming down
for client_list
    remove(client)
for client_list
    kfree(client)
ib_cache_cleanup_one <- missing
ib_device_unregister_sysfs

In many respects, I expect the ib_unregister_device() call to mirror the
error unwind found in the register call with the modifications for
dealing with a device that was actually live.

It's certainly possible in certain circumstances to veer from this
paradigm, but I expect a good reason for doing so.  A person who isn't
immediately RDMA aware can come in and fix a locking bug when the code
is like it is above.  If you start playing subtle tricks with the
locking and ordering of removal, you start to trip up anyone that
doesn't have first hand knowledge of those tricks and why they were
implemented.  That negatively impacts the long term support of the code,
so the reason should be sufficient to warrant the drawback and the
subtle trick should be documented in the code so someone coming around
later knows what's going on.

To a certain extent, your comments in the v6 thread about the cache
being expected to work beyond the life of the device and therefore part
of the core stack are somewhat reasonable, but the life of the cache on
a per device basis is no different than the life of the client
registration.  The above flow would remove the cache from the client
list, but will still in effect treat it just like a client.  The only
difference (and one that I think is correct), is that by taking it out
of the client_list and those loops, you are able to make sure it's the
first client that comes up and the last one that goes down and that it
continues to work for as long as it needs to (after all, once all of the
clients are unregistered and removed for that device, and we are in the
ib_unregister_device routine, the device is going away and no more calls
into the cache will arrive for it).

>> Regardless though, the reason I'm taking this (and a number of other
>> things) into my tree is that waiting for things to be absolutely perfe=
ct
>> on a submission is an interminable waiting game.
>=20
> So, I'm confused by this..
>=20
> I haven't been waiting, I've looked at every release of every one of
> these three big core change patch set. And found actual problems.

Some of lesser and greater importance.  Some worth resubmitting the
entire patchset, and some that I would be perfectly OK with an
incremental patch later on.  A problem does not always mean resubmit, it
can mean fix before merge window with another patch (or during merge
window depending on the situation).

> What I don't understand is your timing on these.. No 'hey, could we
> finish these reviews' or anything, just out of the blue, v7 merged! It
> was just posted yesterday!

That's because v6 was mostly done and the v6 -> v7 changes were minor.
I would have taken v6 and then accepted incremental patches had it still
applied.

These branches are from my internal tree and really are WIP branches.
I've pushed those WIP branches to github.  As I stated when I set my two
different repos up, my github repo is my WIP repo.  It's for people to
be able to see where we are, pull it if they wish, and preferably to
test against ahead of time.  I *want* people to be able to see where I'm
going.  But that doesn't mean it is fixed in stone.  For things like the
fix to the v7 version of this patch, I will accept an incremental patch,
but it need not have a complete changelog because if it just fixes one
of the patches in this submission, I'm OK with squashing it down into
the original patch in order to keep the patch count down and
bisectability up.  But that can only be done prior to the merge window.
 After the merge window opens and the code heads to Linus, fixes must be
discreet patches.

So you can actually break the merge/testing window down into two
distinct phases: pre-pull (where we can fix broken patches by squashing
a fix into and thereby preserve bisections) and post-pull (which is what
we are all used to).

This merge window is riskier than most because of the patches queued up
to go in.  By pulling all of this together and publishing my git repo
early, I'm inviting other interested parties to join me in the early
testing process where we can fix problems and also preserve bisection.

So that's why I'm pulling things together and posting my git repo ahead
of the merge window.  To speak more directly to the timing issue though,
there is only about 3 weeks left before the merge window opens, and all
of next week I'm going to be working on other things.  So I wanted to
get something out that people can look at and test with before I have to
redirect for a week, and that will still leave me two weeks to integrate
fixes prior to the merge window opening.

>> Not to mention that some of these fixes are quick and easy
>> to do and I'd rather quit waiting 24+ hours for a respin turnaround wh=
en
>> I could just hop in and make the fix myself in 15 minutes and test it
>> immediately.
>=20
> It would have been a lot less work for me to just fix the various
> issues than to explain them to the authors. I'm hoping that investment
> means the next series around will be good at V1...
>=20
>>> Looking at your for-rebase branch.. please make sure you get all the
>>> attributions this cycle :|
>>
>> Yet *another* reason why these v6, v7, v8 patchsets are a huge time
>> drain :-/.
>=20
> Sagi's recent patch set is missing several attributions too..
>=20
> Jason
>=20


--=20
Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
              GPG KeyID: 0E572FDD



--m1jPjNeow8MRhmI0FapSv1SmCUXPNeLNo
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2
Comment: Using GnuPG with Thunderbird - http://www.enigmail.net/

iQIcBAEBCAAGBQJVvBMXAAoJELgmozMOVy/diP0P/Rpm6/WW+eR7PXkz37/mvYUP
r6BA2488LiHJhkxFdT9DXhdmLorXifYwUFqgFXkNla1GyWpz8jDt5PVp+JotrkyD
RxB/c4oBC0fMu+P83LGZTcBH/CKpjdC9REZ5le2DRlp3hvyUH7/YYCEbQ6KcuFOc
e7tKjpmn7okrpo/S/drdWl9V8fN6diViU3aF8kjPuW6n9EHEmRkw5508/jTQbA3e
Hm+tng4478SGCh2QYROxMQQBN57XQFUNADWpDJD8CIdMwbPaEb1Y6ee3RH8A+woQ
goonciUKYco48jGe0SC3t7JrkmgZTRSFtCGfsVDGGWa12TKNijV3g+QEIp9ezLIn
pxD7kCSVK6118Zt09Mqf+mkDXh//zJYS2k1zXiSH96cS9BS8XuYSSz3Zt2O630OL
Fx9T3hYTgnf6hwMfQVjtRy0x1cz7XoFHPqnZaQOClKQWDtZez0l8KhmmPoBT6HHH
P/v+FjW4a/h2kod8vEi/BeBQPe5Eao800Q641+otZkL3T5tltPkOWtVUv9pkqkTT
mETnfCp9BH3c0c6YhccsLgOIe+klhj4VcVwpYdSq2T0ntSAZeHttyb3nD2eTAknh
gVNmdrS3hbf7bUh98J3OdY53sCVtk0mOcWPVq3ln+FQeYbJO0a4W5jdLD4+hRzNp
WOykoF6u3wyrCGLyjVg0
=CIHx
-----END PGP SIGNATURE-----

--m1jPjNeow8MRhmI0FapSv1SmCUXPNeLNo--
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
