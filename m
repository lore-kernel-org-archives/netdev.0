From: Sridhar Samudrala <sri@us.ibm.com>
Subject: Re: net-AIO and real-time TCP (blue sky research)
Date: Wed, 11 Aug 2004 16:44:04 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.58.0408111643460.3103@localhost.localdomain>
References: <20040801235102.K1276@almesberger.net> <20040810155148.GA4630@in.ibm.com>
 <20040811201829.T28020@almesberger.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Suparna Bhattacharya <suparna@in.ibm.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Werner Almesberger <werner@almesberger.net>
In-Reply-To: <20040811201829.T28020@almesberger.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Your AIO-TCP looks pretty similar to the partial reliablity extension to
SCTP that allows an SCTP endpoint to signal to its peer that it is no longer
going to retransmit certain messages and should skip past those messages.
        http://www.ietf.org/rfc/rfc3758.txt

Thanks
Sridhar

On Wed, 11 Aug 2004, Werner Almesberger wrote:

> Suparna Bhattacharya wrote:
> > I was hoping all this while that someone with deeper knowledge
> > in this area than me would respond, but well, maybe they were
> > all quiet chuckles :) ?
>
> Or they haven't stopped laughing yet ;-)
>
> > Does your proposal require additional semantics on aio TCP socket
> > reads and writes that differ from the synchronous TCP case, besides
> > not blocking and indicating completion through aio_complete ?
>
> Unfortunately, yes. First of all, we'd need a definition of where
> in the stream the AIO operation is applied. Two possibilities:
>
>  1) explicit: apply the concept of a "file position" to the stream,
>     and make it visible to applications (through aio_offset)
>
>  2) implicit: follow the existing principle that any read consumes
>     just the next chunk of data, and internally assign positions
>     based on the sequence number. As a consequence, AIOs would be
>     ordered over time (in the case of individual aio_reads) and
>     space (in the case of lio_listio).
>
> In any case, it's a departure from existing API properties, i.e.
> 1) would introduce an application-visible "stream position" for
> TCP (which doesn't agree with TCP being able to send arbitrarily
> long streams, but then, a nice 64 bit position is probably close
> enough to near-infinity), and 2) adds ordering to AIO, which may
> be undesirable in terms of consistency, and also in terms of
> lock avoidance.
>
> There's also the issue of whether an AIO read should complete
> after retrieving less than aio_nbytes. Three possibilities:
>
>  1) never (probably not a great idea)
>  2) may always (like "read" does)
>  3) only on the last AIO read returning data
>
> 2) would be the most flexible approach, but requires either
> application-settable positions (to fetch the missing part) or
> automatic re-arranging of subsequent AIO reads.
>
> 3) avoids the problems of 2), but doesn't work well if the
> reader didn't correctly predict segment boundaries, and may
> cause trouble (like in 2) if there are pending requests after
> the one that was "short", and new data arrives.
>
> Last but not least, aio_forget would have to tell TCP that we're
> not only no longer interested in retrieving a certain piece of
> data, but that we'll never be.
>
> If positions are implicit, aio_cancel would actually have this
> effect (since there would be no way to request the same range of
> data again), so we wouldn't even need aio_forget.
>
> > The notion of which segment to aio_forget on the Rx path
> > is a little hazy to me (were you were indeed referring
> > to the receive side here ? I can see this more clearly for
> > the send side when coupled with zero copy).
>
> Yes, this is mainly about receiving. Similar things could be
> done for sending, but that's largely a separate issue.
>
> Let's say I'm issuing three AIOs:
>
>  1: offset = 0, nbytes = 100
>  2: offset = 100, nbytes = 100
>  3: offset = 200, nbytes = 100
>
> Now a segment arrives for 0-99, and another for 200-299.
> Normal TCP will retry (by ACKing sequence 100) until also the
> segment 100-199 has made it.
>
> With AIO-TCP, if our application is happy with getting two
> out of the three requests, it can now aio_forget the 2nd
> request. TCP would notice that can now ACK up to sequence 200,
> for the forgotten read, and even up to sequence 300, because
> the 200-299 has been received. So it'll ACK sequence 300 now,
> and happily move on, without caring whether segment 100-199
> ever gets through.
>
> - Werner
>
> --
>   _________________________________________________________________________
>  / Werner Almesberger, Buenos Aires, Argentina     werner@almesberger.net /
> /_http://www.almesberger.net/____________________________________________/
>
>
