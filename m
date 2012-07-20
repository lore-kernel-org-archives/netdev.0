From: Yuchung Cheng <ycheng@google.com>
Subject: Re: resurrecting tcphealth
Date: Fri, 20 Jul 2012 07:06:12 -0700
Message-ID: <CAK6E8=dKZUJ3evPDGc3gP0a5bsBbYnL0NGhPZenB=T_t+5Kx5w@mail.gmail.com>
References: <e9caf38359467bfa8a1e2ac86f6ef2cc.squirrel@webmail.univie.ac.at>
 <20120713165544.6767ea8f@nehalam.linuxnetplumber.net> <87741204cd72d363d54dadf9a94bb6fe.squirrel@webmail.univie.ac.at>
 <1342439185.23494.19.camel@edumazet-glaptop> <cc2022d86834a8798518f9cccc605d45.squirrel@webmail.univie.ac.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Piotr Sawuk <a9702387@unet.univie.ac.at>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cc2022d86834a8798518f9cccc605d45.squirrel@webmail.univie.ac.at>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jul 16, 2012 at 6:03 AM, Piotr Sawuk <a9702387@unet.univie.ac.at> wrote:
> On Mo, 16.07.2012, 13:46, Eric Dumazet wrote:
>> On Mon, 2012-07-16 at 13:33 +0200, Piotr Sawuk wrote:
>>> On Sa, 14.07.2012, 01:55, Stephen Hemminger wrote:
>>> > I am not sure if the is really necessary since the most
>>> > of the stats are available elsewhere.
>>>
>>> if by "most" you mean address and port then you're right.
>>> but even the rtt reported by "ss -i" seems to differ from tcphealth.
>>
>> Thats because tcphealth is wrong, it assumes HZ=1000 ?
>>
>> tp->srtt unit is jiffies, not ms.
>
> thanks. any conversion-functions in the kernel for that?
>>
>> tcphealth is a gross hack.
>
> what would you do if you tried making it less gross?
>
> I've not found any similar functionality, in the kernel.
> I want to know an estimate for the percentage of data lost in tcp.
> and I want to know that without actually sending much packets.
> afterall I'm on the receiving end most of the time.
> percentage of duplicate packets received is nice too.
> you have any suggestions?

counting dupack may not be as reliable as you'd like.
say the remote sends you 100 packets and only the first one is lost,
you'll see 99 dupacks. Morover any small degree reordering (<3)
will generate substantial dupacks but the network is perfectly fine
(see Craig Patridge's "reordering is not pathological" paper).
unfortunately receiver can't and does not have to distinguish loss
 or reordering. you can infer that but it should not be kernel's job.
there are public tools that inspect tcpdump traces to do that

exposing duplicate packets received can be done via getsockopt(TCP_INFO)
although I don't know what that gives you. the remote can be too
aggressive in retransmission (not just because of a bad RTO) or
the network RTT fluctuates.

I don't what if tracking last_ack_sent (the latest RCV.NXT) without
knowing the ISN is useful.

btw the term project paper cited concludes SACK is not useful is simply
wrong. This makes me suspicious about how rigorous and thoughtful of
its design.

>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
