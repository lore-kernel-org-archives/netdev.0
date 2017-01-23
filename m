From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Subject: Re: [PATCHv3 net-next 4/4] sctp: implement sender-side procedures
 for Add Incoming/Outgoing Streams Request Parameter
Date: Mon, 23 Jan 2017 14:02:34 -0200
Message-ID: <20170123160234.GY3781@localhost.localdomain>
References: <cover.1484845510.git.lucien.xin@gmail.com>
 <daa150a23548dda0a2fd513c622773f0ff9b2df3.1484845510.git.lucien.xin@gmail.com>
 <063D6719AE5E284EB5DD2968C1650D6DB026B563@AcuExch.aculab.com>
 <20170123145347.GB31445@hmswarspite.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Laight <David.Laight@ACULAB.COM>,
        "'Xin Long'" <lucien.xin@gmail.com>,
        network dev <netdev@vger.kernel.org>,
        "linux-sctp@vger.kernel.org" <linux-sctp@vger.kernel.org>,
        Vlad Yasevich <vyasevich@gmail.com>,
        "davem@davemloft.net" <davem@davemloft.net>
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:60932 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750828AbdAWQCp (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 23 Jan 2017 11:02:45 -0500
Content-Disposition: inline
In-Reply-To: <20170123145347.GB31445@hmswarspite.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 23, 2017 at 09:53:47AM -0500, Neil Horman wrote:
> On Mon, Jan 23, 2017 at 11:25:56AM +0000, David Laight wrote:
> > From: Xin Long
> > > Sent: 19 January 2017 17:19
> > > This patch is to implement Sender-Side Procedures for the Add
> > > Outgoing and Incoming Streams Request Parameter described in
> > > rfc6525 section 5.1.5-5.1.6.
> > > 
> > > It is also to add sockopt SCTP_ADD_STREAMS in rfc6525 section
> > > 6.3.4 for users.
> > ...
> > > +	out = params->sas_outstrms;
> > > +	in  = params->sas_instrms;
> > > +
> > > +	if (!out && !in)
> > > +		goto out;
> > > +
> > > +	if (out) {
> > > +		__u16 nums = stream->outcnt + out;
> > 
> > Make nums 'unsigned int', the code will be smaller and you can
> > use the value for the overflow check.
> > 
> > > +		/* Check for overflow, can't use nums here */
> > > +		if (stream->outcnt + out > SCTP_MAX_STREAM)
> > > +			goto out;
> > > +
> > > +		/* Use ksize to check if stream array really needs to realloc */
> > > +		if (ksize(stream->out) / sizeof(*stream->out) < nums) {
> > > +			struct sctp_stream_out *streamout;
> > > +
> > > +			streamout = kcalloc(nums, sizeof(*streamout),
> > > +					    GFP_KERNEL);
> > > +			if (!streamout) {
> > > +				retval = -ENOMEM;
> > > +				goto out;
> > > +			}
> > > +
> > > +			memcpy(streamout, stream->out,
> > > +			       sizeof(*streamout) * stream->outcnt);
> > > +
> > > +			kfree(stream->out);
> > > +			stream->out = streamout;
> > > +		}
> > 
> > Does kcalloc() zero the entire area, or just the length you ask for?
> > If the latter you need to zero the rest here.
> Better still, just use krealloc.  You still need to zero out any space beyond
> the old length, but it will make the code shorter, and avoid the need for
> additional temporary variables.

Seems if we pass gfp | __GFP_ZERO to krealloc it will end up zeroing the
slab for us before doing the memcpy.
I didn't follow all paths but in slab_alloc_node it will end up calling:
        if (unlikely(gfpflags & __GFP_ZERO) && object)
                memset(object, 0, s->object_size);
So I would expect that other paths also do it.

  Marcelo

> 
> Neil
> 
> > ...
> > 
> > 	David
> > 
> > --
> > To unsubscribe from this list: send the line "unsubscribe linux-sctp" in
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
> > 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-sctp" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
