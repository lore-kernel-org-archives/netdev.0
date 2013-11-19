From: Fan Du <fan.du@windriver.com>
Subject: Re: [PATCH net v3] vti: fix spd lookup: match plaintext pkt, not
 ipsec pkt
Date: Tue, 19 Nov 2013 17:16:34 +0800
Message-ID: <528B2C72.5060809@windriver.com>
References: <1383646612-30103-1-git-send-email-christophe.gouault@6wind.com> <1383725153-26298-1-git-send-email-christophe.gouault@6wind.com> <20131107112549.GP31491@secunet.com> <527B8DC5.6080702@6wind.com> <1902752B0C92F943AB7EA9EE13E2DEEC1273BA977C@HQ1-EXCH02.corp.brocade.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Christophe Gouault <christophe.gouault@6wind.com>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	"David S. Miller" <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.hengli.com.au>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: Saurabh Mohan <saurabh.mohan@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.windriver.com ([147.11.146.13]:41314 "EHLO
	mail1.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751396Ab3KSJPM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Nov 2013 04:15:12 -0500
In-Reply-To: <1902752B0C92F943AB7EA9EE13E2DEEC1273BA977C@HQ1-EXCH02.corp.brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi, Saurabh

On 2013=E5=B9=B411=E6=9C=8819=E6=97=A5 05:38, Saurabh Mohan wrote:
>
>
>> -----Original Message-----
>> From: Christophe Gouault [mailto:christophe.gouault@6wind.com]
>> Sent: Thursday, November 07, 2013 4:56 AM
>> To: Steffen Klassert
>> Cc: David S. Miller; Herbert Xu; netdev@vger.kernel.org; Saurabh Moh=
an;
>> Sergei Shtylyov; Eric Dumazet
>> Subject: Re: [PATCH net v3] vti: fix spd lookup: match plaintext pkt=
, not ipsec
>> pkt
>>
>> Hello Steffen,
>>
>> I am also interested in knowing Saurabh's intentions regarding the
>> behavior of policies bound to vti interfaces.
>>
> The semantics is to match the policy "src 0.0.0.0/0 dst 0.0.0.0/0 pro=
to any"
> That is the only policy that VTI should use. The mark is needed to
> distinguish and limit the policy to a specific vti tunnel interface o=
nly.
> There is no other policy that may be applied to a vti interface.
> The fact that traffic is going over the tunnel  interface implies tha=
t it
> must be encrypted/decrypted. Applying the above policy is a way
> to achieve that.

I'm not much experienced with VTI usage practical production usage scen=
ario, but
I have one question about the necessity of policy checking on VTI recei=
ving part.
- A VTI tunnel is hashed by destination address and i_key when creating=
 them;
- After each tunneled IP packet delivered to vti_rcv, the first step is=
 looking
   for the right tunnel, this is done by using tunneled IP packet outer=
 source and
   destination address without any key matching rule involved.

If there are any other tunnel with the same source/destination address,=
 but not
the same mark in place, the tunnel lookup in the vti_rcv will properly =
not hit
VTI tunnel, but the non-VTI tunnel. So the VTI net device statistics wi=
ll not be
accurate, and what's the point of checking policy for the wrong tunnel =
interface?

Or the VTI tunnel is the only tunnel with this specific source/destinat=
ion address
in the production deployment. Again the upper layer 4 will check the po=
licy after
all, that's the right place to do the policy checking.

So IMO, it's unnecessary to check policy for a net_device like VTI, act=
ually I hold
a patch of removing the VTI policy checking due to net-next closure for=
 the moment.

>> However, please note that setting a policy with a wildcard selector
>> works in both cases (before or after this patch), so a common test c=
ase
>> can be defined.
>>
>> Actually the *previous* patch on vti (7263a5187f9e vti: get rid of n=
f
>> mark rule in prerouting) introduced significant changes, and implies
>> behaviors dependant on the kernel version, but it seemed to meet
>> Saurabh's agreement, as the following thread witnesses:
>>
>> http://www.spinics.net/lists/netdev/msg253134.html
>>
> Getting rid of the pre-routing mark, which had to be done outside of
> the vti tunnel code was prone to misconfiguration.
> Though it is unfortunate that it creates a kernel version dependency.
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>

--=20
=E6=B5=AE=E6=B2=89=E9=9A=8F=E6=B5=AA=E5=8F=AA=E8=AE=B0=E4=BB=8A=E6=9C=9D=
=E7=AC=91

--fan fan
