From: Yuchung Cheng <ycheng@google.com>
Subject: Re: [PATCH net-next] tcp: remove cwnd moderation after recovery
Date: Wed, 30 Mar 2016 13:20:31 -0700
Message-ID: <CAK6E8=d61AbL+-E6_kyiwAe3ByXt4CU3DuHAmC5aH7DY11+yiQ@mail.gmail.com>
References: <1459296952-12214-1-git-send-email-ycheng@google.com> <20160329173545.5fe0ae8b@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Matt Mathis <mattmathis@google.com>,
	Neal Cardwell <ncardwell@google.com>,
	Soheil Hassas Yeganeh <soheil@google.com>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f49.google.com ([74.125.82.49]:33060 "EHLO
	mail-wm0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754016AbcC3UVM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Mar 2016 16:21:12 -0400
Received: by mail-wm0-f49.google.com with SMTP id r72so114233395wmg.0
        for <netdev@vger.kernel.org>; Wed, 30 Mar 2016 13:21:11 -0700 (PDT)
In-Reply-To: <20160329173545.5fe0ae8b@xeon-e3>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 29, 2016 at 5:35 PM, Stephen Hemminger
<stephen@networkplumber.org> wrote:
> On Tue, 29 Mar 2016 17:15:52 -0700
> Yuchung Cheng <ycheng@google.com> wrote:
>
>> For non-SACK connections, cwnd is lowered to inflight plus 3 packets
>> when the recovery ends. This is an optional feature in the NewReno
>> RFC 2582 to reduce the potential burst when cwnd is "re-opened"
>> after recovery and inflight is low.
>>
>> This feature is questionably effective because of PRR: when
>> the recovery ends (i.e., snd_una == high_seq) NewReno holds the
>> CA_Recovery state for another round trip to prevent false fast
>> retransmits. But if the inflight is low, PRR will overwrite the
>> moderated cwnd in tcp_cwnd_reduction() later.
>>
>> On the other hand, if the recovery ends because the sender
>> detects the losses were spurious (e.g., reordering). This feature
>> unconditionally lowers a reverted cwnd even though nothing
>> was lost.
>>
>> By principle loss recovery module should not update cwnd. Further
>> pacing is much more effective to reduce burst. Hence this patch
>> removes the cwnd moderation feature.
>>
>> Signed-off-by: Matt Mathis <mattmathis@google.com>
>> Signed-off-by: Neal Cardwell <ncardwell@google.com>
>> Signed-off-by: Soheil Hassas Yeganeh <soheil@google.com>
>
> I have a concern that this might break Linux builtin protection
> against hostile receiver sending bogus ACK's.  Remember Linux is
> different than NewReno. You are changing something that has existed for
> a long long time.

I suppose the bogus ACKs are ACKs acking future but in-flight data
packets. The most bogus ACK would ack at most SND.NXT otherwise it
will be filtered early in tcp_ack(). Then cwnd_moderation() will pull
cwnd down to inflight + maxburst = 0 + 3 = 3. But immediately
afterward tcp_cwnd_reduction() will over-write cwnd = inflight +
sndcnt =~ 0 + newly_acked_sacked.

w/o pacing, such a bogus ACK can at most induce a burst of a window
(minus 3 dupacks). Restart after (short) idle or receiving stretched
ACKs can induce the same degree of behavior. More importantly the cwnd
moderation is already a NOP b/c cwnd is over-written by the PRR,
regardless of this patch. If the receiver's intention is to speed up
recovery, he is risking reliability w/ future ACKs. if the sole
intention is network abuse then he unlikely would bother to trigger
recovery and congestion control reactions in the first place.

I will update the commit message regarding your concern. Thanks.
