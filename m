From: Daniel Phillips <phillips@phunq.net>
Subject: Re: Distributed storage.
Date: Tue, 7 Aug 2007 11:24:56 -0700
Message-ID: <200708071124.56859.phillips@phunq.net>
References: <20070731171347.GA14267@2ka.mipt.ru> <200708051423.45484.phillips@phunq.net> <20070807120523.GX5245@kernel.dk>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Evgeniy Polyakov <johnpol@2ka.mipt.ru>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	Peter Zijlstra <peterz@infradead.org>
To: Jens Axboe <jens.axboe@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl081-085-152.lax1.dsl.speakeasy.net ([64.81.85.152]:41258
	"EHLO moonbase.phunq.net" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751047AbXHGSZJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Aug 2007 14:25:09 -0400
In-Reply-To: <20070807120523.GX5245@kernel.dk>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tuesday 07 August 2007 05:05, Jens Axboe wrote:
> On Sun, Aug 05 2007, Daniel Phillips wrote:
> > A simple way to solve the stable accounting field issue is to add a
> > new pointer to struct bio that is owned by the top level submitter
> > (normally generic_make_request but not always) and is not affected
> > by any recursive resubmission.  Then getting rid of that field
> > later becomes somebody's summer project, which is not all that
> > urgent because struct bio is already bloated up with a bunch of
> > dubious fields and is a transient structure anyway.
>
> Thanks for your insights. Care to detail what bloat and dubious
> fields struct bio has?

First obvious one I see is bi_rw separate from bi_flags.  Front_size and 
back_size smell dubious.  Is max_vecs really necessary?  You could 
reasonably assume bi_vcnt rounded up to a power of two and bury the 
details of making that work behind wrapper functions to change the 
number of bvecs, if anybody actually needs that.  Bi_endio and 
bi_destructor could be combined.  I don't see a lot of users of bi_idx, 
that looks like a soft target.  See what happened to struct page when a 
couple of folks got serious about attacking it, some really deep hacks 
were done to pare off a few bytes here and there.  But struct bio as a 
space waster is not nearly in the same ballpark.

It would be interesting to see if bi_bdev could be made read only.  
Generally, each stage in the block device stack knows what the next 
stage is going to be, so why do we have to write that in the bio?  For 
error reporting from interrupt context?  Anyway, if Evgeniy wants to do 
the patch, I will happily unload the task of convincing you that random 
fields are/are not needed in struct bio :-)

Regards,

Daniel
