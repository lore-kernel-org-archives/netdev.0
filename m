From: Duan Jiong <djduanjiong@gmail.com>
Subject: Re: [PATCH  v3 0/6] ipv6: Do route updating for redirect in ndisc
 layer
Date: Mon, 16 Sep 2013 22:08:12 +0800
Message-ID: <523710CC.1090404@gmail.com>
References: <5236EFEB.60106@cn.fujitsu.com> <5236F808.9050605@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	hannes@stressinduktion.org,
	"linux-sctp@vger.kernel.org" <linux-sctp@vger.kernel.org>
To: Daniel Borkmann <dborkman@redhat.com>,
	Duan Jiong <duanj.fnst@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f47.google.com ([209.85.160.47]:36843 "EHLO
	mail-pb0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753536Ab3IPOIV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Sep 2013 10:08:21 -0400
In-Reply-To: <5236F808.9050605@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=D3=DA 2013/9/16 20:22, Daniel Borkmann =D0=B4=B5=C0:
> On 09/16/2013 01:47 PM, Duan Jiong wrote:
>> From: Duan Jiong <duanj.fnst@cn.fujitsu.com>
>>
>> the ip6_redirect() could be replaced with
>> ip6_redirect_no_header(), we could always use ip6_redirect()
>> for route updating in ndisc layer and use the data of the
>> redirected header option just for finding the socket to be
>> notified and then notify user in protocols' err_handler.
> If I get this right, it seems to me that this patchset actually consi=
sts of two
> different kind of changes:
>
> 1) Not notifying user space on ICMP redirects (net material)
> 2) Simplify code for updating route in ndisc layer instead of error h=
andlers (net-next)
>
> Also, you do the *actual* change in the very last patch, which means =
that from
> patch 1 to 5 we're in an inconsistent and buggy state unless we also =
apply patch
> number 6. It should actually be the other way around, that you first =
do the actual
> change and then migrate users (also commit messages are quite terse).

I make the patch set on net tree, not on net-next. Maybe those
things should be done in two patch sets.

> Moreover, just looking at the SCTP part (sctp_err_lookup() function) =
=2E..
>
> /* RFC 4960, Appendix C. ICMP Handling
>  *
>  * ICMP6) An implementation MUST validate that the Verification Tag
>  * contained in the ICMP message matches the Verification Tag of
>  * the peer.  If the Verification Tag is not 0 and does NOT
>  * match, discard the ICMP message.  If it is 0 and the ICMP
>  * message contains enough bytes to verify that the chunk type is
>  * an INIT chunk and that the Initiate Tag matches the tag of the
>  * peer, continue with ICMP7.  If the ICMP message is too short
>  * or the chunk type or the Initiate Tag does not match, silently
>  * discard the packet.
>  */
> =20
> ... it seems to me that we would simply ignore such RFC requirements =
with
> your patch for the sctp_v6_err() part.
>
> Care to elaborate? ;-)

Sorry, i didn't notice that.

According to the RFC requirements, it suggests that we can't update
route for redirect in ndisc layer before calling into sctp_err_lookup()=
,
because we must verify the ICMP Message. Now maybe we update route for
redirect in ndisc layer is wrong.

Do you have any idea?

>> ---
>>   Changes for v3:
>>   1.del the ICMP6_INC_STATS_BH  error count, these are in fact
>>     no errors.
>>
>>   Changes for v2:
>>   1.handle the update of the NDISC_REDIRECT error code directly in
>>     icmpv6_err_convert.
>>   2.squash some patchs into one patch.
>>   3.modify the subject of those patchs.
>>
>> Duan Jiong (6):
>>    ipv6: del the statements for updating route in (dccp|tcp|sctp)_v6=
_err
>>    ipv6: just match on ICMPV6_PKT_TOOBIG in those err_handle
>>    ipv6: del statements for dealing with NDISC_REDIRECT
>>    ip6tnl: move route updating for redirect to ndisc layer
>>    ipv6: modify the err to 0 when dealing with NDISC_REDIRECT
>>    ipv6: Do route updating for redirect in ndisc layer
>>
>>   include/net/ip6_route.h |  3 ---
>>   net/dccp/ipv6.c         | 13 +------------
>>   net/ipv6/ah6.c          |  9 ++-------
>>   net/ipv6/esp6.c         |  9 ++-------
>>   net/ipv6/icmp.c         |  5 +++--
>>   net/ipv6/ip6_tunnel.c   |  5 -----
>>   net/ipv6/ipcomp6.c      |  9 ++-------
>>   net/ipv6/ndisc.c        |  6 ++----
>>   net/ipv6/raw.c          |  3 +--
>>   net/ipv6/route.c        | 29 ++---------------------------
>>   net/ipv6/tcp_ipv6.c     | 12 ++++--------
>>   net/ipv6/udp.c          |  2 --
>>   net/sctp/input.c        | 12 ------------
>>   net/sctp/ipv6.c         |  6 +++---
>>   14 files changed, 22 insertions(+), 101 deletions(-)
>>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-sctp"=
 in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
