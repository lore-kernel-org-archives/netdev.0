From: Xufeng Zhang <xufengzhang.main@gmail.com>
Subject: Re: [PATCH] sctp: don't break the loop while meeting the active_path
 so as to find the matched transport
Date: Mon, 11 Mar 2013 10:14:50 +0800
Message-ID: <CA+=dFzjyd4av9D1TmrvguRXv-V7JnGWYJcN=ZEDu8Qhz2s+U7Q@mail.gmail.com>
References: <1362728377-11025-1-git-send-email-xufeng.zhang@windriver.com>
	<20130308142720.GA9873@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Xufeng Zhang <xufeng.zhang@windriver.com>, vyasevich@gmail.com,
	davem@davemloft.net, linux-sctp@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130308142720.GA9873@hmsreliant.think-freely.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 3/8/13, Neil Horman <nhorman@tuxdriver.com> wrote:
> On Fri, Mar 08, 2013 at 03:39:37PM +0800, Xufeng Zhang wrote:
>> sctp_assoc_lookup_tsn() function searchs which transport a certain TSN
>> was sent on, if not found in the active_path transport, then go search
>> all the other transports in the peer's transport_addr_list, however, we
>> should continue to the next entry rather than break the loop when meet
>> the active_path transport.
>>
>> Signed-off-by: Xufeng Zhang <xufeng.zhang@windriver.com>
>> ---
>>  net/sctp/associola.c |    2 +-
>>  1 files changed, 1 insertions(+), 1 deletions(-)
>>
>> diff --git a/net/sctp/associola.c b/net/sctp/associola.c
>> index 43cd0dd..d2709e2 100644
>> --- a/net/sctp/associola.c
>> +++ b/net/sctp/associola.c
>> @@ -1079,7 +1079,7 @@ struct sctp_transport *sctp_assoc_lookup_tsn(struct
>> sctp_association *asoc,
>>  			transports) {
>>
>>  		if (transport == active)
>> -			break;
>> +			continue;
>>  		list_for_each_entry(chunk, &transport->transmitted,
>>  				transmitted_list) {
>>  			if (key == chunk->subh.data_hdr->tsn) {
>> --
>> 1.7.0.2
>>
>>
>
> This works, but what might be better would be if we did a move to front
> heuristic in sctp_assoc_set_primary.  E.g. when we set the active_path, move
> the
> requisite transport to the front of the transport_addr_list.  If we did
> that,
> then we could just do one for loop in sctp_assoc_lookup_tsn and wind up
> implicitly check the active path first without having to check it seprately
> and
> skip it in the second for loop.

Thanks for your review, Neil!

I know what you mean, yes, it's most probably that the searched TSN was
transmitted in the currently active_path, but what should we do if not.

Check the comment in sctp_assoc_lookup_tsn() function:
/* Let's be hopeful and check the active_path first. */
/* If not found, go search all the other transports. */

It has checked the active_path first and then traverse all the other
transports in
the transport_addr_list except the active_path.

So what I want to fix here is the inconsistency between the function
should do and
the code actually does.



Thanks,
Xufeng


>
> Neil
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
>
