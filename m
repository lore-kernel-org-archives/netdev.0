From: Xufeng Zhang <xufeng.zhang@windriver.com>
Subject: Re: [PATCH] sctp: Fix sk_ack_backlog wrap-around problem
Date: Thu, 12 Jun 2014 09:38:58 +0800
Message-ID: <539904B2.6010805@windriver.com>
References: <1402454244-8427-1-git-send-email-xufeng.zhang@windriver.com> <539851DF.3070808@gmail.com> <53988A03.4090801@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <nhorman@tuxdriver.com>, <davem@davemloft.net>,
	<linux-sctp@vger.kernel.org>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>
To: Vlad Yasevich <vyasevich@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <53988A03.4090801@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 06/12/2014 12:55 AM, Vlad Yasevich wrote:
> On 06/11/2014 08:55 AM, Vlad Yasevich wrote:
>    
>> On 06/10/2014 10:37 PM, Xufeng Zhang wrote:
>>      
>>> Consider the scenario:
>>> For a TCP-style socket, while processing the COOKIE_ECHO chunk in
>>> sctp_sf_do_5_1D_ce(), after it has passed a series of sanity check,
>>> a new association would be created in sctp_unpack_cookie(), but afterwards,
>>> some processing maybe failed, and sctp_association_free() will be called to
>>> free the previously allocated association, in sctp_association_free(),
>>> sk_ack_backlog value is decremented for this socket, since the initial
>>> value for sk_ack_backlog is 0, after the decrement, it will be 65535,
>>> a wrap-around problem happens, and if we want to establish new associations
>>> afterward in the same socket, ABORT would be triggered since sctp deem the
>>> accept queue as full.
>>> Fix this issue by only decrementing sk_ack_backlog for associations in
>>> the endpoint's list.
>>>
>>> Fix-suggested-by: Neil Horman<nhorman@tuxdriver.com>
>>> Signed-off-by: Xufeng Zhang<xufeng.zhang@windriver.com>
>>> ---
>>>   net/sctp/associola.c |    2 +-
>>>   1 files changed, 1 insertions(+), 1 deletions(-)
>>>
>>> diff --git a/net/sctp/associola.c b/net/sctp/associola.c
>>> index 39579c3..60564f2 100644
>>> --- a/net/sctp/associola.c
>>> +++ b/net/sctp/associola.c
>>> @@ -330,7 +330,7 @@ void sctp_association_free(struct sctp_association *asoc)
>>>   	/* Only real associations count against the endpoint, so
>>>   	 * don't bother for if this is a temporary association.
>>>   	 */
>>> -	if (!asoc->temp) {
>>> +	if (!asoc->temp&&  !list_empty(&asoc->asocs)) {
>>>   		list_del(&asoc->asocs);
>>>
>>>   		/* Decrement the backlog value for a TCP-style listening
>>>
>>>        
>> I am not crazy about this patch.   It's been suggested before that may
>> be duplicate cookie processing should really be creating a temporary
>> association since that's is how that association is being used.
>>      
> I had another look at the description for triggering this issue and
> realized that I was thinking about something else when looking at
> this solution.
>
> There is however no need to test both the list and temp value.
> We can simply always test the that list is not empty before doing
> list_del().
>    

Thanks a lot for the comment!
I'll send V2 later.


Thanks,
Xufeng


> -vlad
>
>    
>>   It
>> might be nice at that approach.  It actually benefits us as the
>> association destruction would happen immediately instead of being delayed.
>>      
>
>    
