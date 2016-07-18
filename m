From: pravin shelar <pshelar@ovn.org>
Subject: Re: [ovs-dev] [PATCH net-next v11 5/6] openvswitch: add layer 3
 flow/port support
Date: Mon, 18 Jul 2016 15:34:52 -0700
Message-ID: <CAOrHB_C3Hq-V4uPWLELSc2VMywjYSnKiFJ4VJQDnPpCu7s1Xkw@mail.gmail.com>
References: <1467827996-32547-1-git-send-email-simon.horman@netronome.com>
 <1467827996-32547-6-git-send-email-simon.horman@netronome.com>
 <CAOrHB_BYD40ZkWbU0dvhPOCcaCVgooksOUkejxyFoagyoiBTNw@mail.gmail.com>
 <20160713073152.GC29661@penelope.isobedori.kobe.vergenet.net>
 <CAOrHB_A1ri6fouFH0H4KpEqg1icCmz+U1tcgn-5BoryX5pb1gw@mail.gmail.com> <20160718045025.GA2490@penelope.isobedori.kobe.vergenet.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	ovs dev <dev@openvswitch.org>, Jiri Benc <jbenc@redhat.com>
To: Simon Horman <simon.horman@netronome.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay2-d.mail.gandi.net ([217.70.183.194]:47193 "EHLO
	relay2-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751993AbcGRWe6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Jul 2016 18:34:58 -0400
Received: from mfilter27-d.gandi.net (mfilter27-d.gandi.net [217.70.178.155])
	by relay2-d.mail.gandi.net (Postfix) with ESMTP id 1107BC5A55
	for <netdev@vger.kernel.org>; Tue, 19 Jul 2016 00:34:56 +0200 (CEST)
Received: from relay2-d.mail.gandi.net ([IPv6:::ffff:217.70.183.194])
	by mfilter27-d.gandi.net (mfilter27-d.gandi.net [::ffff:10.0.15.180]) (amavisd-new, port 10024)
	with ESMTP id KExHF7dfzEyH for <netdev@vger.kernel.org>;
	Tue, 19 Jul 2016 00:34:54 +0200 (CEST)
Received: from mail-it0-f54.google.com (mail-it0-f54.google.com [209.85.214.54])
	(Authenticated sender: pshelar@ovn.org)
	by relay2-d.mail.gandi.net (Postfix) with ESMTPSA id 65541C5A43
	for <netdev@vger.kernel.org>; Tue, 19 Jul 2016 00:34:54 +0200 (CEST)
Received: by mail-it0-f54.google.com with SMTP id j124so4062902ith.1
        for <netdev@vger.kernel.org>; Mon, 18 Jul 2016 15:34:54 -0700 (PDT)
In-Reply-To: <20160718045025.GA2490@penelope.isobedori.kobe.vergenet.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Jul 17, 2016 at 9:50 PM, Simon Horman
<simon.horman@netronome.com> wrote:
> [CC Jiri Benc for portion regarding GRE]
>
> Hi Pravin,
>
> On Fri, Jul 15, 2016 at 02:07:37PM -0700, pravin shelar wrote:
>> On Wed, Jul 13, 2016 at 12:31 AM, Simon Horman
>> <simon.horman@netronome.com> wrote:
>> > Hi Pravin,
>> >
>> > On Thu, Jul 07, 2016 at 01:54:15PM -0700, pravin shelar wrote:
>> >> On Wed, Jul 6, 2016 at 10:59 AM, Simon Horman
>> >> <simon.horman@netronome.com> wrote:
>> >
>> > ...
>>
>> >
>> >> > diff --git a/net/openvswitch/flow.c b/net/openvswitch/flow.c
>> >> > index 0ea128eeeab2..86f2cfb19de3 100644
>> >> > --- a/net/openvswitch/flow.c
>> >> > +++ b/net/openvswitch/flow.c
>> >> ...
>> >>
>> >> > @@ -723,9 +729,17 @@ int ovs_flow_key_extract(const struct ip_tunnel_info *tun_info,
>> >> >         key->phy.skb_mark = skb->mark;
>> >> >         ovs_ct_fill_key(skb, key);
>> >> >         key->ovs_flow_hash = 0;
>> >> > +       key->phy.is_layer3 = skb->mac_len == 0;
>> >>
>> >> I do not think mac_len can be used. mac_header needs to be checked.
>> >> ...
>> >
>> > Yes, indeed. The update to use skb_mac_header_was_set() here accidently
>> > slipped into the following patch, sorry about that.
>> >
>> > With that change in place I believe that this patch is internally
>> > consistent because mac_header and mac_len are set correctly by the
>> > call to key_extract() which is called by ovs_flow_key_extract() just
>> > after where the excerpt above ends.
>> >
>> > That said, I do think that it is possible to rely on skb_mac_header_was_set
>> > throughout the datapath, including action processing etc... I have provided
>> > an incremental patch - which I created on top of this entire series - at
>> > the end of this email. If you prefer that approach I am happy to take it,
>> > though I do feel that using mac_len leads to slightly cleaner code. Let me
>> > know what you think.
>> >
>>
>>
>> I am not sure if you can use only mac_len to detect L3 packet. This
>> does not work with MPLS packets, mac_len is used to account MPLS
>> headers pushed on skb. Therefore in case of a MPLS header on L3
>> packet, mac_len would be non zero and we have to look at either
>> mac_header or some other metadata like is_layer3 flag from key to
>> check for L3 packet.
>
> At least within OvS mac_len does not include the length of the MPLS label
> stack. Rather, the MPLS label stack length is the difference between the
> end of (mac_header + mac_len) and network_header.
>
> So I think that the scheme does work as mac_len is 0 if there is no L2
> header regardless of if an MPLS label stack is present or not.
>

I was thinking in overall networking stack rather than just ovs
datapath. I think we should have consistent method of detecting L3
packet. As commented in previous mail it could be achieved using
skb-protocol and device type.
