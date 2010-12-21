From: Nandita Dukkipati <nanditad@google.com>
Subject: Re: [PATCH v2 1/1] TCP: increase default initial receive window.
Date: Mon, 20 Dec 2010 16:23:24 -0800
Message-ID: <AANLkTinobEo0yu-a_tfk1qS4cfg2ByhnGqsKjkV0HGYc@mail.gmail.com>
References: <1292642451-892-1-git-send-email-nanditad@google.com>
	<1292890556-29904-1-git-send-email-nanditad@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Tom Herbert <therbert@google.com>,
	Laurent Chavey <chavey@google.com>,
	Yuchung Cheng <ycheng@google.com>,
	Nandita Dukkipati <nanditad@google.com>
To: "David S. Miller" <davem@davemloft.net>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Rick Jones <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([74.125.121.67]:9855 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757844Ab0LUAX2 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Dec 2010 19:23:28 -0500
Received: from wpaz9.hot.corp.google.com (wpaz9.hot.corp.google.com [172.24.198.73])
	by smtp-out.google.com with ESMTP id oBL0NQXO026200
	for <netdev@vger.kernel.org>; Mon, 20 Dec 2010 16:23:27 -0800
Received: from gxk21 (gxk21.prod.google.com [10.202.11.21])
	by wpaz9.hot.corp.google.com with ESMTP id oBL0NPOS006906
	for <netdev@vger.kernel.org>; Mon, 20 Dec 2010 16:23:25 -0800
Received: by gxk21 with SMTP id 21so1890218gxk.24
        for <netdev@vger.kernel.org>; Mon, 20 Dec 2010 16:23:25 -0800 (PST)
In-Reply-To: <1292890556-29904-1-git-send-email-nanditad@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As per the comments, I have resubmitted the patch with a longer
explanation. Please let me know if the preference is to have a sysctl
for the initial default receive window, as I am ok either way.

Thanks,
-Nandita

On Mon, Dec 20, 2010 at 4:15 PM, Nandita Dukkipati <nanditad@google.com=
> wrote:
> This patch changes the default initial receive window to 10 mss
> (defined constant). The default window is limited to the maximum
> of 10*1460 and 2*mss (when mss > 1460).
>
> draft-ietf-tcpm-initcwnd-00 is a proposal to the IETF that recommends
> increasing TCP's initial congestion window to 10 mss or about 15KB.
> Leading up to this proposal were several large-scale live Internet
> experiments with an initial congestion window of 10 mss (IW10), where
> we showed that the average latency of HTTP responses improved by
> approximately 10%. This was accompanied by a slight increase in
> retransmission rate (0.5%), most of which is coming from applications
> opening multiple simultaneous connections. To understand the extreme
> worst case scenarios, and fairness issues (IW10 versus IW3), we furth=
er
> conducted controlled testbed experiments. We came away finding minima=
l
> negative impact even under low link bandwidths (dial-ups) and small
> buffers. =A0These results are extremely encouraging to adopting IW10.
>
> However, an initial congestion window of 10 mss is useless unless a T=
CP
> receiver advertises an initial receive window of at least 10 mss.
> Fortunately, in the large-scale Internet experiments we found that mo=
st
> widely used operating systems advertised large initial receive window=
s
> of 64KB, allowing us to experiment with a wide range of initial
> congestion windows. Linux systems were among the few exceptions that
> advertised a small receive window of 6KB. The purpose of this patch i=
s
> to fix this shortcoming.
>
> References:
> 1. A comprehensive list of all IW10 references to date.
> http://code.google.com/speed/protocols/tcpm-IW10.html
>
> 2. Paper describing results from large-scale Internet experiments wit=
h IW10.
> http://ccr.sigcomm.org/drupal/?q=3Dnode/621
>
> 3. Controlled testbed experiments under worst case scenarios and a
> fairness study.
> http://www.ietf.org/proceedings/79/slides/tcpm-0.pdf
>
> 4. Raw test data from testbed experiments (Linux senders/receivers)
> with initial congestion and receive windows of both 10 mss.
> http://research.csc.ncsu.edu/netsrv/?q=3Dcontent/iw10
>
> 5. Internet-Draft. Increasing TCP's Initial Window.
> https://datatracker.ietf.org/doc/draft-ietf-tcpm-initcwnd/
>
> Signed-off-by: Nandita Dukkipati <nanditad@google.com>
> ---
> Changelog since v1:
> - A longer and better commit message.
>
> =A0include/net/tcp.h =A0 =A0 | =A0 =A03 +++
> =A0net/ipv4/tcp_output.c | =A0 11 ++++++++---
> =A02 files changed, 11 insertions(+), 3 deletions(-)
>
> diff --git a/include/net/tcp.h b/include/net/tcp.h
> index b448030..38509f0 100644
> --- a/include/net/tcp.h
> +++ b/include/net/tcp.h
> @@ -60,6 +60,9 @@ extern void tcp_time_wait(struct sock *sk, int stat=
e, int timeo);
> =A0*/
> =A0#define MAX_TCP_WINDOW =A0 =A0 =A0 =A0 32767U
>
> +/* Offer an initial receive window of 10 mss. */
> +#define TCP_DEFAULT_INIT_RCVWND =A0 =A0 =A0 =A010
> +
> =A0/* Minimal accepted MSS. It is (60+60+8) - (20+20). */
> =A0#define TCP_MIN_MSS =A0 =A0 =A0 =A0 =A0 =A088U
>
> diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
> index 2d39066..dc7c096 100644
> --- a/net/ipv4/tcp_output.c
> +++ b/net/ipv4/tcp_output.c
> @@ -228,10 +228,15 @@ void tcp_select_initial_window(int __space, __u=
32 mss,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
> =A0 =A0 =A0 =A0}
>
> - =A0 =A0 =A0 /* Set initial window to value enough for senders, foll=
owing RFC5681. */
> + =A0 =A0 =A0 /* Set initial window to a value enough for senders sta=
rting with
> + =A0 =A0 =A0 =A0* initial congestion window of TCP_DEFAULT_INIT_RCVW=
ND. Place
> + =A0 =A0 =A0 =A0* a limit on the initial window when mss is larger t=
han 1460.
> + =A0 =A0 =A0 =A0*/
> =A0 =A0 =A0 =A0if (mss > (1 << *rcv_wscale)) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 int init_cwnd =3D rfc3390_bytes_to_pack=
ets(mss);
> -
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 int init_cwnd =3D TCP_DEFAULT_INIT_RCVW=
ND;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (mss > 1460)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 init_cwnd =3D
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 max_t(u32, (1460 * TCP_=
DEFAULT_INIT_RCVWND) / mss, 2);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0/* when initializing use the value fro=
m init_rcv_wnd
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 * rather than the default from above
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 */
> --
> 1.7.3.1
>
>
