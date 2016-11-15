From: =?UTF-8?Q?Vicente_Jim=C3=A9nez?= <googuy@gmail.com>
Subject: Re: [PATCH] icmp: Restore resistence to abnormal messages
Date: Tue, 15 Nov 2016 20:32:49 +0100
Message-ID: <CAO1wt+aZjRE_KTY0iRNJryeHvehrK6kuGMn6wOOeFuT1ncpPxA@mail.gmail.com>
References: <20161111202018.13795-1-googuy@gmail.com> <20161114.133646.1687576478968660327.davem@davemloft.net>
 <CAO1wt+b4OkJ4DmJ7_hUj_oKj4p_rRMuKUVpiBY7MSFMa=0WKQg@mail.gmail.com>
 <20161115.115657.798577230951109692.davem@redhat.com> <20161115173024.GD30581@breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: David Miller <davem@redhat.com>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        James Morris <jmorris@namei.org>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Florian Westphal <fw@strlen.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161115173024.GD30581@breakpoint.cc>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I agree that both patches try to solve the same problem in a very similar w=
ay.
Florian Westphal's patch do two more things:
1- add warning with pr_warn_ratelimited. I like this idea. I also
though about adding some message but I have no kernel experience and I
preferred to have just a working solution.
2- Check if the packet size is lower than (536 + 8). I think this is
not necessary because low values (even the zero case) is already
handled by the protocol. Also I don't understand why you choose this
value, it seems to be related to TCP MSS and the compared value is IP
packet size.

Finally, both patches decrement current packet by a value: Mine by 2
and Florian's by 8 bytes. Both arbitrary values. Personally I prefer
to go by small steps. If the small step fails, it just iterate again
and with 4 iterations, my patch also decrement the original value by 8
bytes (4x2).
Basically they are the same but my patch take smaller steps and miss
the warning message.

If David Miller thinks this could be a good addition, I'll add the
warning message to my patch.

We can also discuss the amount to subtract.

On Tue, Nov 15, 2016 at 6:30 PM, Florian Westphal <fw@strlen.de> wrote:
> David Miller <davem@redhat.com> wrote:
>> From: Vicente Jim=C3=A9nez <googuy@gmail.com>
>> Date: Tue, 15 Nov 2016 17:49:43 +0100
>>
>> > On Mon, Nov 14, 2016 at 7:36 PM, David Miller <davem@davemloft.net> wr=
ote:
>> >> From: Vicente Jimenez Aguilar <googuy@gmail.com>
>> >> Date: Fri, 11 Nov 2016 21:20:18 +0100
>> >>
>> >>> @@ -819,6 +820,12 @@ static bool icmp_unreach(struct sk_buff *skb)
>> >>>                               /* fall through */
>> >>>                       case 0:
>> >>>                               info =3D ntohs(icmph->un.frag.mtu);
>> >>> +                             /* Handle weird case where next hop MT=
U is
>> >>> +                              * equal to or exceeding dropped packe=
t size
>> >>> +                              */
>> >>> +                             old_mtu =3D ntohs(iph->tot_len);
>> >>> +                             if (info >=3D old_mtu)
>> >>> +                                     info =3D old_mtu - 2;
>> >>
>> >> This isn't something the old code did.
>> >>
>> >> The old code behaved much differently.
>> >>
>> > I don't wanted to restore old behavior just fix a strange case that
>> > was handle by this code where the next hop MTU reported by the router
>> > is equal or greater than the actual path MTU. Because router
>> > information is wrong, we need a way to guess a good packet size
>> > ignoring router data. The simplest strategy that avoid odd numbers is
>> > reducing dropped packet size by 2.
>>
>> This whole approach seems arbitrary.
>>
>> You haven't discussed in any way, what causes this in the first place.
>> And what about that cause makes simply subtracting by 2 work well or
>> not.
>>
>> You have a very locallized, specific, situation on your end you want
>> to fix.  But we must accept changes that handle things generically and
>> in a way that would help more than just your specific case.
>
> FWIW this is similar to the patch I sent a while ago:
>
> https://patchwork.ozlabs.org/patch/493997/
>
> I think in interest of robustness principle ("eat shit and don't die")
> one of these changes should go in :-|



--=20
saludos
vicente
