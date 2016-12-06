From: Simon Horman <simon.horman@netronome.com>
Subject: Re: [PATCH v2 net-next 1/2] flow dissector: ICMP support
Date: Tue, 6 Dec 2016 15:23:57 +0100
Message-ID: <20161206142353.GA24064@penelope.horms.nl>
References: <1480710702-16850-1-git-send-email-simon.horman@netronome.com>
 <1480710702-16850-2-git-send-email-simon.horman@netronome.com>
 <20161203104918.GA1880@nanopsycho.orion>
 <CALx6S36EorReKwSs=qpS6uxCrL=_CQHf2BfV+Y=Kw-Dzfc241A@mail.gmail.com>
 <20161205142208.GA16425@penelope.horms.nl>
 <CALx6S37f-TFAhAidri12iD0KnhFE2kYuVnsXsj7yjivk-ovRiw@mail.gmail.com>
 <20161206105145.GA27020@penelope.horms.nl>
 <20161206122634.GH1984@nanopsycho>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Tom Herbert <tom@herbertland.com>,
        David Miller <davem@davemloft.net>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Jay Vosburgh <j.vosburgh@gmail.com>,
        Veaceslav Falico <vfalico@gmail.com>,
        Andy Gospodarek <andy@greyhouse.net>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        Jiri Pirko <jiri@mellanox.com>
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f45.google.com ([74.125.82.45]:38170 "EHLO
        mail-wm0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751388AbcLFOYQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 6 Dec 2016 09:24:16 -0500
Received: by mail-wm0-f45.google.com with SMTP id f82so127763044wmf.1
        for <netdev@vger.kernel.org>; Tue, 06 Dec 2016 06:24:15 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20161206122634.GH1984@nanopsycho>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 06, 2016 at 01:26:34PM +0100, Jiri Pirko wrote:
> Tue, Dec 06, 2016 at 11:51:46AM CET, simon.horman@netronome.com wrote:
> >On Mon, Dec 05, 2016 at 09:29:45AM -0800, Tom Herbert wrote:
> >> On Mon, Dec 5, 2016 at 6:23 AM, Simon Horman <simon.horman@netronome.com> wrote:
> >> > On Sat, Dec 03, 2016 at 10:52:32AM -0800, Tom Herbert wrote:
> >> >> On Sat, Dec 3, 2016 at 2:49 AM, Jiri Pirko <jiri@resnulli.us> wrote:
> >> >> > Fri, Dec 02, 2016 at 09:31:41PM CET, simon.horman@netronome.com wrote:
> >> >> >>Allow dissection of ICMP(V6) type and code. This re-uses transport layer
> >> >> >>port dissection code as although ICMP is not a transport protocol and their
> >> >> >>type and code are not ports this allows sharing of both code and storage.
> >> >> >>
> >> >> >>Signed-off-by: Simon Horman <simon.horman@netronome.com>
> >> >
> >> > ...
> >> >
> >> >> > Digging into this a bit more. I think it would be much nice not to mix
> >> >> > up l4 ports and icmp stuff.
> >> >> >
> >> >> > How about to have FLOW_DISSECTOR_KEY_ICMP
> >> >> > and
> >> >> > struct flow_dissector_key_icmp {
> >> >> >         u8 type;
> >> >> >         u8 code;
> >> >> > };
> >> >> >
> >> >> > The you can make this structure and struct flow_dissector_key_ports into
> >> >> > an union in struct flow_keys.
> >> >> >
> >> >> > Looks much cleaner to me.
> >> >
> >> > Hi Jiri,
> >> >
> >> > I wondered about that too. The main reason that I didn't do this the first
> >> > time around is that I wasn't sure what to do to differentiate between ports
> >> > and icmp in fl_init_dissector() given that using a union would could to
> >> > mask bits being set in both if they are set in either.
> >> >
> >> > I've taken a stab at addressing that below along with implementing your
> >> > suggestion. If the treatment in fl_init_dissector() is acceptable
> >> > perhaps something similar should be done for FLOW_DISSECTOR_KEY_IPV[46]_ADDRS
> >> > too?
> >> >
> >> >> I agree, this patch adds to many conditionals into the fast path for
> >> >> ICMP handling. Neither is there much point in using type and code as
> >> >> input to the packet hash.
> >> >
> >> > Hi Tom,
> >> >
> >> > I'm not sure that I follow this. A packet may be ICMP or not regardless of
> >> > if FLOW_DISSECTOR_KEY_PORT (and now FLOW_DISSECTOR_KEY_ICMP) port is set or
> >> > not. I'd appreciate some guidance here.
> >> >
> >> > First-pass at implementing Jiri's suggestion follows:
> >> >
> >
> >...
> >
> >> > diff --git a/net/core/flow_dissector.c b/net/core/flow_dissector.c
> >> > index 0584b4bb4390..33e5fa2b3e87 100644
> >> > --- a/net/core/flow_dissector.c
> >> > +++ b/net/core/flow_dissector.c
> >
> >...
> >
> >> > @@ -975,6 +983,10 @@ static const struct flow_dissector_key flow_keys_dissector_keys[] = {
> >> >                 .offset = offsetof(struct flow_keys, ports),
> >> >         },
> >> >         {
> >> > +               .key_id = FLOW_DISSECTOR_KEY_ICMP,
> >> > +               .offset = offsetof(struct flow_keys, icmp),
> >> > +       },
> >> 
> >> This is the problem I was referring to. This adds ICMP to the keys for
> >> computing the skb hash and the ICMP type and code are in a union with
> >> port numbers so they are in the range over which the hash is computed.
> >> This means that we are treating type and code as some sort of flow and
> >> and so different type/code between the same src/dst could follow
> >> different paths in ECMP. For the purposes of computing a packet hash I
> >> don't think we want ICMP information included. This might be a matter
> >> of not putting FLOW_DISSECTOR_KEY_ICMP in flow_keys_dissector_keys,
> >> where we need this information we could define another structure that
> >> has all the same fields as in flow_keys_dissector_keys and include
> >> FLOW_DISSECTOR_KEY_ICMP. Alternatively, the flow_dissector_key_icmp
> >> could also be outside of the area that is used in the hash: that is no
> >> in flow_keys_hash_start(keys) to flow_keys_hash_length(keys), keyval);
> >
> >...
> >
> >> > diff --git a/net/sched/cls_flower.c b/net/sched/cls_flower.c
> >> > index c96b2a349779..f4ba69bd362f 100644
> >> > --- a/net/sched/cls_flower.c
> >> > +++ b/net/sched/cls_flower.c
> >> > @@ -38,7 +38,10 @@ struct fl_flow_key {
> >> >                 struct flow_dissector_key_ipv4_addrs ipv4;
> >> >                 struct flow_dissector_key_ipv6_addrs ipv6;
> >> >         };
> >> > -       struct flow_dissector_key_ports tp;
> >> > +       union {
> >> > +               struct flow_dissector_key_ports tp;
> >> > +               struct flow_dissector_key_icmp icmp;
> >> > +       };
> >> 
> >> When an ICMP packet is encapsulated within UDP then icmp overwrites
> >> valid port information with is a stronger signal of the flow (unless
> >> FLOW_DISSECTOR_F_STOP_AT_ENCAP is set). This is another reason not to
> >> use a union with ports.
> >
> >...
> >
> >Hi Tom,
> >
> >thanks for your explanation. I think I have a clearer picture now.
> >
> >I have reworked things to try to address your concerns.
> >In particular:
> >
> >* FLOW_DISSECTOR_KEY_ICMP is no longer added to flow_keys_dissector_keys.
> >  I don't think it is needed at all for the use-case I currently have in
> >  mind, which is classifying packets using tc_flower. And adding it there
> >  was an error on my part.
> 
> I was just about to ask why you are adding it there. Good.
> 
> 
> >
> >* I stopped using a union for ports and icmp. At the very least this seems
> >  to make it easier to reason about things as we no longer need to consider
> >  that a port value may in fact be an ICMP type or code.
> 
> This should be within csl_flower code. You can easily have it as a union
> in struct fl_flow_key. 

Ok, will do.

> >  This seems to allow us avoid adding a number of is_icmp checks (as I believe
> >  you pointed out earlier). And should also address the problem you state
> >  immediately above.
> 
> I don't understand the check you are talking about. The union just allow
> to share the mem. I don't see any checks needed.

I meant the checks that the patchset adds were in bond_main.c and
other places before accessing the ports fields. I now see we can avoid them
while still using a union.

> >* I have also placed icmp outside of the range flow_keys_hash_start(keys)
> >  to flow_keys_hash_length(keys), keyval). This is because I now see no
> >  value of having it inside that range and it both avoids any chance of
> >  contaminating the hash with ICMP values and hashing over unwanted
> >  (hopefully zero) values.
> 
> Okay, now I'm confused again. You don't want to add this to
> flow_keys_dissector_keys. Why would you?

Sorry, I think it was me that was being confused. I'll drop that change.
I agree it should not be necessary.
