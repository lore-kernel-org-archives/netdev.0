From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH RFC V2 2/2] net: Optimize snmp stat aggregation by
 walking all the percpu data at once
Date: Fri, 28 Aug 2015 17:06:14 -0700
Message-ID: <1440806774.8932.94.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1440610653-14210-3-git-send-email-raghavendra.kt@linux.vnet.ibm.com>
	 <20150827.113823.214019265460582055.davem@davemloft.net>
	 <55E00238.10909@linux.vnet.ibm.com>
	 <20150828.112413.424099339331017970.davem@davemloft.net>
	 <1440789654.11525.137.camel@perches.com>
	 <1440794020.8932.45.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1440795211.11525.146.camel@perches.com>
	 <1440795336.8932.46.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1440796183.11525.153.camel@perches.com>
	 <1440796487.8932.48.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1440797172.11525.161.camel@perches.com>
	 <1440800980.8932.66.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1440803577.11525.182.camel@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	raghavendra.kt@linux.vnet.ibm.com, edumazet@google.com,
	kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net, jiri@resnulli.us, hannes@stressinduktion.org,
	tom@herbertland.com, azhou@nicira.com, ebiederm@xmission.com,
	ipm@chirality.org.uk, nicolas.dichtel@6wind.com,
	serge.hallyn@canonical.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, anton@au1.ibm.com,
	nacc@linux.vnet.ibm.com, srikar@linux.vnet.ibm.com
To: Joe Perches <joe@perches.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1440803577.11525.182.camel@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2015-08-28 at 16:12 -0700, Joe Perches wrote:

> Generally true.  It's always difficult to know how much
> stack has been consumed though and smaller stack frames
> are generally better.

Calling kmalloc(288, GFP_KERNEL) might use way more than 288 bytes in
kernel stack on 64 bit arch.

__slab_alloc() itself for example uses 208 bytes on stack, so add all
others, and you might go above 500 bytes.
 
So for a _leaf_ function, it is better to declare an automatic variable,
as you in fact reduce max stack depth.

Not only it uses less kernel stack, it is also way faster, as you avoid
kmalloc()/kfree() overhead and reuse probably already hot cache lines in
kernel stack.
