From: John Fastabend via iovisor-dev <iovisor-dev-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org>
Subject: Re: [PATCH RFC 11/11] net/mlx5e: XDP TX xmit more
Date: Wed, 7 Sep 2016 19:58:50 -0700
Message-ID: <57D0D3EA.1090004@gmail.com>
References: <1473252152-11379-1-git-send-email-saeedm@mellanox.com>
	<1473252152-11379-12-git-send-email-saeedm@mellanox.com>
	<1473259302.10725.31.camel@edumazet-glaptop3.roam.corp.google.com>
	<CALzJLG8G1SvmHKLm2Oqn3v8FUAOjScS+=tsbOaixkPUY4JFDPQ@mail.gmail.com>
	<1473262379.10725.42.camel@edumazet-glaptop3.roam.corp.google.com>
	<CALzJLG9iVpS2qH5Ryc_DtEjrQMhcKD+qrLrGn=vet=_9N8eXPw@mail.gmail.com>
	<20160907202234.55e18ef3@redhat.com>
Reply-To: John Fastabend <john.fastabend-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Linux Netdev List <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	iovisor-dev <iovisor-dev-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org>,
	Jamal Hadi Salim <jhs-jkUAjuhPggJWk0Htik3J/w@public.gmane.org>, Saeed Mahameed <saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Eric Dumazet <edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Tom Herbert <tom-BjP2VixgY4xUbtYUoyoikg@public.gmane.org>
To: Jesper Dangaard Brouer <brouer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	Saeed Mahameed <saeedm-LDSdmyG8hGV8YrgS2mwiifqBs+8SCbDb@public.gmane.org>
Return-path: <iovisor-dev-bounces-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org>
In-Reply-To: <20160907202234.55e18ef3-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.iovisor.org/mailman/options/iovisor-dev>,
	<mailto:iovisor-dev-request-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.iovisor.org/pipermail/iovisor-dev/>
List-Post: <mailto:iovisor-dev-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org>
List-Help: <mailto:iovisor-dev-request-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org?subject=help>
List-Subscribe: <https://lists.iovisor.org/mailman/listinfo/iovisor-dev>,
	<mailto:iovisor-dev-request-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org?subject=subscribe>
Sender: iovisor-dev-bounces-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org
Errors-To: iovisor-dev-bounces-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org
List-Id: netdev.vger.kernel.org

On 16-09-07 11:22 AM, Jesper Dangaard Brouer wrote:
> 
> On Wed, 7 Sep 2016 19:57:19 +0300 Saeed Mahameed <saeedm-LDSdmyG8hGV8YrgS2mwiifqBs+8SCbDb@public.gmane.org> wrote:
>> On Wed, Sep 7, 2016 at 6:32 PM, Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
>>> On Wed, 2016-09-07 at 18:08 +0300, Saeed Mahameed wrote:  
>>>> On Wed, Sep 7, 2016 at 5:41 PM, Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:  
>>>>> On Wed, 2016-09-07 at 15:42 +0300, Saeed Mahameed wrote:  
> [...]
>>>
>>> Only if a qdisc is present and pressure is high enough.
>>>
>>> But in a forwarding setup, we likely receive at a lower rate than the
>>> NIC can transmit.
> 
> Yes, I can confirm this happens in my experiments.
> 
>>>  
>>
>> Jesper has a similar Idea to make the qdisc think it is under
>> pressure, when the device TX ring is idle most of the time, i think
>> his idea can come in handy here. I am not fully involved in the
>> details, maybe he can elaborate more.
>>
>> But if it works, it will be transparent to napi, and xmit more will
>> happen by design.
> 
> Yes. I have some ideas around getting more bulking going from the qdisc
> layer, by having the drivers provide some feedback to the qdisc layer
> indicating xmit_more should be possible.  This will be a topic at the
> Network Performance Workshop[1] at NetDev 1.2, I have will hopefully
> challenge people to come up with a good solution ;-)
> 

One thing I've noticed but haven't yet actually analyzed much is if
I shrink the nic descriptor ring size to only be slightly larger than
the qdisc layer bulking size I get more bulking and better perf numbers.
At least on microbenchmarks. The reason being the nic pushes back more
on the qdisc. So maybe a case for making the ring size in the NIC some
factor of the expected number of queues feeding the descriptor ring.

.John
