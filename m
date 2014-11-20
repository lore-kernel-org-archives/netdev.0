From: Joe Stringer <joestringer@nicira.com>
Subject: Re: [PATCHv10 ovs 12/15] datapath: Add support for unique flow identifiers.
Date: Thu, 20 Nov 2014 10:57:34 -0800
Message-ID: <201411201057.35003.joestringer@nicira.com>
References: <1415906275-3172-1-git-send-email-joestringer@nicira.com> <201411191620.32217.joestringer@nicira.com> <CALnjE+qwnKa-s1GoZRvh-RgjRO5eKvrf+XnvD_meGES1L=fe0w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: "dev@openvswitch.org" <dev@openvswitch.org>,
	netdev <netdev@vger.kernel.org>
To: Pravin Shelar <pshelar@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog103.obsmtp.com ([74.125.149.71]:51903 "HELO
	na3sys009aog103.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752077AbaKTTFa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Nov 2014 14:05:30 -0500
Received: by mail-pa0-f46.google.com with SMTP id lj1so3094940pab.19
        for <netdev@vger.kernel.org>; Thu, 20 Nov 2014 11:05:30 -0800 (PST)
In-Reply-To: <CALnjE+qwnKa-s1GoZRvh-RgjRO5eKvrf+XnvD_meGES1L=fe0w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wednesday, November 19, 2014 16:39:20 Pravin Shelar wrote:
> On Wed, Nov 19, 2014 at 4:20 PM, Joe Stringer <joestringer@nicira.com> 
wrote:
> > On Wednesday, November 19, 2014 15:34:24 Pravin Shelar wrote:
> >> On Thu, Nov 13, 2014 at 11:17 AM, Joe Stringer <joestringer@nicira.com>
> > 
> > wrote:
> >> > @@ -684,33 +691,43 @@ static size_t ovs_flow_cmd_msg_size(const struct
> >> > sw_flow_actions *acts)
> >> > 
> >> >  /* Called with ovs_mutex or RCU read lock. */
> >> >  static int ovs_flow_cmd_fill_match(const struct sw_flow *flow,
> >> > 
> >> > -                                  struct sk_buff *skb)
> >> > +                                  struct sk_buff *skb, u32
> >> > ufid_flags)
> >> > 
> >> >  {
> >> >  
> >> >         struct nlattr *nla;
> >> >         int err;
> >> > 
> >> > -       /* Fill flow key. */
> >> > -       nla = nla_nest_start(skb, OVS_FLOW_ATTR_KEY);
> >> > -       if (!nla)
> >> > -               return -EMSGSIZE;
> >> > -
> >> > -       err = ovs_nla_put_flow(&flow->unmasked_key,
> >> > &flow->unmasked_key, skb, -                              false);
> >> > -       if (err)
> >> > -               return err;
> >> > -
> >> > -       nla_nest_end(skb, nla);
> >> > +       /* Fill flow key. If userspace didn't specify a UFID, then
> >> > ignore the +        * OMIT_KEY flag. */
> >> > +       if (!(ufid_flags & OVS_UFID_F_OMIT_KEY) ||
> >> > +           !flow->index_by_ufid) {
> >> 
> >> I am not sure about this check, userspace needs to send atleast ufid
> >> or the unmasked key as id for flow. otherwise we shld flag error. Here
> >> we can serialize flow->key.
> >> There could be another function which takes care of flow-id
> >> serialization where we serialize use ufid or unmasked key as flow id.
> >> Lets group ufid and unmasked key together rather than masked key and
> >> unmasked key which are not related.
> > 
> > Right, at flow setup time the flow key is always required, but the UFID
> > is optional. For most other cases, one of the two most be specified. For
> > flow dump, neither is required from userspace, but OMIT_KEY flag may be
> > raised. That's the particular case that this logic is trying to catch
> > (dump all flows, including those that were set up without UFID - in
> > which case the OMIT_KEY flag doesn't make sense, so treat the flag like
> > a request rather than a command).
> 
> How do you handle overlapping flows without the flow id in dump operation?

In userspace? revalidators will dump flows, then if the flow-key is exactly the 
same as another flow then they will be hashed to the same udpif_key and the 
second flow will be ignored each dump. So, stats may get messed up. If they 
differ but overlap, they will hash to different udpif_keys and stats tracked 
separately. Revalidator won't check the validity of overlapping flows until the 
next change to ofproto-dpif.
