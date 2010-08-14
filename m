From: Jussi Kivilinna <jukivili@gmail.com>
Subject: Re: QoS weirdness : HTB accuracy
Date: Sat, 14 Aug 2010 20:27:17 +0300
Message-ID: <20100814202717.994841la0qbd5kw0@hayate.sektori.org>
References: <067c83163988908ef546d7ff7f560a17@localhost>
	<4BF32BB0.7010700@redfish-solutions.com>
	<e6bd0cff8dafc8b3af0760facb5fdc8c@localhost>
	<1276204948.1403.13.camel@andybev> <1278265807.1506.86.camel@andybev>
	<Pine.LNX.4.64.1007071457020.6631@ask.diku.dk>
	<20100707180753.104124gv6yvtou9s@hayate.sektori.org>
	<1281549546.1432.248.camel@andybev>
Mime-Version: 1.0
Content-Type: text/plain;
	charset=UTF-8;
	DelSp="Yes";
	format="flowed"
Content-Transfer-Encoding: 8BIT
Cc: "Jesper Dangaard Brouer" <hawk@diku.dk>,
	"Julien Vehent" <julien@linuxwall.info>,
	"Philip A. Prindeville" <philipp_subx@redfish-solutions.com>,
	Netdev <netdev@vger.kernel.org>,
	netfilter <netfilter@vger.kernel.org>, hawk@comx.dk
To: "Andrew Beverley" <andy@andybev.com>
Return-path: <netfilter-owner@vger.kernel.org>
In-Reply-To: <1281549546.1432.248.camel@andybev>
Content-Disposition: inline
Sender: netfilter-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Quoting "Andrew Beverley" <andy@andybev.com>:

> On Wed, 2010-07-07 at 18:07 +0300, Jussi Kivilinna wrote:
>> >>>> I was, in fact, an error in my ruleset. I had put the  
>> 'linklayer atm' at
>> >>>> both the branch and leaf levels, so the overhead was computed twice,
>> >>>> creating those holes in the bandwidth.
>> >>>
>> >>> I am seeing similar behaviour with my setup. Am I making the same
>> >>> mistake? A subset of my rules is as follows:
>> >>>
>> >>> tc qdisc add dev ppp0 root handle 1: htb r2q 1
>> >>>
>> >>> tc class add dev ppp0 parent 1: classid 1:1 htb \
>> >>>    rate ${DOWNLINK}kbit ceil ${DOWNLINK}kbit \
>> >>>    overhead $overhead linklayer atm                   <------- Here
>> >>>
>> >>> tc class add dev ppp0 parent 1:1 classid 1:10 htb \
>> >>>    rate 612kbit ceil 612kbit prio 0 \
>> >>>    overhead $overhead linklayer atm                   <------- And here
>> >>>
>> >>> tc qdisc add dev ppp0 parent 1:10 handle 4210: \
>> >>>    sfq perturb 10 limit 50
>> >>>
>> >>> tc filter add dev ppp0 parent 1:0 protocol ip \
>> >>>    prio 10 handle 10 fw flowid 1:10
>> >>
>> >> I removed the overhead option on the first leaf, and the speeds change
>> >> to what I expect. However, the rules above are taken straight from the
>> >> ADSL Optimizer project, which was the source of the original overhead
>> >> patch for tc. So is the ADSL Optimizer project wrong?
>> >
>> > After looking at the HTB kernel code I believe that the ADSL
>> > Optimizer project is NOT wrong.  You should/must set the linklayer
>> > option on both the root class and leaf (else you would be charging
>> > the root/parent node too little).
>> >
>>
>> It's been while I looked at the linklayer/size-table code, but if I
>> remember right overhead is calculated with first linklayer packet sees
>> in qdisc. So when packet goes to leaf with 'linklayer atm', packet get
>> packet size with overhead for ATM and root linklayer is not used for
>> that packet. Because of this you can have leafs with different
>> overheads (pppoe, ipv6-tunnel, etc, with ) and all get right
>> overhead... ..
>>
>> ..
>>
>> ...Uh oh...
>>
>> HTB still has linklayer/overhead of its own, I was talking about the
>> generic linklayer code that can be used with all qdiscs. Never mind,
>> sorry.
>
> Ah, I hadn't come across the tc-stab functionality until now. So that
> does exactly the same for all qdiscs as the original ATM patch does for
> HTB? But they work slightly differently as you have alluded to above?
>

Yes, tc-stab works with all qdiscs. Packet size is calculated  
everytime when qdisc_enqueue() is called and qdisc has size-table set.  
When none of qdiscs has size-table, packet size ends up being same as  
skb->len. So if leaf has size-table, that takes preference over  
earlier parent size-tables.

-Jussi

