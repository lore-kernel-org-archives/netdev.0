From: Willem de Bruijn <willemb@google.com>
Subject: Re: [PATCH net-next v2 1/8] net-timestamp: explicit SO_TIMESTAMPING
 ancillary data struct
Date: Fri, 18 Jul 2014 11:54:12 -0400
Message-ID: <CA+FuTSc-0oEi7vB8w6s55xtzFd+74o-f8qW-AUk8j7JqneKgqA@mail.gmail.com>
References: <1404416380-3545-1-git-send-email-willemb@google.com>
 <1404416380-3545-2-git-send-email-willemb@google.com> <20140705201007.GC3869@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	richardcochran@gomail.com,
	Stephen Hemminger <stephen@networkplumber.org>
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vc0-f171.google.com ([209.85.220.171]:35162 "EHLO
	mail-vc0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756781AbaGRPyn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Jul 2014 11:54:43 -0400
Received: by mail-vc0-f171.google.com with SMTP id hq11so6146098vcb.2
        for <netdev@vger.kernel.org>; Fri, 18 Jul 2014 08:54:43 -0700 (PDT)
In-Reply-To: <20140705201007.GC3869@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Jul 5, 2014 at 4:10 PM, Richard Cochran
<richardcochran@gmail.com> wrote:
> On Thu, Jul 03, 2014 at 03:39:33PM -0400, Willem de Bruijn wrote:
>
>> +struct scm_timestamping {
>> +     struct timespec ts[3];
>> +};
>> +
>> +#define SCM_TSTAMP_SND               0x1     /* driver passed skb to NIC */
>> +#define SCM_TSTAMP_ACK               0x2     /* transport layer saw ACK */
>> +#define SCM_TSTAMP_ENQ               0x4     /* stack passed skb to TC layer */
>> +#define SCM_TSTAMP_RCV               0x8     /* stack received skb */
>> +#define SCM_TSTAMP_HWSYS     0x10    /* NIC tstamp in system format */
>> +#define SCM_TSTAMP_HWRAW     0x20    /* NIC tstamp in native format */
>> +
>> +#define SCM_TSTAMP_OFF(n, ts)        (ts << (10 * n))
>
> Hm ...
>

> So you want ee_info to be a bit field like this?
>
>    | 10 bits    | 10 bits    | 10 bits    | 2 bits |
>    |------------+------------+------------+--------|
>    | ts[0] type | ts[1] type | ts[2] type | rsv    |
>
> Why not simplify this into two fields:
>
> 1. the index ts[] that contains a time stamp
> 2. the type of the time stamp
>
> The kernel never provides more than one value in ts[], and it is hard
> to imagine that we will ever do this. The original so_timestamping
> interface and documentation seem to suggest that multiple values are
> possible, but there was never, ever any code that did this. As an end
> user, I found that very confusing.
>
> I would prefer making the extended interface simpler, rather than
> giving the impression that multiple time stamps are possible when they
> really are not.

Agreed. I have a simpler patchset ready where ee_info only
defines contents of ts[0] and the SCM fields are just an enum.

Before I send the entire patchset again, I plan to simplify two
other parts if no one objects.

1. only one MSG_TSTAMP send() flag.

The socket flag space is limited, so defining a flag for
each type of timestamp is not practical. Instead, define one flag
MSG_TSTAMP that generates all timestamps by default. The
default can be overridden at the socket level with timestamping
option fields such as SOF_TIMESTAMPING_ENQ_SOFTWARE.

2. correlate tstamps with data

If multiple datagrams are in flight, it is ambiguous to which
datagram a timestamp refers. The payload is looped with the
timestamp, but content-based correlation can be expensive,
even impossible.

My previous patch addressed this for TCP only, by passing
a seqno in ee_data. That has issues of its own. For one, with
write_seq at send time not know to the process, it is still hard
to correlate. I am going to remove that.

Returning a counter in ee_data to distinguish tstamps from
successive send(.., MSG_TSTAMP) calls allows correlation.
Better is if it works for all protocols. An explicit per-sk counter
+ per-skb id field would require scarce skb space. Instead.
I plan to just loop skb->mark and leave it to the application to
choose marks wisely.
