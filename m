From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH net] net: sctp: fix multihoming retransmission path selection
 to rfc4960
Date: Thu, 20 Feb 2014 13:48:19 +0100
Message-ID: <5305F993.4060603@redhat.com>
References: <1392897186-26841-1-git-send-email-dborkman@redhat.com> <063D6719AE5E284EB5DD2968C1650D6D0F6C762B@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-sctp@vger.kernel.org" <linux-sctp@vger.kernel.org>,
	Gui Jianfeng <guijianfeng@cn.fujitsu.com>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:58645 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752786AbaBTMsh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Feb 2014 07:48:37 -0500
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D0F6C762B@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/20/2014 01:25 PM, David Laight wrote:
> From: Daniel Borkmann
>>
>> Problem statement: 1) both paths (primary path1 and alternate
>> path2) are up after the association has been established i.e.,
>> HB packets are normally exchanged, 2) path2 gets inactive after
>> path_max_retrans * max_rto timed out (i.e. path2 is down completely),
>> 3) now, if a transmission times out on the only surviving/active
>> path1 (any ~1sec network service impact could cause this like
>> a channel bonding failover), then the retransmitted packets are
>> sent over the inactive path2; this happens with partial failover
>> and without it.
>>
>> Besides not being optimal in the above scenario, a small failure
>> or timeout in the only existing path has the potential to cause
>> long delays in the retransmission (depending on RTO_MAX) until
>> the still active path is reselected.
>
> The current behaviour doesn't seem very good - real networks tend
> to have non-zero packet loss these days (for all sorts of reasons).
>
> I guess that under moderate traffic flow retransmit requests from
> the remote system recover the data before a timeout actually occurs.
>
> That probably means that a path with a high error rate will continue
> to be used when an alternate path would be much better.
>
> I was wondering whether it is valid (or even reasonable) to send
> the retransmit down multiple paths?  Particularly if they are
> not known to be working.

As far as I can see, the RFC says that we should pick one, and
not broadcast through all paths, besides HB should monitor these
anyway.

Future work, however, could select a retransmission path "more
intelligent" based on further transport path properties, but
that is certainly not net material, plus it seems we would need
additional state logic indicating that a path has been used before
to not exclude other less optimal transports on successive
retransmits.

> Or maybe resend heartbeats in a desperate attempt to find a working
> path?

Yes, that is done through HBs, see 1.5.7 of RFC4960.

> Do you guys know which kernel version(s) have that patch?

git describe 4141ddc02a92
v2.6.26-rc4-210-g4141ddc

> We have a few customers using sctp (for m3ua) and I really ought
> to keep track of the 'good' and 'bad' kernel versions.
>
> 	David
