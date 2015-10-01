From: Jesse Gross <jesse@nicira.com>
Subject: Re: [RFT v3] geneve: implement support for IPv6-based tunnels
Date: Thu, 1 Oct 2015 14:07:55 -0700
Message-ID: <CAEP_g=-huo5m9LY8thQ3YN=tSHM3jfT0LysnMgdXDT2L80XkBg@mail.gmail.com>
References: <1443632696-9900-1-git-send-email-linville@tuxdriver.com>
 <1443638045-27229-1-git-send-email-linville@tuxdriver.com>
 <CAEP_g=9g=Bt09+Kf9CWaSuhPFhUVXcesW28ksq+8b5hQwzf6Vw@mail.gmail.com> <20151001200355.GF3086@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	Pravin B Shelar <pshelar@nicira.com>,
	Jiri Benc <jbenc@redhat.com>,
	David Miller <davem@davemloft.net>
To: "John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f180.google.com ([209.85.217.180]:34033 "EHLO
	mail-lb0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750762AbbJAVIQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Oct 2015 17:08:16 -0400
Received: by lbbmp1 with SMTP id mp1so16535638lbb.1
        for <netdev@vger.kernel.org>; Thu, 01 Oct 2015 14:08:14 -0700 (PDT)
In-Reply-To: <20151001200355.GF3086@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 1, 2015 at 1:03 PM, John W. Linville <linville@tuxdriver.com> wrote:
> On Thu, Oct 01, 2015 at 09:26:59AM -0700, Jesse Gross wrote:
>> On Wed, Sep 30, 2015 at 11:34 AM, John W. Linville
>> <linville@tuxdriver.com> wrote:
>> > +static struct dst_entry *geneve_get_dst(struct sk_buff *skb,
>>
>> It might be worth clarifying this name - it wasn't immediately obvious
>> to me the difference between geneve_get_rt() and geneve_get_dst() is
>> IPv4 vs. IPv6.
>
> geneve_get_v4_rt and geneve_get_v6_dst?

Sure.

>> > +       err = udp_tunnel6_xmit_skb(dst, gs6->sock->sk, skb, dev,
>> > +                                  &fl6.saddr, &fl6.daddr, 0, ttl,
>> > +                                  sport, geneve->dst_port, !udp_csum);
>>
>> It seems like TOS is not handled here?
>
> There is no tos parameter for udp_tunnel6_xmit_skb.  Is there some
> other way to inject it?  Is there a mapping to priority (i.e. the
> 0 parameter)?

I think the TOS field and priority are essentially the same thing - no
mapping required, just a different name in IPv6. And then once we do
that, I guess we should bring over the ECN logic from IPv4.

>> > @@ -823,9 +1095,11 @@ static int geneve_configure(struct net *net, struct net_device *dev,
>> >         int err;
>> >
>> >         if (metadata) {
>> > -               if (rem_addr || vni || tos || ttl)
>> > +               if (remote != &geneve_remote_unspec || vni || tos || ttl)
>> >                         return -EINVAL;
>>
>> I think this will fail in the non-compat metadata case. The remote
>> that is passed in will be a zeroed copy on the stack, so the address
>> won't match the static version. I believe the check should be for
>> AF_UNSPEC instead.
>
> It is actually checking the pointer value against the address of
> that static data structure, which is only reference through the
> geneve_dev_create_fb path to calling geneve_configure.  Knowing that
> are you still troubled by it?

Yeah, I understand how it is working for the geneve_dev_create_fb()
path. However, I think that we should also be able to hit this using
the path from geneve_newlink() - this is basically the
COLLECT_METADATA case.

I now see that this isn't possible because we require a remote address
in geneve_newlink (including with the existing code). However, that
seems wrong now that we have lightweight tunnels.
