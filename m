From: Willem de Bruijn <willemb@google.com>
Subject: Re: [PATCH net-next 1/7] net-timestamp: explicit SO_TIMESTAMPING
 ancillary data struct
Date: Wed, 25 Jun 2014 17:18:44 -0400
Message-ID: <CA+FuTSco8-fs--+_esBk4k4S4144xSbh9tv2awWyc+vyT0R9Vg@mail.gmail.com>
References: <1403624632-17327-1-git-send-email-willemb@google.com>
 <1403624632-17327-2-git-send-email-willemb@google.com> <20140625045607.GC3845@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org, Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f179.google.com ([209.85.216.179]:34444 "EHLO
	mail-qc0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755780AbaFYVTP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Jun 2014 17:19:15 -0400
Received: by mail-qc0-f179.google.com with SMTP id x3so2301311qcv.38
        for <netdev@vger.kernel.org>; Wed, 25 Jun 2014 14:19:14 -0700 (PDT)
In-Reply-To: <20140625045607.GC3845@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 25, 2014 at 12:56 AM, Richard Cochran
<richardcochran@gmail.com> wrote:
> On Tue, Jun 24, 2014 at 11:43:46AM -0400, Willem de Bruijn wrote:
>
>> The code is backward compatible with legacy applications that treat
>> the ancillary data as an anonymous array 'struct timespec data[3]'.
>> It will break applications that test the size of the cmsg data.
>
> I think this introduces an unacceptable ABI change.
> In linuxptp we have
>
>                 if (SOL_SOCKET == level && SO_TIMESTAMPING == type) {
>                         if (cm->cmsg_len < sizeof(*ts) * 3) {
>                                 pr_warning("short SO_TIMESTAMPING message");
>                                 return -1;
>                         }
>                         ts = (struct timespec *) CMSG_DATA(cm);
>                 }
>
> but other applications might barf if the length isn't exactly right.

Fair point.

>> +/**
>> + *   struct sock_errqueue_timestamping - timestamps exposed through cmsg
>> + *
>> + *   The timestamping interfaces SO_TIMESTAMPING, MSG_TSTAMP_*
>> + *   communicate network timestamps to userspace by passing this struct
>> + *   through a cmsg in recvmsg().
>> + *
>> + *   @ts_sw:     the sw timestamp: the contents depends on ts_type.
>
> This would overload the field. I don't like that.
>
>> + *   @ts_hw_sys: a hardware generated timestamp converted to system time.
>> + *   @ts_hw_raw: a hardware generated timestamp converted in its raw format.
>> + *   @ts_type:   the type of timestamp ts_sw. One of SCM_TSTAMP_*
>> + *   @ts_key:    socket flow index that the timestamps correspond to
>> + *               (stream transport protocols only, e.g., TCP seqno)
>> + *
>> + *   The first three fields are dictated by historical use. The hardware
>> + *   timestamps are empty unless hardware timestamping is enabled, but
>> + *   they have to be present in each message.
>> + */
>> +struct sock_errqueue_timestamping {
>> +     struct timespec ts_sw;
>> +     struct timespec ts_hw_sys;
>> +     struct timespec ts_hw_raw;
>> +     __u32 ts_key;
>> +     __u16 ts_type;
>> +     __u16 ts_padding;
>> +};
>> +
>> +enum {
>> +     SCM_TSTAMP_SND = 1,
>> +     SCM_TSTAMP_ACK = 2,
>> +     SCM_TSTAMP_ENQ = 3
>> +};
>
> So why not simply introduce a new kind of CMSG for these new time
> stamps? It appears that the use case for these is totally different
> than for SO_TIMESTAMPING. I can't imagine why you would want to mix
> them together.

See also my reply in the patchset cover message (0/7). I do not agree
that the use case for the two interfaces is totally different. Both aim to
return a software timestamp on device transmission, for instance. The
only difference is whether this should occur on every datagram from a
socket or on a per-datagram bases.

Because of the legacy issue you raised, I agree that a new CMSG may
be in order. The simpler solution is to store ts_key and ts_type in
ee_data and ee_info, because these are so far undefined for error
SO_EE_ORIGIN_TIMESTAMPING.

> Thanks,
> Richard
