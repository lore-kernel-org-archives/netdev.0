From: Tomasz Grobelny <tomasz@grobelny.oswiecenia.net>
Subject: Re: [DCCP] [RFC] [Patchv2 1/1]: Queuing policies -- reworked version of Tomasz's patch set
Date: Tue, 15 Apr 2008 01:45:05 +0200
Message-ID: <200804150145.05571.tomasz@grobelny.oswiecenia.net>
References: <200804111224.06958.tomasz@grobelny.oswiecenia.net> <20080414065041.GA4431@gerrit.erg.abdn.ac.uk> <20080414073915.GA9655@gerrit.erg.abdn.ac.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: Gerrit Renker <gerrit@erg.abdn.ac.uk>,
	Arnaldo Carvalho de Melo <acme@redhat.com>,
	dccp@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from oswiecenia.net ([83.13.108.58]:4275 "EHLO poczta.oswiecenia.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754662AbYDNXpm convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Apr 2008 19:45:42 -0400
In-Reply-To: <20080414073915.GA9655@gerrit.erg.abdn.ac.uk>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dnia Monday 14 of April 2008, Gerrit Renker napisa=B3:
> [DCCP] [RFC]: Reworked queueing policy patch set
>
> This is a re-worked version of Tomasz's priority-queueing patch set f=
or
> DCCP. The essential internals of his patch set have been left untouch=
ed,
> in particular the prio/simple algorithms are the same as before.
>
> The changes for which I am asking for comments are:
>
>   Given that each file has less than 100 lines, it seemed better to p=
ut
> them all into one file and export the declarations in dccp.h, the res=
ult is
> now:
>
>   With less than 150 lines, there is still room for a few more polici=
es.
>
=46or now the files are small but I would expect at least qpolicy_prio.=
c to grow=20
a little bit in the future. What comes to mind are get/setsockopts (for=
=20
example statistics about packets dropped by qpolicy), and per packet ex=
piry=20
times. I didn't look how big the files are but wanted to have clear=20
separation between specific policies and common code. But if you think =
that=20
this organization is better I have no problem with it.

> 2. Let pop() return result
> --------------------------
>   * at least for the forseeable future, the underlying queue is
> sk_write_queue; * an skb can not be on two lists at the same time;
>   * thus skb_unlink will always be part of implementing pop();
>   * having pop() return the skb is more versatile (compare Assembler
> pop()).
>
That should be fine...

>   * makes tx_qlen a socket member of dccp_sock (there was a bug in th=
e
>     implementation -- tx_qlen was shared by all sockets using the sam=
e
> policy);=20
Haven't tested it thoroughly but it shouldn't be so. After all qpol_txq=
len was=20
part of struct dccp_qpolicy which was in turn part of dccp_sock.

> +/*
> + * Wrappers for methods provided by policy currently in use
> + */
> +void qpolicy_push(struct sock *sk, struct sk_buff *skb, struct msghd=
r
> *msg) +{
> +	struct dccp_packet_info *dcp =3D NULL;
> +
> +	if (msg->msg_control !=3D NULL && msg->msg_controllen =3D=3D sizeof=
(*dcp))
> +		dcp =3D (struct dccp_packet_info *)msg->msg_control;
> +
> +	qpol_table[dccp_sk(sk)->dccps_qpolicy].push(sk, skb, dcp);
> +}
> +
What happens if application is compiled with dccp_packet_info containin=
g only=20
one field (priority) and kernel containing two fields (for example prio=
rity=20
and later added expiry time)? Wouldn't that implementation make extensi=
ons to=20
dccp_packet_info impossible?

> @@ -501,6 +519,8 @@ struct dccp_sock {
>  	struct ccid			*dccps_hc_rx_ccid;
>  	struct ccid			*dccps_hc_tx_ccid;
>  	struct dccp_options_received	dccps_options_received;
> +	__u8				dccps_qpolicy;
> +	__u32				dccps_tx_qlen;
>  	enum dccp_role			dccps_role:2;
>  	__u8				dccps_hc_rx_insert_options:1;
>  	__u8				dccps_hc_tx_insert_options:1;
I know that currently none of the policies has any per-socket data. But=
 if it=20
had were should it go?

> +	case DCCP_SOCKOPT_QPOLICY_ID:
> +		if (sk->sk_state !=3D DCCP_CLOSED)
> +			err =3D -EISCONN;
What about DCCP_LISTENING state?

> --- a/Documentation/networking/dccp.txt
> +++ b/Documentation/networking/dccp.txt
> @@ -45,6 +45,17 @@ http://linux-net.osdl.org/index.php/DCCP
>
> +DCCP_SOCKOPT_QPOLICY_TXQLEN sets the maximum TX queue length. This i=
s
> relevant only for +those TX dequeueing policies that honour this uppe=
r
> bound (currently only the +simple/default policy does this). This soc=
ket
> option overrides the default value +of the sysctl
> /proc/sys/net/dccp/default/tx_qlen.
>
In my implementation prio policy did honour DCCP_SOCKOPT_QPOLICY_TXQLEN=
=20
setting. At least it was meant to do so.

Having said "ok" here and there or nothing in other points I haven't tr=
ied=20
applying this patch nor tested your rework.
--=20
Regards,
Tomasz Grobelny
