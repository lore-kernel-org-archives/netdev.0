From: Jason Gunthorpe <jgunthorpe-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: Re: [PATCH for-next V7 00/10] Move RoCE GID management to IB/Core
Date: Sat, 1 Aug 2015 21:03:30 -0600
Message-ID: <CABLbMxNu_uYPs0=uT+yX0CjJ+2obZ5qvAeXA2y4A77K2Dm+y3w@mail.gmail.com>
References: <55BC1317.50700@redhat.com>
	<be961828-39ff-4a15-863e-93cc86dfcf49@email.android.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Or Gerlitz <gerlitz.or-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Matan Barak <matanb-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Sean Hefty <sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Somnath Kotur <Somnath.Kotur-1wcpHE2jlwO1Z/+hSey0Gg@public.gmane.org>,
	Moni Shoua <monis-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>, talal-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org,
	Haggai Eran <haggaie-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Linux Netdev List <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Jason Gunthorpe <jgunthorpe-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>,
	Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <be961828-39ff-4a15-863e-93cc86dfcf49-2ueSQiBKiTY7tOexoI0I+QC/G2K4zDHf@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

> In many respects, I expect the ib_unregister_device() call to mirror the
>  error unwind found in the register call with the modifications for
>  dealing with a device that was actually live.

Yes, it should look like that, I also noticed there were ordering
problems in this area. and we probably have some long standing
use-after-free bugs in here which are hopefully harmless..

However, the kfrees should still be in release.

> To a certain extent, your comments in the v6 thread about the cache
> being expected to work beyond the life of the device and therefore part
> of the core stack are somewhat reasonable, but the life of the cache on
> a per device basis is no different than the life of the client
> registration.

Well, no, later patches in the series add calls into this code from
the drivers, and I looked into those and it wasn't obviously clear
that they were or could be made safe, or that future uses from drivers
would also be safe.

I looked at all of this, and thought about addressing the issue by
suggesting reordering removal, but it just doesn't guarantee safety,
requires too much auditing to prove and is a lot more work. Moving the
kfree is 10 lines or so and is guaranteed correct.

I disagree this is subtle or unexpected design pattern. The standard
kernel pattern with kref is a create/remove/release triplet. When you
have kref controlled structure every single member in that structure
needs to be analyzed for lifetime and the unwind(s) needs to be placed
in remove or release. For this cache code, that analysis tells me the
kfree unwind needs to live in release and the workqueue/event stuff in
remove. That is how I noticed to start with: a kfree of a member
inside a kref'd structure outside of release looks out of place,
especially if there is no locking protecting it...

The idiom is also to often use kref_put as part of the error unwind in
create, and since v7 doesn't do this it introduces a double kfree bug
as well..

At the end of the day this really shouldn't be the problem of the
caller, as long as the ib_device pointer is valid then core API should
be callable without causing a use-after-free.

> These branches are from my internal tree and really are WIP branches.
> I've pushed those WIP branches to github.  As I stated when I set my two

Sure testing sounds reasonable, maybe you need a different phrase for
this situation than 'thanks applied'.

Anyhow, it is a holiday here till Tuesday, hopefully Matan can fix
this up for your testing before then.

Jason
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
