From: Vlad Yasevich <vyasevich@gmail.com>
Subject: Re: [PATCH] net/sctp: Validate parameter size for SCTP_GET_ASSOC_STATS
 control message
Date: Wed, 27 Feb 2013 15:37:05 -0500
Message-ID: <512E6E71.2080007@gmail.com>
References: <1361994231-5355-1-git-send-email-linux@roeck-us.net> <20130227200931.GB7993@hmsreliant.think-freely.org> <20130227202255.GA31830@roeck-us.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Neil Horman <nhorman@tuxdriver.com>, netdev@vger.kernel.org,
	linux-sctp@vger.kernel.org, Sridhar Samudrala <sri@us.ibm.com>,
	"David S. Miller" <davem@davemloft.net>
To: Guenter Roeck <linux@roeck-us.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vc0-f171.google.com ([209.85.220.171]:37894 "EHLO
	mail-vc0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753758Ab3B0UhK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Feb 2013 15:37:10 -0500
In-Reply-To: <20130227202255.GA31830@roeck-us.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/27/2013 03:22 PM, Guenter Roeck wrote:
> On Wed, Feb 27, 2013 at 03:09:31PM -0500, Neil Horman wrote:
>> On Wed, Feb 27, 2013 at 11:43:51AM -0800, Guenter Roeck wrote:
>>> Building sctp may fail with:
>>>
>>> In function =E2=80=98copy_from_user=E2=80=99,
>>>      inlined from =E2=80=98sctp_getsockopt_assoc_stats=E2=80=99 at
>>>      net/sctp/socket.c:5656:20:
>>> arch/x86/include/asm/uaccess_32.h:211:26: error: call to
>>>      =E2=80=98copy_from_user_overflow=E2=80=99 declared with attrib=
ute error: copy_from_user()
>>>      buffer size is not provably correct
>>>
>>> if built with W=3D1 due to a missing parameter size validation.
>>>
>>> Signed-off-by: Guenter Roeck <linux@roeck-us.net>
>>> ---
>>>   net/sctp/socket.c |    2 ++
>>>   1 file changed, 2 insertions(+)
>>>
>>> diff --git a/net/sctp/socket.c b/net/sctp/socket.c
>>> index cedd9bf..0a5f2bf 100644
>>> --- a/net/sctp/socket.c
>>> +++ b/net/sctp/socket.c
>>> @@ -5652,6 +5652,8 @@ static int sctp_getsockopt_assoc_stats(struct=
 sock *sk, int len,
>>>   	/* User must provide at least the assoc id */
>>>   	if (len < sizeof(sctp_assoc_t))
>>>   		return -EINVAL;
>>> +	if (len > sizeof(struct sctp_assoc_stats))
>>> +		len =3D sizeof(struct sctp_assoc_stats);
>>>
>>>   	if (copy_from_user(&sas, optval, len))
>>>   		return -EFAULT;
>>> --
>>> 1.7.9.7
>>>
>>>
>>
>> Theres more than that going on here.  This will fix the warning, but=
 the
>> function is written such that, if you pass in a size that is greater=
 than the
>> size of a struct sctp_association, but less than a struct sctp_assoc=
_stats.  I'm
>> not sure that a partial stat struct is really that useful to people.=
  What if
>> you were to check for max(struct sctp_association, struct sctp_assoc=
_stats) as
>> your minimum length check, then just did a copy_from_user of that le=
ngth.  It
>> would save you having to compute two lengths separately, since you c=
ould then
>> just do a copy_to_user(...,sizeof(struct sctp_assoc_stats), at the b=
ottom of
>> that function.
>>
> Yes, but that would require input from someone who knows the code. Al=
l I am trying
> to accomplish is to ensure that copy_from_user does not overwrite the=
 stack.
>

The function already has the following in it:

	/* Allow the struct to grow and fill in as much as possible */
         len =3D min_t(size_t, len, sizeof(sas));


It would be better to move that up to before the copy_from_user.
The alternative would be to do:
	if (copy_from_user(&sas, optval, sizeof(sctp_assoc_t))

since all we are after here is an association id and nothing else.

-vlad

> Thanks,
> Guenter
>
