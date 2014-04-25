From: Vlad Yasevich <vyasevich@gmail.com>
Subject: Re: [PATCH v3 net] net: sctp: Don't transition to PF state when transport
 has exhausted 'Path.Max.Retrans'.
Date: Fri, 25 Apr 2014 13:34:11 -0400
Message-ID: <535A9C93.9090106@gmail.com>
References: <1398445570-11429-1-git-send-email-kheiss@gmail.com> <CAGugRbVRL0Dz0Vc_X0Qu-FjMRPr7OhZtrb+rW-qktt1ji_i44A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: linux-sctp@vger.kernel.org, davem <davem@davemloft.net>,
	Neil Horman <nhorman@tuxdriver.com>
To: Karl Heiss <kheiss@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f173.google.com ([209.85.216.173]:62901 "EHLO
	mail-qc0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752435AbaDYReP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Apr 2014 13:34:15 -0400
In-Reply-To: <CAGugRbVRL0Dz0Vc_X0Qu-FjMRPr7OhZtrb+rW-qktt1ji_i44A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/25/2014 01:21 PM, Karl Heiss wrote:
> On Fri, Apr 25, 2014 at 1:06 PM, Karl Heiss <kheiss@gmail.com> wrote:
>> Don't transition to the PF state on every strike after 'Path.Max.Retrans'.
>> Per draft-ietf-tsvwg-sctp-failover-03 Section 5.1.6:
>>
>>    Additional (PMR - PFMR) consecutive timeouts on a PF destination
>>    confirm the path failure, upon which the destination transitions to the
>>    Inactive state.  As described in [RFC4960], the sender (i) SHOULD notify
>>    ULP about this state transition, and (ii) transmit heartbeats to the
>>    Inactive destination at a lower frequency as described in Section 8.3 of
>>    [RFC4960].
>>
>> This also prevents sending SCTP_ADDR_UNREACHABLE to the user as the state
>> bounces between SCTP_INACTIVE and SCTP_PF for each subsequent strike.
>>
>> Signed-off-by: Karl Heiss <kheiss@gmail.com>
>> ---
>> Changes in v2:
>>   - Flesh out commit message
>>
>> Changes in v3:
>>   - Compare transport state instead of pathmaxrxt
>>
>>  net/sctp/sm_sideeffect.c |    5 +++--
>>  1 files changed, 3 insertions(+), 2 deletions(-)
>>
>> diff --git a/net/sctp/sm_sideeffect.c b/net/sctp/sm_sideeffect.c
>> index 5d6883f..7805623 100644
>> --- a/net/sctp/sm_sideeffect.c
>> +++ b/net/sctp/sm_sideeffect.c
>> @@ -496,11 +496,12 @@ static void sctp_do_8_2_transport_strike(sctp_cmd_seq_t *commands,
>>
>>         /* If the transport error count is greater than the pf_retrans
>>          * threshold, and less than pathmaxrtx, and if the current state
>> -        * is not SCTP_UNCONFIRMED, then mark this transport as Partially
>> -        * Failed, see SCTP Quick Failover Draft, section 5.1
>> +        * is not SCTP_UNCONFIRMED or SCTP_INACTIVE, then mark this transport
>> +        * as Partially Failed, see SCTP Quick Failover Draft, section 5.1
>>          */
>>         if ((transport->state != SCTP_PF) &&
>>            (transport->state != SCTP_UNCONFIRMED) &&
>> +          (transport->state != SCTP_INACTIVE) &&
> 
> On second thought, would this not make more sense to be:
> 
>          if ((transport->state == SCTP_ACTIVE) &&
> 
> Since the only valid transition into PF is from ACTIVE?

Hmm..  we that UNKNOWN state, but it doesn't look like it survives
past the handshake...

So, yes, this would simplify things.

-vlad

> 
>>            (asoc->pf_retrans < transport->pathmaxrxt) &&
>>            (transport->error_count > asoc->pf_retrans)) {
>>
>> --
>> 1.7.1
>>
