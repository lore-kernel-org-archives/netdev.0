From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: Distributed storage.
Date: Fri, 3 Aug 2007 14:42:50 +0400
Message-ID: <20070803104249.GC10089@2ka.mipt.ru>
References: <20070731171347.GA14267@2ka.mipt.ru> <170fa0d20708022109s60ebb85aqe68ec1033634ef27@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-fsdevel@vger.kernel.org, Daniel Phillips <phillips@phunq.net>
To: Mike Snitzer <snitzer@gmail.com>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <170fa0d20708022109s60ebb85aqe68ec1033634ef27@mail.gmail.com>
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Mike.

On Fri, Aug 03, 2007 at 12:09:02AM -0400, Mike Snitzer (snitzer@gmail.com) wrote:
> >     * storage can be formed on top of remote nodes and be exported
> >         simultaneously (iSCSI is peer-to-peer only, NBD requires device
> >         mapper and is synchronous)
> 
> Having the in-kernel export is a great improvement over NBD's
> userspace nbd-server (extra copy, etc).
> 
> But NBD's synchronous nature is actually an asset when coupled with MD
> raid1 as it provides guarantees that the data has _really_ been
> mirrored remotely.

I believe, that the right answer to this is barrier, but not synchronous
sending/receiving, which might slow things down noticebly. Barrier must
wait until remote side received data and send back a notice. Until
acknowledge is received, no one can say if data mirrored or ever
received by remote node or not.

> > TODO list currently includes following main items:
> >     * redundancy algorithm (drop me a request of your own, but it is highly
> >         unlikley that Reed-Solomon based will ever be used - it is too slow
> >         for distributed RAID, I consider WEAVER codes)
> 
> I'd like to better understand where you see DST heading in the area of
> redundancy.    Based on your blog entries:
> http://tservice.net.ru/~s0mbre/blog/devel/dst/2007_07_24_1.html
> http://tservice.net.ru/~s0mbre/blog/devel/dst/2007_07_31_2.html
> (and your todo above) implementing a mirroring algorithm appears to be
> a near-term goal for you.  Can you comment on how your intended
> implementation would compare, in terms of correctness and efficiency,
> to say MD (raid1) + NBD?  MD raid1 has a write intent bitmap that is
> useful to speed resyncs; what if any mechanisms do you see DST
> embracing to provide similar and/or better reconstruction
> infrastructure?  Do you intend to embrace any exisiting MD or DM
> infrastructure?

Depending on what algorithm will be preferred - I do not want mirroring,
it is _too_ wasteful in terms of used storage, but it is the simplest.
Right now I still consider WEAVER codes as the fastest in distributed
envornment from what I checked before, but it is quite complex and spec
is (at least for me) not clear in all aspects right now. I did not even
start userspace implementation of that codes. (Hint: spec sucks, kidding :)

For simple mirroring each node must be split to chunks, each one has
representation bin in main node mask, when dirty full chunk is resynced.
Depending on node size and amount of memory chunk size varies. Setup is
performed during node initialization. Having checksum for each chunk
is a good step.

All interfaces are already there, although require cleanup and move from
place to place, but I decided to make initial release small.

> BTW, you have definitely published some very compelling work and its
> sad that you're predisposed to think DST won't be recieved well if you
> pushed for inclusion (for others, as much was said in the 7.31.2007
> blog post I referenced above).  Clearly others need to embrace DST to
> help inclusion become a reality.  To that end, its great to see that
> Daniel Phillips and the other zumastor folks will be putting DST
> through its paces.

In that blog entry I misspelled Zen with Xen - that's an error,
according to prognosis - time will judge :)

> regards,
> Mike
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 
	Evgeniy Polyakov
