From: Tomasz Grobelny <tomasz@grobelny.oswiecenia.net>
Subject: Re: [PATCH 1/1] [DCCP][QPOLICY]: Make information about qpolicies available to userspace
Date: Wed, 25 Jun 2008 22:15:19 +0200
Message-ID: <200806252215.19851.tomasz@grobelny.oswiecenia.net>
References: <20080517155916.34622BD22@poczta.oswiecenia.net> <200806241002.42482.tomasz@grobelny.oswiecenia.net> <20080625180545.GB8260@gerrit.erg.abdn.ac.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: acme@redhat.com, dccp@vger.kernel.org, netdev@vger.kernel.org
To: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from oswiecenia.net ([83.13.108.58]:3466 "EHLO poczta.oswiecenia.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751239AbYFYUPj convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Jun 2008 16:15:39 -0400
In-Reply-To: <20080625180545.GB8260@gerrit.erg.abdn.ac.uk>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dnia Wednesday 25 of June 2008, Gerrit Renker napisa=B3:
> | > Yes having them separate gives a clearer semantics. But it comes =
at a
> | > price - to retrieve the parameters, we need an extra function or =
lookup
> | > table.
> |
> | An additional bitfield in dccp_qpolicy_operations should do it when=
 it
> | comes to storing that information. When it comes to retrieving see =
next
> | point...
> |
> | > Maybe there is an elegant solution which allows to encode the req=
uired
> | > parameters while keeping the semantics clear?
> |
> | What about something like:
> | 	setsockopt(sockfd, DCCP_SOCKOPT_QPOLICY_ID, DCCPQ_POLICY_PRIO);
> | to choose policy (exactly as it is now) and a new function to ensur=
e that
> | the kernel understands parameters:
> | 	setsockopt(sockfd, DCCP_SOCKOPT_QPOLICY_PARAMS, DCCP_SCM_PRIORITY =
|
> | DCCP_SCM_TIMEOUT);
> |
> | The second call would return an error if the kernel does not know
> | anything about DCCP_SCM_TIMEOUT (or a choosen policy does not suppo=
rt
> | it). This would have the additional benefit (over similar getsockop=
t)
> | that the kernel will be able to optimize its behaviour knowning the=
 set
> | of parameters that will be used.
> |
> | What do you think about such an interface?
> | --
>
> In both solutions there is a need to maintain an integrity constraint
> between the qpolicy ID and the set of parameters that the qpolicy use=
s.
>
It is always the case, either explicit (as I propose) or implicit (when=
 it=20
would be a part of policy id).

> With the bitmask approach this constraint is expressed only once, whe=
n
> the policy is defined in the source file.
>
In what I propose it would also be defined once. Instead of:
	[DCCPQ_POLICY_PRIO] =3D {
		.push	=3D qpolicy_simple_push,
		.full	=3D qpolicy_prio_full,
		.top	=3D qpolicy_prio_best_skb,
	},
we would simply have:
	[DCCPQ_POLICY_PRIO] =3D {
		.push	=3D qpolicy_simple_push,
		.full	=3D qpolicy_prio_full,
		.top	=3D qpolicy_prio_best_skb,
		.params =3D DCCP_SCM_PRIORITY | DCCP_SCM_TIMEOUT,
	},
Doesn't seem complicated, does it?

> With the socket approach, the constraint needs to be expressed each t=
ime
> the policy is used.
>
Yes. Two points:
1. The other option is /proc I guess... would that be better? I think n=
ot=20
(even though I had other optinion on this subject earlier).
2. I think that it is actually good to enforce on application developer=
s the=20
need to declare which parameters they want to use. This way they almost=
=20
cannot do it wrong.

> I don't know your reservations against the bitmask approach (other th=
an the
> semantics), but I find having to define the parameters each time the
> qpolicy is used cumbersome, and it can also be a source of errors.
>
The bitmask approach is ok but I view combining parameters with policy =
id=20
counterintuitive.

To make things clear: we both agree that the application should be able=
 to get=20
information if the parameters it wants to use are supported by the kern=
el=20
it's running on, right?

The place where we differ is that you would prefer to have:
setsockopt(sockfd, DCCP_POLICY_ID, DCCPQ_POLICY_PRIO|(DCCP_SCM_PRIORITY=
<<8));

and I would like to have:
setsockopt(sockfd, DCCP_POLICY_ID, DCCPQ_POLICY_PRIO);
setsockopt(sockfd, DCCP_POLICY_PARAMS, DCCP_SCM_PRIORITY);

Is that right?
--=20
Regards,
Tomasz Grobelny
