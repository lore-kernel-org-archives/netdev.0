From: =?UTF-8?B?TWlrYSBQZW50dGlsw6Q=?= <mika.penttila@kolumbus.fi>
Subject: Re: [PATCH] IPv6: Implement RFC 4429 Optimistic Duplicate Address
 Detection
Date: Mon, 22 Jan 2007 20:39:24 +0200
Message-ID: <45B504DC.8030107@kolumbus.fi>
References: <20070119212314.GA10748@hmsreliant.homelinux.net> <20070120.080507.25118874.yoshfuji@linux-ipv6.org> <20070122181528.GD21059@hmsreliant.homelinux.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: yoshfuji@linux-ipv6.org, davem@davemloft.net, kuznet@ms2.inr.ac.ru,
	pekkas@netcore.fi, jmorris@namei.org, kaber@coreworks.de,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw1.turkuamk.fi ([195.148.208.125]:50962 "EHLO
	mail-gw1.turkuamk.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932085AbXAVS6k convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Jan 2007 13:58:40 -0500
To: Neil Horman <nhorman@tuxdriver.com>
In-Reply-To: <20070122181528.GD21059@hmsreliant.homelinux.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Neil Horman wrote:
> On Sat, Jan 20, 2007 at 08:05:07AM +0900, YOSHIFUJI Hideaki / =E5=90=89=
=E8=97=A4=E8=8B=B1=E6=98=8E wrote:
>  =20
>> Hello.
>>
>> In article <20070119212314.GA10748@hmsreliant.homelinux.net> (at Fri=
, 19 Jan 2007 16:23:14 -0500), Neil Horman <nhorman@tuxdriver.com> says=
:
>>
>>    =20
>>> Patch to Implement IPv6 RFC 4429 (Optimistic Duplicate Address Dete=
ction).  In
>>>      =20
>> Good work.  We will see if this would break core and basic ipv6 code=
=2E
>> Dave, please hold on.
>>
>> Some quick comments.
>> --yoshfuji
>>    =20
> <snip>
>
> Reposted patch, with your suggestions/corrections incorporated.  The =
only thing
> I left alone was your last comment regarding the checking of saddr fo=
r being a
> unicast address.  According to the RFC as I read it, its possible to =
receive
> valid neighbor soliciations with a source address that is the unspeci=
fied
> address, which I didn't think ipv6_addr_type flagged as being unicast=
=2E  Now it
> may be that such NS messages are discarded before arriving at that re=
cieve
> routine, but I was figuring better safe than sorry.  If you're suffic=
iently
> confident that we won't see non-unicast saddrs there, let me know and=
 I'll
> happily remove that as well.
>
> Thanks & Regards
> Neil
>
> NTATIVE) {
> +
> +		if (ifp->flags & (IFA_F_TENTATIVE|IFA_F_OPTIMISTIC)) {
>  			/* Address is tentative. If the source
> -			   is unspecified address, it is someone
> -			   does DAD, otherwise we ignore solicitations
> -			   until DAD timer expires.
> +			   is unspecified address, someone else
> +			   is doing DAD, and if its not us, then
> +			   we need to fail our own DAD
> +			   RFC 4429 Sec 3.3
>  			 */
>  			if (!dad)
>  				goto out;
> @@ -816,8 +845,20 @@ static void ndisc_recv_ns(struct sk_buff *skb)
>  					goto out;
>  				}
>  			}
> -			addrconf_dad_failure(ifp);=20
> -			return;
> +
> +			/* The one exception to the above rule about=20
> +			   optimistic addresses is that we need to always=20
> +			   respond to an NS from a unicast address if we are
> +			   optimistic. RFC 4429 Sec 3.3.  If (unicast
> +			   and optimistic) are false then we can just fail
> +			   dad now.
> +			*/
> +			type =3D ipv6_addr_type(saddr);		=09
> +			if (!((ifp->flags & IFA_F_OPTIMISTIC) &&=20
> +			    (type & IPV6_ADDR_UNICAST))) {
> +				addrconf_dad_failure(ifp);=20
> +				return;
> +			}
>  		}
>  =20
I think you should remove / modify the :
if (!dad)
    goto out;

which makes the rfc4429 tests not functional.

--Mika




