From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH nf-next 0/4] netfilter: rework netfilter ipv6 defrag
Date: Tue, 20 Oct 2015 22:53:07 +0200
Message-ID: <20151020205306.GK4386@breakpoint.cc>
References: <1445112865-31523-1-git-send-email-fw@strlen.de>
 <CANr6G5zvmj_tL5Pt6-70GQ4dTJXLewX9A4uMGC_0OFzXYQVdew@mail.gmail.com>
 <20151020081716.GH4386@breakpoint.cc>
 <CANr6G5xW7m2SXFiU22pFVD6uvDj5ymX=jZkRJk2vMYQoJykvLw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Westphal <fw@strlen.de>, netfilter-devel@vger.kernel.org,
	Linux Netdev List <netdev@vger.kernel.org>,
	Andy Zhou <azhou@nicira.com>
To: Joe Stringer <joestringer@nicira.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CANr6G5xW7m2SXFiU22pFVD6uvDj5ymX=jZkRJk2vMYQoJykvLw@mail.gmail.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Joe Stringer <joestringer@nicira.com> wrote:
> > Good point.  No, I don't.  Any suggestions?
> > I can try to just re-target -nf tree (sans patch #2).  Pablo?
> 
> The smallest change seems to be adding the nf_ct_frag6_consume_orig()
> call to OVS, plus the morph logic from patch 3. Alternatively if Pablo
> is fine with having the series re-targeted, then that sounds
> reasonable to me too.

Pablo, your call.

I would suggest to re-target patches #1 and #3 to nf tree, I can do
this, just let me know.

Alternative is to just add the nf_ct_frag6_consume_orig call to
openvswitch and handle that via net tree.

I can then wait for that change to pop up in nf-next and just resend
this series (which will then undo that change).

Let me know, thanks!

> > ipv4 side seems broken as well (ip_defrag frees skb on errors other than
> > -EINPROGRESS, so it looks like we will double-free in
> > do_execute_actions)
> 
> Oh dear. Thanks for the report. I propose wrapping the ip_defrag()
> with an skb_get()/skb_consume() as this seems to require the least
> invasive changes:
> 
> diff --git a/net/openvswitch/conntrack.c b/net/openvswitch/conntrack.c
> index a5ec34f8502f..0d2d24c99fd5 100644
> --- a/net/openvswitch/conntrack.c
> +++ b/net/openvswitch/conntrack.c
> @@ -303,7 +303,11 @@ static int handle_fragments(struct net *net,
> struct sw_flow_key *key,
>                 int err;
> 
>                 memset(IPCB(skb), 0, sizeof(struct inet_skb_parm));
> +
> +               skb_get(skb);
>                 err = ip_defrag(skb, user);
> +               if (!err || err == -EINPROGRESS)
> +                       consume_skb(skb);
>                 if (err)
>                         return err;

Indeed, that seems like the least invasive change.

Feel free to submit this to -net, there is no dependency on any of the
other changes.
