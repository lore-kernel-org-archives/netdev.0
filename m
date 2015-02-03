From: Michal Kazior <michal.kazior-++hxYGjEMp0AvxtiuMwx3w@public.gmane.org>
Subject: Re: Throughput regression with `tcp: refine TSO autosizing`
Date: Tue, 3 Feb 2015 10:00:33 +0100
Message-ID: <CA+BoTQko60aGP7QG+ELrgRmU=OFBZVc9n1X-ecGX2rLBnULSTA@mail.gmail.com>
References: <CA+BoTQkVu23P3EOmY_Q3E1GJnWsyF==Pawz4iPOS_Bq5dvfO5Q@mail.gmail.com>
	<1422537297.21689.15.camel@edumazet-glaptop2.roam.corp.google.com>
	<CA+BoTQk2xT-8DqPuiiKG+kHAjLPrj8F9dLTb-rcGhvMq0u_2Qw@mail.gmail.com>
	<1422628835.21689.95.camel@edumazet-glaptop2.roam.corp.google.com>
	<CA+BoTQkV+mOZfe_Niz5101sMQeaV6muKCsShptjGQ1AgOHqqoQ@mail.gmail.com>
	<1422903136.21689.114.camel@edumazet-glaptop2.roam.corp.google.com>
	<54CFEB46.3050006@candelatech.com>
	<1422918363.21689.132.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ben Greear <greearb-my8/4N5VtI7c+919tysfdA@public.gmane.org>,
	linux-wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	eyalpe-LDSdmyG8hGV8YrgS2mwiifqBs+8SCbDb@public.gmane.org
To: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1422918363.21689.132.camel-XN9IlZ5yJG9HTL0Zs8A6p/gx64E7kk8eUsxypvmhUTTZJqsBc5GL+g@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 3 February 2015 at 00:06, Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrot=
e:
> On Mon, 2015-02-02 at 13:25 -0800, Ben Greear wrote:
>
>> It is a big throughput win to have fewer TCP ack packets on
>> wireless since it is a half-duplex environment.  Is there anything
>> we could improve so that we can have fewer acks and still get
>> good tcp stack behaviour?
>
> First apply TCP stretch ack fixes to the sender. There is no way to g=
et
> good performance if the sender does not handle stretch ack.
>
> d6b1a8a92a14 tcp: fix timing issue in CUBIC slope calculation
> 9cd981dcf174 tcp: fix stretch ACK bugs in CUBIC
> c22bdca94782 tcp: fix stretch ACK bugs in Reno
> 814d488c6126 tcp: fix the timid additive increase on stretch ACKs
> e73ebb0881ea tcp: stretch ACK fixes prep
>
> Then, make sure you do not throttle ACK too long, especially if you h=
ope
> to get Gbit line rate on a 4 ms RTT flow.
>
> GRO does not mean : send one ACK every ms, or after 3ms delay...

I think it's worth pointing out that If you assume 3-frame A-MSDU and
64-frame A-MPDU you get 192 frames (as far as TCP/IP is concerned) per
aggregation window. Assuming effective 600mbps throughput:

 python> 1.0/((((600/8)*1024*1024)/1500)/(3*64))
 0.003663003663003663

This is probably worst case, but still probably worth to keep in mind.

ath10k has a knob to tune A-MSDU aggregation count. The default is "3"
and it's what I've been testing so far.

When I change it to "1" on sender I get 250->400mbps boost in TCP -P5
but see no difference with -P1 (number of flows). Changing it to "1"
on receiver yields no difference. I can try adding this configuration
permutation to my future tests if you're interested.

So that you have an idea - using "1" on sender degrades UDP throughput
(even 690->500mbps in some cases).


Micha=C5=82
--
To unsubscribe from this list: send the line "unsubscribe linux-wireles=
s" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
