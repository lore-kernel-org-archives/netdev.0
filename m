From: Yuchung Cheng <ycheng@google.com>
Subject: Re: tcp: multiple ssthresh reductions before all packets are retransmitted
Date: Mon, 16 Jun 2014 12:04:37 -0700
Message-ID: <CAK6E8=dwh1btNzX80YNre9u7rS+SgochXxHxDhQYQZCvY8yVMQ@mail.gmail.com>
References: <20140616153515.GA4907@unicorn.suse.cz> <CAK6E8=cFnDut3xYhNqHkhV9FNXkuTtrT=iB19Way80A43LAXwQ@mail.gmail.com>
 <20140616174721.GA15406@lion>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>
To: Michal Kubecek <mkubecek@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f176.google.com ([209.85.223.176]:59043 "EHLO
	mail-ie0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751127AbaFPTFS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Jun 2014 15:05:18 -0400
Received: by mail-ie0-f176.google.com with SMTP id rd18so5482275iec.35
        for <netdev@vger.kernel.org>; Mon, 16 Jun 2014 12:05:17 -0700 (PDT)
In-Reply-To: <20140616174721.GA15406@lion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jun 16, 2014 at 10:47 AM, Michal Kubecek <mkubecek@suse.cz> wrote:
> On Mon, Jun 16, 2014 at 10:02:08AM -0700, Yuchung Cheng wrote:
>> On Mon, Jun 16, 2014 at 8:35 AM, Michal Kubecek <mkubecek@suse.cz> wrote:
>> >
>> > RFC 5681 says that ssthresh reduction in response to RTO should be done
>> > only once and should not be repeated until all packets from the first
>> > loss are retransmitted. RFC 6582 (as well as its predecessor RFC 3782)
>> > is even more specific and says that when loss is detected, one should
>> > mark current SND.NXT and ssthresh shouldn't be reduced again due to
>> > a loss until SND.UNA reaches this remembered value.
>> >
>> > Linux implementation does exactly that but in TCP_CA_Loss state,
>> > tcp_enter_loss() also takes icsk_retransmits into account:
>> >
>> >         /* Reduce ssthresh if it has not yet been made inside this window. */
>> >         if (icsk->icsk_ca_state <= TCP_CA_Disorder ||
>> >             !after(tp->high_seq, tp->snd_una) ||
>> >             (icsk->icsk_ca_state == TCP_CA_Loss && !icsk->icsk_retransmits)) {
>> >                 new_recovery = true;
>> >                 tp->prior_ssthresh = tcp_current_ssthresh(sk);
>> >                 tp->snd_ssthresh = icsk->icsk_ca_ops->ssthresh(sk);
>> >                 tcp_ca_event(sk, CA_EVENT_LOSS);
>> >         }
>> >
>> > This seems correct as icsk_retransmits is supposed to mean "we still
>> > have packets to retransmit". But icsk_retransmits is reset in
>> > tcp_process_loss() if one of two conditions is satisfied:
>>
>> icsk_retransmits indicates the number of recurring timeouts (of the
>> same sequence). so it is reset when the recovery is done or SND_UNA is
>> advanced. the variable name however is confusing.
>
> In that case, I suppose the problem would be this part
>
>     (icsk->icsk_ca_state == TCP_CA_Loss && !icsk->icsk_retransmits)
>
> of the condition above (in tcp_enter_loss()). As that would mean we
> would allow further ssthresh reduction as soon as SND.UNA moves forward
> (not when it reaches high_seq).

Nice catch. That check is incorrect and should be removed. I have used
packetdrill to verify it fixes the ssthresh problem.

`../common/defaults.sh`

0.000 socket(..., SOCK_STREAM, IPPROTO_TCP) = 3
   +0 setsockopt(3, SOL_SOCKET, SO_REUSEADDR, [1], 4) = 0
   +0 bind(3, ..., ...) = 0
   +0 listen(3, 1) = 0

   +0 < S 0:0(0) win 32792 <mss 1000,sackOK,nop,nop,nop,wscale 7>
   +0 > S. 0:0(0) ack 1 <mss 1460,nop,nop,sackOK,nop,wscale 6>

+.020 < . 1:1(0) ack 1 win 257
   +0 accept(3, ..., ...) = 4
   +0 write(4, ..., 11000) = 11000
   +0 > . 1:10001(10000) ack 1

// TLP (is dropped too)
+.040 > P. 10001:11001(1000) ack 1

// RTO and retransmit head, SST is set
+.221 > . 1:1001(1000) ack 1
   +0 %{ sst = tcpi_snd_ssthresh }%

+.020 < . 1:1(0) ack 1001 win 257
   +0 > . 1001:2001(1000) ack 1
   +0 > . 2001:3001(1000) ack 1

+.020 < . 1:1(0) ack 2001 win 257
   +0 > . 3001:4001(1000) ack 1
   +0 > . 4001:5001(1000) ack 1

// Another timeout during recovery. Check SST remains the same
+.020 < . 1:1(0) ack 2001 win 257
+.421 > . 2001:3001(1000) ack 1
   +0 %{ assert tcpi_snd_ssthresh == sst }%

+.020 < . 1:1(0) ack 3001 win 257
   +0 > . 3001:4001(1000) ack 1
   +0 > . 4001:5001(1000) ack 1

+.020 < . 1:1(0) ack 5001 win 257
   +0 > . 5001:6001(1000) ack 1
   +0 > . 6001:7001(1000) ack 1
   +0 > . 7001:8001(1000) ack 1
   +0 > . 8001:9001(1000) ack 1

+.020 < . 1:1(0) ack 9001 win 257
   +0 > . 9001:10001(1000) ack 1
   +0 > P. 10001:11001(1000) ack 1

// Recovery is done. Check SST remains the same
+0.20 < . 1:1(0) ack 11001 win 257
   +0 %{ assert tcpi_snd_ssthresh == sst }%

Do you want to submit a one-liner patch? or I am happy to do that.


>
>> does your suggested change fix the problem you are observing?
>
> It does, with it ssthresh isn't lowered again until all lost packets are
> retransmitted (at which time, cwnd is already reasonably high).
>
>                                                           Michal Kubecek
>
