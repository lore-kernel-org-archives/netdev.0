From: Tomasz Grobelny <tomasz@grobelny.oswiecenia.net>
Subject: Re: [PATCH 1/1] [DCCP][QPOLICY]: External interface changes
Date: Mon, 28 Apr 2008 23:29:48 +0200
Message-ID: <200804282329.48669.tomasz@grobelny.oswiecenia.net>
References: <200804222230.25743.tomasz@grobelny.oswiecenia.net> <20080424220704.0483DBC12@poczta.oswiecenia.net> <20080428150819.GA27604@gerrit.erg.abdn.ac.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: acme@redhat.com, dccp@vger.kernel.org, netdev@vger.kernel.org
To: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from oswiecenia.net ([83.13.108.58]:4157 "EHLO poczta.oswiecenia.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S937777AbYD1VaW convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Apr 2008 17:30:22 -0400
In-Reply-To: <20080428150819.GA27604@gerrit.erg.abdn.ac.uk>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dnia Monday 28 of April 2008, Gerrit Renker napisa=B3:
> | @@ -721,9 +721,7 @@ static int dccp_msghdr_parse(struct msghdr *msg=
,
> | __u32 **priority)
> |
> |  		switch (cmsg->cmsg_type) {
> |  		case DCCP_SCM_PRIORITY:
> | -			if (cmsg->cmsg_len !=3D CMSG_LEN(sizeof(__u32)))
> | -				return -EINVAL;
> | -			*priority =3D (__u32 *)CMSG_DATA(cmsg);
> | +			*cmsg_qpolicy =3D cmsg;
> |  			break;
> |  		default:
> |  			return -EINVAL;
>
> Here the cmsg is exported to any current qpolicy. The disadvantages
> are	that * there is no longer any length check, the functions using t=
his
> interface have in the worst case no idea how much the user wanted to =
pass,
> so this is dangerous (compare also RFC 3542, 20.2);
The information about size can be retrieved in specific qpolicy. It is =
not=20
CMSG_DATA(cmsg) that is passed to qpolicy but cmsg itself along with cm=
sg_len=20
field.

>  * the separation-of-concerns becomes unclear: now part of the parsin=
g is
> done in dccp_msg_hdr_parse() and another part in some of the
> qpolicy_xxx_push() routines, so one routine does part of the work of
> another;
That is a problem. So I think all the code should be moved to=20
qpolicy_prio_push().

>  * each qpolicy_xxx_push() routine needs to have a cmsghdr* argument =
even
> if it is not used.
>
Before the change I could say: why call dccp_msghdr_parse() if choosen =
policy=20
cannot make use of it's result.
No matter what we will always have either "unnecessary code", "unnecess=
ary=20
parameter" or something else that is "unnecessary" simply because simpl=
e=20
policy is, well... simple. But it has to be so to keep interfaces clean=
=2E

> It is however possible to reach the same goal with just a small
> modification: * so far only one SCM message (DCCP_SCM_PRIORITY) has b=
een
> defined; * maintainers generally accepted the use of skb->priority wh=
ile on
> layer 4; * hence for all sub-variants of a "prio" policy (strict/part=
ial
> orderings), one can use DCCP_SCM_PRIORITY, in combination with
> skb->priority; * for different policies, define a different DCCP_SCM_=
xxx
> message and store the cmsg data in a different field (to be decided);
>  * this has the advantage that type/length checking is all in one pla=
ce,
>    so that the qpolicy routines need to do qpolicy only.
>
I would use different DCCP_SCM_xxx for different parameters. So that on=
e=20
qpolicy could use more than one DCCP_SCM_xxx. And parsing of specific=20
DCCP_SCM_xxx should IMHO happen in qpolicy_*_push().

> | --- a/net/dccp/qpolicy.c
> | +++ b/net/dccp/qpolicy.c
> | @@ -57,8 +58,13 @@ static struct sk_buff *qpolicy_prio_worst_skb(st=
ruct
> | sock *sk) return worst;
> |  }
> |
> | -static void qpolicy_prio_push(struct sock *sk, struct sk_buff *skb=
)
> | +static void qpolicy_prio_push(struct sock *sk, struct sk_buff *skb=
,
> | +				struct cmsghdr *cmsg)
> |  {
> | +	struct dccp_qpolicy_prio_info info;
> | +	memcpy(&info, CMSG_DATA(cmsg), min(cmsg->cmsg_len, sizeof(info)))=
;
>
> That is the problem I see - `info' could end up with garbled data, if=
 the
> user had accidentally passed `u32' instead of CMSG_LEN(sizeof priorit=
y).
>
Right, but this could easily be fixed by initializing info prior to mem=
cpy.=20
Then only data provided by user would override defaults. But see below.

> The CMSG_LEN() ensures an additional check - that the user is in fact=
 using
> proper encapsulation via CMSG_xxx macros and not via
> msg_control/msg_controllen directly. The latter leads to hard-to-debu=
g
> problems: in my case, I found this works - by accident - on 32-bit In=
tel,
> but will fail on 64-bit computers in compatibility mode.
>
Then min(cmsg->cmsg_len, sizeof(info)) could be changed to min(CMSG_LEN=
(cmsg),=20
sizeof(info)), I see no problem with that.

That said I think that multiple DCCP_SCM_xxx per policy might be a bett=
er=20
approach.
--=20
Regards,
Tomasz Grobelny
