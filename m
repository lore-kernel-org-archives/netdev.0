From: Gilad Ben-Yossef <gilad@codefidence.com>
Subject: Re: [PATCH v2 2/8] Allow tcp_parse_options to consult dst entry
Date: Wed, 21 Oct 2009 16:07:30 +0200
Message-ID: <4ADF15A2.1050804@codefidence.com>
References: <1256115421-12714-1-git-send-email-gilad@codefidence.com> <1256115421-12714-3-git-send-email-gilad@codefidence.com> <alpine.DEB.2.00.0910211559050.5304@wel-95.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Netdev <netdev@vger.kernel.org>, ori@comsleep.com
To: =?ISO-8859-1?Q?Ilpo_J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xenbox.codefidence.com ([92.48.73.16]:40852 "EHLO
	xenbox.codefidence.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753207AbZJUOHa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Oct 2009 10:07:30 -0400
In-Reply-To: <alpine.DEB.2.00.0910211559050.5304@wel-95.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Ilpo,


Thanks for the feedback :-)


Ilpo J=E4rvinen wrote:

> On Wed, 21 Oct 2009, Gilad Ben-Yossef wrote:
>
>  =20
>> We need tcp_parse_options to be aware of dst_entry to=20
>> take into account per dst_entry TCP options settings
>>
>> Signed-off-by: Gilad Ben-Yossef <gilad@codefidence.com>
>> Sigend-off-by: Ori Finkelman <ori@comsleep.com>
>> Sigend-off-by: Yony Amit <yony@comsleep.com>
>>
>> ---
>>  include/net/tcp.h        |    3 ++-
>>  net/ipv4/syncookies.c    |   27 ++++++++++++++-------------
>>  net/ipv4/tcp_input.c     |    9 ++++++---
>>  net/ipv4/tcp_ipv4.c      |   19 ++++++++++---------
>>  net/ipv4/tcp_minisocks.c |    7 +++++--
>>  net/ipv6/syncookies.c    |   28 +++++++++++++++-------------
>>  net/ipv6/tcp_ipv6.c      |    3 ++-
>>  7 files changed, 54 insertions(+), 42 deletions(-)
>>
>>
>>    =20
<snip>
>> diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
>> index 7cda24b..1cb0ec4 100644
>> --- a/net/ipv4/tcp_ipv4.c
>> +++ b/net/ipv4/tcp_ipv4.c
>> @@ -1256,11 +1256,18 @@ int tcp_v4_conn_request(struct sock *sk, str=
uct sk_buff *skb)
>>  	tcp_rsk(req)->af_specific =3D &tcp_request_sock_ipv4_ops;
>>  #endif
>> =20
>> +	ireq =3D inet_rsk(req);
>> +	ireq->loc_addr =3D daddr;
>> +	ireq->rmt_addr =3D saddr;
>> +	ireq->no_srccheck =3D inet_sk(sk)->transparent;
>> +	ireq->opt =3D tcp_v4_save_options(sk, skb);
>> +
>> +	dst =3D inet_csk_route_req(sk, req);
>>  	tcp_clear_options(&tmp_opt);
>>  	tmp_opt.mss_clamp =3D 536;
>>  	tmp_opt.user_mss  =3D tcp_sk(sk)->rx_opt.user_mss;
>> =20
>> -	tcp_parse_options(skb, &tmp_opt, 0);
>> +	tcp_parse_options(skb, &tmp_opt, 0, dst);
>> =20
>>  	if (want_cookie && !tmp_opt.saw_tstamp)
>>  		tcp_clear_options(&tmp_opt);
>> @@ -1269,14 +1276,8 @@ int tcp_v4_conn_request(struct sock *sk, stru=
ct sk_buff *skb)
>> =20
>>  	tcp_openreq_init(req, &tmp_opt, skb);
>> =20
>> -	ireq =3D inet_rsk(req);
>> -	ireq->loc_addr =3D daddr;
>> -	ireq->rmt_addr =3D saddr;
>> -	ireq->no_srccheck =3D inet_sk(sk)->transparent;
>> -	ireq->opt =3D tcp_v4_save_options(sk, skb);
>> -
>>  	if (security_inet_conn_request(sk, skb, req))
>> -		goto drop_and_free;
>> +		goto drop_and_release;
>> =20
>>  	if (!want_cookie)
>>  		TCP_ECN_create_request(req, tcp_hdr(skb));
>> @@ -1301,7 +1302,7 @@ int tcp_v4_conn_request(struct sock *sk, struc=
t sk_buff *skb)
>>  		 */
>>  		if (tmp_opt.saw_tstamp &&
>>  		    tcp_death_row.sysctl_tw_recycle &&
>> -		    (dst =3D inet_csk_route_req(sk, req)) !=3D NULL &&
>> +		    dst !=3D NULL &&
>>    =20
>
> Why you need this NULL check this here while you trap it with BUG_ON=20
> elsewhere? Does your patch perhaps create a remote DoS opportunity?
>
>
>  =20
Indeed, I believe you are right. Good catch.

What about this (I know the patch gets eaten by Thunderbird, sorry abou=
t=20
that. This is just for explaining what I want to do):

diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c

index 1cb0ec4..1d611e3 100644

--- a/net/ipv4/tcp_ipv4.c

+++ b/net/ipv4/tcp_ipv4.c

@@ -1263,6 +1263,9 @@ int tcp_v4_conn_request(struct sock *sk, struct s=
k_buff *skb)

        ireq->opt =3D tcp_v4_save_options(sk, skb);

=20

        dst =3D inet_csk_route_req(sk, req);

+       if(!dst)

+               goto drop_and_free;

+

        tcp_clear_options(&tmp_opt);

        tmp_opt.mss_clamp =3D 536;

        tmp_opt.user_mss  =3D tcp_sk(sk)->rx_opt.user_mss;

@@ -1302,7 +1305,6 @@ int tcp_v4_conn_request(struct sock *sk, struct s=
k_buff *skb)

                 */

                if (tmp_opt.saw_tstamp &&

                    tcp_death_row.sysctl_tw_recycle &&

-                   dst !=3D NULL &&

                    (peer =3D rt_get_peer((struct rtable *)dst)) !=3D N=
ULL &&

                    peer->v4daddr =3D=3D saddr) {

                        if (get_seconds() < peer->tcp_ts_stamp + TCP_PA=
WS_MSL &&



My rational is that since if the connection is formed we will need to=20
send a syn/ack ( call to __tcp_v4_send_synack a couple of lines below)=20
and since we can't do that  if we don't have a route, this makes sense.

If this sounds sane, I'll re-spin the patch with this as a fix.

Thanks a bunch!
Gilad


--=20
Gilad Ben-Yossef
Chief Coffee Drinker & CTO
Codefidence Ltd.

Web:   http://codefidence.com
Cell:  +972-52-8260388
Skype: gilad_codefidence
Tel:   +972-8-9316883 ext. 201
=46ax:   +972-8-9316884
Email: gilad@codefidence.com

Check out our Open Source technology and training blog - http://tuxolog=
y.net

	"Sorry cannot parse this, its too long to be true  :)"
	  -- Eric Dumazet on netdev mailing list

