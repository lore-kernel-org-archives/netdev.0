From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: Re: [PATCH] sctp: add verification checks to SCTP_AUTH_KEY option
Date: Tue, 26 Aug 2008 09:37:08 -0400
Message-ID: <48B40704.5040702@hp.com>
References: <20080825164440.GA504@kernel.sg> <12196959323990-git-send-email-vladislav.yasevich@hp.com> <48B35561.2010001@redhat.com> <48B35B59.2020208@hp.com> <48B371F1.5080605@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-sctp@vger.kernel.org, security@kernel.org
To: Eugene Teo <eteo@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0026.austin.hp.com ([15.216.28.33]:48090 "EHLO
	g1t0026.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753838AbYHZNhL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Aug 2008 09:37:11 -0400
In-Reply-To: <48B371F1.5080605@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eugene Teo wrote:
> Vlad Yasevich wrote:
>> Eugene Teo wrote:
>>> Vlad Yasevich wrote:
> [...]
>>>> +	if (authkey->sca_keylength > optlen) {
>>>> +		ret = -EINVAL;
>>>> +		goto out;
>>> Is there a better upper bound check?
>> Hm...  optlen - sizeof(struct sctp_authkey)  is more accurate.
>>
>> There is really no other bound.
> 
> Linus suggested that it is better to declare an upper bound for key_len.
> I think it makes a lot of sense as a key shouldn't be as long as the
> boundary limit of its declared data type.
> 
>

I am starting to think that this might be completely unnecessary.

The sctp_auth_set_key() function is be called from two places:

  1) setsockopt() code path

  2) sctp_auth_asoc_set_secret() code path


In case (1), sca_keylength is never going to exceed 65536 since it's
bounded by a u16 from the user api.  As such, the malloc() will never
overflow.  This is the case we were really concerned about since the user
can supply bogus values.

In case (2), it is possible for the length to exceed 65536 since it's
trying to create a generated key and the algorithm takes raw pieces of the
SCTP handshake packets to do that.  However, there is no way that they can
exceed another 132K bytes because max IP datagram size is 65K and both ends
have to exchange security data.  Using IPv6 Jumbo extension I guess they can
go higher but we are probably going to fail memory allocations at that point.

That makes the theoretical maximum for the key to be 192K, but that discounts
the Jumbo usage.  So, I think using the current INT_MAX is sufficient to catch
possible overflows caused by case (2).   I think restricting the size further is
pointless and could end up being too restrictive.

-vlad

