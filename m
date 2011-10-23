From: Jiri Pirko <jpirko@redhat.com>
Subject: Re: [patch net-next V2] net: introduce ethernet teaming device
Date: Sun, 23 Oct 2011 14:51:01 +0200
Message-ID: <20111023125101.GA20078@minipsycho.orion>
References: <1319200747-2508-1-git-send-email-jpirko@redhat.com>
 <1319208237.32161.14.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
 <20111022151346.GA2028@minipsycho.orion>
 <1319302282.6180.60.camel@edumazet-laptop>
 <20111023082545.GA15908@minipsycho.orion>
 <1319366709.27507.14.camel@edumazet-laptop>
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
Received: from mx1.redhat.com ([209.132.183.28]:60462 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755441Ab1JWMvS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 23 Oct 2011 08:51:18 -0400
Content-Disposition: inline
In-Reply-To: <1319366709.27507.14.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sun, Oct 23, 2011 at 12:45:09PM CEST, eric.dumazet@gmail.com wrote:
>Le dimanche 23 octobre 2011 =E0 10:25 +0200, Jiri Pirko a =E9crit :
>
>> Please forgive me, it's possible I'm missing something. But I see no=
 way how
>> team->mode_ops.receive can change during team_handle_frame (holding
>> rcu_read_lock) for the reason I stated earlier.
>>=20
>> team_port_del() calls netdev_rx_handler_unregister() and after that =
it
>> calls synchronize_rcu(). That ensures that by the finish of team_por=
t_del()
>> run, team_handle_frame() is not called for this port anymore.
>>=20
>> And this combined with "if (!list_empty(&team->port_list))" check in
>> team_change_mode() ensures safety.
>>=20
>> Of course team_port_del() and team_change_mode() are both protected =
by
>> team->lock so they are mutually excluded.
>
>Oh well.
>
>Jirka, I believe I do understand how RCU is working ;)

With this I do not argue :)
But note that team->mode_ops.receive is not rcu-protected pointer per
say (no rcu_assign, rcu_dereference).

>
>There is an obvious problem I pointed to you, but you persist leaving
>this potential bug.
>
>After netdev_rx_handler_unregister(), you can still have other cpus
>calling your handler and reading/using previous memory content. Only
>after synchronize_rcu() you can be safe. But in your patch the bug
>window is _exactly_ _before_ synchronize_rcu() returns.

Yes. And team->mode_ops.receive can change only after synchronize_rcu i=
s
done. It's not possible it changes within the window you are talking ab=
out.

>
>Your spinlock wont help you at all, since readers dont take it.
>Spinlock only protects writers.

Sure. team->lock ensures that team_change_mode() is not called withing
the "bug window" but only after team_port_del() finishes.

>
>
>So a reader, even holding rcu lock, can really see two different
>mode_ops.receive values for the :
>
>if (team->mode_ops.receive)
>	res =3D team->mode_ops.receive(team, port, skb);
>
>
>rcu_lock() doesnt mean the reader can see an unique .receive value,=09

I'm very well aware of this.

>
>I am afraid you misunderstood the point.
>
>Real point of RCU here is that the _writer_ wont returns from
>synchronize_rcu() if at least one reader is still running the handler.
>
>No problem with me, I'll just post a patch later, I just cant Ack your
>work as is.
>
>
>
