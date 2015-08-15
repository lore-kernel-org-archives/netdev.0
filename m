From: Tom Herbert <tom@herbertland.com>
Subject: Re: [PATCH net-next 04/11] udp: Handle VRF device in sendmsg
Date: Fri, 14 Aug 2015 20:16:16 -0700
Message-ID: <CALx6S36MAQRgEqcJbTO_m6eMEAzoJ6k3o67z7EgLa3BjUg6MbQ@mail.gmail.com>
References: <1439499551-90231-1-git-send-email-dsa@cumulusnetworks.com>
	<1439499551-90231-5-git-send-email-dsa@cumulusnetworks.com>
	<CALx6S34ymDARX9EjCUZtHzd=+iUpry5WbCR4axXSDFBhVSTDUw@mail.gmail.com>
	<CAJmoNQGorXyd_vjigkJGntdNMmwMhL8AUfxA+s98uaY9ia73Gw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Ahern <dsa@cumulusnetworks.com>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Roopa Prabhu <roopa@cumulusnetworks.com>,
	Andy Gospodarek <gospo@cumulusnetworks.com>,
	Jon Toppins <jtoppins@cumulusnetworks.com>,
	Nikolay Aleksandrov <nikolay@cumulusnetworks.com>,
	Dinesh Dutt <ddutt@cumulusnetworks.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Jamal Hadi Salim <hadi@mojatatu.com>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	"David S. Miller" <davem@davemloft.net>, svaidya@brocade.com
To: Shrijeet Mukherjee <shm@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f182.google.com ([209.85.223.182]:33805 "EHLO
	mail-io0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752305AbbHODQR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Aug 2015 23:16:17 -0400
Received: by iodb91 with SMTP id b91so102918023iod.1
        for <netdev@vger.kernel.org>; Fri, 14 Aug 2015 20:16:17 -0700 (PDT)
In-Reply-To: <CAJmoNQGorXyd_vjigkJGntdNMmwMhL8AUfxA+s98uaY9ia73Gw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Aug 14, 2015 at 10:58 AM, Shrijeet Mukherjee
<shm@cumulusnetworks.com> wrote:
>
>
> On Fri, Aug 14, 2015 at 9:27 AM, Tom Herbert <tom@herbertland.com> wrote:
>>
>> On Thu, Aug 13, 2015 at 1:59 PM, David Ahern <dsa@cumulusnetworks.com>
>> wrote:
>> > For unconnected UDP sockets using a VRF device lookup source address
>> > based on VRF table. This allows the UDP header to be properly setup
>> > before showing up at the VRF device via the dst.
>> >
>> > Signed-off-by: Shrijeet Mukherjee <shm@cumulusnetworks.com>
>> > Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
>> > ---
>> >  net/ipv4/udp.c | 22 +++++++++++++++++++++-
>> >  1 file changed, 21 insertions(+), 1 deletion(-)
>> >
>> > diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
>> > index 83aa604f9273..7af5052e3b1f 100644
>> > --- a/net/ipv4/udp.c
>> > +++ b/net/ipv4/udp.c
>> > @@ -1013,11 +1013,31 @@ int udp_sendmsg(struct sock *sk, struct msghdr
>> > *msg, size_t len)
>> >
>> >         if (!rt) {
>> >                 struct net *net = sock_net(sk);
>> > +               __u8 flow_flags = inet_sk_flowi_flags(sk);
>> >
>> >                 fl4 = &fl4_stack;
>> > +
>> > +               /* unconnected socket. If output device is enslaved to a
>> > VRF
>> > +                * device lookup source address from VRF table. This
>> > mimics
>> > +                * behavior of ip_route_connect{_init}.
>> > +                */
>> > +               if (netif_index_is_vrf(net, ipc.oif)) {
>> > +                       flowi4_init_output(fl4, ipc.oif, sk->sk_mark,
>> > tos,
>> > +                                          RT_SCOPE_UNIVERSE,
>> > sk->sk_protocol,
>> > +                                          (flow_flags |
>> > FLOWI_FLAG_VRFSRC),
>> > +                                          faddr, saddr, dport,
>> > +                                          inet->inet_sport);
>> > +
>> > +                       rt = ip_route_output_flow(net, fl4, sk);
>> > +                       if (!IS_ERR(rt)) {
>> > +                               saddr = fl4->saddr;
>> > +                               ip_rt_put(rt);
>> > +                       }
>> > +               }
>> > +
>>
>> I really don't like this. It seems like you're putting device specific
>> code in a critical L4 data path function. Also, does ipv6/udp.c need
>> be updated similarly? Why can't VRF be abstracted out in routing
>> lookups?
>
>
> Tom,
>
> Did not have a better way to make this work. The point of the VRF driver was
> to be completely transparent for anything other routing lookups. Modifying
> the header in the driver means that fragmentation etc will have trouble.
>
> So this code really just makes the saddr evaluation before we enter the udp
> code path and is similar to what the tcp side does. If you have a suggestion
> on a different and hopefully consistent way to do with tcp and ipv6, that
> would be preferable.

At least collect this code into one (static inline) function to better
minimize the code churn in udp. If this is general functionality that
can be used by other drivers then abstract it out as such. Also, if
the VRF driver is not configured it seems like this code should
compiled out. As it stands now "if (netif_index_is_vrf(net, ipc.oif))
{" adds a conditional to every call of udp_sendmsg rather or not we
are using VRF :-(.

Tom
