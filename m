From: "Milam, Chad" <Chad_Milam@nyc.yr.com>
Subject: RE: dst cache overflow 2.2.x; x>=16
Date: Mon, 15 Apr 2002 15:07:44 -0400
Sender: owner-netdev@oss.sgi.com
Message-ID: <D4CA6B275AA33241AC771F0C0B43A921011BE86A@nyc285ex01.nyc.corp.yr.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: 8bit
Return-path: <owner-netdev@oss.sgi.com>
content-class: urn:content-classes:message
To: <netdev@oss.sgi.com>,
   "Julian Anastasov <ja@ssi.bg>" <IMCEANOTES-Julian+20Anastasov+20+3Cja+40ssi+2Ebg+3E@avee-health.com>
List-Id: netdev.vger.kernel.org

Julian writes: 
> 	Hello,
> 
> On Mon, 15 Apr 2002, Milam, Chad wrote:
> 
> > I also do not think that nuking valid routes in the cache will produce any
> > major issues, other than slowing things down for a few seconds.  the cache
> > is just the cache, not the real route table. and yes, it pretty much
> 
> 	Of course. You can play only with max_size to achieve the same
> result. max_size should be appropriate to the rate new hosts appear
> in the cache. I'm wondering whether your patched kernel does not have
> some bug, for example, unfreed skbs or struct rtable. Make sure that
> the unpatched kernels have the same bug. If it appears after 22
> hours (I assume the system load for all these 22 hours is same)
> then this is a bug. Playing with the hash size is final step but it
> can only give you some CPU cycles. Touching max_size should be
> enough.

no. Increasing max_size only delays its death. That is my point. The problem
existed on an out of the box RH7, RH6.2, RH6.1 install. The whole point of the
patch was to fix a problem that existed _prior_ to me patching it.


> > guarantees the route cache will be purged, therefore avoiding a reboot and
> > avoiding a quickly repeated overflow...
> 
> 	Are you sure you have stalled entries? What shows /proc/slabinfo
> after 22 hours (skbuff_head_cache, etc)?

well, what I can tell you is this. If I run a loop like the following, counter 
will only show say, 50 routes in the cache.
------
start=atomic_read(&ipv4_dst_ops.entries);
i=0;
counter=0;
while(i<RT_HASH_DIVISOR){
	rthp=&rt_hash_table[i];
	while((rth=*rthp)!=NULL){
		*rthp=rth->u.rt_next;
		rth->u.rt_next=NULL;
		counter+=1;
	}
	i++;
}
printk("before: %d, after: %d", start, counter);
------ 
> 	One hint: can this command solve the problem (to flush the
> cache entries)?:
> 
> for i in down up ; do ip link set ethXXX $i ; done

downing all interfaces and reupping them does not seem to solve the problem either :S

thanks,
chad
