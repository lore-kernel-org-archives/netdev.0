From: Miroslav Lichvar <mlichvar@redhat.com>
Subject: Re: Extending socket timestamping API for NTP
Date: Wed, 8 Feb 2017 11:14:46 +0100
Message-ID: <20170208101446.GA23304@localhost>
References: <20170207140144.GA11233@localhost>
 <CACSApva7DeBcRUFG13Xb7YoegHcLWwwd=ecLVf9wSgNSKFbUDA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>,
        Richard Cochran <richardcochran@gmail.com>,
        Jiri Benc <jbenc@redhat.com>,
        "Keller, Jacob E" <jacob.e.keller@intel.com>,
        Denny Page <dennypage@me.com>,
        Willem de Bruijn <willemb@google.com>
To: Soheil Hassas Yeganeh <soheil@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:41208 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752404AbdBHKPQ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 8 Feb 2017 05:15:16 -0500
Content-Disposition: inline
In-Reply-To: <CACSApva7DeBcRUFG13Xb7YoegHcLWwwd=ecLVf9wSgNSKFbUDA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Feb 07, 2017 at 10:54:22AM -0800, Soheil Hassas Yeganeh wrote:
> On Tue, Feb 7, 2017 at 6:01 AM, Miroslav Lichvar <mlichvar@redhat.com> wrote:
> > 2) new SO_TIMESTAMPING option to receive from the error queue only
> >    user data as was passed to sendmsg() instead of Ethernet frames
> >
> >    Parsing Ethernet and IP headers (especially IPv6 options) is not
> >    fun and SOF_TIMESTAMPING_OPT_ID is not always practical, e.g. in
> >    applications which process messages from the error queue
> >    asynchronously and don't bind/connect their sockets.
> 
> This is going to be quite useful. However, I'm not sure if sending
> back the original packet would be a proper API. Instead, one option is
> to add a control message, so that applications can set the OPT_ID for
> the timestamp. Perhaps, something like from user's perspective:
> 
> cmsg->cmsg_level             = SOL_SOCKET;
> cmsg->cmsg_type              = SCM_TIMESTAMPING_OPT_ID;
> cmsg->cmsg_len               = CMSG_LEN(sizeof(__u32));
> *((__u32 *) CMSG_DATA(cmsg)) = my_id;

That could be very useful. The question is if 32 bits worth of user
data would be good enough for all applications. In the case of the NTP
server, I currently save 128 bits per client in order to support the
interleaved mode. Half of that is the receive timestamp, which is
compared to the receive timestamp from messages received from the
error queue. Matching only lower 32 bits of the timestamp would
probably still work fine. However, if NTP supported follow up messages
like PTP, 32 bits would not be enough to create a valid message for
the client without saving some additional state. Getting the original
message would be very convenient here. NTP packets are normally very
short, so I'm not sure how much benefit there would be in using the
OPT_ID.

-- 
Miroslav Lichvar
