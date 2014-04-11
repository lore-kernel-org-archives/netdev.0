From: Bjorn Helgaas <bhelgaas@google.com>
Subject: Re: [PATCH] tcp: fix compiler array bounds warning on selective_acks[]
Date: Fri, 11 Apr 2014 10:12:43 -0600
Message-ID: <CAErSpo4KOe5zBYNXDhdEFUMdhCBhs00CCvYHbW3071ZUdN6s6A@mail.gmail.com>
References: <20140410213029.24916.93892.stgit@bhelgaas-glaptop.roam.corp.google.com>
 <063D6719AE5E284EB5DD2968C1650D6D0F6F5DFA@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	James Morris <jmorris@namei.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	Patrick McHardy <kaber@trash.net>
To: David Laight <David.Laight@aculab.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D0F6F5DFA@AcuExch.aculab.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Apr 11, 2014 at 2:59 AM, David Laight <David.Laight@aculab.com> wrote:
> Bjorn Helgaas
>> With -Werror=array-bounds, gcc v4.8.x warns that in tcp_sack_remove(), a
>> selective_acks[] "array subscript is above array bounds".
>>
>> I don't understand how gcc figures this out, or why we don't see similar
>> problems many other places, but this is the only fix I can figure out.
> ...
>> diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
>> index 65cf90e063d5..65133b108236 100644
>> --- a/net/ipv4/tcp_input.c
>> +++ b/net/ipv4/tcp_input.c
>> @@ -4047,7 +4047,8 @@ static void tcp_sack_remove(struct tcp_sock *tp)
>>
>>                       /* Zap this SACK, by moving forward any other SACKS. */
>>                       for (i = this_sack+1; i < num_sacks; i++)
>> -                             tp->selective_acks[i-1] = tp->selective_acks[i];
>> +                             if (i < ARRAY_SIZE(tp->selective_acks))
>> +                                     tp->selective_acks[i-1] = tp->selective_acks[i];
>>                       num_sacks--;
>>                       continue;
>>               }
>
> You really shouldn't add that test every time around the loop.
>
> Try changing the loop so the assignment is:
>    tp->selective_acks[i] = tp->selective_acks[i + 1];
>
> or the loop test to:
>         i <= num_sacks - 1;
>
> Or beat up the gcc developers :-)

You're right, that *is* ugly.  And it seems that gcc-v4.9.x doesn't
complain about this, and that's good enough for my purposes, so I
withdraw this patch.

Thanks and sorry for the noise,
  Bjorn
