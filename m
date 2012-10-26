From: Vlad Yasevich <vyasevich@gmail.com>
Subject: Re: [PATCH net-next] sctp: support per-association stats via a new
 SCTP_GET_ASSOC_STATS call
Date: Fri, 26 Oct 2012 15:16:48 -0400
Message-ID: <508AE1A0.4090100@gmail.com>
References: <1351258973-17227-1-git-send-email-michele@acksyn.org> <20121026143704.GC25087@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Michele Baldessari <michele@acksyn.org>,
	linux-sctp@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Thomas Graf <tgraf@suug.ch>
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f174.google.com ([209.85.216.174]:56093 "EHLO
	mail-qc0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S966119Ab2JZTQ6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Oct 2012 15:16:58 -0400
In-Reply-To: <20121026143704.GC25087@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/26/2012 10:37 AM, Neil Horman wrote:
> On Fri, Oct 26, 2012 at 03:42:53PM +0200, Michele Baldessari wrote:
>> The current SCTP stack is lacking an API to have per association
>> statistics. This is a kernel implementation modeled after OpenSolaris'
>> SCTP_GET_ASSOC_STATS.
>>
>> Userspace part will follow on lksctp if/when there is a general ACK on this.
>>
>> Signed-off-by: Michele Baldessari <michele@acksyn.org>
>> Acked-by: Thomas Graf <tgraf@suug.ch>
>> ---
>>   include/net/sctp/sctp.h    |  3 +++
>>   include/net/sctp/structs.h | 39 +++++++++++++++++++++++++++
>>   include/net/sctp/user.h    | 26 ++++++++++++++++++
>>   net/sctp/associola.c       | 20 ++++++++++++++
>>   net/sctp/endpointola.c     |  5 +++-
>>   net/sctp/input.c           |  5 ++--
>>   net/sctp/output.c          |  5 ++++
>>   net/sctp/outqueue.c        | 12 +++++++++
>>   net/sctp/sm_sideeffect.c   |  2 ++
>>   net/sctp/sm_statefuns.c    | 12 +++++++--
>>   net/sctp/socket.c          | 67 ++++++++++++++++++++++++++++++++++++++++++++++
>>   net/sctp/transport.c       |  2 ++
>>   12 files changed, 193 insertions(+), 5 deletions(-)
>>
> We already have files in /proc/net/sctp to count snmp system-wide totals,
> per-endpoint totals, and per association totals.  Why do these stats differently
> instead of just adding them the per-association file?  I get that solaris does
> this, but its not codified in any of the RFC's or other standards.  I would
> really rather see something like this go into the interfaces we have, rather
> than creating a new one.
>
> I also am a bit confused regarding the stats themselves.  Most are fairly clear,
> but some seem lacking (you count most things sent and received, but only count
> received gap acks).  Others seems vague and or confusing (when counting
> retransmitted chunks and packets, how do you count a packet that has both new
> and retransmitted chunks)?  And the max observed rto stat is just odd.  Each
> transport has an rto value, not each association, and you cal already see the
> individual transport rto values in /proc/net/sctp/remaddr.
>
>
>> +
>> +	/* Gap Ack Blocks received */
>> +	__u64 gapcnt;
>> +
> No gapcnt for sent gap ack blocks?
>
>>   		unsigned long timeout;
>> diff --git a/net/sctp/outqueue.c b/net/sctp/outqueue.c
>> index 1b4a7f8..569ee3a 100644
>> --- a/net/sctp/outqueue.c
>> +++ b/net/sctp/outqueue.c
>> @@ -667,6 +667,8 @@ redo:
>>   				chunk->fast_retransmit = SCTP_DONT_FRTX;
>>
>>   			q->empty = 0;
>> +			if (q->asoc)
>> +				q->asoc->rtxchunks++;
>>   			break;
>>   		}
>>
>> @@ -678,6 +680,10 @@ redo:
>>   			break;
>>   	}
>>
>> +	if (q->asoc)
>> +		q->asoc->rtxpackets++;
>> +
>> +
> This seems incorrect to me.  The packet being assembled here may have new chunks
> in it (either control or data).  Counting a packet as being retransmitted just
> because it has a retransmitted chunk in it seems wrong.  At the very least its a
> misleading/vague statistic.

Agreed

-vlad

>>   			break;
>> diff --git a/net/sctp/sm_statefuns.c b/net/sctp/sm_statefuns.c
>> index b6adef8..4f94432 100644
>> --- a/net/sctp/sm_statefuns.c
>> +++ b/net/sctp/sm_statefuns.c
>> @@ -6127,9 +6127,13 @@ static int sctp_eat_data(const struct sctp_association *asoc,
>>   		/* The TSN is too high--silently discard the chunk and
>>   		 * count on it getting retransmitted later.
>>   		 */
>> +		if (chunk->asoc)
>> +			chunk->asoc->outseqtsns++;
> This just seems wrong.  The definition states that this is counting the last TSN
> recevied (despite being name outseqtsns), yet this looks like you're:
> 1) just incrementing a counter, rather than recording the TSN value itself
> (which may or may not be what you meant, but seems to contradict what the
> comments at the definition)
> 2) Only incremanting it if the TSN is out of range, which makes very little
> sense to me.
>
>>
