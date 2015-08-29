From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH RFC V3 2/2] net: Optimize snmp stat aggregation by
 walking all the percpu data at once
Date: Sat, 29 Aug 2015 08:21:24 -0700
Message-ID: <1440861684.3276.7.camel@perches.com>
References: <y>
	 <1440839278-21928-1-git-send-email-raghavendra.kt@linux.vnet.ibm.com>
	 <1440839278-21928-3-git-send-email-raghavendra.kt@linux.vnet.ibm.com>
	 <1440858726.8932.149.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>,
	davem@davemloft.net, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net, jiri@resnulli.us,
	edumazet@google.com, hannes@stressinduktion.org,
	tom@herbertland.com, azhou@nicira.com, ebiederm@xmission.com,
	ipm@chirality.org.uk, nicolas.dichtel@6wind.com,
	serge.hallyn@canonical.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, anton@au1.ibm.com,
	nacc@linux.vnet.ibm.com, srikar@linux.vnet.ibm.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1440858726.8932.149.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 2015-08-29 at 07:32 -0700, Eric Dumazet wrote:
> On Sat, 2015-08-29 at 14:37 +0530, Raghavendra K T wrote:
> 
> >  
> >  static inline void __snmp6_fill_stats64(u64 *stats, void __percpu *mib,
> > -				      int items, int bytes, size_t syncpoff)
> > +					int items, int bytes, size_t syncpoff)
> >  {
> > -	int i;
> > +	int i, c;
> >  	int pad = bytes - sizeof(u64) * items;
> > +	u64 buff[items];
> > +
> 
> One last comment : using variable length arrays is confusing for the
> reader, and sparse as well.
> 
> $ make C=2 net/ipv6/addrconf.o
> ...
>   CHECK   net/ipv6/addrconf.c
> net/ipv6/addrconf.c:4733:18: warning: Variable length array is used.
> net/ipv6/addrconf.c:4737:25: error: cannot size expression
> 
> 
> I suggest you remove 'items' parameter and replace it by
> IPSTATS_MIB_MAX, as __snmp6_fill_stats64() is called exactly once.

If you respin, I suggest:

o remove "items" from the __snmp6_fill_stats64 arguments
  and use IPSTATS_MIB_MAX in the function instead

o add braces around the for_each_possible_cpu loop

	for_each_possible_cpu(c) {
		for (i = 1; i < items; i++)
			buff[i] += snmp_get_cpu_field64(mib, c, i, syncpoff);
	}
