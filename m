From: Michal Kazior <michal.kazior-++hxYGjEMp0AvxtiuMwx3w@public.gmane.org>
Subject: Re: [RFC/RFT] mac80211: implement fq_codel for software queuing
Date: Tue, 8 Mar 2016 11:57:41 +0100
Message-ID: <CA+BoTQ=ASe2o7kfiC8q6YOkNp9q6DF3Yc3XZgL=scVsw9VdqrA@mail.gmail.com>
References: <1456492163-11437-1-git-send-email-michal.kazior@tieto.com>
	<CAA93jw4XsEnp3jTgPL7OKWTJP-83VwRaCdb+foc8nCuqxk3WZA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Emmanuel Grumbach <emmanuel.grumbach-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Felix Fietkau <nbd-p3rKhJxN3npAfugRpC6u6w@public.gmane.org>,
	Tim Shepard <shep-FrUbXkNCsVf2fBVCVOL8/A@public.gmane.org>
To: Dave Taht <dave.taht-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CAA93jw4XsEnp3jTgPL7OKWTJP-83VwRaCdb+foc8nCuqxk3WZA-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 8 March 2016 at 00:06, Dave Taht <dave.taht-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
> Dear Michal:
>
> Going through this patchset... (while watching it compile)
>
>
> +       if (!local->hw.txq_cparams.target)
> +               local->hw.txq_cparams.target =3D MS2TIME(5);
>
> MS2TIME(20) for now and/or add something saner to this than !*backlog
>
> target will not be a constant in the long run.
>
> +       if (now - custom_codel_get_enqueue_time(skb) < p->target ||
> +           !*backlog) {
> +               /* went below - stay below for at least interval */
> +               vars->first_above_time =3D 0;
> +               return false;
> +       }
>
>
> *backlog < some_sane_value_for_an_aggregate_for_this_station
>
> Unlike regular codel *backlog should be a ptr to the queuesize for
> this station, not the total queue.
>
> regular codel, by using the shared backlog for all queues, is trying
> to get to a 1 packet depth for all queues, (see commit:
> 865ec5523dadbedefbc5710a68969f686a28d928 ), and store the flow in the
> network, not the queue...
>
> BUT in wifi's case you want to provide good service to all stations,
> which is filling up an aggregate
> for each... (and varying the "sane_value_for_the_aggregate" to suit
> per sta service time requirements in a given round of all stations).

Hmm.. This actually makes me think that:

        skb =3D codel_dequeue(flow, &flow->backlog, &flow->cvars,
                            &hw->txq_cparams, codel_get_time(), false);

is kind of wrong.

If you want to maintain per-sta aggregate-long queue this probably
needs a sta->backlog instead of flow->backlog (because you can have
multiple flows per station) in the first place.

Not quite sure about cvars though. Thoughts?


Micha=C5=82
--
To unsubscribe from this list: send the line "unsubscribe linux-wireles=
s" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
