From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH RFC 0/2] Optimize the snmp stat aggregation for large
 cpus
Date: Wed, 26 Aug 2015 07:09:38 -0700
Message-ID: <1440598178.8932.25.camel@edumazet-glaptop2.roam.corp.google.com>
References: <y>
	 <1440489266-31127-1-git-send-email-raghavendra.kt@linux.vnet.ibm.com>
	 <20150825.160730.1747721171751442778.davem@davemloft.net>
	 <55DD9401.9090809@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, kuznet@ms2.inr.ac.ru,
	jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net,
	jiri@resnulli.us, edumazet@google.com, hannes@stressinduktion.org,
	tom@herbertland.com, azhou@nicira.com, ebiederm@xmission.com,
	ipm@chirality.org.uk, nicolas.dichtel@6wind.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	anton@au1.ibm.com, nacc@linux.vnet.ibm.com,
	srikar@linux.vnet.ibm.com
To: Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <55DD9401.9090809@linux.vnet.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2015-08-26 at 15:55 +0530, Raghavendra K T wrote:
> On 08/26/2015 04:37 AM, David Miller wrote:
> > From: Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>
> > Date: Tue, 25 Aug 2015 13:24:24 +0530
> >
> >> Please let me know if you have suggestions/comments.
> >
> > Like Eric Dumazet said the idea is good but needs some adjustments.
> >
> > You might want to see whether a per-cpu work buffer works for this.
> 
> sure, Let me know if I understood correctly,
> 
> we allocate the temp buffer,
> we will have a  "add_this_cpu_data" function and do
> 
> for_each_online_cpu(cpu)
>                  smp_call_function_single(cpu, add_this_cpu_data, buffer, 1)
> 
> if not could you please point to an example you had in mind.


Sorry I do not think it is a good idea.

Sending an IPI is way more expensive and intrusive than reading 4 or 5
cache lines from memory (per cpu)

Definitely not something we want.

> 
> >
> > It's extremely unfortunately that we can't depend upon the destination
> > buffer being properly aligned, because we wouldn't need a temporary
> > scratch area if it were aligned properly.
> 
> True, But I think for 64 bit cpus when (pad == 0) we can go ahead and
> use stats array directly and get rid of put_unaligned(). is it correct?


Nope. We have no alignment guarantee. It could be 0x............04
pointer value. (ie not a multiple of 8)

> 
> (my internal initial patch had this version but thought it is ugly to
> have ifdef BITS_PER_LONG==64)

This has nothing to do with arch having 64bit per long. It is about
alignment of a u64.
