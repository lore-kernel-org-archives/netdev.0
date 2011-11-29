From: Vladislav Yasevich <vladislav.yasevich@hp.com>
Subject: Re: [PATCH] sctp: integer overflow in sctp_auth_create_key()
Date: Tue, 29 Nov 2011 10:03:04 -0500
Message-ID: <4ED4F428.9030807@hp.com>
References: <426D7BA8-ECD0-44D6-A09F-2033F0C825FC@gmail.com> <4ED3AC7D.6090108@hp.com> <147F953A-CC69-41FF-ACD4-64E5E2956411@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, Sridhar Samudrala <sri@us.ibm.com>,
	"David S. Miller" <davem@davemloft.net>,
	linux-sctp@vger.kernel.org, netdev@vger.kernel.org,
	security@kernel.org
To: Xi Wang <xi.wang@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0017.houston.hp.com ([15.201.24.20]:48088 "EHLO
	g4t0017.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753466Ab1K2PDK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Nov 2011 10:03:10 -0500
In-Reply-To: <147F953A-CC69-41FF-ACD4-64E5E2956411@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/29/2011 02:33 AM, Xi Wang wrote:
> I agree that this is not a security issue if key_len can never get large.
> 
> So how about just removing the overflow check at all?

That should be ok as well.  There is an overflow guard in the api
entry point so that should guard against overflows from user space.

On the network end I miscalculated a little.  The key is actually made up
of user_key (1 short) + 2 * key_vector (3 shorts) for a total of 7*MAX_USHORT;
however, that still will not overflow 32 bits.

-vlad

> 
> - xi
> 
> On Nov 28, 2011, at 10:45 AM, Vladislav Yasevich wrote:
>>
>> Hmm.  Yes, this is a more correct check.
>>
>> Acked-by: Vlad Yasevich <vladislav.yasevich@hp.com>
>>
>>
>> However, I don't think this is a security issue.  As I've written before, this function is
>> called from 2 places:
>>
>>  1) setsockopt() code path
>>
>>  2) sctp_auth_asoc_set_secret() code path
>>
>> In case (1), sca_keylength is never going to exceed 65535 since it's
>> bounded by a u16 from the user api.  As such, The integer promotion will
>> not impact anything and the malloc() will never overflow.
>>
>> In case (2), sca_keylength is computed based on the key the user provided
>> (MAX_USHORT) and the combination of protocol negotiated data where that
>> combination has a max size of 3 * MAX_USHORT (see sctp_auth_make_key_vector()).
>> So, even this case, our maximum key length can be 4* MAX_USHORT which still
>> will always be below MAX_INT and will not overflow.
>>
>> So, I don't think there is big security consideration here, just a bad
>> check that just happens to always work.
>>
>> -vlad
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-sctp" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
