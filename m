From: Vlad Yasevich <vyasevic@redhat.com>
Subject: Re: [PATCH] net/sctp: Validate parameter size for SCTP_GET_ASSOC_STATS
 control message
Date: Wed, 27 Feb 2013 15:58:04 -0500
Message-ID: <512E735C.10600@redhat.com>
References: <1361994231-5355-1-git-send-email-linux@roeck-us.net> <20130227.153344.2178498124458359369.davem@davemloft.net>
Reply-To: vyasevic@redhat.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-7;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux@roeck-us.net, netdev@vger.kernel.org,
	linux-sctp@vger.kernel.org, vyasevich@gmail.com, sri@us.ibm.com,
	nhorman@tuxdriver.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:46795 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752599Ab3B0U6X (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Feb 2013 15:58:23 -0500
In-Reply-To: <20130227.153344.2178498124458359369.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/27/2013 03:33 PM, David Miller wrote:
> From: Guenter Roeck <linux@roeck-us.net>
> Date: Wed, 27 Feb 2013 11:43:51 -0800
>
>> Building sctp may fail with:
>>
>> In function =A1copy_from_user=A2,
>>      inlined from =A1sctp_getsockopt_assoc_stats=A2 at
>>      net/sctp/socket.c:5656:20:
>> arch/x86/include/asm/uaccess_32.h:211:26: error: call to
>>      =A1copy_from_user_overflow=A2 declared with attribute error: co=
py_from_user()
>>      buffer size is not provably correct
>>
>> if built with W=3D1 due to a missing parameter size validation.
>>
>> Signed-off-by: Guenter Roeck <linux@roeck-us.net>
>
> This change is correct, but please fix this by simply moving the:
>
> 	/* Allow the struct to grow and fill in as much as possible */
> 	len =3D min_t(size_t, len, sizeof(sas));
>
> line higher up in the function.
>
> And I also prefer this because:
>
> 	something testing sizeof(foo);
> 	if (copy_from_user(..., ..., sizeof(foo)))
>
> must easier to audit and validate, especially in patch form.
>
> Otherwise I have to bring the code into an editor and read the whole
> function just to make sure you got the type correct.

Right.  In this particular case, we are after a very small portion of=20
user data (just the association id) and copying the entire structure is
rather pointless.

A nicer solution here would be to do this:
	 if (copy_from_user(&sas, optval, sizeof(sctp_assoc_t))

We are already guaranteed that much space and we make sure that we don'=
t=20
overwrite the kernel stack.

-vlad
