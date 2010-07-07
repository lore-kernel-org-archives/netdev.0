From: Jesper Dangaard Brouer <hawk@diku.dk>
Subject: Re: QoS weirdness : HTB accuracy
Date: Wed, 7 Jul 2010 15:07:08 +0200 (CEST)
Message-ID: <Pine.LNX.4.64.1007071457020.6631@ask.diku.dk>
References: <067c83163988908ef546d7ff7f560a17@localhost>
 <4BF32BB0.7010700@redfish-solutions.com>  <e6bd0cff8dafc8b3af0760facb5fdc8c@localhost>
  <1276204948.1403.13.camel@andybev> <1278265807.1506.86.camel@andybev>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: Julien Vehent <julien@linuxwall.info>,
	"Philip A. Prindeville" <philipp_subx@redfish-solutions.com>,
	Netdev <netdev@vger.kernel.org>,
	netfilter <netfilter@vger.kernel.org>, hawk@comx.dk
To: Andrew Beverley <andy@andybev.com>
Return-path: <netfilter-owner@vger.kernel.org>
In-Reply-To: <1278265807.1506.86.camel@andybev>
Sender: netfilter-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Sun, 4 Jul 2010, Andrew Beverley wrote:

>>> I was, in fact, an error in my ruleset. I had put the 'linklayer atm' at
>>> both the branch and leaf levels, so the overhead was computed twice,
>>> creating those holes in the bandwidth.
>>
>> I am seeing similar behaviour with my setup. Am I making the same
>> mistake? A subset of my rules is as follows:
>>
>> tc qdisc add dev ppp0 root handle 1: htb r2q 1
>>
>> tc class add dev ppp0 parent 1: classid 1:1 htb \
>>     rate ${DOWNLINK}kbit ceil ${DOWNLINK}kbit \
>>     overhead $overhead linklayer atm                   <------- Here
>>
>> tc class add dev ppp0 parent 1:1 classid 1:10 htb \
>>     rate 612kbit ceil 612kbit prio 0 \
>>     overhead $overhead linklayer atm                   <------- And here
>>
>> tc qdisc add dev ppp0 parent 1:10 handle 4210: \
>>     sfq perturb 10 limit 50
>>
>> tc filter add dev ppp0 parent 1:0 protocol ip \
>>     prio 10 handle 10 fw flowid 1:10
>
> I removed the overhead option on the first leaf, and the speeds change
> to what I expect. However, the rules above are taken straight from the
> ADSL Optimizer project, which was the source of the original overhead
> patch for tc. So is the ADSL Optimizer project wrong?

After looking at the HTB kernel code I believe that the ADSL Optimizer 
project is NOT wrong.  You should/must set the linklayer option on both 
the root class and leaf (else you would be charging the root/parent node 
too little).

It is the expected behavior that small packets cause a significant
reduction in the available bandwidth on the ATM link.  Small packets will 
(almost) always cause 2 ATM packets (being send) using 106 bytes, thus
eg. sending a 40 bytes TCP ACK packet result in approx 62% overhead.

Cheers,
   Jesper Brouer

--
-------------------------------------------------------------------
MSc. Master of Computer Science
Dept. of Computer Science, University of Copenhagen
Author of http://www.adsl-optimizer.dk
-------------------------------------------------------------------
