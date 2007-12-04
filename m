From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [0/4] DST: Distributed storage.
Date: Tue, 4 Dec 2007 19:00:40 +0300
Message-ID: <20071204160040.GA8055@2ka.mipt.ru>
References: <aqqqqasdzxczc036@2ka.mipt.ru> <11967790263179@2ka.mipt.ru> <170fa0d20712040725o506a47cayb137993041ec3a63@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: lkml <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org,
	linux-fsdevel@vger.kernel.org
To: Mike Snitzer <snitzer@gmail.com>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <170fa0d20712040725o506a47cayb137993041ec3a63@mail.gmail.com>
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Mike.

On Tue, Dec 04, 2007 at 10:25:29AM -0500, Mike Snitzer (snitzer@gmail.com) wrote:
> Thanks for your continued work on DST.  I'd like to know if you've
> thought further about how synchronous mirroring would be best
> implemented with DST.
> 
> You shared you views some time ago via comments on your blog:
> http://tservice.net.ru/~s0mbre/blog/devel/dst/2007_11_05.html
> 
> At that time you were saying you'd add a sync bit to the request
> structure that is sent to remote nodes.  I'd imagine this would also
> require ordering of the block io, no?  Is order guaranteed when the
> requests are submitted over the DST protocol?  Otherwise how can you
> ensure a valid remote mirror (in the case of network disconnects,
> etc)?
> 
> Guaranteeing consistent data on all members of a mirror is important.
> The main question is: what mechanisms _should_ be used in DST to
> provide this consistency?  And do you have a timeframe for when DST
> might support such mechanisms for consistent data?
> 
> For the purpose of this discussion please assume that the disk cache
> is either write-through or battery-backed.

In this case sync bit would only imply waiting until all pending
requests reached remote nodes. This is not implemented yet.
Order of the requests for given node is guaranteed by DST core,
it is possible to perform multiple requests in parallel for/from
different nodes.

In the more generic case it should wait until data has reached media,
i.e. perform flushing.
I did not implement that since actually no multiple-device system in
Linux supports barriers (please note, that in this discussion sync bit
actually means a barrier in the block layer).

Protocol changes are pretty trivial and are absolutely transparent for
the DST core - only remote targets (both userspace and kernelspace)
should be changed to invoke ->issue_flush_fn() callback when needed for
underlying device and do not process new requests until flush completed.
Thus barrier bit can be attached to data packets and can also be single
requests without data.

DST will continue to collect data, but will not send it to remote nodes
(actually it can send it, but data will not be processed and will stay
in the remote's receiving queue). This is a main concern about barrier -
should or not main node continue to process requests if previous ones
have not reached media yet, thus I have not yet implemented barriers.

> regards,
> Mike

-- 
	Evgeniy Polyakov
