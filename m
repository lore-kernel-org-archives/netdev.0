From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH] net: af_packet: Validate parameter size for PACKET_HDRLEN
 control message
Date: Wed, 27 Feb 2013 22:18:06 +0100
Message-ID: <512E780E.5050204@redhat.com>
References: <1361994418-1403-1-git-send-email-linux@roeck-us.net> <512E6AF9.3030901@redhat.com> <20130227.152630.35846741651175869.davem@davemloft.net> <20130227203327.GA6113@roeck-us.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Guenter Roeck <linux@roeck-us.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:36665 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751248Ab3B0VSL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Feb 2013 16:18:11 -0500
In-Reply-To: <20130227203327.GA6113@roeck-us.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/27/2013 09:33 PM, Guenter Roeck wrote:
> On Wed, Feb 27, 2013 at 03:26:30PM -0500, David Miller wrote:
>> From: Daniel Borkmann <dborkman@redhat.com>
>> Date: Wed, 27 Feb 2013 21:22:17 +0100
>>
>>> On 02/27/2013 08:46 PM, Guenter Roeck wrote:
>>>> Building af_packet may fail with
>>>>
>>>> In function =E2=80=98copy_from_user=E2=80=99,
>>>>       inlined from =E2=80=98packet_getsockopt=E2=80=99 at
>>>>       net/packet/af_packet.c:3215:21:
>>>> arch/x86/include/asm/uaccess_32.h:211:26: error: call to
>>>>       =E2=80=98copy_from_user_overflow=E2=80=99 declared with attr=
ibute error:
>>>>       copy_from_user()
>>>>       buffer size is not provably correct
>>>>
>>>> if built with W=3D1 due to a missing parameter size validation.
>>>>
>>>> Signed-off-by: Guenter Roeck <linux@roeck-us.net>
>>>> ---
>>>>    net/packet/af_packet.c |    2 ++
>>>>    1 file changed, 2 insertions(+)
>>>>
>>>> diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
>>>> index c7bfeff..1976b23 100644
>>>> --- a/net/packet/af_packet.c
>>>> +++ b/net/packet/af_packet.c
>>>> @@ -3210,6 +3210,8 @@ static int packet_getsockopt(struct socket
>>>> *sock, int level, int optname,
>>>>    		val =3D po->tp_version;
>>>>    		break;
>>>>    	case PACKET_HDRLEN:
>>>> +		if (len < sizeof(int))
>>>> +			return -EINVAL;
>>>
>>> I think this could break some user space applications here, those w=
ho
>>> e.g. only pass
>>> an uint16_t to packet_getsockopt with PACKET_HDRLEN.
>>
>> Well, their shit is broken on big endian then.
>
> There must be something else going on anyway ... yes, my patch fixes =
the
> warning/error, but copy_from_user should only bail out if the copy si=
ze
> can be larger than the provided buffer (unless I misunderstand the co=
de
> in copy_from_user). And the second check should take care of that.

=46air enough, from what I read the implementation on x86_64 uses gcc's
__builtin_object_size(<X>, 0) [1]. Since the <to> (<X>) argument is kno=
wn
at compile time (val:int), __builtin_object_size() will return sizeof(i=
nt)-1,
the number of bytes from val start to the end of the object val pointer
points to. Since our length that we pass can be [0, sizeof(int)] the
compiler cannot prove it, if the copy_from_user() buffer size is correc=
t.
Thus, "buffer size is not provably correct". Applications not passing i=
nt
to this getsockopt(2) are screwed up then anyway.

   [1] http://gcc.gnu.org/onlinedocs/gcc/Object-Size-Checking.html
