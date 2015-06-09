From: Kenneth Klette Jonassen <kennetkl@ifi.uio.no>
Subject: Re: [PATCH v2 net-next 2/2] tcp: add CDG congestion control
Date: Wed, 10 Jun 2015 00:41:26 +0200
Message-ID: <CA++eYdvm3RVOvu4Eg9op7RaBcn0y6-mczTqgAzinto__WvXLWA@mail.gmail.com>
References: <1433785420-4191-1-git-send-email-kennetkl@ifi.uio.no>
	<1433785420-4191-2-git-send-email-kennetkl@ifi.uio.no>
	<CAK6E8=e33mt9WReuw2vUuyE5G-feSHOSqOmR9KxjkbCOaP_h_w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Kenneth Klette Jonassen <kennetkl@ifi.uio.no>,
	netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Neal Cardwell <ncardwell@google.com>,
	David Hayes <davihay@ifi.uio.no>,
	Andreas Petlund <apetlund@simula.no>,
	Dave Taht <dave.taht@bufferbloat.net>,
	Nicolas Kuhn <nicolas.kuhn@telecom-bretagne.eu>
To: Yuchung Cheng <ycheng@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f41.google.com ([74.125.82.41]:36171 "EHLO
	mail-wg0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751955AbbFIWl2 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Jun 2015 18:41:28 -0400
Received: by wgbgq6 with SMTP id gq6so22803950wgb.3
        for <netdev@vger.kernel.org>; Tue, 09 Jun 2015 15:41:26 -0700 (PDT)
In-Reply-To: <CAK6E8=e33mt9WReuw2vUuyE5G-feSHOSqOmR9KxjkbCOaP_h_w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 9, 2015 at 7:44 AM, Yuchung Cheng <ycheng@google.com> wrote=
:
> On Mon, Jun 8, 2015 at 10:43 AM, Kenneth Klette Jonassen
> <kennetkl@ifi.uio.no> wrote:
=E2=80=A6

>> +enum cdg_state {
>> +       CDG_UNKNOWN =3D 0,
>> +       CDG_FULL    =3D 0,
> why duplicate states?

We explicitly infer a full or non-full queue in tcp_cdg_grad().

The unknown state is semantically different; it is before we infer
anything about the network.

We could change the full state to have its own value. (It does not
matter in the current code, but it could be useful for TCP_CC_INFO.)

>> +       if (hystart_detect & 1) {
> Define 1 and 2 like cubic does?
>> +       prior_snd_cwnd =3D tp->snd_cwnd;
>> +       tcp_reno_cong_avoid(sk, ack, acked);
>> +
>> +       if (ca->shadow_wnd) {
>> +               u32 incr =3D tp->snd_cwnd - prior_snd_cwnd;
>> +
>> +               ca->shadow_wnd =3D max(ca->shadow_wnd, ca->shadow_wn=
d + incr);
>  u32 shadow_wnd may overflow?! there might be some bugs ...

CDG can potentially operate without losses over some time, so
shadow_wnd can reach U32_MAX on normal links.
The max() should revert any increment that causes overflow/wrapping of
shadow_wnd.

We limit shadow_wnd to min(shadow_wnd / 2, snd_cwnd) in ssthresh().

>> +       if (ca->state =3D=3D CDG_BACKOFF)
>> +               return max(2U, (tp->snd_cwnd * min(1024U, backoff_be=
ta)) >> 10);
>> +
>> +       if (ca->state =3D=3D CDG_NONFULL && use_tolerance) {
>> +               bool is_ecn =3D (tp->prior_ssthresh =3D=3D 0);
>> +
>> +               if (!is_ecn) {
>> +                       tp->ecn_flags &=3D ~TCP_ECN_DEMAND_CWR;
>> +                       return tp->snd_cwnd;
>> +               }
> I might be missing something here: cdg_backoff also calls
> tcp_enter_cwr() that clears prior_ssthresh but it's not triggered by
> ECE marks?

That is ok. We set ca->state =3D CDG_BACKOFF in tcp_cdg_backoff() to
distinguish a delay backoff.

>
> if the intention is to use loss tolerance only when undo is enabled
> why not just check undo_marker?

The intention is to not use loss tolerance if we receive an ECN signal.

Inferring ECN from (prior_ssthresh =3D=3D 0) is far from perfect of
course, but it is always cleared when receiving ECN.

In tcp_enter_loss(), undo_marker is set after calling ssthresh(). We
could change that, but undo_marker is also imperfect for detecting
ECN.

If in doubt, let us remove the ECN check now. Then in a later patch
set, we could try passing flag to ssthresh like you suggested. We
should also look at tcp_dctcp if we do that.

>> +       if (use_shadow)
>> +               ca->shadow_wnd =3D min(ca->shadow_wnd >> 1, tp->snd_=
cwnd);
>> +       else
>> +               ca->shadow_wnd =3D 0;
> it'd be good to not reset shadow_wnd, but only use it if use_shadow.
> so we can monitor shadow_wnd
> in TCP_CC_INFO in the future.

Ok, then we should always set/maintain a shadow_wnd.
