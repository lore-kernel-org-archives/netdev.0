From: Willem de Bruijn <willemb@google.com>
Subject: Re: [PATCH net-next v2] packet: tx timestamping on tpacket ring
Date: Sun, 21 Apr 2013 12:42:45 -0400
Message-ID: <CA+FuTSc9ikN6gOsnKjM4Gv-2M+W-_jwijW4Wy=_RLLuRxoJw9A@mail.gmail.com>
References: <CA+FuTSdGdhgpRARbv9zFnDESzCQBzT=DS-WgGZRWBLBvhN_sNg@mail.gmail.com>
 <1366408317-16432-1-git-send-email-willemb@google.com> <51728B32.4040200@redhat.com>
 <CA+FuTSckxSB-rDFVJbbWdxX=5HfNoD4vwkeHy71Ab2cam8wpGQ@mail.gmail.com> <5173BB0F.90900@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	Paul Chavent <paul.chavent@onera.fr>,
	Richard Cochran <richardcochran@gmail.com>
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f171.google.com ([209.85.223.171]:54025 "EHLO
	mail-ie0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753249Ab3DUQnR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 21 Apr 2013 12:43:17 -0400
Received: by mail-ie0-f171.google.com with SMTP id e11so6338880iej.30
        for <netdev@vger.kernel.org>; Sun, 21 Apr 2013 09:43:16 -0700 (PDT)
In-Reply-To: <5173BB0F.90900@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Apr 21, 2013 at 6:10 AM, Daniel Borkmann <dborkman@redhat.com> wrote:
> On 04/21/2013 04:30 AM, Willem de Bruijn wrote:
>>
>> On Sat, Apr 20, 2013 at 8:33 AM, Daniel Borkmann <dborkman@redhat.com>
>> wrote:
>
> [..]
>>>
>>> On 04/19/2013 11:51 PM, Willem de Bruijn wrote:
>>> If we currently have the po->tp_tstamp member that was introduced for the
>>> RX_RING
>>> part only, using it if possible for the TX_RING part as well would be
>>> good,
>>> at
>>> least cleaner.
>>
>>
>> Then the caller has to set both the SOL_SOCKET and SOL_PACKET
>> options. I'm not convinced that that is an improvement over using generic
>> socket tx timestamping option as is. How would you use it specifically?
>> To determine whether or not to write the values into the ring, or more
>> extensively?
>
>
> I would use it in combination with tpacket_get_timestamp(). There, we do not
> check for SOCK_TIMESTAMPING_SOFTWARE, but just fall back for skb->tstamp if
> not null. The tpacket_get_timestamp() would need a small change though, in
> that sense that i) getnstimeofday() is moved out of the function and ii) the
> function will return a bool, if the ts variable was filled. Thus, in the RX
> path if the function returns false, you do getnstimeofday() as fallback, and
> in the TX path nothing needs to be done in __packet_set_timestamp() if the
> skb
> was not timestamped.
>
> That said, for the software timestamps, the caller would not need to do more
> as with your current patch, for the hardware part, it's then the same afaik
> as in the RX_RING.
>
> Just to give some pseudo code (instead of the bool, we could also use an
> enum
> that tells which timestamp was found, but more on that further below):
>
> static bool tpacket_get_timestamp(struct sk_buff *skb, struct timespec *ts,
>                                   unsigned int flags)
> {
>         struct skb_shared_hwtstamps *shhwtstamps = skb_hwtstamps(skb);
>
>         if (shhwtstamps) {
>                 if ((flags & SOF_TIMESTAMPING_SYS_HARDWARE) &&
>                     ktime_to_timespec_cond(shhwtstamps->syststamp, ts))
>                         return true;
>                 if ((flags & SOF_TIMESTAMPING_RAW_HARDWARE) &&
>                     ktime_to_timespec_cond(shhwtstamps->hwtstamp, ts))
>                         return true;
>         }
>
>         if (ktime_to_timespec_cond(skb->tstamp, ts))
>                 return true;
>
>         return false;
> }
>
> In tpacket_rcv():
> ...
>         if (!tpacket_get_timestamp(skb, &ts, po->tp_tstamp))
>                 getnstimeofday(ts);
> ...
>
> In __packet_set_timestamp():
> ...
>         if (!tpacket_get_timestamp(skb, &ts, po->tp_tstamp))
>                 return;
> ...
>
>
>>> Also the documentation [1] should receive a status update on
>>> this
>>> feature, otherwise only Paul will use this feature and nobody else.
>>
>>
>> Okay. I'll update the documentation. Speaking of which, it would be
>> great if someone could proofread the packet socket manpage update
>> patch (http://patchwork.ozlabs.org/patch/228709/)
>
>
> Ok, I will have a look.

Saw your ack. Thanks, Daniel!
>
>>> Not an expert in timestamping, but why can't we also allow hw timestamps
>>> but
>>> have
>>> to use sw only?
>>
>>
>> To avoid getting into the same situation on tx that Richard pointed out
>> about rx: the ring can only communicate one timestamp and cannot
>> communicate which one it is. Better to be consistent in that case, I
>> think. I'm open to discussing this, though.
>
>
> Ok, I agree that it would be very useful to also state what timestamp is
> being reported. Ideally, without introducing yet another tpacket version.
>
> The only thing I can currently think of could be to use the tp_status bit
> for that, then used by both RX_RING and TX_RING, e.g. ...
>
>         TP_STATUS_TS_SYS_HARDWARE       (1 << 30)
>         TP_STATUS_TS_RAW_HARDWARE       (1 << 31)
>
> ... although it would be a bit of waste to use 2 bits for that. If none of
> them is set, it indicates that the timestamp is in software-only. This we
> could do, if you don't have a better idea.

I like that a lot. Visibility would certainly improve the state on
rx-ring side. One issue with interleaving various kinds of timestamps,
even when clearly labeled in tp_status, is that applications likely
cannot use timestamp series from different sources, as these sequences
are incomparable. Tx has the advantage that time sources can be chosen
per socket independent of all other sockets. The only time when
multiple sources come into play is when a socket has hw timestamps
selected, but the hardware failed to create a tstamp for some
device-specific reason. In that case, generating the sw timestamp may
or may not be helpful to the application. When at least it is clearly
labeled in tp_status, worst case the application will simply ignore
it. If the application only selects software timestamps, the mechanism
works just like what I proposed: always communicate the software
timestamp and do not modify tp_status. So, I'd say this is a clear
win. Since it is a strict superset, how about I send the current patch
as is (with extra documentation) and you submit the hw tstamp support
+ labels separately?

> ``Better to be consistent in that case'' would not be the current situation
> with the patch, right? I mean, for RX_RING, we report one of those 3, for
> TX_RING only the sw timestamp. So on one hand we might be consistent, but on
> the other hand we're not. ;-) With the above proposal, we could tackle this
> and stay consistent then. If you want, I could do that after your revised
> patch gets accepted (with hw ts support). Let me know what you think of
> that.
