From: Pravin Shelar <pshelar@nicira.com>
Subject: Re: [PATCH net] net: Clear local_df only if crossing namespace.
Date: Mon, 10 Feb 2014 13:00:14 -0800
Message-ID: <CALnjE+qiRbLWBJyhig7DFETRLRgAZHqJqUEYGVuJ6nXc7cPguw@mail.gmail.com>
References: <1391811158-11433-1-git-send-email-pshelar@nicira.com>
	<20140207222840.GD16198@order.stressinduktion.org>
	<CALnjE+pbcbENWjQcE8T0QLa=d0iia3EBBVJz-sGVzAZbsQarLQ@mail.gmail.com>
	<20140208005843.GE16198@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: Pravin Shelar <pshelar@nicira.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	"Templin, Fred L" <Fred.L.Templin@boeing.com>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog102.obsmtp.com ([74.125.149.69]:40203 "HELO
	na3sys009aog102.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1753322AbaBJVAP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Feb 2014 16:00:15 -0500
Received: by mail-vb0-f53.google.com with SMTP id p17so5085739vbe.26
        for <netdev@vger.kernel.org>; Mon, 10 Feb 2014 13:00:14 -0800 (PST)
In-Reply-To: <20140208005843.GE16198@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Feb 7, 2014 at 4:58 PM, Hannes Frederic Sowa
<hannes@stressinduktion.org> wrote:
> [Cc Nicolas]
>
> On Fri, Feb 07, 2014 at 02:49:20PM -0800, Pravin Shelar wrote:
>> On Fri, Feb 7, 2014 at 2:28 PM, Hannes Frederic Sowa
>> <hannes@stressinduktion.org> wrote:
>> > Hi!
>> >
>> > On Fri, Feb 07, 2014 at 02:12:38PM -0800, Pravin wrote:
>> >> --- a/net/core/skbuff.c
>> >> +++ b/net/core/skbuff.c
>> >> @@ -3905,12 +3905,13 @@ EXPORT_SYMBOL(skb_try_coalesce);
>> >>   */
>> >>  void skb_scrub_packet(struct sk_buff *skb, bool xnet)
>> >>  {
>> >> -     if (xnet)
>> >> +     if (xnet) {
>> >>               skb_orphan(skb);
>> >> +             skb->local_df = 0;
>> >> +     }
>> >>       skb->tstamp.tv64 = 0;
>> >>       skb->pkt_type = PACKET_HOST;
>> >>       skb->skb_iif = 0;
>> >> -     skb->local_df = 0;
>> >>       skb_dst_drop(skb);
>> >>       skb->mark = 0;
>> >>       secpath_reset(skb);
>> >
>> > I wonder if this should be the right behaviour for tunnels, which should just
>> > do fragmentation based on IP_DF, even if the packet originated locally from a
>> > socket which allowed local fragmentation (inet->pmtudisc < IP_PMTUDISC_DO).
>> >
>> This is not about tunneling, skb_scrub_packet() is generic function
>> which should not reset local_df on all packets.
>>
>> We can have separate discussion about use of local_df and tunneling in
>> another thread.
>
> This change only affects tunnel code as of current net branch, how do
> you not expect a discussion about that in this thread, I really wonder?
>
> May I know because of wich vport, vxlan or gre, you did this change?
>
It affects both gre and vxlan.

> I am feeling a bit uncomfortable handling remote and local packets that
> differently on lower tunnel output (local_df is mostly set on locally
> originating packets).

For ip traffic it make sense to turn on local_df only for local
traffic, since for remote case we can send icmp (frag-needed) back to
source. No such thing exist for OVS tunnels. ICMP packet are not
returned to source for the tunnels. That is why to be on safe side,
local_df is turned on for tunnels in OVS.

Thanks.
