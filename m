From: Neal Cardwell <ncardwell@google.com>
Subject: Re: [PATCH net-next] tcp: Fix CWV being too strict on thin streams
Date: Sat, 19 Sep 2015 08:46:25 -0400
Message-ID: <CADVnQy=BXvWMXUGeeABjsHDpfa4FF+RUfCvJXpupcyYKG+=+ig@mail.gmail.com>
References: <1442619503-2282-1-git-send-email-bro.devel+kernel@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	Netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	=?UTF-8?Q?Bendik_R=C3=B8nning_Opstad?= <bro.devel+kernel@gmail.com>,
	Andreas Petlund <apetlund@simula.no>,
	Carsten Griwodz <griff@simula.no>,
	Jonas Markussen <jonassm@ifi.uio.no>,
	Kenneth Klette Jonassen <kennetkl@ifi.uio.no>,
	Yuchung Cheng <ycheng@google.com>
To: =?UTF-8?Q?Bendik_R=C3=B8nning_Opstad?= <bro.devel@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f176.google.com ([209.85.214.176]:36600 "EHLO
	mail-ob0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752014AbbISMq0 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 19 Sep 2015 08:46:26 -0400
Received: by obbmp4 with SMTP id mp4so20886646obb.3
        for <netdev@vger.kernel.org>; Sat, 19 Sep 2015 05:46:25 -0700 (PDT)
In-Reply-To: <1442619503-2282-1-git-send-email-bro.devel+kernel@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Sep 18, 2015 at 7:38 PM, Bendik R=C3=B8nning Opstad
<bro.devel@gmail.com> wrote:
>
> Application limited streams such as thin streams, that transmit small
> amounts of payload in relatively few packets per RTT, are prevented f=
rom
> growing the CWND after experiencing loss. This leads to increased
> sojourn times for data segments in streams that often transmit
> time-dependent data.
>
> After the CWND is reduced due to loss, and an ACK has made room in th=
e
> send window for more packets to be transmitted, the CWND will not gro=
w
> unless there is more unsent data buffered in the output queue than th=
e
> CWND permits to be sent. That is because tcp_cwnd_validate(), which
> updates tp->is_cwnd_limited, is only called in tcp_write_xmit() when =
at
> least one packet with new data has been sent. However, if all the
> buffered data in the output queue was sent within the current CWND,
> is_cwnd_limited will remain false even when there is no more room in =
the
> CWND. While the CWND is fully utilized, any new data put on the outpu=
t
> queue will be held back (i.e. limited by the CWND), but
> tp->is_cwnd_limited will not be updated as no packets were transmitte=
d.
>
> Fix by updating tp->is_cwnd_limited if no packets are sent due to the
> CWND being fully utilized.

Thanks for this report!

When you say "CWND is reduced due to loss", are you talking about RTO
or Fast Recovery? Do you have any traces you can share that illustrate
this issue?

Have you verified that this patch fixes the issue you identified? I
think the fix may be in the wrong place for that scenario, or at least
incomplete.

In the scenario you describe, you say "all the buffered data in the
output queue was sent within the current CWND", which means that there
is no unsent data, so in tcp_write_xmit() the call to tcp_send_head()
would return NULL, so we would not enter the while loop, and could not
set is_cwnd_limited to true.

In the scenario you describe, I think we'd need to check for being
cwnd-limited in tcp_xmit_retransmit_queue().

How about something like the following patch:

diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index d0ad355..8e6a772 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -2145,6 +2145,7 @@ repair:
                tcp_cwnd_validate(sk, is_cwnd_limited);
                return false;
        }
+       tp->is_cwnd_limited |=3D is_cwnd_limited;
        return !tp->packets_out && tcp_send_head(sk);
 }

@@ -2762,8 +2763,10 @@ void tcp_xmit_retransmit_queue(struct sock *sk)
                 * packet to be MSS sized and all the
                 * packet counting works out.
                 */
-               if (tcp_packets_in_flight(tp) >=3D tp->snd_cwnd)
+               if (tcp_packets_in_flight(tp) >=3D tp->snd_cwnd) {
+                       tp->is_cwnd_limited =3D true;
                        return;
+               }

                if (fwd_rexmitting) {
 begin_fwd:

neal
