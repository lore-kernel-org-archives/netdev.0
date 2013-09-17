From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH  v3 0/6] ipv6: Do route updating for redirect in ndisc
 layer
Date: Tue, 17 Sep 2013 11:00:07 +0200
Message-ID: <52381A17.7080309@redhat.com>
References: <5236EFEB.60106@cn.fujitsu.com> <5236F808.9050605@redhat.com> <523710CC.1090404@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Duan Jiong <duanj.fnst@cn.fujitsu.com>, davem@davemloft.net,
	netdev@vger.kernel.org, hannes@stressinduktion.org,
	"linux-sctp@vger.kernel.org" <linux-sctp@vger.kernel.org>
To: Duan Jiong <djduanjiong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:32130 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751584Ab3IQJT7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Sep 2013 05:19:59 -0400
In-Reply-To: <523710CC.1090404@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/16/2013 04:08 PM, Duan Jiong wrote:
> =D3=DA 2013/9/16 20:22, Daniel Borkmann =D0=B4=B5=C0:
>> On 09/16/2013 01:47 PM, Duan Jiong wrote:
>>> From: Duan Jiong <duanj.fnst@cn.fujitsu.com>
>>>
>>> the ip6_redirect() could be replaced with
>>> ip6_redirect_no_header(), we could always use ip6_redirect()
>>> for route updating in ndisc layer and use the data of the
>>> redirected header option just for finding the socket to be
>>> notified and then notify user in protocols' err_handler.
>> If I get this right, it seems to me that this patchset actually cons=
ists of two
>> different kind of changes:
>>
>> 1) Not notifying user space on ICMP redirects (net material)
>> 2) Simplify code for updating route in ndisc layer instead of error =
handlers (net-next)
>>
>> Also, you do the *actual* change in the very last patch, which means=
 that from
>> patch 1 to 5 we're in an inconsistent and buggy state unless we also=
 apply patch
>> number 6. It should actually be the other way around, that you first=
 do the actual
>> change and then migrate users (also commit messages are quite terse)=
=2E
>=20
> I make the patch set on net tree, not on net-next. Maybe those
> things should be done in two patch sets.
>=20
>> Moreover, just looking at the SCTP part (sctp_err_lookup() function)=
 ...
>>
>> /* RFC 4960, Appendix C. ICMP Handling
>>   *
>>   * ICMP6) An implementation MUST validate that the Verification Tag
>>   * contained in the ICMP message matches the Verification Tag of
>>   * the peer.  If the Verification Tag is not 0 and does NOT
>>   * match, discard the ICMP message.  If it is 0 and the ICMP
>>   * message contains enough bytes to verify that the chunk type is
>>   * an INIT chunk and that the Initiate Tag matches the tag of the
>>   * peer, continue with ICMP7.  If the ICMP message is too short
>>   * or the chunk type or the Initiate Tag does not match, silently
>>   * discard the packet.
>>   */
>>  =20
>> ... it seems to me that we would simply ignore such RFC requirements=
 with
>> your patch for the sctp_v6_err() part.
>>
>> Care to elaborate? ;-)
>=20
> Sorry, i didn't notice that.
>=20
> According to the RFC requirements, it suggests that we can't update
> route for redirect in ndisc layer before calling into sctp_err_lookup=
(),
> because we must verify the ICMP Message. Now maybe we update route fo=
r
> redirect in ndisc layer is wrong.

Looking further into RFC4960 [1] ... it says:

Appendix C.  ICMP Handling

   Whenever an ICMP message is received by an SCTP endpoint, the
   following procedures MUST be followed to ensure proper utilization o=
f
   the information being provided by layer 3.

   ICMP1) An implementation MAY ignore all ICMPv4 messages where the
          type field is not set to "Destination Unreachable".

   ICMP2) An implementation MAY ignore all ICMPv6 messages where the
          type field is not "Destination Unreachable", "Parameter
          Problem", or "Packet Too Big".
   ...

So this basically means that only packets in step 2 are interesting for=
 us here,
we *may* ignore the rest. The verification comes at step 6, so we may h=
ave
ignored the packet first. ;-) Therefore, I think your proposal should n=
ot be an
issue for SCTP.

I'd however prefer that your patch handles this similarly as in sctp_v4=
_err(),
so that in the default switch-case, we just go to out_unlock.

In any case, your commit message would need to be more elaborate and re=
flect
"why" it is okay/safe to change that in SCTP or other cases, preferably=
 with
reference to the RFC. Otherwise, looking at the Git history in future w=
ill just be
confusing as it won't clarify why it was reasonable doing so this way.

  [1] http://tools.ietf.org/html/rfc4960#appendix-C
