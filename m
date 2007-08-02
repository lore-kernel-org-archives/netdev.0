From: Daniel Phillips <phillips@phunq.net>
Subject: Re: Distributed storage.
Date: Thu, 2 Aug 2007 14:08:24 -0700
Message-ID: <200708021408.24876.phillips@phunq.net>
References: <20070731171347.GA14267@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="koi8-r"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-fsdevel@vger.kernel.org,
	Peter Zijlstra <peterz@infradead.org>
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <20070731171347.GA14267@2ka.mipt.ru>
Content-Disposition: inline
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tuesday 31 July 2007 10:13, Evgeniy Polyakov wrote:
> Hi.
>
> I'm pleased to announce first release of the distributed storage
> subsystem, which allows to form a storage on top of remote and local
> nodes, which in turn can be exported to another storage as a node to
> form tree-like storages.

Excellent!  This is precisely what the doctor ordered for the 
OCFS2-based distributed storage system I have been mumbling about for 
some time.  In fact the dd in ddsnap and ddraid stands for "distributed 
data".  The ddsnap/raid devices do not include an actual network 
transport, that is expected to be provided by a specialized block 
device, which up till now has been NBD.  But NBD has various 
deficiencies as you note, in addition to its tendency to deadlock when 
accessed locally.  Your new code base may be just the thing we always 
wanted.  We (zumastor et al) will take it for a drive and see if 
anything breaks.

Memory deadlock is a concern of course.  From a cursory glance through, 
it looks like this code is pretty vm-friendly and you have thought 
quite a lot about it, however I respectfully invite peterz 
(obsessive/compulsive memory deadlock hunter) to help give it a good 
going over with me.

I see bits that worry me, e.g.:

+		req = mempool_alloc(st->w->req_pool, GFP_NOIO);

which seems to be callable in response to a local request, just the case 
where NBD deadlocks.  Your mempool strategy can work reliably only if 
you can prove that the pool allocations of the maximum number of 
requests you can have in flight do not exceed the size of the pool.  In 
other words, if you ever take the pool's fallback path to normal 
allocation, you risk deadlock.

Anyway, if this is as grand as it seems then I would think we ought to 
factor out a common transfer core that can be used by all of NBD, 
iSCSI, ATAoE and your own kernel server, in place of the roll-yer-own 
code those things have now.

Regards,

Daniel
