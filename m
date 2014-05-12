From: Duan Jiong <duanj.fnst@cn.fujitsu.com>
Subject: Re: [PATCH v2] neigh: set nud_state to NUD_INCOMPLETE when probing
 router reachability
Date: Mon, 12 May 2014 11:26:10 +0800
Message-ID: <53703F52.9060900@cn.fujitsu.com>
References: <536C64C0.5050204@cn.fujitsu.com> <1399845863.17976.116165369.3E7E2F36@webmail.messagingengine.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>, Jiri Benc <jbenc@redhat.com>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([59.151.112.132]:33848 "EHLO
	heian.cn.fujitsu.com" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751004AbaELD2b convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 11 May 2014 23:28:31 -0400
In-Reply-To: <1399845863.17976.116165369.3E7E2F36@webmail.messagingengine.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=E4=BA=8E 2014=E5=B9=B405=E6=9C=8812=E6=97=A5 06:04, Hannes Frederic So=
wa =E5=86=99=E9=81=93:
> On Thu, May 8, 2014, at 22:16, Duan Jiong wrote:
>>
>> Since commit 7e98056964("ipv6: router reachability probing"), a rout=
er falls
>> into NUD_FAILED will be probed.
>>
>> Now if function rt6_select() selects a router which neighbour state =
is NUD_FAILED,
>> and at the same time function rt6_probe() changes the neighbour stat=
e to NUD_PROBE,
>> then function dst_neigh_output() can directly send packets, but actu=
ally the
>> neighbour still is unreachable. If we set nud_state to NUD_INCOMPLET=
E instead
>> NUD_PROBE, packets will not be sent out until the neihbour is reacha=
ble.
>>
>> In addition, because the route should be probes with a single NS, so=
 we must
>> set neigh->probes to neigh_max_probes(), then the neigh timer timeou=
t and function
>> neigh_timer_handler() will not send other NS Messages.
>>
>> Signed-off-by: Duan Jiong <duanj.fnst@cn.fujitsu.com>
>> ---
>> Changes from v1:
>> 	*modify changelog to explain in detail why use neigh_max_probes().
>>
>>  net/core/neighbour.c | 4 ++--
>>  1 file changed, 2 insertions(+), 2 deletions(-)
>>
>> diff --git a/net/core/neighbour.c b/net/core/neighbour.c
>> index 8f8a96e..32d872e 100644
>> --- a/net/core/neighbour.c
>> +++ b/net/core/neighbour.c
>> @@ -1248,8 +1248,8 @@ void __neigh_set_probe_once(struct neighbour *=
neigh)
>>  	neigh->updated =3D jiffies;
>>  	if (!(neigh->nud_state & NUD_FAILED))
>>  		return;
>> -	neigh->nud_state =3D NUD_PROBE;
>> -	atomic_set(&neigh->probes, NEIGH_VAR(neigh->parms, UCAST_PROBES));
>> +	neigh->nud_state =3D NUD_INCOMPLETE;
>> +	atomic_set(&neigh->probes, neigh_max_probes(neigh));
>=20
> Wouldn't it be better if we neigh_suspect the neighbour and leaving t=
he state in NUD_PROBE? We call down to ->output in case neighbour is in=
 NUD_PROBE state, so we must just disable connected 'fast-path'.
>=20

You can look into neigh_event_send() called in neigh_resolve_output(), =
and if neigh->nud_state
still is NUD_PROBE, the neigh_event_send() will return 0, so the packet=
 will still be sent out
without probe.

So, using neigh_suspect is not a good idea.

Thanks,
  Duan
 =20
> Greetings,
>=20
>   Hannes
> .
>=20
