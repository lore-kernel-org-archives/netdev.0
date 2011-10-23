From: Jiri Pirko <jpirko@redhat.com>
Subject: Re: [patch net-next V2] net: introduce ethernet teaming device
Date: Sun, 23 Oct 2011 10:25:47 +0200
Message-ID: <20111023082545.GA15908@minipsycho.orion>
References: <1319200747-2508-1-git-send-email-jpirko@redhat.com>
 <1319208237.32161.14.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
 <20111022151346.GA2028@minipsycho.orion>
 <1319302282.6180.60.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	bhutchings@solarflare.com, shemminger@vyatta.com, fubar@us.ibm.com,
	andy@greyhouse.net, tgraf@infradead.org, ebiederm@xmission.com,
	mirqus@gmail.com, kaber@trash.net, greearb@candelatech.com,
	jesse@nicira.com, fbl@redhat.com, benjamin.poirier@gmail.com,
	jzupka@redhat.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:65385 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755151Ab1JWI0D (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 23 Oct 2011 04:26:03 -0400
Content-Disposition: inline
In-Reply-To: <1319302282.6180.60.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sat, Oct 22, 2011 at 06:51:22PM CEST, eric.dumazet@gmail.com wrote:
>Le samedi 22 octobre 2011 =E0 17:13 +0200, Jiri Pirko a =E9crit :
>> >> +
>> >> +/************************
>> >> + * Rx path frame handler
>> >> + ************************/
>> >> +
>> >> +/* note: already called with rcu_read_lock */
>> >> +static rx_handler_result_t team_handle_frame(struct sk_buff **ps=
kb)
>> >> +{
>> >> +	struct sk_buff *skb =3D *pskb;
>> >> +	struct team_port *port;
>> >> +	struct team *team;
>> >> +	rx_handler_result_t res =3D RX_HANDLER_ANOTHER;
>> >> +
>> >> +	skb =3D skb_share_check(skb, GFP_ATOMIC);
>> >> +	if (!skb)
>> >> +		return RX_HANDLER_CONSUMED;
>> >> +
>> >> +	*pskb =3D skb;
>> >> +
>> >> +	port =3D team_port_get_rcu(skb->dev);
>> >> +	team =3D port->team;
>> >> +
>> >> +	if (team->mode_ops.receive)
>> >
>> >Hmm, you need ACCESS_ONCE() here or rcu_dereference()
>> >
>> >See commit 4d97480b1806e883eb (bonding: use local function pointer =
of
>> >bond->recv_probe in bond_handle_frame) for reference
>>=20
>> I do not think so. Because mode_ops.receive changes only from
>> __team_change_mode() and this can be called only in case no ports ar=
e in
>> team. And team_port_del() calls synchronize_rcu().
>>=20
>
>
>
>We are used to code following this template :
>
>if (ops->handler)
>	ops->handler(arguments);
>
>But this is valid only because ops points to constant memory.
>
>
>In your case, we really see its not true, dont try to pretend its safe=
=2E

Please forgive me, it's possible I'm missing something. But I see no wa=
y how
team->mode_ops.receive can change during team_handle_frame (holding
rcu_read_lock) for the reason I stated earlier.

team_port_del() calls netdev_rx_handler_unregister() and after that it
calls synchronize_rcu(). That ensures that by the finish of team_port_d=
el()
run, team_handle_frame() is not called for this port anymore.

And this combined with "if (!list_empty(&team->port_list))" check in
team_change_mode() ensures safety.

Of course team_port_del() and team_change_mode() are both protected by
team->lock so they are mutually excluded.

Jirka.

>
>
>
