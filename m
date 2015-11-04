From: Denys Fedoryshchenko <nuclearcat@nuclearcat.com>
Subject: Re: kernel panic in 4.2.3, rb_erase in sch_fq
Date: Wed, 04 Nov 2015 06:25:29 +0200
Message-ID: <0705e2b76150c28341d7e1915433450d@visp.net.lb>
References: <d66d455afe6dd28bed32ed3e17f797b7@visp.net.lb>
 <CAHA+R7MNxEkMfyQa56d0HRk2HxeqsduUfM3BkBh=Oxm2yNBVaA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII;
 format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jamal Hadi Salim <jhs@mojatatu.com>,
	"David S. Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>, linux-kernel@vger.kernel.org
To: Cong Wang <cwang@twopensource.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAHA+R7MNxEkMfyQa56d0HRk2HxeqsduUfM3BkBh=Oxm2yNBVaA@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 2015-11-04 00:06, Cong Wang wrote:
> On Mon, Nov 2, 2015 at 6:11 AM, Denys Fedoryshchenko
> <nuclearcat@nuclearcat.com> wrote:
>> Hi!
>> 
>> Actually seems i was getting this panic for a while (once per week) on
>> loaded pppoe server, but just now was able to get full panic message.
>> After checking commit logs on sch_fq.c i didnt seen any fixes, so 
>> probably
>> upgrading to newer kernel wont help?
> 
> 
> Can you share your `tc qdisc show dev xxxx` with us? And how to 
> reproduce
> it? I tried to setup htb+fq and then flip the interface back and forth
> but I don't
> see any crash.
My guess it wont be easy to reproduce, it is happening on box with 4.5k 
interfaces, that constantly create/delete interfaces,
and even with that this problem may happen once per day, or may not 
happen for 1 week.

Here is script that is being fired after new ppp interface detected. But 
pppoe process are independent from
process that are "establishing" shapers.

/sbin/tc qdisc del  root
/sbin/tc qdisc add  handle 1: root htb default 3

/sbin/tc filter add parent 1:0 protocol ip prio 4 handle 1 fw flowid 1:3
/sbin/tc filter add parent 1:0 protocol ip prio 3 u32 match ip protocol 
6 0xff match ip src 10.0.252.8/32 flowid 1:3/sbin/tc filter add parent 
1:0 protocol ip prio 5 u32 match ip protocol 1 0xff flowid 1:0
/sbin/tc filter add parent 1:0 protocol ip prio 5 u32 match ip protocol 
6 0xff match ip sport 80 0xffff flowid 1:4
/sbin/tc filter add parent 1:0 protocol ip prio 5 u32 match ip protocol 
6 0xff match ip sport 443 0xffff flowid 1:5
/sbin/tc filter add parent 1:0 protocol ip prio 100 u32 match u32 0 0 
flowid 1:2

/sbin/tc class add  classid 1:1 parent 1:0 htb rate 512Kbit ceil 
512Kbit.
/sbin/tc class add  classid 1:2 parent 1:1 htb rate 32Kbit ceil 512Kbit
/sbin/tc class add  classid 1:3 parent 1:0 htb rate 10Mbit ceil 10Mbit
/sbin/tc class add  classid 1:4 parent 1:1 htb rate 32Kbit ceil 512Kbit
/sbin/tc class add  classid 1:5 parent 1:1 htb rate 32Kbit ceil 512Kbit

/sbin/tc qdisc add parent 1:2 fq limit 300
/sbin/tc qdisc add parent 1:3 pfifo limit 300
/sbin/tc qdisc add parent 1:4 fq limit 300
/sbin/tc qdisc add parent 1:5 fq limit 300

Possible cases come to my mind (but maybe i missed others):
  Script and tc working and interface are deleted in a process (e.g. 
interface disappears)
  Script deleting root while there is heavy traffic on interface and a 
lot of packets queued
  ppp interface destroyed, while there is a lot of traffic queued on it 
(this one a bit rare situation)

> 
> Thanks.
