From: Neal Cardwell <ncardwell@google.com>
Subject: Re: [PATCH v2 2/3] RFC tcp: early retransmit
Date: Tue, 1 May 2012 13:53:02 -0400
Message-ID: <CADVnQykJSgh7j9HL-pkbfhFASPLRV=veQ1Y0Nym0rn8smYzyiQ@mail.gmail.com>
References: <1335638781-960-1-git-send-email-ycheng@google.com>
	<1335638781-960-2-git-send-email-ycheng@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, ilpo.jarvinen@helsinki.fi,
	nanditad@google.com, edumazet@gmail.com, netdev@vger.kernel.org
To: Yuchung Cheng <ycheng@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f46.google.com ([209.85.213.46]:64247 "EHLO
	mail-yw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758378Ab2EARxD convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 May 2012 13:53:03 -0400
Received: by yhmm54 with SMTP id m54so39976yhm.19
        for <netdev@vger.kernel.org>; Tue, 01 May 2012 10:53:03 -0700 (PDT)
In-Reply-To: <1335638781-960-2-git-send-email-ycheng@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Apr 28, 2012 at 2:46 PM, Yuchung Cheng <ycheng@google.com> wrot=
e:
> --- a/Documentation/networking/ip-sysctl.txt
> +++ b/Documentation/networking/ip-sysctl.txt
> @@ -202,6 +202,20 @@ tcp_ecn - INTEGER
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0not support ECN, behavior is like =
with ECN disabled.
> =A0 =A0 =A0 =A0Default: 2
>
> +tcp_early_retrans - INTEGER
> + =A0 =A0 =A0 Enable Early Retransmit (ER), per RFC 5827. ER lowers t=
he threshold

I get a trailing-whitespace error in the documentation when I apply thi=
s patch:

> git am /tmp/er2.patch
Applying: RFC tcp: early retransmit
=2E../.git/rebase-apply/patch:20:
trailing whitespace.
       Enable Early Retransmit (ER), per RFC 5827. ER lowers the thresh=
old
warning: 1 line adds whitespace errors.

Also, to keep the sysctls alphabetical, tcp_early_retrans should probab=
ly go
before tcp_ecn.

> --- a/include/linux/tcp.h
> +++ b/include/linux/tcp.h
> @@ -365,12 +365,13 @@ struct tcp_sock {
>
> =A0 =A0 =A0 =A0u32 =A0 =A0 frto_highmark; =A0/* snd_nxt when RTO occu=
rred */
> =A0 =A0 =A0 =A0u16 =A0 =A0 advmss; =A0 =A0 =A0 =A0 /* Advertised MSS =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 */
> - =A0 =A0 =A0 u8 =A0 =A0 =A0frto_counter; =A0 /* Number of new acks a=
fter RTO */
> - =A0 =A0 =A0 u8 =A0 =A0 =A0nonagle =A0 =A0 : 4,/* Disable Nagle algo=
rithm? =A0 =A0 =A0 =A0 =A0 =A0 */
> + =A0 =A0 =A0 u16 =A0 =A0 nonagle =A0 =A0 : 4,/* Disable Nagle algori=
thm? =A0 =A0 =A0 =A0 =A0 =A0 */
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0thin_lto =A0 =A0: 1,/* Use linear time=
outs for thin streams */
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0thin_dupack : 1,/* Fast retransmit on =
first dupack =A0 =A0 =A0*/
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0repair =A0 =A0 =A0: 1,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 unused =A0 =A0 =A0: 1;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 do_early_retrans: 1;/* Enable RFC5827 e=
arly-retransmit =A0*/
> +
> + =A0 =A0 =A0 u8 =A0 =A0 =A0frto_counter; =A0 /* Number of new acks a=
fter RTO */
> =A0 =A0 =A0 =A0u8 =A0 =A0 =A0repair_queue;

To keep the change minimal and reduce the risk of mysterious
performance regressions from cache effects, I'd suggest keeping the
frto_counter and nonagle u8 bytes as u8 bytes in their current
location, and add a new u8 for the two ER bits. Same amount of space
as the scheme in the patch, just less shuffling.

> @@ -987,6 +989,7 @@ static void tcp_update_reordering(struct sock *sk=
, const int metric,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 tp->undo_marker ? tp->und=
o_retrans : 0);
> =A0#endif
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0tcp_disable_fack(tp);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 tcp_disable_early_retrans(tp);
> =A0 =A0 =A0 =A0}
> =A0}

I think we should stick with the behavior where we disable early
retransmit any time tcp_update_reordering() is called with a non-zero
reordering metric. This is what we've tested and measured, and my
sense is that we could risk a significant number of spurious ER
firings if instead we relax this so that only reordering >3 causes us
to disable ER. I know the delayed ER should help avoid spurious ER
firings when there is a small degree of reordering, but my guess would
be that the max(RTT/4, 2ms) is perhaps not big enough if we're
allowing delayed ER for connections that have already witnessed small
degrees of reordering. So until we have more experimental data, I'd
recommend sticking with:

	if (metric > 0)
		tcp_disable_early_retrans(tp);

Otherwise, looks good to me.

neal
